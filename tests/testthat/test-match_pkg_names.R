context("Matching library load calls")

test_that("input is a character string", {
  expect_error(match_pkg_names(1234))
})

test_that("library and require calls are matched", {
  test_string <- c("library(boot)\nrequire(tools)")
  matched <- match_pkg_names(test_string)
  manual_pkg_table <- tibble::tribble(
      ~call, ~package_name, ~pkgname_clean,
      "library(boot)",        "boot",         "boot",
      "require(tools)",       "tools",        "tools"
    )
  expect_identical(matched, manual_pkg_table)
})

test_that("commented lines are skipped", {
  test_string <- c("library(boot)\nlibrary(unheadr) # comment\nrequire(tools)")
  matched <- match_pkg_names(test_string)
  manual_pkg_table <- tibble::tribble(
    ~call, ~package_name, ~pkgname_clean,
    "library(boot)",        "boot",         "boot",
    "require(tools)",       "tools",        "tools"
  )
  expect_identical(matched, manual_pkg_table)
})

test_that("quoted packaged names stripped for matching", {
  test_string <- c('library("boot")\nrequire(tools)')
  matched <- match_pkg_names(test_string)
  manual_pkg_table <- tibble::tribble(
    ~call, ~package_name, ~pkgname_clean,
    "library(\"boot\")",    "\"boot\"",         "boot",
    "require(tools)",       "tools",        "tools"
  )
  expect_identical(matched, manual_pkg_table)
})
