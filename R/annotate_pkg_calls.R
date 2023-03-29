#' Annotate package calls
#'
#' @param string_og Text string (script) with package load calls.
#' @param pkg_field Field from package description to retrieve, defaults to
#'   "Title"
#'
#' @return Text string with package Title annotations. Will make note of
#'   packages not currently installed.
#'
#' @examples
#' test_string <- c("library(boot)\nrequire(tools)")
#' annotate_pkg_calls(test_string)
#' @importFrom rlang .data
#' @export
annotate_pkg_calls <- function(string_og, pkg_field = "Title") {
  out_tb <- match_pkg_names(string_og)
  if (nrow(out_tb) == 0) cat("no matching library load calls")
  if (nrow(out_tb) == 0) {
    return(string_og)
  }
  # get pkg titles
  out_tb$pck_desc <- purrr::map_chr(out_tb$pkgname_clean, utils::packageDescription, fields = pkg_field)
  out_tb$pck_desc <- stringi::stri_replace_na(out_tb$pck_desc, "not installed on this machine")

  # build annotation
  if (all(!grepl("p_load", out_tb$call))) { # no pacman calls
    out_tb$annotated <- paste(out_tb$call, "#", out_tb$pck_desc)

    return(stringi::stri_replace_all_fixed(
      str = string_og, pattern = out_tb$call,
      replacement = out_tb$annotated, vectorize_all = FALSE
    ))
  }

  if (all(grepl("p_load", out_tb$call))) { # only pacman calls
    pacld <- out_tb[stringr::str_detect(out_tb$call, ".+load\\("), ]
    pacld$pkgnamesep <- paste0(pacld$package_name,",")
    pacld <- dplyr::mutate(dplyr::group_by(pacld,call), pkgnamesep = ifelse(dplyr::row_number()==dplyr::n(), gsub(",","",.data$pkgnamesep), .data$pkgnamesep))
    pacld$annotated <- paste(pacld$pkgnamesep, "#", pacld$pck_desc)
    pacld <- dplyr::summarize(dplyr::group_by(pacld, call), pkgs = paste(.data$annotated, collapse = "\n"))
    pacld$ldcalls <- stringr::str_extract(pacld$call, ".+\\(")
    pacld <- dplyr::mutate(pacld, annotpac = paste(.data$ldcalls, .data$pkgs, ")", sep = "\n"))
    return(
      stringi::stri_replace_all_fixed(
        str = string_og, pattern = pacld$call,
        replacement = pacld$annotpac, vectorize_all = FALSE
      )
    )
  }

  if (any(grepl("p_load", out_tb$call)) & any(grepl("libr|req", out_tb$call))) { # pacman and base calls
    pacld <- out_tb[stringr::str_detect(out_tb$call, ".+load\\("), ]
    pacld$pkgnamesep <- paste0(pacld$package_name,",")
    pacld <- dplyr::mutate(dplyr::group_by(pacld,call), pkgnamesep = ifelse(dplyr::row_number()==dplyr::n(), gsub(",","",.data$pkgnamesep), .data$pkgnamesep))
    pacld$annotated <- paste(pacld$pkgnamesep, "#", pacld$pck_desc)
    pacld <- dplyr::summarize(dplyr::group_by(pacld, call), pkgs = paste(.data$annotated, collapse = "\n"))
    pacld$ldcalls <- stringr::str_extract(pacld$call, ".+\\(")
    pacld <- dplyr::mutate(pacld, annotpac = paste(.data$ldcalls, .data$pkgs, ")", sep = "\n"))
    string_og <- stringi::stri_replace_all_fixed(
      str = string_og, pattern = pacld$call,
      replacement = pacld$annotpac, vectorize_all = FALSE
    )
    out_tb <- out_tb[!stringr::str_detect(out_tb$call, ".+load\\("), ]
    out_tb$annotated <- paste(out_tb$call, "#", out_tb$pck_desc)
    return(
      stringi::stri_replace_all_fixed(
        str = string_og, pattern = out_tb$call,
        replacement = out_tb$annotated, vectorize_all = FALSE
      )
    )
  }
}
