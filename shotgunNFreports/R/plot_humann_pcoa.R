plot_humann_pcoa <- function(humann_df) {

  mat <- humann_df |>
    dplyr::group_by(sample) |>
    dplyr::mutate(
      relative_abundance = abundance / sum(abundance, na.rm = TRUE) * 100
    ) |>
    dplyr::ungroup() |>
    dplyr::select(sample, pathway, relative_abundance) |>
    tidyr::pivot_wider(
      names_from = pathway,
      values_from = relative_abundance,
      values_fill = 0
    )

  sample_names <- mat$sample
  mat_num <- mat |> dplyr::select(-sample)
  rownames(mat_num) <- sample_names

  bc <- vegan::vegdist(mat_num, method = "bray")
  pcoa <- stats::cmdscale(bc, eig = TRUE, k = 2)

  pcoa_df <- data.frame(
    sample = rownames(pcoa$points),
    PC1 = pcoa$points[, 1],
    PC2 = pcoa$points[, 2]
  )

  ggplot2::ggplot(
    pcoa_df,
    ggplot2::aes(PC1, PC2, label = sample, color = sample)
  ) +
    ggplot2::geom_point(size = 5) +
    ggplot2::geom_text(vjust = -1) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::labs(
      title = "Bray-Curtis PCoA of HUMAnN pathway profiles",
      x = "PC1",
      y = "PC2"
    )
}
