read_coverm <- function(results_dir) {

  files <- list.files(
    file.path(results_dir, "coverm"),
    pattern = "coverm_mag_abundance\\.tsv$",
    full.names = TRUE
  )

  if (length(files) == 0) return(tibble::tibble())

  purrr::map_dfr(files, function(f) {

    sample <- basename(f)
    sample <- stringr::str_remove(sample, "\\.coverm_mag_abundance\\.tsv$")

    x <- readr::read_tsv(f, show_col_types = FALSE)

    tibble::tibble(
      sample = sample,
      genome = x[[1]],
      relative_abundance = as.numeric(x[[2]]),
      mean_coverage = as.numeric(x[[3]]),
      covered_fraction = as.numeric(x[[4]])
    ) |>
      dplyr::filter(genome != "unmapped")
  })
}
