#' Annotate Function Calls
#'
#' @param string_og text string (script) with package load calls
#'
#' @return text string with function call annotations. Will make note of
#'   packages not currently installed. Lines with existing comments or
#'   annotations are ignored by the regular expression that matches package
#'   names.
#'
#' @examples
#' test_string <- c("library(boot)\nrequire(lattice)\ncanonical.theme()")
#' cat(annotate_fun_calls(test_string))
#'
#' @importFrom dplyr `%>%` filter pull
#' @importFrom purrr map
#' @importFrom stringi stri_replace_all_fixed
#' @importFrom tibble rowid_to_column
#'
#' @export
#'
annotate_fun_calls <- function(string_og) {
  out_tb <- match_pkg_names(string_og) # list, ordered, packages loading.
  if (nrow(out_tb) == 0) {
    # if no library or require calls, then return same string.
    cat("no matching library load calls")
    return(string_og)
  }
  fun_calls <- get_function_calls(string_og) # get script's function calls.
  # Removing quotes from package loading name!
  out_tb$annotation <- unlist(map(gsub("\"|'", "", out_tb$package_name), ~ {
    pkg_funs <- '"Package currently not installed"' # default annotation.
    if (
      suppressMessages(suppressWarnings(require(.x, character.only = TRUE)))
    ) {
      # if the package could be loaded, then get which are the called functions
      # that are exported by this package.
      pkg_funs <- fun_calls[fun_calls %in% getNamespaceExports(asNamespace(.x))]
    }
    if (length(pkg_funs) == 0) {
      # notify which packages do not have functions being used.
      pkg_funs <- '"No used functions found"'
    }
    paste(pkg_funs, collapse = " ") # return a final string.
  }))
  # the annotation is going to be the package call, plus a comment with its
  # function calls.
  out_tb$annotated <- paste0(out_tb$call, " # ", out_tb$annotation)
  # final line formatting.
  align_annotations(stringi::stri_replace_all_fixed(
    str = string_og, pattern = out_tb$call,
    replacement = out_tb$annotated, vectorize_all = FALSE
  ))
}

# Returns function calls in a code (as string)
#
# @param string_og text string (script)
#
# @return text string with all the function calls found.
#
# @examples
# test_string <- c("library(boot)\nrequire(lattice)\ncanonical.theme()")
# get_function_calls(test_string)
#
get_function_calls <- function(string_og) {
  token <- text <- NULL
  base::parse(text = string_og, keep.source = TRUE) %>% # parse text.
    utils::getParseData(includeText = TRUE) %>% # format as table.
    filter(token %in% c( # keep only tokens of interest.
      "SYMBOL_FUNCTION_CALL",
      "SPECIAL" # dplyr pipes appear as SPECIAL .
    )) %>%
    pull(text) %>% # retrieve only the used text.
    unique() # remove repeated.
}
