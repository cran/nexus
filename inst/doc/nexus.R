## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
## Install extra packages (if needed)
# install.packages("folio")

library(nexus)

## -----------------------------------------------------------------------------
## Mineral compositions of rock specimens
## Data from Aitchison 1986
data("hongite")
head(hongite)

## Coerce to compositional data
coda <- as_composition(hongite)
head(coda)

## -----------------------------------------------------------------------------
## Coerce to count data
counts <- as_amounts(coda)

all.equal(hongite, as.data.frame(counts))

## -----------------------------------------------------------------------------
## Create a data.frame
X <- data.frame(
  type = c("A", "A", "B", "A", "B", "C", "C", "C", "B"),
  Ca = c(7.72, 7.32, 3.11, 7.19, 7.41, 5, 4.18, 1, 4.51),
  Fe = c(6.12, 5.88, 5.12, 6.18, 6.02, 7.14, 5.25, 5.28, 5.72),
  Na = c(0.97, 1.59, 1.25, 0.86, 0.76, 0.51, 0.75, 0.52, 0.56)
)

## Coerce to a compositional matrix
## (the 'type' column will be removed)
Y <- as_composition(X)

## ----transform, fig.width=7, fig.height=8, out.width='100%'-------------------
## CLR
clr <- transform_clr(coda)

## Back transform
back <- transform_inverse(clr)

all.equal(back, coda)

