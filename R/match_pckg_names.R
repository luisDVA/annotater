#' Match Package Names
#'
#' @param string_og text string (script) with package load calls
#'
#' @return a tibble with the package load calls and package names
#' #'
#' @examples
#' test_string <- c("library(boot)\nrequire(Matrix)")
#' match_pckg_names(test_string)
#'
#'@export
match_pckg_names <- function(string_og) {
  tb_names <- c("call", "package_name")
  lib_matches <- stringr::str_match_all(string_og, "library\\((.*)\\)")
  lib_tb <- tibble::as_tibble(lib_matches[[1]], .name_repair = ~tb_names)
  req_matches <- stringr::str_match_all(string_og, "require\\((.*)\\)")
  req_tb <- tibble::as_tibble(req_matches[[1]], .name_repair = ~tb_names)
  dplyr::bind_rows(lib_tb, req_tb)
}
