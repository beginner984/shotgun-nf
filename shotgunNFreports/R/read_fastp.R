#' Read fastp JSON summaries from Shotgun-NF output
#'
#' @param results_dir Path to a Shotgun-NF results directory.
#' @return A tibble of per-sample fastp QC metrics.
#' @export
read_fastp_summary <- function(results_dir) {
  fastp_dir <- file.path(results_dir, "fastp")

  files <- list.files(
    fastp_dir,
    pattern = "\\.fastp\\.json$",
    full.names = TRUE
  )

  if (length(files) == 0) {
    warning("No fastp JSON files found in: ", fastp_dir)
    return(tibble::tibble())
  }

  purrr::map_dfr(files, function(f) {
    x <- jsonlite::fromJSON(f)
    sample <- derive_sample(f)

    tibble::tibble(
      sample = sample,
      reads_before = x$summary$before_filtering$total_reads,
      reads_after = x$summary$after_filtering$total_reads,
      bases_before = x$summary$before_filtering$total_bases,
      bases_after = x$summary$after_filtering$total_bases,
      q30_before = x$summary$before_filtering$q30_rate,
      q30_after = x$summary$after_filtering$q30_rate,
      gc_before = x$summary$before_filtering$gc_content,
      gc_after = x$summary$after_filtering$gc_content,
      read_retention_percent = 100 * reads_after / reads_before
    )
  })
}
