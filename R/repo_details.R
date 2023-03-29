#' Retrieve repo details
#'
#' Internal helper function.
#' @param pkgs_col Name of variable with the non-CRAN repos.
#'
#' @return A character vector of user names and repository names.
#'
repo_details <- function(pkgs_col) {
  repDets <- suppressWarnings(purrr::map(pkgs_col, utils::packageDescription, fields = c("RemoteUsername", "RemoteRepo")))
  purrr::flatten_chr(purrr::map(repDets, paste0, collapse = "/"))
}
