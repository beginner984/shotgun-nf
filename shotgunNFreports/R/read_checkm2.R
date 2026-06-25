#' Read CheckM2 quality reports
#'
#' @param results_dir Shotgun-NF results directory.
#' @return Tibble of MAG quality metrics.
#' @export
read_checkm2 <- function(results_dir) {
  checkm2_dir <- file.path(results_dir, "checkm2")

  files <- list.files(
  checkm2_dir,
  pattern = "quality_report\\.tsv$",
  recursive = TRUE,
  full.names = TRUE
)

files <- files[!grepl("_clean/quality_report\\.tsv$", files)]

  if (length(files) == 0) {
    warning("No CheckM2 quality_report.tsv files found")
    return(tibble::tibble())
  }

  purrr::map_dfr(files, function(f) {
    x <- readr::read_tsv(f, show_col_types = FALSE)
    sample <- basename(dirname(f))
    sample <- stringr::str_remove(sample, "_checkm2$")
    x$sample <- sample
    x
  })
}
