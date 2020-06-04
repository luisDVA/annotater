#' Annotate Repository Sources
#'
#' @param string_og text string (script) with package load calls
#'
#' @return text string with package repository source annotations. Will make
#'   note of packages not currently installed. Lines with existing comments or
#'   annotations are ignored by the regular expression that matches package
#'   names. Also ignores base packages.
#'
#' @examples
#' test_string <- c("library(boot)\nrequire(lattice)")
#' annotate_repo_source(test_string)
#' @importFrom rlang .data
#' @export
annotate_repo_source <- function(string_og) {
  out_tb <- match_pckg_names(string_og)
  if (nrow(out_tb) == 0) cat("no matching library load calls")
  if (nrow(out_tb) == 0) {
    return(string_og)
  }
  out_tb <- tibble::rowid_to_column(out_tb)
  pck_descs <- purrr::map(out_tb$package_name, utils::packageDescription,
    fields = c("Repository", "RemoteType", "biocViews")
  )
  pck_descs <- purrr::map(pck_descs, as.list)
  pck_descs <- tidyr::unnest(tibble::enframe(purrr::map(pck_descs, purrr::flatten_chr)), cols = c(.data$value))
  pck_descs <- dplyr::rename(pck_descs, rowid = 1, repo = 2)
  pck_descs <- dplyr::left_join(out_tb, pck_descs, by = "rowid")
  pck_descs <- dplyr::mutate(pck_descs, repo = ifelse(stringr::str_detect(.data$repo, ","), "Bioconductor", .data$repo))
  pck_descs <- dplyr::add_count(pck_descs, .data$package_name)
  pck_descs <- stats::na.omit(dplyr::mutate(pck_descs, repo = dplyr::if_else(.data$n == 1, "none", .data$repo)))
  pck_descs <- dplyr::mutate(pck_descs, user_repo = dplyr::case_when(
    .data$repo ==
      "CRAN" ~ "CRAN",
    .data$repo == "Bioconductor" ~ "Bioconductor",
    .data$repo == "none" ~ "not installed on this machine",
    TRUE ~ repo_details(.data$package_name)
  ), annotation = dplyr::case_when(stringr::str_detect(
    user_repo,
    "/"
  ) ~ paste0("[", .data$repo, "::", user_repo, "]"), TRUE ~ user_repo))
  pck_descs <- dplyr::mutate(pck_descs, version = pkg_version(.data$package_name))
  pck_descs$annotated <- paste0(pck_descs$call, " # ", pck_descs$annotation, " v", pck_descs$version)
  align_annotations(stringi::stri_replace_all_fixed(
    str = string_og, pattern = pck_descs$call,
    replacement = pck_descs$annotated, vectorize_all = FALSE
  ))
}
