context("package loading annotations")

test_that("correct text when there are no matches", {
  test_string <- c("cdog\n23")
  expect_output(annotate_pkg_calls(test_string), "no matching library load calls")
  expect_output(annotate_repo_source(test_string), "no matching library load calls")
  expect_output(annotate_repostitle(test_string), "no matching library load calls")
  expect_output(annotate_pkg_datasets(test_string), "no matching library load calls")
  })

test_that("repo details returns a user/repository-name vector", {
  expect_match(repo_details("stringr"), ".*\\/.*")
})

test_that("repository sources returns a repository-version combination", {
  test_string <- c("library(tibble)")
  expect_match(
    annotate_repo_source(test_string),
    "library\\(tibble\\) # .+\\w+ v.*"
  )
})

test_that("repository sources returns a repository-version combination (p_load)", {
  test_string <- c("p_load(tibble)")
  expect_match(
    annotate_repo_source(test_string),
    "p_load\\(\ntibble # .+\\w+ v.*\\)"
  )
})

test_that("input for alignment function is a character string", {
  expect_error(align_annotations(1234))
})

test_that("repository title and sources includes a repository-version combination", {
  test_string <- c("library(tibble)")
  expect_match(
    annotate_repostitle(test_string),
    "\\w v.*"
  )
})

test_that("repository sources returns a repository-version combination (p_load and library)", {
  test_string <- c(
    "p_load(tidyr)
library(stringi)"
  )
  expect_match(
    annotate_repo_source(test_string),
    "p_load.*tidyr\\s*# .+ v.*library.stringi.* .+ v.*"
  )
})

test_that("package function annotations when none used", {
  test_string <- c("library(purrr)\nread_delim('dat')")
  test_string_p <- c("p_load(tidyr)\nread_delim('dat')")
  expect_match(
    annotate_fun_calls(test_string),
    "No used functions found"
  )
  expect_match(
    annotate_fun_calls(test_string_p),
    "No used functions found"
  )
})


test_that("package dataset annotations when none used", {
  test_string <- c("library(tibble)\nread_delim('dat')")
  expect_match(
    annotate_pkg_datasets(test_string),
    "No loaded datasets found"
  )
})

test_that("if statement for pacman calls works", {
  test_string <- c("p_load(purrr)")
  expect_match(
    annotate_repostitle(test_string),
    "# Functional"
  )
})

test_that("if statement for pacman + base calls works", {
  test_string <- c("p_load(purrr)\nlibrary(tidyr)")
  expect_match(annotate_repostitle(test_string), "# Functional")
  expect_match(annotate_repostitle(test_string), "# Tidy")
})
