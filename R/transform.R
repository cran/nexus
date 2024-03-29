# DATA TRANSFORMATION
#' @include AllGenerics.R
NULL

# LR ===========================================================================
#' @export
#' @rdname transform_lr
#' @aliases transform_lr,CompositionMatrix-method
setMethod(
  f = "transform_lr",
  signature = c(object = "CompositionMatrix"),
  definition = function(object) {
    J <- ncol(object)
    parts <- colnames(object)
    weights <- rep(1 / J, J)

    w <- unlist(utils::combn(weights, 2, FUN = function(x) Reduce(`*`, x),
                             simplify = FALSE))
    r <- unlist(utils::combn(parts, 2, FUN = paste, collapse = "_",
                             simplify = FALSE))

    jj <- utils::combn(seq_len(J), 2, simplify = FALSE)
    lr <- matrix(data = 0, nrow = nrow(object), ncol = length(jj))
    for (i in seq_along(jj)) {
      a <- jj[[i]][[1]]
      b <- jj[[i]][[2]]
      lr[, i] <- log(object[, a] / object[, b], base = exp(1))
    }

    rownames(lr) <- rownames(object)
    colnames(lr) <- r

    .LR(
      lr,
      parts = parts,
      ratio = r,
      order = seq_len(J),
      weights = w,
      totals = object@totals,
      codes = object@codes,
      samples = object@samples,
      groups = object@groups
    )
  }
)

# CLR ==========================================================================
#' @export
#' @rdname transform_clr
#' @aliases transform_clr,CompositionMatrix-method
setMethod(
  f = "transform_clr",
  signature = c(object = "CompositionMatrix"),
  definition = function(object, weights = FALSE) {
    J <- ncol(object)
    parts <- colnames(object)

    w <- if (any(weights)) colMeans(object) else rep(1 / J, J)
    if (is.numeric(weights)) {
      arkhe::assert_length(weights, J)
      arkhe::assert_positive(weights, strict = FALSE)
      w <- weights / sum(weights) # Sum up to 1
    }

    base <- diag(J) - matrix(data = w, nrow = J, ncol = J)
    clr <- log(object, base = exp(1)) %*% base
    dimnames(clr) <- dimnames(object)

    .CLR(
      clr,
      parts = parts,
      ratio = parts,
      order = seq_len(J),
      base = base,
      weights = w,
      totals = object@totals,
      codes = object@codes,
      samples = object@samples,
      groups = object@groups
    )
  }
)

# ALR ==========================================================================
#' @export
#' @rdname transform_alr
#' @aliases transform_alr,CompositionMatrix-method
setMethod(
  f = "transform_alr",
  signature = c(object = "CompositionMatrix"),
  definition = function(object, j = ncol(object)) {
    D <- ncol(object)
    parts <- colnames(object)

    ## Reorder
    j <- if (is.character(j)) which(parts == j) else as.integer(j)
    ordering <- c(which(j != seq_len(D)), j)
    parts <- parts[ordering]
    z <- object[, ordering]

    base <- diag(1, nrow = D, ncol = D - 1)
    base[D, ] <- -1

    alr <- log(z, base = exp(1)) %*% base
    rownames(alr) <- rownames(z)
    colnames(alr) <- paste(parts[-D], parts[D], sep = "_")

    w <- rep(1 / D, D)
    w <- w[-D] * w[D]

    .ALR(
      alr,
      parts = parts,
      ratio = colnames(alr),
      order = order(ordering),
      base = base,
      weights = w,
      totals = object@totals,
      codes = object@codes,
      samples = object@samples,
      groups = object@groups
    )
  }
)

# ILR ==========================================================================
ilr_base <- function(D, method = "basic") {
  ## Validation
  method <- match.arg(method, several.ok = FALSE)

  seq_parts <- seq_len(D - 1)

  ## Original ILR transformation defined by Egozcue et al. 2003
  if (method == "basic") {
    ## Helmert matrix (rotation matrix)
    H <- stats::contr.helmert(D)                  # D x D-1
    H <- t(H) / sqrt((seq_parts + 1) * seq_parts) # D-1 x D

    ## Center
    M <- diag(x = 1, nrow = D) - matrix(data = 1 / D, nrow = D, ncol = D)
    V <- tcrossprod(M, H)
  }

  V
}

#' @export
#' @rdname transform_ilr
#' @aliases transform_ilr,CompositionMatrix,missing-method
setMethod(
  f = "transform_ilr",
  signature = c(object = "CompositionMatrix", base = "missing"),
  definition = function(object) {
    H <- ilr_base(D = ncol(object), method = "basic")
    methods::callGeneric(object, base = H)
  }
)

#' @export
#' @rdname transform_ilr
#' @aliases transform_ilr,CompositionMatrix,matrix-method
setMethod(
  f = "transform_ilr",
  signature = c(object = "CompositionMatrix", base = "matrix"),
  definition = function(object, base) {
    D <- ncol(object)
    seq_parts <- seq_len(D - 1)
    parts <- colnames(object)

    ## Rotated and centered values
    y <- log(object, base = exp(1))
    ilr <- y %*% base

    ratio <- vapply(
      X = seq_parts,
      FUN = function(i, k) {
        paste(paste0(k[seq_len(i)], collapse = "-"), k[i + 1], sep = "_")
      },
      FUN.VALUE = character(1),
      k = parts
    )
    colnames(ilr) <- paste0("Z", seq_parts)
    rownames(ilr) <- rownames(object)

    .ILR(
      ilr,
      parts = parts,
      ratio = ratio,
      order = seq_len(D),
      base = base,
      weights = rep(1 / D, D),
      totals = object@totals,
      codes = object@codes,
      samples = object@samples,
      groups = object@groups
    )
  }
)

# Pivot ========================================================================
#' @export
#' @rdname transform_plr
#' @aliases transform_plr,CompositionMatrix-method
setMethod(
  f = "transform_plr",
  signature = c(object = "CompositionMatrix"),
  definition = function(object, pivot = 1) {
    J <- ncol(object)
    parts <- colnames(object)

    ## Reorder
    pivot <- if (is.character(pivot)) which(parts == pivot) else as.integer(pivot)
    ordering <- c(pivot, which(pivot != seq_len(J)))
    parts <- parts[ordering]
    obj <- object[, ordering]

    x <- seq_len(J - 1)
    balances <- diag(sqrt((J - x) / (J - x + 1)))
    z <- 1 / matrix(data = seq_len(J) - J, nrow = J, ncol = J)
    z[lower.tri(z)] <- 0
    diag(z) <- 1
    z <- z[-nrow(z), ]

    H <- t(balances %*% z)
    plr <- log(obj, base = exp(1)) %*% H

    ratio <- vapply(
      X = seq_len(J - 1),
      FUN = function(i, parts) {
        j <- length(parts)
        sprintf("%s_%s", parts[1], paste0(parts[(i+1):j], collapse = "-"))
      },
      FUN.VALUE = character(1),
      parts = parts
    )
    colnames(plr) <- paste0("Z", seq_len(J - 1))
    rownames(plr) <- rownames(obj)

    .PLR(
      plr,
      parts = parts,
      ratio = ratio,
      order = order(ordering),
      base = H,
      weights = rep(1 / J, J),
      totals = object@totals,
      codes = object@codes,
      samples = object@samples,
      groups = object@groups
    )
  }
)

# Backtransform ================================================================
## CLR -------------------------------------------------------------------------
#' @export
#' @rdname transform_inverse
#' @aliases transform_inverse,CLR,missing-method
setMethod(
  f = "transform_inverse",
  signature = c(object = "CLR", origin = "missing"),
  definition = function(object) {
    y <- methods::as(object, "matrix") # Drop slots
    y <- exp(y)
    y <- y / rowSums(y)

    dimnames(y) <- list(rownames(object), object@parts)
    .CompositionMatrix(
      y,
      totals = object@totals,
      codes = object@codes,
      samples = object@samples,
      groups = object@groups
    )
  }
)
## ALR -------------------------------------------------------------------------
#' @export
#' @rdname transform_inverse
#' @aliases transform_inverse,ALR,missing-method
setMethod(
  f = "transform_inverse",
  signature = c(object = "ALR", origin = "missing"),
  definition = function(object) {
    y <- exp(object)
    y <- y / (1 + rowSums(y))
    z <- 1 - rowSums(y)

    y <- cbind(y, z)
    dimnames(y) <- list(rownames(object), object@parts)
    y <- y[, object@order]

    .CompositionMatrix(
      y,
      totals = object@totals,
      codes = object@codes,
      samples = object@samples,
      groups = object@groups
    )
  }
)
## ILR -------------------------------------------------------------------------
#' @export
#' @rdname transform_inverse
#' @aliases transform_inverse,ILR,missing-method
setMethod(
  f = "transform_inverse",
  signature = c(object = "ILR", origin = "missing"),
  definition = function(object) {
    y <- tcrossprod(object, object@base)
    y <- exp(y)
    y <- y / rowSums(y)

    dimnames(y) <- list(rownames(object), object@parts)
    y <- y[, object@order]

    .CompositionMatrix(
      y,
      totals = object@totals,
      codes = object@codes,
      samples = object@samples,
      groups = object@groups
    )
  }
)

#' @export
#' @rdname transform_inverse
#' @aliases transform_inverse,matrix,ILR-method
setMethod(
  f = "transform_inverse",
  signature = c(object = "matrix", origin = "ILR"),
  definition = function(object, origin) {
    y <- tcrossprod(object, origin@base)
    y <- exp(y)
    y <- y / rowSums(y)

    dimnames(y) <- list(rownames(object), origin@parts)
    y <- y[, origin@order]

    y
  }
)
