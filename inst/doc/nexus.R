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

## -----------------------------------------------------------------------------
## Data from Wood and Liu 2023
data("bronze", package = "folio")

## Use the third column (dynasties) for grouping
coda <- as_composition(bronze, groups = 3)

## ----barplot, fig.width=7, fig.height=7, out.width='100%'---------------------
## Compositional bar plot
barplot(coda, select = is_element_major(coda), order_rows = "Cu", space = 0)

## ----mean, eval=FALSE---------------------------------------------------------
#  ## Compositional mean by artefact
#  coda <- condense(coda, by = list(bronze$dynasty, bronze$reference))

## ----transform, fig.width=7, fig.height=8, out.width='100%'-------------------
## CLR
clr <- transform_clr(coda)

## Back transform
back <- transform_inverse(clr)

all.equal(back, coda)

## -----------------------------------------------------------------------------
## Assume that about a third of the samples does not belong to any group
grp <- groups(coda)
grp[sample(length(grp), size = 100)] <- NA

## Set groups
groups(coda) <- grp

## Retrieve groups
# groups(coda)

## ----pca, fig.width=7, fig.height=7, out.width='50%', fig.show='hold'---------
## CLR
clr <- transform_clr(coda, weights = TRUE)

## PCA
lra <- pca(clr)

## Visualize results
viz_individuals(lra, color = c("#004488", "#DDAA33", "#BB5566"))
viz_hull(x = lra, border = c("#004488", "#DDAA33", "#BB5566"))

viz_variables(lra)

## ----manova-------------------------------------------------------------------
## ILR
ilr <- transform_ilr(coda)

bronze$ilr <- ilr

## MANOVA
fit <- manova(ilr ~ groups(ilr), data = bronze)
summary(fit)

## ----lda, fig.width=7, fig.height=7, out.width='100%'-------------------------
## LDA
discr <- MASS::lda(groups(ilr) ~ ilr, data = bronze)
plot(discr)

## Back transform results
transform_inverse(discr$means, origin = ilr)

