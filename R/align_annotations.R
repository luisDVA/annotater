#' Vertical alignment of package annotations
#'
#' Internal helper function, based on `unheadr::regex_valign``
#'
#' @param annot_string Character vector with annotated package calls.
#' @param regex_ai Custom regular expression to match lines with package annotations.
#' @param sep_str Whitespace separator.
#' @return A character vector with vertically aligned package calls.
#'
align_annotations <- function(annot_string,
  regex_ai = "(?!\\))(?!\\s)(?=\\#\\sCRAN\\sv|\\#\\sBiocon|\\#\\snot\\sinstal|\\#\\s\\[)",
  sep_str = "") {
  if (!is.character(annot_string)) {
    stop("input 'stringvec' must be a character vector")
  }
  stringvec <- unlist(strsplit(annot_string, "\n"))
  match_position <- regexpr(regex_ai, stringvec,
    perl = TRUE,
    ignore.case = TRUE
  )
  padding <- function(x) {
    padspacing <- paste(rep.int(" ", max(x)), collapse = "")
    substring(padspacing, 0L, x)
  }
  nspaces <- padding(max(match_position) - match_position)
  for (i in seq_along(stringvec)) {
    stringvec[i] <- sub(regex_ai, nspaces[i], stringvec[i],
      perl = TRUE, ignore.case = TRUE
    )
  }
  lines_out <- sub(regex_ai, sep_str, stringvec, perl = TRUE, ignore.case = TRUE)
  paste0(lines_out, collapse = "\n")
}
