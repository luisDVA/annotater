#' Annotate repositories in active file
#'
#' Annotates package load calls with repository details in the active .R file
#'
#' @return No return value, wraps [annotate_repo_source()] for access via Addin
#'
#' @export
annotate_repos_active_file <- function() {
  context <- rstudioapi::getSourceEditorContext()
  contents_parsed <- paste0(context$contents, sep = "\n", collapse = "")
  out <- annotater::annotate_repo_source(contents_parsed)
  outlines <- stringi::stri_split_lines1(out)

  rstudioapi::modifyRange(
    c(1, 1, length(context$contents) + 1, 1),
    paste0(append(outlines, ""), collapse = "\n"),
    id = context$id
  )
}
