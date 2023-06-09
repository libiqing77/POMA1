
#' Rank Product/Rank Sum Analysis for Mass Spectrometry Data
#'
#' @description PomaRankProd() performs the Rank Product method to identify differential feature concentration/intensity.
#'
#' @param data A SummarizedExperiment object.
#' @param logged If "TRUE" (default) data have been previously log transformed.
#' @param logbase Numerical. Base for log transformation.
#' @param paired Number of random pairs generated in the function, if set to NA (default), the odd integer closer to the square of the number of replicates is used.
#' @param cutoff The pfp/pvalue threshold value used to select features.
#' @param method If cutoff is provided, the method needs to be selected to identify features. "pfp" uses percentage of false prediction, which is a default setting. "pval" uses p-values which is less stringent than pfp.
#'
#' @export
#'
#' @return A list with all results for Rank Product analysis including tables and plots.
#' @references Breitling, R., Armengaud, P., Amtmann, A., and Herzyk, P.(2004) Rank Products: A simple, yet powerful, new method to detect differentially regulated genes in replicated microarray experiments, FEBS Letter, 57383-92
#' @references Hong, F., Breitling, R., McEntee, W.C., Wittner, B.S., Nemhauser, J.L., Chory, J. (2006). RankProd: a bioconductor package for detecting differentially expressed genes in meta-analysis Bioinformatics. 22(22):2825-2827
#' @references Del Carratore, F., Jankevics, A., Eisinga, R., Heskes, T., Hong, F. & Breitling, R. (2017). RankProd 2.0: a refactored Bioconductor package for detecting differentially expressed features in molecular profiling datasets. Bioinformatics. 33(17):2774-2775
#' @author Pol Castellano-Escuder
#'
#' @importFrom magrittr %>%
#' 
#' @examples 
#' data("st000336")
#' 
#' st000336 %>% 
#'   PomaImpute() %>%
#'   PomaRankProd()
PomaRankProd <- function(data,
                         logged = TRUE,
                         logbase = 2,
                         paired = NA,
                         cutoff = 0.05,
                         method = "pfp"){

  if (missing(data)) {
    stop("data argument is empty!")
  }
  if(!is(data, "SummarizedExperiment")){
    stop("data is not a SummarizedExperiment object. \nSee POMA::PomaSummarizedExperiment or SummarizedExperiment::SummarizedExperiment")
  }
  if (!(method %in% c("pfp", "pval"))) {
    stop("Incorrect value for method argument!")
  }
  if (sum(apply(t(SummarizedExperiment::assay(data)), 2, function(x){sum(x < 0, na.rm = TRUE)})) != 0) {
    stop("Negative values detected in your data!")
  }
  if (missing(method)) {
    message("method argument is empty! pfp method will be used")
  }

  Group <- as.factor(SummarizedExperiment::colData(data)[,1])

  if (length(levels(Group)) != 2) {
    stop("Data must have two groups...")
  }

  data_class <- as.numeric(ifelse(Group == levels(Group)[1], 0, 1))
  
  class1 <- levels(as.factor(Group))[1]
  class2 <- levels(as.factor(Group))[2]

  RP <- RankProd::RankProducts(SummarizedExperiment::assay(data), 
                               data_class, 
                               logged = logged, 
                               na.rm = TRUE, 
                               plot = FALSE,
                               RandomPairs = paired,
                               rand = 123,
                               gene.names = rownames(data))

  top_rank <- RankProd::topGene(RP, 
                                cutoff = cutoff, 
                                method = method,
                                logged = logged, 
                                logbase = logbase,
                                gene.names = rownames(data))
          
  one <- as.data.frame(top_rank$Table1)
  two <- as.data.frame(top_rank$Table2)

  if(nrow(one) == 0 & nrow(two) == 0){
    stop("No significant features found...")
  }
  
  if(nrow(one) != 0){
    
    one <- one %>% 
      tibble::rownames_to_column("feature") %>% 
      dplyr::rename(rp_rsum = 3,
                    pvalue = P.value,
                    feature_index = gene.index) %>% 
      dplyr::as_tibble()
    
    colnames(one)[4] <- paste0("FC_", class1, "_", class2)
  }
  
  if(nrow(two) != 0){
    
    two <- two %>% 
      tibble::rownames_to_column("feature") %>% 
      dplyr::rename(rp_rsum = 3,
                    pvalue = P.value,
                    feature_index = gene.index) %>% 
      dplyr::as_tibble()
    
    colnames(two)[4] <- paste0("FC_", class1, "_", class2)
  }

  #### PLOT

  pfp <- as.matrix(RP$pfp)

  ####

  if (is.null(RP$RPs)) {
    RP1 <- as.matrix(RP$RSs)
    rank <- as.matrix(RP$RSrank)
  }

  if (!is.null(RP$RPs)){
    RP1 <- as.matrix(RP$RPs)
    rank <- as.matrix(RP$RPrank)
  }

  ind1 <- which(!is.na(RP1[, 1]))
  ind2 <- which(!is.na(RP1[, 2]))
  ind3 <- append(ind1, ind2)
  ind3 <- unique(ind3)
  RP.sort.upin2 <- sort(RP1[ind1, 1], index.return = TRUE)
  RP.sort.downin2 <- sort(RP1[ind2, 2], index.return = TRUE)
  pfp1 <- pfp[ind1, 1]
  pfp2 <- pfp[ind2, 2]
  rank1 <- rank[ind1, 1]
  rank2 <- rank[ind2, 2]

  rp_plot <- data.frame(rank1 = rank1, rank2 = rank2, pfp1 = pfp1 ,  pfp2 = pfp2)

  plot1 <- ggplot2::ggplot(rp_plot, ggplot2::aes(x = rank1, y = pfp1)) +
    ggplot2::geom_point(size = 1.5, alpha=0.9) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = "Number of identified features",
                  y = "Estimated PFP",
                  title = paste0("Identification of Up-regulated features under class ", class2))

  plot2 <- ggplot2::ggplot(rp_plot, ggplot2::aes(x = rank2, y = pfp2)) +
    ggplot2::geom_point(size = 1.5, alpha=0.9) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = "Number of identified features",
                  y = "Estimated PFP",
                  title = paste0("Identification of Down-regulated features under class ", class2))

  return(list(upregulated = one,
              downregulated = two,
              Upregulated_RP_plot = plot1,
              Downregulated_RP_plot = plot2))

}

