summarise_report_outputs <- function(fastp, bracken_species, humann, checkm2, rgi, bgc, trace) {
  tibble::tibble(
    metric = c(
      "samples_detected",
      "bracken_species_records",
      "unique_bracken_taxa",
      "humann_pathway_records",
      "unique_humann_pathways",
      "checkm2_bins",
      "rgi_amr_hits",
      "antismash_bgc_regions",
      "nextflow_tasks"
    ),
    value = c(
      dplyr::n_distinct(fastp$sample),
      nrow(bracken_species),
      dplyr::n_distinct(bracken_species$name),
      nrow(humann),
      dplyr::n_distinct(humann$pathway),
      nrow(checkm2),
      nrow(rgi),
      nrow(bgc),
      nrow(trace)
    )
  )
}
