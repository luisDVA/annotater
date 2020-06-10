context("package loading annotations")

test_that("lines as is when there are no matches", {
  test_string <- c("cdog\n23")
  expect_output(annotate_pkg_calls(test_string), "no matching library load calls")
  expect_output(annotate_repo_source(test_string), "no matching library load calls")
  expect_output(annotate_repostitle(test_string), "no matching library load calls")
})

test_that("repo details returns a user/repository-name vector", {
  expect_match(repo_details("boot"), ".*\\/.*")
})

test_that("repository sources returns a repository-version combination", {
  test_string <- c("library(boot)")
  expect_match(
    annotate_repo_source(test_string),
    "library\\(boot\\) # CRAN v.*"
  )
})

test_that("input for alignment function is a character string", {
  expect_error(align_annotations(1234))
})

test_that("repository title and sources includes a repository-version combination", {
  test_string <- c("library(boot)")
  expect_match(
    annotate_repostitle(test_string),
    "CRAN v.*"
  )
})
