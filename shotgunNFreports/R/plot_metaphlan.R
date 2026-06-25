plot_metaphlan_top_taxa <- function(metaphlan_df,
                                    rank = "phylum",
                                    top_n = 10) {

  df <- metaphlan_df |>
    dplyr::filter(rank == !!rank)

  if (nrow(df) == 0) return(NULL)

  summary_df <- df |>
    dplyr::group_by(sample, taxon) |>
    dplyr::summarise(
      relative_abundance = sum(relative_abundance, na.rm = TRUE),
      .groups = "drop"
    )

  top_taxa <- summary_df |>
    dplyr::group_by(taxon) |>
    dplyr::summarise(
      total_abundance = sum(relative_abundance),
      .groups = "drop"
    ) |>
    dplyr::arrange(desc(total_abundance)) |>
    dplyr::slice_head(n = top_n) |>
    dplyr::pull(taxon)

  plot_df <- summary_df |>
    dplyr::mutate(
      taxon_plot = ifelse(taxon %in% top_taxa, taxon, "Other")
    ) |>
    dplyr::group_by(sample, taxon_plot) |>
    dplyr::summarise(
      relative_abundance = sum(relative_abundance),
      .groups = "drop"
    )

  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(
      x = sample,
      y = relative_abundance,
      fill = taxon_plot
    )
  ) +
    ggplot2::geom_col() +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::labs(
      title = paste0("MetaPhlAn ", rank, "-level composition"),
      x = "Sample",
      y = "Relative abundance (%)",
      fill = "Taxon"
    )
}

plot_metaphlan_domain <- function(metaphlan_df) {

  df <- metaphlan_df |>
    dplyr::filter(rank %in% c("kingdom", "unclassified")) |>
    dplyr::mutate(
      taxon = dplyr::if_else(rank == "unclassified", "Unclassified", taxon)
    )

  if (nrow(df) == 0) return(NULL)

  ggplot2::ggplot(
    df,
    ggplot2::aes(x = sample, y = relative_abundance, fill = taxon)
  ) +
    ggplot2::geom_col() +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::labs(
      title = "MetaPhlAn classified vs unclassified composition",
      x = "Sample",
      y = "Relative abundance (%)",
      fill = "Group"
    )
}
