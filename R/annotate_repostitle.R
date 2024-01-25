#' Annotate package titles and repository sources
#'
#' @param string_og Text string (script) with package load calls.
#'
#' @return Text string with package titles and package repository source
#'   annotations. Will make note of packages not currently installed. Lines with
#'   existing comments or annotations are ignored by the regular expression that
#'   matches package names. Also ignores base packages.
#'
#' @details Some annotations may be long, check for possible line breaks
#'   introduced into your script.
#' @examples
#' test_string <- c("library(boot)\nrequire(lattice)")
#' annotate_repostitle(test_string)
#' @importFrom rlang .data
#' @export
annotate_repostitle <- function(string_og) {
  out_tb <- match_pkg_names(string_og)
  if (nrow(out_tb) == 0) cat("no matching library load calls")
  if (nrow(out_tb) == 0) {
    return(string_og)
  }
  out_tb <- tibble::rowid_to_column(out_tb)
  # get pkg titles
  out_tb$pck_title <- purrr::map_chr(out_tb$pkgname_clean, utils::packageDescription, fields = "Title")
  out_tb$pck_title <- stringi::stri_replace_na(out_tb$pck_title, "not installed on this machine")
  # new title variable
  out_tb$title <- paste(out_tb$pck_title)
  # repo descriptions
  pck_descs <- purrr::map(out_tb$pkgname_clean, utils::packageDescription,
    fields = c("Repository", "RemoteType", "biocViews")
  )
  pck_descs <- purrr::map(pck_descs, as.list)
  pck_descs <- tidyr::unnest(tibble::enframe(purrr::map(pck_descs, purrr::flatten_chr)), cols = c("value"))
  pck_descs <- dplyr::rename(pck_descs, rowid = 1, repo = 2)
  pck_descs <- dplyr::left_join(out_tb, pck_descs, by = "rowid")
  pck_descs <- dplyr::mutate(pck_descs, repo = ifelse(stringr::str_detect(.data$repo, ","), "Bioconductor", .data$repo))
  pck_descs <- dplyr::add_count(pck_descs, .data$package_name)
  pck_descs <- stats::na.omit(dplyr::mutate(pck_descs, repo = dplyr::if_else(.data$n == 1, "none", .data$repo)))
  pck_descs <- dplyr::mutate(pck_descs, user_repo = dplyr::case_when(
    .data$repo ==
      "CRAN" ~ "CRAN",
    .data$repo == "Bioconductor" ~ "Bioconductor",
    .data$repo == "RSPM" ~ "Posit RPSM",
    .data$repo == "none" ~ "not installed on this machine",
    str_detect(.data$repo,"universe")~.data$repo,# for Runiverse pkgs
    TRUE ~ repo_details(.data$pkgname_clean)
  ), annotation = dplyr::case_when(stringr::str_detect(
    user_repo,
    "/(?!.+r-universe.+)"
  ) ~ paste0("[", .data$repo, "::", user_repo, "]"), TRUE ~ user_repo))
  pck_descs <- dplyr::mutate(pck_descs, version = pkg_version(gsub("[\'\"]", "", .data$package_name)))

  # build annotations
  if (all(!grepl("p_load", pck_descs$call))) { # no pacman calls
    pck_descs$annotated <- paste0(pck_descs$call, " # ", pck_descs$title, ", ", pck_descs$annotation, " v", pck_descs$version)

    return(
      stringi::stri_replace_all_fixed(
        str = string_og, pattern = pck_descs$call,
        replacement = pck_descs$annotated, vectorize_all = FALSE
      )
    )
  }

  if (all(grepl("p_load", pck_descs$call))) { # only pacman calls
    pacld <- pck_descs[which(stringr::str_detect(out_tb$call, ".+load\\(")), ]
    pacld$pkgnamesep <- paste0(pacld$package_name, ", ")
    pacld <- dplyr::mutate(dplyr::group_by(pacld, call), pkgnamesep = ifelse(dplyr::row_number() == dplyr::n(), gsub(",", "", .data$pkgnamesep), .data$pkgnamesep))
    pacld$annotatedpac <- paste0(pacld$pkgnamesep, "# ", pacld$title, " ", pacld$annotation, " v", pacld$version)
    pacld <- dplyr::summarize(dplyr::group_by(pacld, call), pkgs = paste(.data$annotatedpac, collapse = "\n"))
    pacld$ldcalls <- stringr::str_extract(pacld$call, ".+\\(")
    pacld <- dplyr::mutate(pacld, annotpac = paste(.data$ldcalls, .data$pkgs, ")", sep = "\n "))
    return(
      stringi::stri_replace_all_fixed(
        str = string_og, pattern = pacld$call,
        replacement = pacld$annotpac, vectorize_all = FALSE
      )
    )
  }

  if (any(grepl("p_load", pck_descs$call)) & any(grepl("libr|req", out_tb$call))) { # pacman and base calls
    pacld <- pck_descs[which(stringr::str_detect(out_tb$call, ".+load\\(")), ]
    pacld$pkgnamesep <- paste0(pacld$package_name, ", ")
    pacld <- dplyr::mutate(dplyr::group_by(pacld, call), pkgnamesep = ifelse(dplyr::row_number() == dplyr::n(), gsub(",", "", .data$pkgnamesep), .data$pkgnamesep))
    pacld$annotatedpac <- paste0(pacld$pkgnamesep, "# ", pacld$title, " ", pacld$annotation, " v", pacld$version)
    pacld <- dplyr::summarize(dplyr::group_by(pacld, call), pkgs = paste(.data$annotatedpac, collapse = "\n "))
    pacld$ldcalls <- stringr::str_extract(pacld$call, ".+\\(")
    pacld <- dplyr::mutate(pacld, annotpac = paste(.data$ldcalls, .data$pkgs, ")", sep = "\n "))
    string_og <- stringi::stri_replace_all_fixed(
      str = string_og, pattern = pacld$call,
      replacement = pacld$annotpac, vectorize_all = FALSE
    )
    pck_descs <- pck_descs[!stringr::str_detect(out_tb$call, ".+load\\("), ]
    pck_descs$annotated <- paste0(pck_descs$call, " # ", pck_descs$title, " ", pck_descs$annotation, " v", pck_descs$version)

    return(
      stringi::stri_replace_all_fixed(
        str = string_og, pattern = out_tb$call,
        replacement = pck_descs$annotated, vectorize_all = FALSE
      )
    )
  }
}
