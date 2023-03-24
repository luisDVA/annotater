#' Annotate package datasets
#'
#' @param string_og text string (script) with package load calls
#'
#' @return text string with annotations for datasets loaded from packages
#'   explicitly, lazily, or through name-spacing. Will make note of packages not
#'   currently installed. Lines with existing comments or annotations are
#'   ignored.
#'
#' @export
#'
#' @examples
#' test_string <- c("library(tidyr)\nlibrary(purrr)\ndata(construction)\nsummary(fish_encounters)")
#' annotate_pkg_datasets(test_string)
#'
annotate_pkg_datasets <- function(string_og) {
  out_tb <- match_pkg_names(string_og)
  pkgsvec <- out_tb$pkgname_clean

  if (nrow(out_tb) == 0) {
    # if no library or require calls, then return same string.
    cat("no matching library load calls")
    return(string_og)
  }

  # query packages for datasets
  pkgdatasets <- get_pkg_datasets(pkgsvec)


  # get datasets from each package
  alltext <- base::parse(text = string_og, keep.source = TRUE)  #%>% # parse text.
  parsed_text <-   utils::getParseData(alltext,includeText = TRUE) #%>% # format as table.
  filtered_text <-   dplyr::filter(parsed_text,!token %in% c( # keep only tokens of interest.
    "COMMENT",
    "SYMBOL_FUNCTION_CALL",
    "SPECIAL" # dplyr pipes appear as SPECIAL .
  ))
  text_expr <- dplyr::filter(filtered_text,token=="expr")
  expr_df <- dplyr::distinct(dplyr::select(text_expr,text))
  expr_df <- dplyr::mutate(expr_df,text=str_remove_all(text,'^[\'\"]|[\'\"]$'))

  # build annotations
  datmatches <- dplyr::rename(dplyr::left_join(pkgdatasets,expr_df,by=c("dataset"="text"),keep=TRUE),matched=text)
  datmatches <- dplyr::filter(datmatches,!is.na(matched))
  datmatches$matched <- stringr::str_remove(datmatches$matched,".*::")
  datmatches <- dplyr::distinct(datmatches,source_pkg,matched)
  datmatches <- dplyr::summarize(dplyr::group_by(datmatches,source_pkg),loaded_datasets=paste(matched, collapse = " "))
  out_tb <- dplyr::left_join(out_tb,datmatches,by=c("pkgname_clean"="source_pkg"))
  out_tb$loaded_datasets <- tidyr::replace_na(out_tb$loaded_datasets,'No loaded datasets found')
  out_tb$annotated <- paste0(out_tb$call, " # ", out_tb$loaded_datasets)

  # annotate the script text
  align_annotations(
    stringi::stri_replace_all_fixed(
      str = string_og, pattern = out_tb$call,
      replacement = out_tb$annotated, vectorize_all = FALSE
    ))
}

#' Query data from packages
#'
#' @param pkgvec Vector of package names
#'
#' @return A data frame with all the bundled data from the specified packages.
#'
#'
#' @examples
#' get_pkg_datasets(c("dplyr","stringr"))
#'
get_pkg_datasets <- function(pkgvec){
  source_pkg <- data(package=pkgvec)$results[,1]
  dataset_name <- data(package=pkgvec)$results[,3]
  dataset_name <- stringr::str_extract(dataset_name,"([^\\s]+)")
  pkgdatasets <- dplyr::tibble(source_pkg,dataset_name)
  pkgdatasets$namespaced <- paste0(pkgdatasets$source_pkg,"::",pkgdatasets$dataset_name)
  tidyr::pivot_longer(pkgdatasets,-source_pkg,names_to = "load_type",values_to = "dataset")
}

