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

## ---- eval = FALSE------------------------------------------------------------
#  data("st000336")
#  PomaEDA(st000336)

## ---- echo = FALSE, warning = FALSE, comment = NA, message = FALSE------------
data <- st000336
imputation <- "knn"
normalization <- "log_pareto"
clean_outliers <- TRUE
coeff_outliers <- 1.5

## ---- echo = FALSE, warning = FALSE, comment = NA, message = FALSE------------
# This file is part of POMA.

# POMA is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# POMA is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with POMA. If not, see <https://www.gnu.org/licenses/>.

library(POMA)

e <- t(SummarizedExperiment::assay(data))
target <- SummarizedExperiment::colData(data) %>% 
  as.data.frame() %>% 
  tibble::rownames_to_column("ID") %>% 
  dplyr::rename(Group = 2) %>% 
  dplyr::select(ID, Group)

## ---- echo = FALSE, warning = FALSE, comment = NA, message = FALSE------------
if(clean_outliers){
  imputed <- PomaImpute(data, method = imputation)
  pre_processed <- PomaNorm(imputed, method = normalization) %>%
    PomaOutliers(coef = coeff_outliers)
} else {
  imputed <- PomaImpute(data, method = imputation)
  pre_processed <- PomaNorm(imputed, method = normalization)
}

## ---- echo = FALSE, warning = FALSE, comment = NA, message = FALSE------------
# zeros
zeros <- data.frame(number = colSums(e == 0, na.rm = TRUE)) %>%
  tibble::rownames_to_column("names") %>%
  dplyr::filter(number != 0)

all_zero <- zeros %>% 
  dplyr::filter(number == nrow(e))

# missing values
nas <- data.frame(number = colSums(is.na(e))) %>%
  tibble::rownames_to_column("names") %>%
  dplyr::filter(number != 0)

# zero variance
var_zero <- e %>%
  as.data.frame() %>%
  dplyr::summarise_all(~ var(., na.rm = TRUE)) %>%
  t() %>%
  as.data.frame() %>%
  tibble::rownames_to_column("names") %>%
  dplyr::filter(V1 == 0)

## ---- echo = FALSE, warning = FALSE, comment = NA, message = FALSE------------
summary_table1 <- data.frame(Samples = nrow(e),
                             Features = ncol(e),
                             Covariates = ncol(SummarizedExperiment::colData(data)) - 1)

summary_table2 <- data.frame(Number_Zeros = sum(zeros$number),
                             Percentage_Zeros = paste(round((sum(zeros$number)/(nrow(e)*ncol(e)))*100, 2), "%"))

summary_table3 <- data.frame(Number_Missings = sum(is.na(e)),
                             Percentage_Missings = paste(round((sum(is.na(e))/(nrow(e)*ncol(e)))*100, 2), "%"))

summary_table1 
summary_table2
summary_table3

## ---- echo = FALSE, warning = FALSE, comment = NA, message = FALSE------------
if (nrow(nas) >= 1){
  ggplot2::ggplot(nas, ggplot2::aes(reorder(names, number), number, fill = number)) +
    ggplot2::geom_col() +
    ggplot2::labs(x = NULL,
                  y = "Missing values",
                  title = "Missing Value Plot") +
    ggplot2::theme_bw() + 
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
                   legend.position = "none") +
    ggplot2::scale_fill_viridis_c(begin = 0, end = 0.8)
}

## ---- echo = FALSE, warning = FALSE, comment = NA, message = FALSE------------
if (nrow(zeros) >= 1){
  ggplot2::ggplot(zeros, ggplot2::aes(reorder(names, number), number, fill = number)) +
    ggplot2::geom_col() +
    ggplot2::labs(x = NULL,
              y = "Zeros",
              title = "Zeros Plot") +
    ggplot2::theme_bw() + 
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
                   legend.position = "none") +
    ggplot2::scale_fill_viridis_c(begin = 0, end = 0.8)
}

## ---- echo = FALSE, warning = FALSE, comment = NA, message = FALSE------------
counts <- data.frame(table(target$Group))
colnames(counts) <- c("Group", "Counts")

ggplot2::ggplot(counts, ggplot2::aes(reorder(Group, Counts), Counts, fill = Group)) +
  ggplot2::geom_col() +
  ggplot2::labs(x = NULL,
                y = "Counts") +
  ggplot2::theme_bw() + 
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
                 legend.position = "none") +
  ggplot2::scale_fill_viridis_d(begin = 0, end = 0.8)

## ---- echo = FALSE, warning = FALSE, comment = NA, message = FALSE------------
indNum <- nrow(SummarizedExperiment::colData(pre_processed))
jttr <- ifelse(indNum <= 10, TRUE, FALSE)

p1 <- PomaBoxplots(imputed, 
                   jitter = jttr, 
                   label_size = 8,
                   legend_position = "bottom") +
  ggplot2::labs(x = "Samples",
                y = "Value",
                title = "Not Normalized") 

p2 <- PomaBoxplots(pre_processed, 
                   jitter = jttr, 
                   label_size = 8,
                   legend_position = "bottom") +
  ggplot2::labs(x = "Samples",
                y = "Value",
                title = paste0("Normalized (", normalization, ")"))

p1
p2

## ---- echo = FALSE, warning = FALSE, comment = NA, message = FALSE------------
p3 <- PomaDensity(imputed) +
  ggplot2::ggtitle("Not Normalized")

p4 <- PomaDensity(pre_processed) +
  ggplot2::ggtitle(paste0("Normalized (", normalization, ")"))

p3
p4

## ---- echo = FALSE, warning = FALSE, comment = NA, message = FALSE------------
outliers <- data %>% 
  PomaImpute(method = imputation) %>%
  PomaNorm(method = normalization) %>%
  PomaOutliers(do = "analyze", coef = coeff_outliers)
outliers$polygon_plot

## ---- echo = FALSE, warning = FALSE, comment = NA, message = FALSE------------
if(nrow(outliers$outliers) >= 1){
  outliers$outliers
  }

## ---- echo = FALSE, warning = FALSE, comment = NA, message = FALSE------------
correlations <- PomaCorr(pre_processed, 
                         label_size = 8)

high_correlations <- correlations$correlations %>% 
  dplyr::filter(abs(corr) > 0.97)

## ---- echo = FALSE, warning = FALSE, comment = NA, message = FALSE, fig.align = 'center'----
correlations$corrplot

## ---- echo = FALSE, warning = FALSE, comment = NA, message = FALSE------------
PomaHeatmap(pre_processed, sample_names = FALSE)

## ---- echo = FALSE, warning = FALSE, comment = NA, message = FALSE------------
PomaMultivariate(pre_processed, method = "pca", ellipse = FALSE)$scoresplot

## ---- echo = FALSE, warning = FALSE, comment = NA, message = FALSE------------
PomaUMAP(pre_processed, 
         hdbscan_minpts = 5,
         show_clusters = TRUE)$umap_plot

