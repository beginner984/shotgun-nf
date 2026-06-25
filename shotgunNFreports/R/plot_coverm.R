plot_mag_abundance_heatmap <- function(coverm_df) {

  if (nrow(coverm_df) == 0) return(NULL)

  plot_df <- coverm_df |>
    dplyr::mutate(
      mag_id = paste(sample, genome, sep = "_")
    )

  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(
      x = sample,
      y = mag_id,
      fill = relative_abundance
    )
  ) +
    ggplot2::geom_tile(color = "white") +
    ggplot2::scale_fill_viridis_c() +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::labs(
      title = "MAG relative abundance across samples",
      x = "Sample",
      y = "MAG",
      fill = "Relative abundance (%)"
    )
}
