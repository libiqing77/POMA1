#' Convert data frames to a MSnSet Object
#'
#' @description This function converts data frame objects to a MSnSet object.
#' 
#' @param target Metadata variables structured in columns. Sample ID must be the first column and group/type/treatment of the study must be the second column.
#' @param features Table of features. Each feature in one column.
#'
#' @export
#'
#' @return A MSnSet object.
#' @references Laurent Gatto and Kathryn S. Lilley. MSnbase - an R/Bioconductor package for isobaric tagged mass spectrometry data visualization, processing and quantitation. Bioinformatics 28, 288-289 (2012).
#' @author Pol Castellano-Escuder
#'
#' @importFrom MSnbase MSnSet
#' @importFrom tibble column_to_rownames remove_rownames
#' @importFrom dplyr rename
#' @importFrom magrittr %>%
#' 
#' @examples 
#' data(iris)
#' 
#' # create target: two column (or more) data frame with IDs and Group factor
#' target <- data.frame(ID = 1:150, Group = iris$Species)
#' 
#' # create features: p column data frame (or matrix) with features
#' features <- iris[,1:4]
#' 
#' # create an MSnSet object with POMA
#' object <- PomaMSnSetClass(target = target, features = features)
PomaMSnSetClass <- function(target,
                            features){

  if(nrow(target) != nrow(features)){
    stop(crayon::red(clisymbols::symbol$cross, "Different number of samples between target and features!"))
  }
  if(missing(target)){
    stop(crayon::red(clisymbols::symbol$cross, "target required!"))
  }
  if(missing(features)){
    stop(crayon::red(clisymbols::symbol$cross, "features required!"))
  }
  if(!is.data.frame(target)){
    stop(crayon::red(clisymbols::symbol$cross, "target file is not a data.frame"))
  }
  if(sum(sapply(target, function(x)sum(is.na(x)))) > 0){
    stop(crayon::red(clisymbols::symbol$cross, "missing values not allowed in target file"))
  }
  
  target <- target %>%
    as.data.frame() %>% 
    remove_rownames() %>%
    rename("ID" = 1) %>% 
    column_to_rownames("ID")

  features <- features %>% as.data.frame()
  features <- as.matrix(sapply(features, function(x)as.numeric(as.character(x))))
  rownames(features) <- rownames(target)

  ## create a MSnSet object
  data <- MSnbase::MSnSet(exprs = t(features), pData = target)
  
  if(validObject(data))
    return(data)

}
