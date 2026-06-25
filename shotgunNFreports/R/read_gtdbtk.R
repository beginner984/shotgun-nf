read_gtdbtk <- function(results_dir) {
  files <- list.files(
    file.path(results_dir, "gtdbtk"),
    pattern = "gtdbtk\\.bac120\\.summary\\.tsv$",
    recursive = TRUE,
    full.names = TRUE
  )

  files <- files[!grepl("/classify/", files)]

  if (length(files) == 0) {
    warning("No GTDB-Tk bac120 summary files found")
    return(tibble::tibble())
  }

  purrr::map_dfr(files, function(f) {
    sample_id <- basename(dirname(f))
    sample_id <- sub("_gtdbtk$", "", sample_id)

    readr::read_tsv(
      f,
      col_types = readr::cols(.default = readr::col_character()),
      show_col_types = FALSE
    ) |>
      dplyr::mutate(sample = sample_id, .before = 1)
  })
}
