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
## Data from Wood and Liu 2023
data("bronze", package = "folio")

## Use the third column (dynasties) for grouping
coda <- as_composition(bronze, parts = 4:11, groups = 3)

## ----mean---------------------------------------------------------------------
## Compositional mean by artefact
coda <- condense(coda, by = list(bronze$dynasty, bronze$reference))

## ----barplot, fig.width=7, fig.height=7, out.width='100%'---------------------
## Select major elements
major <- coda[, is_element_major(coda)]

## Compositional bar plot
barplot(major, order_rows = "Cu", space = 0)

## ----pca, fig.width=7, fig.height=7, out.width='50%', fig.show='hold'---------
## CLR
clr <- transform_clr(coda, weights = TRUE)

## PCA
lra <- pca(clr)

## Visualize results
viz_individuals(
  x = lra, 
  extra_quali = group_names(clr),
  color = c("#004488", "#DDAA33", "#BB5566"),
  hull = TRUE
)

viz_variables(lra)

## ----manova-------------------------------------------------------------------
## ILR
ilr <- transform_ilr(coda)

## MANOVA
fit <- manova(ilr ~ group_names(ilr))
summary(fit)

## ----lda, fig.width=7, fig.height=7, out.width='100%'-------------------------
## LDA
discr <- MASS::lda(ilr, grouping = group_names(ilr))
plot(discr)

## Back transform results
transform_inverse(discr$means, origin = ilr)

