#' Expand metapackages in Active File
#'
#' Replaces metapackage load calls in the active .R file with multiple separate
#' calls to its core packages.
#'
#' @return No return value, wraps [expand_metapackages()] for access via Addin
#'
#' @export
expand_metapackages_active_file <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  if (context[1]$id == "#console") {
    stop("Focus (blinking cursor) is not on an open R file")
  }
  contents_parsed <- paste0(context$contents, sep = "\n", collapse = "")
  out <- annotater::expand_metapackages(contents_parsed)
  outlines <- stringi::stri_split_lines1(out)

  rstudioapi::modifyRange(
    c(1, 1, length(context$contents) + 1, 1),
    paste0(append(outlines, ""), collapse = "\n"),
    id = context$id
  )
}
