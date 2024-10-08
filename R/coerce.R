# COERCION
#' @include AllGenerics.R
NULL

# To CompositionMatrix =========================================================
#' @export
#' @rdname as_composition
#' @aliases as_composition,numeric-method
setMethod(
  f = "as_composition",
  signature = c(from = "numeric"),
  definition = function(from) {
    from <- matrix(data = from, nrow = 1, ncol = length(from))
    methods::callGeneric(from)
  }
)

#' @export
#' @rdname as_composition
#' @aliases as_composition,matrix-method
setMethod(
  f = "as_composition",
  signature = c(from = "matrix"),
  definition = function(from) {
    ## Make row/column names
    lab <- make_names(x = NULL, n = nrow(from), prefix = "S")
    rownames(from) <- if (has_rownames(from)) rownames(from) else lab
    colnames(from) <- make_names(x = colnames(from), n = ncol(from), prefix = "V")

    ## Close
    totals <- rowSums(from, na.rm = TRUE)
    from <- from / totals

    grp <- as_groups(rep(NA, nrow(from)))
    .CompositionMatrix(from, totals = unname(totals), groups = grp)
  }
)

#' @export
#' @rdname as_composition
#' @aliases as_composition,data.frame-method
setMethod(
  f = "as_composition",
  signature = c(from = "data.frame"),
  definition = function(from, parts = NULL, groups = NULL,
                        verbose = getOption("nexus.verbose")) {
    ## Clean row/column names
    lab <- make_names(x = NULL, n = nrow(from), prefix = "S")
    rownames(from) <- if (has_rownames(from)) rownames(from) else lab
    colnames(from) <- make_names(x = colnames(from), n = ncol(from), prefix = "V")

    ## Group names
    grp <- rep(NA_character_, nrow(from))
    if (!is.null(groups)) grp <- from[, groups, drop = FALSE]
    grp <- as_groups(grp)

    ## Remove non-numeric columns
    if (is.null(parts)) {
      parts <- arkhe::detect(from, f = is.double, margin = 2) # Logical
      if (verbose) {
        n <- sum(parts)
        what <- ngettext(n, "part", "parts")
        cols <- paste0(colnames(from)[parts], collapse = ", ")
        msg <- "Found %g %s (%s)."
        message(sprintf(msg, n, what, cols))
      }
    } else {
      if (is.numeric(parts)) parts <- seq_len(ncol(from)) %in% parts
      if (is.character(parts)) parts <- colnames(from) %in% parts
    }
    coda <- from[, parts, drop = FALSE]
    arkhe::assert_filled(coda)

    ## Build matrix
    coda <- data.matrix(coda, rownames.force = NA)
    totals <- rowSums(coda, na.rm = TRUE)
    coda <- coda / totals

    .CompositionMatrix(coda, totals = unname(totals), groups = grp)
  }
)

# To amounts ===================================================================
#' @export
#' @rdname as_amounts
#' @aliases as_amounts,CompositionMatrix-method
setMethod(
  f = "as_amounts",
  signature = c(from = "CompositionMatrix"),
  definition = function(from) {
    methods::as(from, "matrix") * totals(from)
  }
)

# To data.frame ================================================================
# @export
# @rdname augment
# @aliases augment,CompositionMatrix-method
# setMethod(
#   f = "augment",
#   signature = c(x = "CompositionMatrix"),
#   definition = function(x) {
#     data.frame(
#       .group = groups(x),
#       x
#     )
#   }
# )

# @export
# @rdname augment
# @aliases augment,LogRatio-method
# setMethod(
#   f = "augment",
#   signature = c(x = "LogRatio"),
#   definition = function(x) {
#     data.frame(
#       .group = groups(x),
#       x
#     )
#   }
# )

#' @method as.data.frame CompositionMatrix
#' @export
as.data.frame.CompositionMatrix <- function(x, ...) {
  as.data.frame(methods::as(x, "matrix"), row.names = rownames(x))
}

#' @method as.data.frame LogRatio
#' @export
as.data.frame.LogRatio <- function(x, ...) {
  as.data.frame(methods::as(x, "matrix"), row.names = rownames(x))
}

#' @method as.data.frame OutlierIndex
#' @export
as.data.frame.OutlierIndex <- function(x, ...) {
  as.data.frame(x@standard, row.names = rownames(x))
}
