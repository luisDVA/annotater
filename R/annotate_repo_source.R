#' Annotate Repo Source
#'
#' @param string_og text string (script) with package load calls
#'
#' @return text string with package repository source annotations. Will make note of
#'   packages not currently installed.
#'
#' @examples
#' #' test_string <- c("library(annotater)\nrequire(Matrix)")
#' annotate_repo_source(test_string)
#' @export
annotate_repo_source <- function(string_og) {
  out_tb <- match_pckg_names(string_og)
  out_tb <- tibble::rowid_to_column(out_tb)
  pck_descs <- purrr::map(out_tb$package_name, utils::packageDescription,
                          fields = c("Repository", "RemoteType")
  )
  pck_descs <- purrr::map(pck_descs, as.list)
  pck_descs <- tidyr::unnest(tibble::enframe(purrr::map(pck_descs, purrr::flatten_chr), name = "rowid", value = "repo"))
  pck_descs <- dplyr::left_join(out_tb, pck_descs)
  pck_descs <- dplyr::add_count(pck_descs, package_name)
  pck_descs <- na.omit(dplyr::mutate(pck_descs, repo = dplyr::if_else(n == 1, "none", repo)))
  pck_descs <- dplyr::mutate(pck_descs,
                             user_repo =
                               dplyr::case_when(
                                 repo == "CRAN" ~ "CRAN",
                                 repo == "none" ~ "not installed on this machine",
                                 TRUE ~ repo_details(package_name)
                               ),
                             annotation = dplyr::case_when(
                               stringr::str_detect(user_repo, "/") ~ paste0(repo, "::", user_repo),
                               TRUE ~ user_repo
                             )
  )
  pck_descs$annotated <- paste(pck_descs$call, "#", pck_descs$annotation)
  stringi::stri_replace_all_fixed(
    str = string_og, pattern = pck_descs$call,
    replacement = pck_descs$annotated, vectorize_all = FALSE
  )
}
