#' Annotate active file
#'
#' Annotates package load calls in the active .R file
#'
#' @export
annotate_active_file <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  contents_parsed <- paste0(context$contents, sep = "\n", collapse = "")
  out <- annotater::annotate_pckg_calls(contents_parsed)
  outlines <- stringi::stri_split_lines1(out)

  rstudioapi::modifyRange(
    c(1, 1, length(context$contents) + 1, 1),
    paste0(append(outlines, ""), collapse = "\n"),
    id = context$id
  )
}
