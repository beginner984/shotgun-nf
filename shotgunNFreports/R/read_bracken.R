#' Read Bracken species or genus tables
#'
#' @param results_dir Path to Shotgun-NF results directory.
#' @param level Taxonomic level: "species" or "genus".
#' @return Long-format tibble of Bracken abundance results.
#' @export
read_bracken <- function(results_dir, level = "species") {
  level <- match.arg(level, c("species", "genus"))
  bracken_dir <- file.path(results_dir, "bracken")

  files <- list.files(
    bracken_dir,
    pattern = paste0("\\.bracken\\.", level, "\\.txt$"),
    full.names = TRUE
  )

  if (length(files) == 0) {
    warning("No Bracken ", level, " files found in: ", bracken_dir)
    return(tibble::tibble())
  }

  purrr::map_dfr(files, function(f) {
    x <- readr::read_tsv(f, show_col_types = FALSE)
    x$sample <- derive_sample(f)
    x
  })
}
