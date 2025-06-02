## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
Sys.setenv(LANGUAGE = "en") # Force locale

## ----setup--------------------------------------------------------------------
## Install extra packages (if needed)
# install.packages("folio") # datasets

library(nexus)

## ----data---------------------------------------------------------------------
## Data from Wood and Liu 2023
data("bronze", package = "folio")
dynasty <- as.character(bronze$dynasty) # Save original data for further use

## Randomly add missing values
set.seed(12345) # Set seed for reproductibility
n <- nrow(bronze)
bronze$dynasty[sample(n, size = n / 3)] <- NA

## ----coda---------------------------------------------------------------------
## Use the third column (dynasties) for grouping
coda <- as_composition(bronze, parts = 4:11, groups = 3)

## ----group--------------------------------------------------------------------
## Create a composition data matrix
coda <- as_composition(bronze, parts = 4:11)

## Use the third dynasties for grouping
coda <- group(coda, by = bronze$dynasty)

## ----barplot, fig.width=10, fig.height=10, out.width='100%'-------------------
## Select major elements
major <- coda[, is_element_major(coda)]

## Compositional bar plot
barplot(major, order_rows = "Cu", space = 0)

## ----ternary, fig.width=10, fig.height=10, out.width='100%'-------------------
## Matrix of ternary plots
pairs(coda)

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
## Subset training data
train <- coda[is_assigned(coda), ]

## ILR
ilr_train <- transform_ilr(train)

## MANOVA
fit <- manova(ilr_train ~ group_names(ilr_train))
summary(fit)

## ----lda----------------------------------------------------------------------
## LDA
(discr <- MASS::lda(ilr_train, grouping = group_names(ilr_train)))

## ----lda-model----------------------------------------------------------------
## Back transform results
transform_inverse(discr$means, origin = ilr_train)

## ----lda-plot, fig.width=10, fig.height=10, out.width='100%'------------------
plot(discr, col = c("#DDAA33", "#BB5566", "#004488")[group_indices(ilr_train)])

## ----lda-predict--------------------------------------------------------------
## Subset unassigned samples
test <- coda[!is_assigned(coda), ]
ilr_test <- transform_ilr(test)

## Predict group membership
results <- predict(discr, ilr_test)

## Assess the accuracy of the prediction
(ct <- table(
  predicted = results$class, 
  expected = dynasty[!is_assigned(coda)]
))
diag(proportions(ct, margin = 1))

## Total percent correct
sum(diag(proportions(ct)))

