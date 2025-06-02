## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  message = FALSE
)
Sys.setenv(LANGUAGE = "en") # Force locale

## ----setup--------------------------------------------------------------------
## Install extra packages (if needed)
# install.packages("folio") # datasets
# install.packages("isopleuros") # ternary plot

library(nexus)

## ----composition--------------------------------------------------------------
## Mineral compositions of rock specimens
## Data from Aitchison 1986
data("hongite")
head(hongite)

## Coerce to compositional data
coda <- as_composition(hongite)
head(coda)

## ----amounts------------------------------------------------------------------
## Coerce to count data
counts <- as_amounts(coda)

all.equal(hongite, as.data.frame(counts))

## ----coerce-------------------------------------------------------------------
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

## ----group--------------------------------------------------------------------
## Coerce to a compositional matrix
## (the 'type' column will be used for group definition)
Y <- as_composition(X, group = 1)

## ----condense-----------------------------------------------------------------
## Data from Wood and Liu 2023
data("bronze", package = "folio")

## Create a composition data matrix
coda <- as_composition(bronze, parts = 4:11)

## Compositional mean by artefact
coda <- condense(coda, by = list(bronze$dynasty, bronze$reference))

## ----mean---------------------------------------------------------------------
## Compositional mean
mean(coda)

## ----barplot, fig.width=10, fig.height=10, out.width='100%'-------------------
## Select major elements
major <- coda[, is_element_major(coda)]

## Compositional bar plot
barplot(major, order_rows = "Cu", order_columns = TRUE, space = 0)

## ----histogram, fig.width=5, fig.height=5, fig.show='hold', out.width='33%'----
hist(coda, select = "Cu")
hist(coda, select = "Sn")
hist(coda, select = "Pb")

## ----ternary, fig.width=10, fig.height=10, out.width='100%'-------------------
## Load
library(isopleuros)

## Cu-Sn-Pb ternary plot
CuSnPb <- coda[, c("Cu", "Sn", "Pb")]
ternary_plot(CuSnPb)
ternary_grid()

## ----transform----------------------------------------------------------------
## CLR
clr <- transform_clr(coda)

## Back transform
back <- transform_inverse(clr)

all.equal(back, coda)

