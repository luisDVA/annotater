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
#' @importFrom rlang .data
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

  # build annotations
  if (all(!grepl("p_load", out_tb$call))) { # no pacman calls
    # Removing quotes from package loading name!
    out_tb$annotation <- unlist(purrr::map(out_tb$pkgname_clean, ~ {
      pkg_funs <- 'not installed on this machine' # default annotation
      if (
        suppressMessages(suppressWarnings(require(.x, character.only = TRUE)))
      ) {
        # if the package could be loaded, then get which are the called functions
        # that are exported by this package.
        pkg_funs <- fun_calls[fun_calls %in% getNamespaceExports(asNamespace(.x))]
      }
      if (length(pkg_funs) == 0) {
        # notify which packages do not have functions being used.
        pkg_funs <- 'No used functions found'
      }
      paste(pkg_funs, collapse = " ") # return a final string.
    }))
    # the annotation is going to be the package call, plus a comment with its
    # function calls.

    out_tb$annotated <- paste0(out_tb$call, " # ", out_tb$annotation)
    # final line formatting.
    return(
      align_annotations(stringi::stri_replace_all_fixed(
        str = string_og, pattern = out_tb$call,
        replacement = out_tb$annotated, vectorize_all = FALSE
      ))
    )
  }

  if (all(grepl("p_load", out_tb$call))) { # only pacman calls
    pacld <- out_tb[stringr::str_detect(out_tb$call, ".+load\\("), ]
    pacld$pkgnamesep <- paste0(pacld$package_name, ",")
    pacld <- dplyr::mutate(dplyr::group_by(pacld, call), pkgnamesep = ifelse(dplyr::row_number() == dplyr::n(), gsub(",", "", .data$pkgnamesep), .data$pkgnamesep))
    pacld$annotation <- unlist(purrr::map(gsub("\"|'", "", pacld$package_name), ~ {
      pkg_funs <- 'not installed on this machine' # default annotation.
      if (
        suppressMessages(suppressWarnings(require(.x, character.only = TRUE)))
      ) {
        # if the package could be loaded, then get which are the called functions
        # that are exported by this package.
        pkg_funs <- fun_calls[fun_calls %in% getNamespaceExports(asNamespace(.x))]
      }
      if (length(pkg_funs) == 0) {
        #  notify which packages do not have functions being used.
        pkg_funs <- 'No used functions found'
      }
      paste(pkg_funs, collapse = " ") # return a final string.
    }))
    pacld$annotated <- paste0(pacld$call, " # ", pacld$annotation)
    pacld$annotatedpac <- paste(pacld$pkgnamesep, "#", pacld$annotation)
    pacld <- dplyr::summarize(dplyr::group_by(pacld, call), pkgs = paste(.data$annotatedpac, collapse = "\n"))
    pacld$ldcalls <- stringr::str_extract(pacld$call, ".+\\(")
    pacld <- dplyr::mutate(pacld, annotpac = paste(.data$ldcalls, .data$pkgs, ")", sep = "\n"))
    return(
      align_annotations(stringi::stri_replace_all_fixed(
        str = string_og, pattern = pacld$call,
        replacement = pacld$annotpac, vectorize_all = FALSE
      ))
    )
  }

  if (any(grepl("p_load", out_tb$call)) & any(grepl("libr|req", out_tb$call))) { # pacman and base calls
    pacld <- out_tb[stringr::str_detect(out_tb$call, ".+load\\("), ]
    pacld$pkgnamesep <- paste0(pacld$package_name, ",")
    pacld <- dplyr::mutate(dplyr::group_by(pacld, call), pkgnamesep = ifelse(dplyr::row_number() == dplyr::n(), gsub(",", "", .data$pkgnamesep), .data$pkgnamesep))
    pacld$annotation <- unlist(purrr::map(gsub("\"|'", "", pacld$package_name), ~ {
      pkg_funs <- 'not installed on this machine' # default annotation.
      if (
        suppressMessages(suppressWarnings(require(.x, character.only = TRUE)))
      ) {
        # if the package could be loaded, then get which are the called functions
        # that are exported by this package.
        pkg_funs <- fun_calls[fun_calls %in% getNamespaceExports(asNamespace(.x))]
      }
      if (length(pkg_funs) == 0) {
        #  notify which packages do not have functions being used.
        pkg_funs <- 'No used functions found'
      }
      paste(pkg_funs, collapse = " ") # return a final string.
    }))
    pacld$annotated <- paste0(pacld$call, " # ", pacld$annotation)
    pacld$annotatedpac <- paste0(pacld$pkgnamesep, " # ", pacld$annotation)
    pacld <- dplyr::summarize(dplyr::group_by(pacld, call), pkgs = paste(.data$annotatedpac, collapse = "\n"))
    pacld$ldcalls <- stringr::str_extract(pacld$call, ".+\\(")
    pacld <- dplyr::mutate(pacld, annotpac = paste(.data$ldcalls, .data$pkgs, ")", sep = "\n"))
    string_og <- stringi::stri_replace_all_fixed(
      str = string_og, pattern = pacld$call,
      replacement = pacld$annotpac, vectorize_all = FALSE
    )
    out_tb <- out_tb[!stringr::str_detect(out_tb$call, ".+load\\("), ]
    out_tb$annotation <- unlist(purrr::map(gsub("\"|'", "", out_tb$package_name), ~ {
      pkg_funs <- 'not installed on this machine' # default annotation.
      if (
        suppressMessages(suppressWarnings(require(.x, character.only = TRUE)))
      ) {
        # if the package could be loaded, then get which are the called functions
        # that are exported by this package.
        pkg_funs <- fun_calls[fun_calls %in% getNamespaceExports(asNamespace(.x))]
      }
      if (length(pkg_funs) == 0) {
        #  notify which packages do not have functions being used.
        pkg_funs <- 'No used functions found'
      }
      paste(pkg_funs, collapse = " ") # return a final string.
    }))
    out_tb$annotated <- paste0(out_tb$call, " # ", out_tb$annotation)
    return(
      align_annotations(
        stringi::stri_replace_all_fixed(
          str = string_og, pattern = out_tb$call,
          replacement = out_tb$annotated, vectorize_all = FALSE
        )
      )
    )
  }
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
