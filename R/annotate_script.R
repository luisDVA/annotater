#' Annotate Script
#'
#' @param script_file Path to an R script.
#' @param pkg_field Field from package description to retrieve, defaults to
#'   "Title".
#'
#' @return Prints the annotated script to the console.
#'
#' @export
annotate_script <- function(script_file, pkg_field = "Title") {
  strlines <- readr::read_file(script_file)
  annttd <- annotate_pkg_calls(strlines, pkg_field)
  writeLines(annttd)
}
