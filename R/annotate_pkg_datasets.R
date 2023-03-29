#' Annotate package datasets
#'
#' @param string_og text string (script) with package load calls
#'
#' @return text string with annotations for datasets loaded from packages
#'   explicitly, lazily, or through name-spacing. Will make note of packages not
#'   currently installed. Lines with existing comments or annotations are
#'   ignored.
#'
#' @details
#' No support for \pkg{pacman} package loading at this time.
#'
#' @examples
#' test_string <- c("library(tidyr)\nlibrary(purrr)\ndata(construction)\nsummary(fish_encounters)")
#' annotate_pkg_datasets(test_string)
#'
#'@importFrom rlang .data
#'
#'@export
annotate_pkg_datasets <- function(string_og) {
  out_tb <- match_pkg_names(string_og)
  if (nrow(out_tb) == 0) cat("no matching library load calls")
  if (nrow(out_tb) == 0) {
    return(string_og)
  }
  pkgsvec <- out_tb$pkgname_clean
  # installation status
  checked <- check_pkgs(pkgsvec)
  is_installed_pkg <- NULL
  inst_pkgs <- subset(checked, is_installed_pkg == TRUE)$pkgvec
  # query packages for datasets
  pkgdatasets <- get_pkg_datasets(pkgsvec)

  # get datasets from each package
  alltext <- base::parse(text = string_og, keep.source = TRUE) # parse text.
  parsed_text <- utils::getParseData(alltext, includeText = TRUE) # format as table.
  filtered_text <- dplyr::filter(parsed_text, !.data$token %in% c( # keep only tokens of interest.
    "COMMENT",
    "SYMBOL_FUNCTION_CALL",
    "SPECIAL" # dplyr pipes appear as SPECIAL .
  ))
  text_expr <- dplyr::filter(filtered_text, .data$token == "expr")
  expr_df <- dplyr::distinct(dplyr::select(text_expr, .data$text))
  expr_df <- dplyr::mutate(expr_df, text = stringr::str_remove_all(.data$text, '^[\'\"]|[\'\"]$'))

  # build annotations
  datmatches <- dplyr::rename(dplyr::left_join(pkgdatasets, expr_df, by = c("dataset" = "text"), keep = TRUE), matched = .data$text)
  datmatches <- dplyr::filter(datmatches, !is.na(.data$matched))
  datmatches$matched <- stringr::str_remove(datmatches$matched, ".*::")
  datmatches <- dplyr::distinct(datmatches, .data$source_pkg, .data$matched)
  datmatches <- dplyr::summarize(dplyr::group_by(datmatches, .data$source_pkg), loaded_datasets = paste(.data$matched, collapse = " "))
  out_tb <- dplyr::left_join(out_tb, datmatches, by = c("pkgname_clean" = "source_pkg"))
  out_tb <- dplyr::left_join(out_tb, checked, by = c("pkgname_clean" = "pkgvec"))
  # update for installed w/no data or not installed
  out_tb <-
  dplyr::mutate(out_tb, loaded_datasets = dplyr::case_when(
    (is.na(loaded_datasets) & .data$is_installed_pkg == TRUE) ~ "No loaded datasets found",
    (is.na(loaded_datasets) & .data$is_installed_pkg == FALSE) ~ "Not installed on this machine",
    TRUE ~ loaded_datasets
  ))
  out_tb$annotated <- paste0(out_tb$call, " # ", out_tb$loaded_datasets)
  # annotate the script text
  align_annotations(
    stringi::stri_replace_all_fixed(
      str = string_og, pattern = out_tb$call,
      replacement = out_tb$annotated, vectorize_all = FALSE
    )
  )
}

#' Query data from packages
#'
#' @param inst_pkgs Vector of package names
#'
#' @return A data frame with all the bundled data from the specified packages.
#'
#'
#'
get_pkg_datasets <- function(inst_pkgs) {

  source_pkg <- utils::data(package = inst_pkgs)$results[, 1]
  dataset_name <- utils::data(package = inst_pkgs)$results[, 3]
  dataset_name <- stringr::str_extract(dataset_name, "([^\\s]+)")
  pkgdatasets <- dplyr::tibble(source_pkg, dataset_name)
  pkgdatasets$namespaced <- paste0(pkgdatasets$source_pkg, "::", pkgdatasets$dataset_name)

  tidyr::pivot_longer(pkgdatasets, -source_pkg, names_to = "load_type", values_to = "dataset")
}

#' Check if packages are installed
#'
#' @param pkgvec Vector of package names
#'
#' @return A data frame with installation status for packages in the input text.
#'
#'
check_pkgs <- function(pkgvec) {
  is_installed_pkg <- NULL
  installedpkgs <- utils::installed.packages()[, 1]
  package_check <- vapply(pkgvec, function(x) x %in% installedpkgs, FUN.VALUE = logical(1))
  data.frame(pkgvec, is_installed_pkg = package_check)
}
