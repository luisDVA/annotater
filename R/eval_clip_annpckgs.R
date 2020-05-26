#' Annonate Clipboard Content
#'
#' Evaluates and annotates clipboard content.
#'
#' @return prints annotated clipboard content to the console
#'
#' @export
eval_clip_annpckgs <- function() {
  clip_source <- clipr::read_clip()
  clip_parsed <- paste0(clip_source, sep = "\n", collapse = "")

  cat(annotate_pckg_calls(clip_parsed))
}
