context("functions calls annotations")

test_that("no library call", {
  test_string <- "x <- 3"
  expect_output(
    output <- annotate_fun_calls(test_string),
    "no matching library load calls"
  )
  expect_equal(output, test_string)
})

test_that("library call but no funs", {
  test_string <- "library(ggplot2)"
  expect_equal(
    annotate_fun_calls(test_string),
    paste0(test_string, ' # "No used functions found"')
  )
})

test_that("require call but no funs", {
  test_string <- "require(ggplot2)"
  expect_equal(
    annotate_fun_calls(test_string),
    paste0(test_string, ' # "No used functions found"')
  )
})

test_that("library call with one fun", {
  test_string <- "library(dplyr)\nfilter(data.frame())"
  expect_equal(
    annotate_fun_calls(test_string),
    "library(dplyr) # filter\nfilter(data.frame())"
  )
})

test_that("require call with one fun", {
  test_string <- "require(dplyr)\nfilter(data.frame())"
  expect_equal(
    annotate_fun_calls(test_string),
    "require(dplyr) # filter\nfilter(data.frame())"
  )
})

test_that("library call with two funs", {
  test_string <- "library(dplyr)\ndata.frame() %>% filter()"
  expect_equal(
    annotate_fun_calls(test_string),
    "library(dplyr) # %>% filter\ndata.frame() %>% filter()"
  )
})

test_that("require call with two funs", {
  test_string <- "require(dplyr)\ndata.frame() %>% filter()"
  expect_equal(
    annotate_fun_calls(test_string),
    "require(dplyr) # %>% filter\ndata.frame() %>% filter()"
  )
})

test_that("library call with one fun that is in two packages", {
  test_string <- "library(dplyr)\nlibrary(stats)\ndata.frame() %>% filter()"
  expect_equal(
    annotate_fun_calls(test_string),
    "library(dplyr) # %>% filter\nlibrary(stats) # filter\ndata.frame() %>% filter()"
  )
})

test_that("require call with one fun that is in two packages", {
  test_string <- "require(dplyr)\nrequire(stats)\ndata.frame() %>% filter()"
  expect_equal(
    annotate_fun_calls(test_string),
    "require(dplyr) # %>% filter\nrequire(stats) # filter\ndata.frame() %>% filter()"
  )
})

test_that("library and require with double quotes", {
  test_string <- 'library("dplyr")\nrequire("stats")\ndata.frame() %>% filter()'
  expect_equal(
    annotate_fun_calls(test_string),
    'library("dplyr") # %>% filter\nrequire("stats") # filter\ndata.frame() %>% filter()'
  )
})

test_that("pacman calls split up and annotated", {
  test_string <- "pacman::p_load(dplyr,purrr) \nfilter()\nmap2_chr()"
  expect_equal(
    annotate_fun_calls(test_string),
    "pacman::p_load(\ndplyr, # filter\npurrr # map2_chr\n) \nfilter()\nmap2_chr()"
    )
})

test_that("mixed base and pacman calls split up and annotated", {
  test_string <- "pacman::p_load(purrr)\nlibrary(stringr)\nstr_detect(y); pluck(x); discard()"
  expect_equal(
    annotate_fun_calls(test_string),
    "pacman::p_load(\npurrr # pluck discard\n)\nlibrary(stringr) # str_detect\nstr_detect(y); pluck(x); discard()"
  )
})

test_that("mixed base and pacman calls call but no funs", {
  test_string <- "pacman::p_load(purrr)\nlibrary(stringr)"
  expect_equal(
    annotate_fun_calls(test_string),
    "pacman::p_load(\npurrr # \"No used functions found\"\n)\nlibrary(stringr) # \"No used functions found\""  )
})
