# HELPERS

missingORnull <- function(x) {
  missing(x) || is.null(x)
}

has_rownames <- function(x) {
  .row_names_info(x, type = 1L) > 0L &&
    !is.na(.row_names_info(x, type = 0L)[[1L]])
}

make_names <- function(x, n = length(x), prefix = "X") {
  x <- if (n > 0) x %||% paste0(prefix, seq_len(n)) else character(0)
  x <- make.unique(x, sep = "_")
  x
}

flatten_chr <- function(x, by) {
  z <- tapply(X = x, INDEX = by, FUN = unique, simplify = FALSE)
  z <- vapply(X = z, FUN = paste0, FUN.VALUE = character(1), collapse = ":")
  z
}

#' Plotting Dimensions of Character Strings
#'
#' Convert string length in inch to number of (margin) lines.
#' @param x A [`character`] vector of string whose length is to be calculated.
#' @param ... Further parameter to be passed to [graphics::strwidth()]`, such as
#'  `cex`.
#' @return
#'  A [`numeric`] vector (maximum string width in units of margin lines).
#' @note For internal use only.
#' @family graphic tools
#' @keywords internal
#' @noRd
width2line <- function(x, ...) {
  (max(graphics::strwidth(x, units = "inch", ...)) /
     graphics::par("cin")[2] + graphics::par("mgp")[2]) * graphics::par("cex")
}
height2line <- function(x, ...) {
  (max(graphics::strheight(x, units = "inch", ...)) /
     graphics::par("cin")[2] + graphics::par("mgp")[2]) * graphics::par("cex")
}

#' Label Percentages
#'
#' @param x A [`numeric`] vector.
#' @param digits An [`integer`] indicating the number of decimal places.
#'  If `NULL` (the default), breaks will have the minimum number of digits
#'  needed to show the difference between adjacent values.
#' @param trim A [`logical`] scalar. If `FALSE` (the default), values are
#'  right-justified to a common width (see [base::format()]).
#' @return A [`character`] vector.
#' @keywords internal
#' @noRd
label_percent <- function(x, digits = NULL, trim = FALSE) {
  i <- !is.na(x)
  y <- x[i]
  y <- abs(y) * 100
  y <- format(y, trim = trim, digits = digits)
  y <- paste0(y, "%")
  x[i] <- y
  x
}

#' Column Weights
#'
#' Computes column weights.
#' @param x A `numeric` [`matrix`].
#' @param weights A [`logical`] scalar: should varying weights (column means)
#'  be computed? If `FALSE` (the default), equally-weighted parts are used.
#'  Alternatively, a positive [`numeric`] vector of weights can be specified
#'  (will be rescaled to sum to \eqn{1}).
#' @return A [`numeric`] vector.
#' @keywords internal
#' @noRd
make_weights <- function(x, weights = FALSE) {
  D <- ncol(x)

  w <- if (isTRUE(weights)) colMeans(x) else rep(1 / D, D)
  if (is.numeric(weights)) {
    arkhe::assert_length(weights, D)
    arkhe::assert_positive(weights, strict = TRUE)
    w <- weights / sum(weights) # Sum up to 1
  }

  unname(w)
}
