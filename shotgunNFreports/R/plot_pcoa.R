plot_metaphlan_pcoa <- function(metaphlan_df, rank = "genus") {

  df <- metaphlan_df |>
    dplyr::filter(rank == !!rank)

  if (nrow(df) == 0) return(NULL)

  mat <- df |>
    dplyr::select(sample, taxon, relative_abundance) |>
    tidyr::pivot_wider(
      names_from = taxon,
      values_from = relative_abundance,
      values_fill = 0
    )

  sample_names <- mat$sample

  mat_num <- mat |>
    dplyr::select(-sample)

  rownames(mat_num) <- sample_names

  bc <- vegan::vegdist(mat_num, method = "bray")

  pcoa <- stats::cmdscale(bc, eig = TRUE, k = 2)

  pcoa_df <- data.frame(
    sample = rownames(pcoa$points),
    PC1 = pcoa$points[,1],
    PC2 = pcoa$points[,2]
  )

  ggplot2::ggplot(
    pcoa_df,
    ggplot2::aes(
      x = PC1,
      y = PC2,
      label = sample,
      color = sample
    )
  ) +
    ggplot2::geom_point(size = 5) +
    ggplot2::geom_text(vjust = -1) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::labs(
      title = paste0("Bray-Curtis PCoA (", rank, "-level MetaPhlAn)"),
      x = "PC1",
      y = "PC2"
    )
}
