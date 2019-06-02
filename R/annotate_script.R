#' Annotate Script
#'
#' @param script_file path to an R script
#' @param pckg_field field from package description to retrieve, defaults to
#'   "Title"
#'
#' @return currently prints the annotated script to the console
#' #'
#' @examples
#'
#' @export
annotate_script <- function(script_file, pckg_field) {
  strlines <- readr::read_file(script_file)
  annttd <- annotate_pckg_calls(strlines, pckg_field)
  writeLines(annttd)
}
