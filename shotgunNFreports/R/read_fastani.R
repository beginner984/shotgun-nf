read_fastani <- function(results_dir) {
  f <- file.path(results_dir, "fastani", "fastani_pairs.tsv")

  if (!file.exists(f)) {
    warning("No fastANI output found")
    return(tibble::tibble())
  }

  readr::read_tsv(
    f,
    col_names = c("query", "reference", "ani", "fragments_mapped", "fragments_total"),
    show_col_types = FALSE
  ) |>
    dplyr::mutate(
      query_bin = basename(query),
      reference_bin = basename(reference),
      query_sample = basename(dirname(query)),
      reference_sample = basename(dirname(reference))
    )
}
