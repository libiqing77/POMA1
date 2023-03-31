## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  # fig.align = "center",
  comment = ">"
)

## ---- eval = FALSE------------------------------------------------------------
#  # install.packages("BiocManager")
#  BiocManager::install("POMA")

## ---- warning = FALSE, message = FALSE----------------------------------------
library(POMA)

## ---- warning = FALSE, message = FALSE----------------------------------------
library(ggplot2)
library(ggraph)
library(plotly)

## ---- eval = FALSE------------------------------------------------------------
#  # create an SummarizedExperiment object from two separated data frames
#  target <- readr::read_csv("your_target.csv")
#  features <- readr::read_csv("your_features.csv")
#  
#  data <- PomaSummarizedExperiment(target = target, features = features)

## ---- warning = FALSE, message = FALSE----------------------------------------
# load example data
data("st000336")

## ---- warning = FALSE, message = FALSE----------------------------------------
st000336

## -----------------------------------------------------------------------------
imputed <- PomaImpute(st000336, ZerosAsNA = TRUE, RemoveNA = TRUE, cutoff = 20, method = "knn")
imputed

## -----------------------------------------------------------------------------
normalized <- PomaNorm(imputed, method = "log_pareto")
normalized

## ---- message = FALSE---------------------------------------------------------
PomaBoxplots(imputed, group = "samples", 
             jitter = FALSE,
             legend_position = "none") +
  ggplot2::ggtitle("Not Normalized") # data before normalization

## ---- message = FALSE---------------------------------------------------------
PomaBoxplots(normalized, 
             group = "samples", 
             jitter = FALSE,
             legend_position = "none") +
  ggplot2::ggtitle("Normalized") # data after normalization

## ---- message = FALSE---------------------------------------------------------
PomaDensity(imputed, 
            group = "features",
            legend_position = "none") +
  ggplot2::ggtitle("Not Normalized") # data before normalization

## ---- message = FALSE---------------------------------------------------------
PomaDensity(normalized, 
            group = "features") +
  ggplot2::ggtitle("Normalized") # data after normalization

## -----------------------------------------------------------------------------
PomaOutliers(normalized, do = "analyze")$polygon_plot # to explore
pre_processed <- PomaOutliers(normalized, do = "clean") # to remove outliers
pre_processed

## -----------------------------------------------------------------------------
PomaUnivariate(pre_processed, method = "ttest")

## -----------------------------------------------------------------------------
PomaVolcano(imputed, pval = "adjusted")

## ---- warning = FALSE---------------------------------------------------------
PomaUnivariate(pre_processed, method = "mann")

## -----------------------------------------------------------------------------
PomaLimma(pre_processed, contrast = "Controls-DMD", adjust = "fdr")

## -----------------------------------------------------------------------------
poma_pca <- PomaMultivariate(pre_processed, method = "pca")

## -----------------------------------------------------------------------------
poma_pca$scoresplot +
  ggplot2::ggtitle("Scores Plot")

## ---- warning = FALSE, message = FALSE, results = 'hide'----------------------
poma_plsda <- PomaMultivariate(pre_processed, method = "plsda")

## -----------------------------------------------------------------------------
poma_plsda$scoresplot +
  ggplot2::ggtitle("Scores Plot")

## -----------------------------------------------------------------------------
poma_plsda$errors_plsda_plot +
  ggplot2::ggtitle("Error Plot")

## -----------------------------------------------------------------------------
poma_cor <- PomaCorr(pre_processed, label_size = 8, coeff = 0.6)
poma_cor$correlations
poma_cor$corrplot
poma_cor$graph

## -----------------------------------------------------------------------------
PomaCorr(pre_processed, corr_type = "glasso", coeff = 0.6)$graph

## -----------------------------------------------------------------------------
# alpha = 1 for Lasso
PomaLasso(pre_processed, alpha = 1, labels = TRUE)$coefficientPlot

## -----------------------------------------------------------------------------
poma_rf <- PomaRandForest(pre_processed, ntest = 10, nvar = 10)
poma_rf$error_tree

## -----------------------------------------------------------------------------
poma_rf$confusionMatrix$table

## -----------------------------------------------------------------------------
poma_rf$MeanDecreaseGini_plot

## -----------------------------------------------------------------------------
sessionInfo()

