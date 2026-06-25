#' Summarise detected Shotgun-NF output modules
#'
#' @param results_dir Shotgun-NF results directory.
#' @return Tibble describing detected modules.
#' @export
summarise_modules <- function(results_dir) {
  tibble::tibble(
    module = c(
      "fastp_QC",
      "bracken_taxonomy",
      "kraken2_taxonomy",
      "humann_function",
      "megahit_assembly",
      "quast_assembly_qc",
      "metabat_bins",
      "checkm2_mag_qc",
      "coverm_abundance",
      "prokka_annotation",
      "rgi_amr",
      "antismash_bgc",
      "multiqc",
      "provenance",
      "pipeline_info"
    ),
    path = file.path(
      results_dir,
      c(
        "fastp",
        "bracken",
        "kraken2",
        "humann",
        "assembly",
        "quast",
        "bins",
        "checkm2",
        "coverm",
        "prokka",
        "rgi",
        "antismash",
        "multiqc",
        "provenance",
        "pipeline_info"
      )
    )
  ) |>
    dplyr::mutate(
      detected = dir.exists(path),
      n_files = purrr::map_int(path, function(x) {
        if (!dir.exists(x)) return(0L)
        length(list.files(x, recursive = TRUE, full.names = TRUE))
      })
    )
}
