## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
## Install extra packages (if needed):
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

## ----plot, fig.width=7, fig.height=5, out.width='100%'------------------------
## Ternary plots
plot(coda)

## ----barplot, fig.width=7, fig.height=5, out.width='100%'---------------------
## Compositional bar plot
barplot(coda, order = "A")

## -----------------------------------------------------------------------------
## Create a data.frame
X <- data.frame(
  groups = c("A", "A", "B", "A", "B", "C", "C", "C", "B"),
  Ca = c(7.72, 7.32, 3.11, 7.19, 7.41, 5, 4.18, 1, 4.51),
  Fe = c(6.12, 5.88, 5.12, 6.18, 6.02, 7.14, 5.25, 5.28, 5.72),
  Na = c(0.97, 1.59, 1.25, 0.86, 0.76, 0.51, 0.75, 0.52, 0.56)
)

## Coerce to a compositional matrix
Y <- as_composition(X)
any_assigned(Y)

## -----------------------------------------------------------------------------
## Set groups (NA means no group)
set_groups(Y) <- c("X", "X", "Y", "X", "Y", NA, NA, NA, "Y")

## Retrieve groups
get_groups(Y)

## -----------------------------------------------------------------------------
## Create a data.frame
X <- data.frame(
  samples = c("A", "A", "A", "B", "B", "B", "C", "C", "C"),
  Ca = c(7.72, 7.32, 3.11, 7.19, 7.41, 5, 4.18, 1, 4.51),
  Fe = c(6.12, 5.88, 5.12, 6.18, 6.02, 7.14, 5.25, 5.28, 5.72),
  Na = c(0.97, 1.59, 1.25, 0.86, 0.76, 0.51, 0.75, 0.52, 0.56)
)

## Coerce to a compositional matrix
Y <- as_composition(X)
any_replicated(Y)

## -----------------------------------------------------------------------------
## Set sample names
set_samples(Y) <- c("A", "B", "C", "D", "E", "F", "G", "H", "I")

## Retrieve groups
get_samples(Y)

## ----transform, fig.width=7, fig.height=8, out.width='100%'-------------------
## CLR
clr <- transform_clr(coda)
head(clr)

plot(clr)

back <- transform_inverse(clr)
head(back)

## ----ceramics-----------------------------------------------------------------
## Data from Day et al. 2011
data("kommos", package = "folio")

## Remove rows with missing values
kommos <- remove_NA(kommos, margin = 1)

## Coerce to a compositional matrix
coda <- as_composition(kommos)

## Set groups
set_groups(coda) <- kommos$type

## ----ceramics-barplot, fig.width=7, fig.height=7, out.width='100%'------------
## Compositional bar plot
barplot(coda, order = "Ca")

## ----ceramics-pca, fig.width=7, fig.height=7, out.width='50%', fig.show='hold'----
## CLR
clr <- transform_clr(coda)

## PCA
library(dimensio)

clr_pca <- pca(clr, scale = FALSE)

viz_individuals(clr_pca, highlight = get_groups(coda), pch = 16, 
                col = c("#EE7733", "#0077BB", "#33BBEE", "#EE3377"))
viz_variables(clr_pca)

## ----ceramics-manova----------------------------------------------------------
## ILR
ilr <- transform_ilr(coda)

## MANOVA
fit <- manova(ilr ~ get_groups(ilr))
summary(fit)

## ----ceramics-lda, fig.width=7, fig.height=7, out.width='100%'----------------
## LDA
discr <- MASS::lda(ilr, grouping = get_groups(ilr))
plot(discr)

## Back transform results
transform_inverse(discr$means, origin = ilr)

