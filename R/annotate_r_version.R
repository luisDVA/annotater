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
  session_info <- sessionInfo()
  session_info <- paste0(
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
  insert_code_position <- c(1, 1)
  # It will annotate after the first "```{r",  "```{r," or "```{r ".
  markdown_first_r_chunk <- grep("^```\\{r(}| |,)", context$contents)
  if (length(markdown_first_r_chunk) > 0) {
    # If we found a "```", it means this is not a valid R file, so we consider it's a markdown.
    insert_code_position <- markdown_first_r_chunk[[1]] + 1
    # If this is a quarto file, we should skip the lines starting with "#|" after the "```".
    while (insert_code_position <= length(context$contents) &&
           grepl("^#| ", context$contents[[insert_code_position]])) {
      insert_code_position <- insert_code_position + 1
    }
    insert_code_position <- c(insert_code_position, 1)
  }
  insertText(insert_code_position, paste0(session_info, "# \n"), id = context$id)
}
