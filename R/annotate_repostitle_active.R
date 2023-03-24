#' Annotate titles and repositories in active file
#'
#' Annotates package load calls with package titles and repository details in
#' the active .R file
#'
#' @return No return value, wraps [annotate_repostitle()] for access via Addin
#'
#' @export
annotate_repostitle_active <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  if (context[1]$id == "#console") {
    stop("Focus (blinking cursor) is not on an open R file")
  }
  contents_parsed <- paste0(context$contents, sep = "\n", collapse = "")
  out <- annotater::annotate_repostitle(contents_parsed)
  outlines <- stringi::stri_split_lines1(out)

  rstudioapi::modifyRange(
    c(1, 1, length(context$contents) + 1, 1),
    paste0(append(outlines, ""), collapse = "\n"),
    id = context$id
  )
}
