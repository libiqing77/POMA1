% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/PomaDensity.R
\name{PomaDensity}
\alias{PomaDensity}
\title{Distribution Plot}
\usage{
PomaDensity(
  data,
  group = "samples",
  feature_name = NULL,
  legend_position = "bottom"
)
}
\arguments{
\item{data}{A SummarizedExperiment object.}

\item{group}{Groupping factor for the plot. Options are "samples" and "features". Option "samples" (default) will create a density plot for each group and option "features" will create a density plot of each variable.}

\item{feature_name}{A vector with the name/s of feature/s to plot. If it's NULL (default) a density plot of all variables will be created.}

\item{legend_position}{Character indicating the legend position. Options are "none", "top", "bottom", "left", and "right".}
}
\value{
A ggplot2 object.
}
\description{
PomaDensity() generates a density plot of not normalized and normalized MS data. This plot can help in the comparison between pre and post normalized data and in the "validation" of the normalization process.
}
\examples{
data("st000284")

# samples
PomaDensity(st000284)

# features
PomaDensity(st000284, group = "features")

# concrete features
PomaDensity(st000284, group = "features", 
            feature_name = c("ornithine", "orotate"))
}
\author{
Pol Castellano-Escuder
}
