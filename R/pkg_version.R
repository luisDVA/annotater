#' Retrieve Package Version
#'
#' Internal helper function.
#' @param pkgs_col Package name.
#'
#' @return A character vector with the package version.
#'
pkg_version <- function(pkgs_col) {
  pkgVers <- purrr::map(pkgs_col, utils::packageDescription, fields = "Version")
  purrr::flatten_chr(purrr::map(pkgVers, paste0, collapse = "/"))
}
