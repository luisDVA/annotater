context("annotating files")

test_that("file exists", {
  expect_error(annotate_script("./annotate_script/nonexistent.R"
  ))
})

test_that("package load calls are matched", {
  annotated_output <- capture_output(
    annotate_script(script_file = "./annotating_scripts/demo-script.R")
  )
  manual_output <- c(
"# demo script
library(stats) # The R Stats Package
library(datasets) # The R Datasets Package
")
  expect_identical(annotated_output, manual_output)
})
