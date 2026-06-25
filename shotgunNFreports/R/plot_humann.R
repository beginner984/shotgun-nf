#' Plot top HUMAnN pathways
#'
#' @param humann_df HUMAnN pathway table
#' @param top_n Number of pathways
#' @return ggplot object
#' @export

plot_humann_top_pathways <- function(humann_df, top_n = 20) {

  if (nrow(humann_df) == 0) {
    stop("humann_df is empty")
  }

  top_pathways <- humann_df |>
    dplyr::group_by(pathway) |>
    dplyr::summarise(total = sum(abundance, na.rm = TRUE)) |>
    dplyr::arrange(desc(total)) |>
    dplyr::slice_head(n = top_n) |>
    dplyr::pull(pathway)

  plot_df <- humann_df |>
    dplyr::filter(pathway %in% top_pathways)

  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(
      x = sample,
      y = abundance,
      fill = pathway
    )
  ) +
    ggplot2::geom_col() +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::coord_flip() +
    ggplot2::labs(
      title = "Top HUMAnN pathways",
      x = "Sample",
      y = "Abundance"
    )
}

#' HUMAnN pathway heatmap
#'
#' @param humann_df pathway table
#' @param top_n number of pathways
#' @return ggplot object
#' @export

plot_humann_heatmap <- function(humann_df, top_n = 30) {

  top_pathways <- humann_df |>
    dplyr::group_by(pathway) |>
    dplyr::summarise(total = sum(abundance, na.rm = TRUE)) |>
    dplyr::arrange(desc(total)) |>
    dplyr::slice_head(n = top_n) |>
    dplyr::pull(pathway)

  plot_df <- humann_df |>
    dplyr::filter(pathway %in% top_pathways)

  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(
      x = sample,
      y = pathway,
      fill = abundance
    )
  ) +
    ggplot2::geom_tile() +
    ggplot2::scale_fill_viridis_c() +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::labs(
      title = "HUMAnN pathway heatmap",
      x = "Sample",
      y = "Pathway"
    )
}


plot_humann_top_pathways <- function(humann_df, top_n = 15) {

  top_pathways <- humann_df |>
    dplyr::group_by(pathway) |>
    dplyr::summarise(total = sum(abundance, na.rm = TRUE), .groups = "drop") |>
    dplyr::arrange(desc(total)) |>
    dplyr::slice_head(n = top_n) |>
    dplyr::pull(pathway)

  plot_df <- humann_df |>
  dplyr::group_by(sample) |>
  dplyr::mutate(
    relative_abundance = abundance / sum(abundance, na.rm = TRUE) * 100
  ) |>
  dplyr::ungroup() |>
  dplyr::mutate(
    pathway_plot = ifelse(pathway %in% top_pathways, pathway, "Other")
  ) |>
  dplyr::group_by(sample, pathway_plot) |>
  dplyr::summarise(
    relative_abundance = sum(relative_abundance, na.rm = TRUE),
    .groups = "drop"
  )

  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = sample, y = relative_abundance, fill = pathway_plot)
  ) +
    ggplot2::geom_col() +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::labs(
      title = "HUMAnN pathway composition",
      x = "Sample",
      y = "Relative abundance (%)",
      fill = "Pathway"
    ) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      legend.text = ggplot2::element_text(size = 7)
    )
}
