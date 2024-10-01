#' Annotate R Version
#'
#' @importFrom rstudioapi getActiveDocumentContext insertText versionInfo
#' @importFrom utils sessionInfo
#'
annotate_r_version <- function() {
  context <- getActiveDocumentContext()
  if (context[1]$id == "#console") {
    stop("Focus (blinking cursor) is not on an open R file")
  }
  # Get and parse R session info.
  session_info  <- sessionInfo()
  session_info  <- paste0(
    "# ", session_info$R.version$version.string, "\n",
    "# Platform: ", session_info$platform, "\n",
    "# Running under: ", session_info$running, "\n"
  )
  # Get and parse RStudio version info (if installed).
  rstudio_info <- try(versionInfo(), silent = TRUE)
  if (inherits(rstudio_info, "try-error")) {
    rstudio_info <- ""
  } else {
    rstudio_info <- paste0(
      "# Rstudio ", rstudio_info$version, " (", rstudio_info$release_name, ")\n"
    )
    session_info <- paste0(session_info, rstudio_info)
  }
  insertText(c(1, 1), paste0(session_info, "# \n"), id = context$id)
}
