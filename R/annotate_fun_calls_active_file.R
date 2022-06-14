#' Annotate Function Calls in Active File
#'
#' Annotates package load calls with the used functions of each package in the
#' active .R file
#'
#' @importFrom rstudioapi getActiveDocumentContext modifyRange
#' @importFrom stringi stri_split_lines1
#' @return No return value, wraps [annotate_fun_calls()] for access via Addin
#'
#' @export
#'
annotate_fun_calls_active_file <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  if (context[1]$id == "#console") {
    stop("Focus (blinking cursor) is not on an open R file")
  }
  contents_parsed <- paste0(context$contents, sep = "\n", collapse = "")
  out <- annotater::annotate_fun_calls(contents_parsed)
  outlines <- stringi::stri_split_lines1(out)

  rstudioapi::modifyRange(
    c(1, 1, length(context$contents) + 1, 1),
    paste0(append(outlines, ""), collapse = "\n"),
    id = context$id
  )
}
