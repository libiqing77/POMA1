context("PomaVolcano")

test_that("PomaVolcano works", {

  data("st000336")

  iris_example <- PomaSummarizedExperiment(target = data.frame(ID = 1:150, Group = iris$Species), features = iris[,1:4])
    
  a <- PomaVolcano(st000336, pval = "adjusted", adjust = "fdr")
  b <- PomaVolcano(st000336, pval = "adjusted", pval_cutoff = 0.05, log2FC = 0.6, xlim = 2, adjust = "fdr")
  c <- PomaVolcano(st000336, pval = "raw", pval_cutoff = 0.05, log2FC = 0.6, xlim = 2, adjust = "fdr")
  d <- PomaVolcano(st000336, pval = "raw", pval_cutoff = 0.05, log2FC = 0.6, xlim = 2, adjust = "bonferroni")
  
  df_a <- ggplot2::layer_data(a)
  df_b <- ggplot2::layer_data(b)
  df_c <- ggplot2::layer_data(c)
  df_d <- ggplot2::layer_data(d)
  
  ##
  
  expect_equal(df_a, df_b)
  expect_false(all(df_a$y == df_c$y))
  
  expect_equal(df_c$label, df_d$label)

  ##
  
  expect_error(PomaVolcano(st000336, pval = "ra", adjust = "fdr"))
  expect_error(PomaVolcano(st000336, pval = "raw", adjust = "fd"))
  
  expect_error(PomaVolcano(iris_example, pval = "raw", adjust = "fdr"))
  
  ##
  
  expect_error(PomaVolcano())
  expect_error(PomaVolcano(iris))
  
})

