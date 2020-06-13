#' Annotate Package Calls
#'
#' @param string_og Text string (script) with package load calls.
#' @param pkg_field Field from package description to retrieve, defaults to
#'   "Title"
#'
#' @return Text string with package Title annotations. Will make note of
#'   packages not currently installed.
#' #'
#' @examples
#' test_string <- c("library(boot)\nrequire(tools)")
#' annotate_pkg_calls(test_string)
#' @export
annotate_pkg_calls <- function(string_og, pkg_field = "Title") {
  out_tb <- match_pkg_names(string_og)
  if (nrow(out_tb) == 0) cat("no matching library load calls")
  if (nrow(out_tb) == 0) {
    return(string_og)
  }
  # get pkg titles
  out_tb$pck_desc <- purrr::map_chr(out_tb$pkgname_clean, utils::packageDescription, fields = pkg_field)
  out_tb$pck_desc <- stringi::stri_replace_na(out_tb$pck_desc, "not installed on this machine")
  # new title variable
  out_tb$annotated <- paste(out_tb$call, "#", out_tb$pck_desc)
  stringi::stri_replace_all_fixed(
    str = string_og, pattern = out_tb$call,
    replacement = out_tb$annotated, vectorize_all = FALSE
  )
}
