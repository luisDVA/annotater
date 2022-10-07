#' Expand metapackages
#'
#' @param string_og text string (script) with package load calls
#'
#' @return Text string with metapackage load calls replaced by multiple separate
#'   calls to the core packages that make up the metapackage. Core packages will
#'   be fenced in four commenting symbols and the order follows the attachment
#'   order from each metapackage. Will make note of metapackages not currently
#'   installed.
#'
#' @examples
#' test_string <- c("library()\nlibrary(tidyverse)")
#'
#' @importFrom stringr str_detect
#' @importFrom rlang .data
#'
#' @export
#'
expand_metapackages <- function(string_og){
  supported_metapackages <- c("tidyverse","tidymodels","easystats")
  # metapackage components as of October 6 2022

  # tidyverse v1.3.2
  tidyverse_core <- c(
    "ggplot2", "tibble", "tidyr",
    "readr", "purrr", "dplyr",
    "stringr", "forcats","lubridate"
  )

  # tidymodels v1.0.0
  tidymodels_core <- c(
    "broom", "dials", "dplyr", "ggplot2", "infer",
    "modeldata", "parsnip", "purrr", "recipes", "rsample", "tibble",
    "tidyr", "tune", "workflows", "workflowsets", "yardstick"
  )

  # easystats 0.5.2
  easystats_core <- c(
    "insight", "datawizard", "bayestestR", "performance", "parameters", "effectsize",
    "modelbased", "correlation", "see", "report"
  )
  out_tb <- match_pkg_names(string_og) # list, ordered, packages loading
  if (nrow(out_tb) == 0) {
    # if no library or require calls, then return same string.
    cat("no matching library load calls")
    return(string_og)
  }

  metapkgIndices <- apply(outer(out_tb$pkgname_clean,supported_metapackages, stringr::str_detect), 1, any)
  meta_out_tb <- out_tb[metapkgIndices,]

  if (nrow(meta_out_tb) == 0) {
    # if no metapackages detected, then return same string.
    cat("no metapackages")
    return(string_og)
  }

  # check if installed
    meta_out_tb$installed <-  purrr::map_lgl(meta_out_tb$pkgname_clean,
    function(x) {suppressWarnings(nzchar(system.file(package = paste(x))))})

  meta_out_tb$load_call <- stringr::str_extract(meta_out_tb$call,"^[ \t]*.+(?=\\()")

  meta_out_tb$expand_list <-
    ifelse(meta_out_tb$pkgname_clean=="tidymodels"&meta_out_tb$installed==TRUE,
           paste(tidymodels_core,collapse = ","),NA)
  meta_out_tb$expand_list <-
    ifelse(meta_out_tb$pkgname_clean=="tidyverse"&meta_out_tb$installed==TRUE,
           paste(tidyverse_core,collapse = ","),meta_out_tb$expand_list)
  meta_out_tb$expand_list <-
    ifelse(meta_out_tb$pkgname_clean=="easystats"&meta_out_tb$installed==TRUE,
           paste(easystats_core,collapse = ","),meta_out_tb$expand_list)
  meta_out_tb$expand_list <-
    ifelse(is.na(meta_out_tb$expand_list)&meta_out_tb$installed==FALSE,
           meta_out_tb$pkgname_clean,meta_out_tb$expand_list)

  # build replacement load calls
  meta_out_tb <-  tidyr::separate_rows(meta_out_tb,.data$expand_list)
  meta_out_tb$replacement_call <- paste0(meta_out_tb$load_call,"(",meta_out_tb$expand_list,")")
  meta_out_tb$replacement_call <- ifelse(meta_out_tb$installed==FALSE,paste(meta_out_tb$replacement_call,"# not installed"),meta_out_tb$replacement_call)
  meta_out_tb <- dplyr::summarize(dplyr::group_by(meta_out_tb,call),replacement_call=paste0(.data$replacement_call,collapse = "\n"))
  meta_out_tb$replacement_call <- ifelse(stringr::str_detect(meta_out_tb$replacement_call,"not installed"),
                                               meta_out_tb$replacement_call,paste0("####\n",meta_out_tb$replacement_call,"\n####"))

stringi::stri_replace_all_fixed(
    str = string_og, pattern = meta_out_tb$call,
    replacement = meta_out_tb$replacement_call, vectorize_all = FALSE)
}

