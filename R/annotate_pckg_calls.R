#' Annotate package calls
#'
#' @param string_og text string (script) with package load calls
#' @param pckg_field field from package description to retrieve, defaults to
#'   "Title"
#'
#' @return text string with package Title annotations
#' #'
#' @examples
#' test_string <- c("library(boot)\nrequire(Matrix)")
#' annotate_pckg_calls(test_string)
#' @export
annotate_pckg_calls <- function(string_og, pckg_field = "Title") {
  out_tb <- match_pckg_names(string_og)
  # get pckg titles
  out_tb$pck_desc <- purrr::map_chr(out_tb$package_name, packageDescription, fields = pckg_field)
  # new title variable
  out_tb$annotated <- paste(out_tb$call, "#", out_tb$pck_desc)
  stringi::stri_replace_all_fixed(
    str = string_og, pattern = out_tb$call,
    replacement = out_tb$annotated, vectorize_all = FALSE
  )
}
