#' Null-coalescing helper
#' @keywords internal
`%||%` <- function(a, b) {
  if (!is.null(a)) a else b
}

#' Derive sample name from a Shotgun-NF output file
#' @keywords internal
derive_sample <- function(path) {
  x <- basename(path)

  x <- stringr::str_remove(x, "\\.fastp\\.json$")
  x <- stringr::str_remove(x, "\\.bracken\\.species\\.txt$")
  x <- stringr::str_remove(x, "\\.bracken\\.genus\\.txt$")
  x <- stringr::str_remove(x, "_humann$")
  x <- stringr::str_remove(x, "_quast$")
  x <- stringr::str_remove(x, "_checkm2$")
  x <- stringr::str_remove(x, "_rgi$")
  x <- stringr::str_remove(x, "_antismash$")

  x
}

#' Infer simple metadata from sample names
#'
#' This helper is optional. It attempts to infer group labels from common
#' sample-name patterns such as C1/C2/C3 or G0_T0.
#'
#' @param samples Character vector of sample names.
#' @return A data frame with sample and inferred metadata columns.
#' @export
infer_sample_metadata <- function(samples) {
  tibble::tibble(sample = samples) |>
    dplyr::mutate(
      timepoint = dplyr::case_when(
        stringr::str_detect(sample, "_C[0-9]+") ~ stringr::str_extract(sample, "C[0-9]+"),
        stringr::str_detect(sample, "_T[0-9]+") ~ stringr::str_extract(sample, "T[0-9]+"),
        TRUE ~ NA_character_
      ),
      group = dplyr::case_when(
        stringr::str_detect(sample, "^G[0-9]+") ~ stringr::str_extract(sample, "^G[0-9]+"),
        stringr::str_detect(sample, "^USG[0-9]+") ~ stringr::str_extract(sample, "^USG[0-9]+"),
        TRUE ~ NA_character_
      )
    )
}
