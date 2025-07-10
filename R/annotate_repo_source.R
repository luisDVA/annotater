#' Annotate repository sources
#'
#' @param string_og text string (script) with package load calls
#'
#' @return text string with package repository source annotations. Will make
#'   note of packages not currently installed. Lines with existing comments or
#'   annotations are ignored by the regular expression that matches package
#'   names. Also ignores base packages. Local installs now annotated as such.
#'
#' @examples
#' test_string <- c("library(knitr)\nrequire(datasets)")
#' annotate_repo_source(test_string)
#' @importFrom rlang .data
#' @export
annotate_repo_source <- function(string_og) {
  out_tb <- match_pkg_names(string_og)
  if (nrow(out_tb) == 0) cat("no matching library load calls")
  if (nrow(out_tb) == 0) {
    return(string_og)
  }
  out_tb <- tibble::rowid_to_column(out_tb)
  pck_descs <- suppressWarnings(purrr::map(out_tb$pkgname_clean,
                          utils::packageDescription,
                          fields = c("Repository", "RemoteType", "biocViews")
  ))
  pck_descs <- purrr::map(pck_descs, as.list)
  pck_descs <-
    purrr::map(pck_descs, function(x) {
      if (
        !is.na(x$Repository) &&
        x$Repository == "CRAN" &&
        !is.na(x$RemoteType) &&
        x$RemoteType == "standard"
      ) {
        x$RemoteType <- NA
      }
      x
    })
  pck_descs <- tidyr::unnest(tibble::enframe(purrr::map(pck_descs, purrr::flatten_chr)), cols = c("value"))
  pck_descs <- dplyr::rename(pck_descs, rowid = 1, repo = 2)
  pck_descs <- dplyr::left_join(out_tb, pck_descs, by = "rowid")
  pck_descs <- dplyr::mutate(pck_descs, repo = ifelse(stringr::str_detect(.data$repo, ","), "Bioconductor", .data$repo))
  pck_descs <- dplyr::add_count(pck_descs, .data$package_name)
  pck_descs <- dplyr::mutate(pck_descs, repo = dplyr::if_else(.data$n == 1, "none", .data$repo))
  pck_descs <-
    suppressMessages(dplyr::ungroup(dplyr::summarize(
      dplyr::group_by(pck_descs,call,.data$package_name,.data$pkgname_clean),repo=dplyr::last(stats::na.omit(.data$repo)))))
  pck_descs <- dplyr::mutate(pck_descs, user_repo = dplyr::case_when(
    .data$repo ==
      "CRAN" ~ "CRAN",
    stringr::str_detect(.data$repo, "r-universe") ~ .data$repo,
    .data$repo == "Bioconductor" ~ "Bioconductor",
    .data$repo == "RSPM" ~ "Posit RSPM",
    .data$repo == "none" ~ "not installed on this machine",
    is.na(.data$repo) ~ "local install",
    TRUE ~ repo_details(.data$pkgname_clean)
  ), annotation = dplyr::case_when(stringr::str_detect(
    user_repo,
    "(?<!/)/(?!/)"
  ) ~ paste0("[", .data$repo, "::", user_repo, "]"), TRUE ~ user_repo))
  pck_descs <- dplyr::mutate(pck_descs, version = pkg_version(.data$pkgname_clean))
  # edge case with a single locally installed package
  if (nrow(pck_descs) == 0) {
    locannot <- paste(out_tb$call,"# local install")
    return(
      align_annotations(
        stringi::stri_replace_all_fixed(
          str = string_og, pattern = out_tb$call,
          replacement = locannot, vectorize_all = FALSE
        )
      ))
  }

  # build annotation
  if (all(!grepl("p_load", pck_descs$call))) { # no pacman calls
    pck_descs <-  dplyr::mutate(pck_descs,annotated=dplyr::case_when(
      stringr::str_detect(annotation,"not installed")~paste0(call, " #", " ", annotation, " vNA"),
      TRUE~ paste0(call, " #", " ", annotation, " v", version)
    ))
    return(
      align_annotations(stringi::stri_replace_all_fixed(
        str = string_og, pattern = pck_descs$call,
        replacement = pck_descs$annotated, vectorize_all = FALSE
      ))
    )
  }

  if (all(grepl("p_load", pck_descs$call))) { # only pacman calls
    pacld <- pck_descs[which(stringr::str_detect(out_tb$call, ".+load\\(")), ]
    pacld$pkgnamesep <- paste0(pacld$package_name, ",")
    pacld <- dplyr::mutate(dplyr::group_by(pacld, call), pkgnamesep = ifelse(dplyr::row_number() == dplyr::n(), gsub(",", "", .data$pkgnamesep), .data$pkgnamesep))
    pacld$annotatedpac <- paste0(pacld$pkgnamesep, " # ", pacld$annotation, " v", pacld$version)
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

  if (any(grepl("p_load", pck_descs$call)) & any(grepl("libr|req", out_tb$call))) { # pacman and base calls
    pacld <- pck_descs[which(stringr::str_detect(pck_descs$call, ".+load\\(")), ]
    pacld$pkgnamesep <- paste0(pacld$package_name, ",")
    pacld <- dplyr::mutate(dplyr::group_by(pacld, call), pkgnamesep = ifelse(dplyr::row_number() == dplyr::n(), gsub(",", "", .data$pkgnamesep), .data$pkgnamesep))
    pacld$annotatedpac <- paste0(pacld$pkgnamesep, " # ", pacld$annotation, " v", pacld$version)
    pacld <- dplyr::summarize(dplyr::group_by(pacld, call), pkgs = paste(.data$annotatedpac, collapse = "\n"))
    pacld$ldcalls <- stringr::str_extract(pacld$call, ".+\\(")
    pacld <- dplyr::mutate(pacld, annotpac = paste(.data$ldcalls, .data$pkgs, ")", sep = "\n"))
    string_og <- stringi::stri_replace_all_fixed(
      str = string_og, pattern = pacld$call,
      replacement = pacld$annotpac, vectorize_all = FALSE
    )
    pck_descs <- pck_descs[!stringr::str_detect(out_tb$call, ".+load\\("), ]
    pck_descs <-  dplyr::mutate(pck_descs,annotated=dplyr::case_when(
      stringr::str_detect(annotation,"not installed")~paste0(call, " #", " ", annotation, " vNA"),
      TRUE~ paste0(call, " #", " ", annotation, " v", version)
    ))

    return(
      align_annotations(
        stringi::stri_replace_all_fixed(
          str = string_og, pattern = pck_descs$call,
          replacement = pck_descs$annotated, vectorize_all = FALSE
        )
      )
    )
  }
}
