#' Make an automated Shotgun-NF report
#'
#' This is the main user-facing function. It parses a Shotgun-NF results
#' directory and generates summary tables and figures.
#'
#' @param results_dir Path to Shotgun-NF results directory.
#' @param outdir Output directory for report tables and figures.
#' @param exclude_samples Optional character vector of samples to remove.
#' @return Invisibly returns a list of parsed tables.
#' @export
make_shotgunnf_report <- function(results_dir,
                                  outdir = "shotgunnf_report",
                                  exclude_samples = NULL) {

  dir.create(outdir, recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(outdir, "tables"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(outdir, "figures"), recursive = TRUE, showWarnings = FALSE)

  message("Reading Shotgun-NF results from: ", results_dir)

  # -------------------------
  # Module detection summary
  # -------------------------
  module_summary <- summarise_modules(results_dir)
  readr::write_csv(
    module_summary,
    file.path(outdir, "tables", "module_detection_summary.csv")
  )


  # -------------------------
  # FASTP
  # -------------------------
  fastp <- read_fastp_summary(results_dir)

  if (!is.null(exclude_samples) && nrow(fastp) > 0) {
    fastp <- dplyr::filter(fastp, !sample %in% exclude_samples)
  }

  if (nrow(fastp) > 0) {
    readr::write_csv(fastp, file.path(outdir, "tables", "fastp_summary.csv"))

    p_fastp_reads <- ggplot2::ggplot(
      fastp,
      ggplot2::aes(y = sample, x = read_retention_percent)
    ) +
      ggplot2::geom_segment(
        ggplot2::aes(x = 99, xend = read_retention_percent, yend = sample),
        linewidth = 1.2,
        color = "grey50"
      ) +
      ggplot2::geom_point(size = 3, color = "black") +
      ggplot2::coord_cartesian(xlim = c(99, 100)) +
      ggplot2::theme_minimal(base_size = 12) +
      ggplot2::labs(
        title = "Read retention after fastp filtering",
        x = "Read retention (%)",
        y = "Sample"
      )

    ggplot2::ggsave(
      file.path(outdir, "figures", "qc_read_retention.png"),
      p_fastp_reads, width = 7, height = 5, dpi = 300
    )
  }

  # -------------------------
  # Bracken taxonomy
  # -------------------------
  bracken_species <- read_bracken(results_dir, level = "species")

  if (!is.null(exclude_samples) && nrow(bracken_species) > 0) {
    bracken_species <- dplyr::filter(bracken_species, !sample %in% exclude_samples)
  }

  if (nrow(bracken_species) > 0) {
    readr::write_csv(bracken_species, file.path(outdir, "tables", "bracken_species.csv"))

    alpha <- calculate_alpha_diversity(bracken_species)
    pcoa  <- calculate_beta_pcoa(bracken_species)

    readr::write_csv(alpha, file.path(outdir, "tables", "alpha_diversity.csv"))
    readr::write_csv(pcoa,  file.path(outdir, "tables", "bray_curtis_pcoa.csv"))

    p_taxa  <- plot_taxa_barplot(bracken_species, top_n = 15)
    p_alpha <- plot_alpha_diversity(alpha)
    p_pcoa  <- plot_beta_pcoa(pcoa)

    ggplot2::ggsave(file.path(outdir, "figures", "taxonomy_top_species.png"),
                    p_taxa, width = 9, height = 6, dpi = 300)
    ggplot2::ggsave(file.path(outdir, "figures", "alpha_diversity.png"),
                    p_alpha, width = 9, height = 6, dpi = 300)
    ggplot2::ggsave(file.path(outdir, "figures", "bray_curtis_pcoa.png"),
                    p_pcoa, width = 7, height = 6, dpi = 300)
  } else {
    alpha <- tibble::tibble()
    pcoa <- tibble::tibble()
  }



  # -------------------------
  # MetaPhlAn marker-gene taxonomy
  # -------------------------
  metaphlan <- read_metaphlan(results_dir)

  if (!is.null(exclude_samples) && nrow(metaphlan) > 0) {
    metaphlan <- dplyr::filter(metaphlan, !sample %in% exclude_samples)
  }

  if (nrow(metaphlan) > 0) {
    readr::write_csv(
      metaphlan,
      file.path(outdir, "tables", "metaphlan_profiles.csv")
    )

    p_mpa_domain <- plot_metaphlan_domain(metaphlan)
    ggplot2::ggsave(
      file.path(outdir, "figures", "metaphlan_domain_composition.png"),
      p_mpa_domain, width = 9, height = 6, dpi = 300
    )

    p_mpa_species <- plot_metaphlan_top_taxa(metaphlan, rank = "species", top_n = 15)
    ggplot2::ggsave(
      file.path(outdir, "figures", "metaphlan_top_species.png"),
      p_mpa_species, width = 10, height = 7, dpi = 300
    )
  } else {
    metaphlan <- tibble::tibble()
  }

  # -------------------------
  # HUMAnN pathways
  # -------------------------
  humann <- read_humann_pathways(results_dir)

  if (!is.null(exclude_samples) && nrow(humann) > 0) {
    humann <- dplyr::filter(humann, !sample %in% exclude_samples)
  }

  if (nrow(humann) > 0) {
    readr::write_csv(humann, file.path(outdir, "tables", "humann_pathways.csv"))

    p_humann <- plot_humann_top_pathways(humann)
    ggplot2::ggsave(
      file.path(outdir, "figures", "humann_top_pathways.png"),
      p_humann, width = 10, height = 7, dpi = 300
    )

    p_humann_heatmap <- plot_humann_heatmap(humann)
    ggplot2::ggsave(
      file.path(outdir, "figures", "humann_heatmap.png"),
      p_humann_heatmap, width = 11, height = 9, dpi = 300
    )
  } else {
    humann <- tibble::tibble()
  }

  humann_strat <- read_humann_stratified(results_dir)

  if (!is.null(exclude_samples) && nrow(humann_strat) > 0) {
    humann_strat <- dplyr::filter(humann_strat, !sample %in% exclude_samples)
  }

  if (nrow(humann_strat) > 0) {
    readr::write_csv(
      humann_strat,
      file.path(outdir, "tables", "humann_stratified_pathways.csv")
    )

    p_humann_strat <- plot_humann_stratified(humann_strat)

    ggplot2::ggsave(
      file.path(outdir, "figures", "humann_stratified_pathway.png"),
      p_humann_strat,
      width = 12,
      height = 6,
      dpi = 300
    )
  }



  # -------------------------
  # Runtime trace
  # -------------------------
  trace_file <- file.path(results_dir, "pipeline_info", "trace.tsv")

  if (file.exists(trace_file)) {
    trace <- readr::read_tsv(trace_file, show_col_types = FALSE)
    readr::write_csv(trace, file.path(outdir, "tables", "runtime_trace.csv"))

    if ("duration" %in% names(trace)) {
      runtime_summary <- trace |>
        dplyr::count(name, status, sort = TRUE)

      readr::write_csv(runtime_summary, file.path(outdir, "tables", "runtime_task_summary.csv"))
    }

    p_runtime <- plot_runtime_by_process(trace)
    ggplot2::ggsave(
      file.path(outdir, "figures", "runtime_by_process.png"),
      p_runtime, width = 9, height = 6, dpi = 300
    )

    if ("peak_rss" %in% names(trace) && any(trace$peak_rss != "-", na.rm = TRUE)) {
      p_memory <- plot_memory_by_process(trace)
      ggplot2::ggsave(
        file.path(outdir, "figures", "memory_by_process.png"),
        p_memory, width = 9, height = 6, dpi = 300
      )
    } else {
      writeLines(
        "Peak memory values were unavailable in trace.tsv for this run.",
        file.path(outdir, "tables", "memory_unavailable.txt")
      )
    }
  } else {
    trace <- tibble::tibble()
  }


  # -------------------------
  # CheckM2 MAG quality
  # -------------------------
  checkm2 <- read_checkm2(results_dir)

  if (!is.null(exclude_samples) && nrow(checkm2) > 0) {
    checkm2 <- dplyr::filter(checkm2, !sample %in% exclude_samples)
  }

  if (nrow(checkm2) > 0) {
    readr::write_csv(checkm2, file.path(outdir, "tables", "checkm2_quality.csv"))

    p_checkm2 <- plot_mag_quality(checkm2)

    ggplot2::ggsave(
      file.path(outdir, "figures", "mag_quality.png"),
      p_checkm2, width = 8, height = 6, dpi = 300
    )
  } else {
    checkm2 <- tibble::tibble()
  }


  # -------------------------
  # RGI/CARD AMR
  # -------------------------
  # -------------------------
  # fastANI MAG similarity
  # -------------------------
  fastani <- read_fastani(results_dir)

  if (nrow(fastani) > 0) {
    readr::write_csv(
      fastani,
      file.path(outdir, "tables", "fastani_pairs.csv")
    )

    p_fastani <- plot_fastani_heatmap(fastani)

    if (!is.null(p_fastani)) {
      ggplot2::ggsave(
        file.path(outdir, "figures", "fastani_heatmap.png"),
        p_fastani,
        width = 10,
        height = 10,
        dpi = 300
      )
    }
  }

  # -------------------------
  # GTDB-Tk MAG taxonomy
  # -------------------------
  gtdbtk <- read_gtdbtk(results_dir)

  if (nrow(gtdbtk) > 0) {
    readr::write_csv(
      gtdbtk,
      file.path(outdir, "tables", "gtdbtk_taxonomy.csv")
    )

    p_gtdbtk_phylum <- plot_gtdbtk_phylum(gtdbtk)

    if (!is.null(p_gtdbtk_phylum)) {
      ggplot2::ggsave(
        file.path(outdir, "figures", "gtdbtk_phylum_barplot.png"),
        p_gtdbtk_phylum,
        width = 9,
        height = 5,
        dpi = 300
      )
    }
  }

  rgi <- read_rgi(results_dir)

  if (!is.null(exclude_samples) && nrow(rgi) > 0) {
    rgi <- dplyr::filter(rgi, !sample %in% exclude_samples)
  }

  if (nrow(rgi) > 0) {
    readr::write_csv(rgi, file.path(outdir, "tables", "rgi_amr_hits.csv"))

    p_amr_drug <- plot_amr_drug_class(rgi)
    ggplot2::ggsave(
      file.path(outdir, "figures", "amr_drug_class.png"),
      p_amr_drug, width = 10, height = 7, dpi = 300
    )

    p_amr_heatmap <- plot_amr_heatmap(rgi)
    ggplot2::ggsave(
      file.path(outdir, "figures", "amr_gene_family_heatmap.png"),
      p_amr_heatmap, width = 10, height = 8, dpi = 300
    )
  } else {
    rgi <- tibble::tibble()
  }

    trusted_mag_amr <- summarise_trusted_mag_amr(checkm2, rgi)

  if (nrow(trusted_mag_amr) > 0) {
    readr::write_csv(
      trusted_mag_amr,
      file.path(outdir, "tables", "trusted_mag_amr.csv")
    )

    p_trusted_mag_amr <- plot_trusted_mag_amr(trusted_mag_amr)

    ggplot2::ggsave(
      file.path(outdir, "figures", "trusted_mag_amr.png"),
      p_trusted_mag_amr,
      width = 11,
      height = 7,
      dpi = 300
    )
  }



  # -------------------------
  # antiSMASH BGCs
  # -------------------------
  bgc <- read_antismash(results_dir)

  if (!is.null(exclude_samples) && nrow(bgc) > 0) {
    bgc <- dplyr::filter(bgc, !sample %in% exclude_samples)
  }

  if (nrow(bgc) > 0) {
    readr::write_csv(bgc, file.path(outdir, "tables", "antismash_bgc_regions.csv"))

    p_bgc_counts <- plot_bgc_class_counts(bgc)
    ggplot2::ggsave(
      file.path(outdir, "figures", "bgc_class_counts.png"),
      p_bgc_counts, width = 10, height = 7, dpi = 300
    )

    p_bgc_heatmap <- plot_bgc_heatmap(bgc)
    ggplot2::ggsave(
      file.path(outdir, "figures", "bgc_class_heatmap.png"),
      p_bgc_heatmap, width = 10, height = 8, dpi = 300
    )
  } else {
    bgc <- tibble::tibble()
  }

  trusted_mag_bgc <- summarise_trusted_mag_bgc(checkm2, bgc)

  if (nrow(trusted_mag_bgc) > 0) {

    readr::write_csv(
      trusted_mag_bgc,
      file.path(outdir, "tables", "trusted_mag_bgc.csv")
    )

    p_trusted_mag_bgc <- plot_trusted_mag_bgc(trusted_mag_bgc)

    ggplot2::ggsave(
      file.path(outdir, "figures", "trusted_mag_bgc.png"),
      p_trusted_mag_bgc,
      width = 11,
      height = 7,
      dpi = 300
    )
  }



  # -------------------------
  # Overall report summary
  # -------------------------
  report_summary <- summarise_report_outputs(
    fastp,
    bracken_species,
    humann,
    checkm2,
    rgi,
    bgc,
    trace
  )

  readr::write_csv(
    report_summary,
    file.path(outdir, "tables", "report_summary.csv")
  )

  # -------------------------
  # Simple report index
  # -------------------------
  report_md <- file.path(outdir, "README_report.md")

  table_files <- list.files(file.path(outdir, "tables"), full.names = TRUE, recursive = FALSE)
  table_files <- table_files[file.info(table_files)$isdir == FALSE]

  figure_files <- list.files(file.path(outdir, "figures"), full.names = TRUE, recursive = FALSE)
  figure_files <- figure_files[file.info(figure_files)$isdir == FALSE]

  writeLines(c(
    "# Shotgun-NF automated report",
    "",
    paste0("Results directory: `", results_dir, "`"),
    "",
    "## Generated tables",
    paste0("- `tables/", basename(table_files), "`"),
    "",
    "## Generated figures",
    paste0("- `figures/", basename(figure_files), "`")
  ), report_md)

  message("Report written to: ", outdir)

  invisible(list(
    module_summary = module_summary,
    fastp = fastp,
    bracken_species = bracken_species,
    metaphlan = metaphlan,
    alpha = alpha,
    pcoa = pcoa,
    checkm2 = checkm2,
    rgi = rgi,
    bgc = bgc,
    report_summary = report_summary,
    trace = trace
  ))
}
