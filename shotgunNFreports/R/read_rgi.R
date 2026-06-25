#' Read RGI/CARD TXT outputs
#'
#' @param results_dir Shotgun-NF results directory.
#' @return Tibble of AMR hits.
#' @export
read_rgi <- function(results_dir) {
  rgi_dir <- file.path(results_dir, "rgi")

  files <- list.files(
    rgi_dir,
    pattern = "\\.txt$",
    recursive = TRUE,
    full.names = TRUE
  )

  if (length(files) == 0) {
    warning("No RGI TXT files found")
    return(tibble::tibble())
  }

  purrr::map_dfr(files, function(f) {
    x <- suppressWarnings(readr::read_tsv(f, show_col_types = FALSE))

    if (nrow(x) == 0) return(tibble::tibble())

    sample <- basename(dirname(f))
    sample <- stringr::str_remove(sample, "_rgi$")
    bin_id <- tools::file_path_sans_ext(basename(f))

    x$sample <- sample
    x$bin_id <- bin_id
    x$source_file <- f
    x
  })
}
