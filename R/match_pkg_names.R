#' Match Package Names
#'
#' @param string_og Text string (script) with package load calls.
#'
#' @return A tibble with the package load calls and package names.
#'
#' @examples
#' test_string <- c("library(boot)\nrequire(Matrix)")
#' match_pkg_names(test_string)
#' @export
match_pkg_names <- function(string_og) {
  if (!is.character(string_og)) stop("input must be a character string")
  tb_names <- c("call", "package_name")
  uncommented_str <- stringr::str_match_all(string_og, stringr::regex("^(?:(?!#).)*$", multiline = TRUE))
  uncommented_str <- paste0(collapse = "\n", purrr::flatten_chr(uncommented_str))
  lib_matches <- stringr::str_match_all(uncommented_str, stringr::regex("^\\s*?library\\((.*)\\)", multiline = TRUE))
  colnames(lib_matches[[1]]) <- tb_names
  lib_tb <- tibble::as_tibble(lib_matches[[1]])
  req_matches <- stringr::str_match_all(uncommented_str, stringr::regex("^require\\((.*)\\)", multiline = TRUE))
  colnames(req_matches[[1]]) <- tb_names
  req_tb <- tibble::as_tibble(req_matches[[1]])
  # warn if there are line breaks in p_load calls
  if (stringr::str_detect(string_og, stringr::regex("^p_load\\(.*\n",
    multiline = TRUE
  ))) {
    warning("Remove line breaks from 'pacman' package calls to avoid missing annotations.")
  }
  pac_matches <- stringr::str_match_all(string_og, stringr::regex("^p_load\\((.*)\\)",
    multiline = TRUE
  ))
  pacns_matches <- stringr::str_match_all(string_og, stringr::regex("^pacman::p_load\\((.*)\\)",
    multiline = TRUE
  ))
  colnames(pac_matches[[1]]) <- tb_names
  colnames(pacns_matches[[1]]) <- tb_names
  pac_tb <- tibble::as_tibble(pac_matches[[1]])
  pac_tb_long <- tidyr::separate_rows(pac_tb, package_name)
  pacns_tb <- tibble::as_tibble(pacns_matches[[1]])
  pacns_tb_long <- tidyr::separate_rows(pacns_tb, package_name)
  libreqpacout <- dplyr::bind_rows(lib_tb, req_tb, pac_tb_long, pacns_tb_long)
  dplyr::mutate(libreqpacout, pkgname_clean = stringr::str_remove_all(package_name, "\"|'"))
}
