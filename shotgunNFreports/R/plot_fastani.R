plot_fastani_heatmap <- function(fastani) {
  if (nrow(fastani) == 0) return(NULL)

  df <- fastani |>
    dplyr::mutate(
      query_id = gsub("_passed_bins", "", paste(query_sample, query_bin, sep = "_")),
      reference_id = gsub("_passed_bins", "", paste(reference_sample, reference_bin, sep = "_"))
    ) |>
    dplyr::filter(ani >= 80)

  ggplot2::ggplot(df, ggplot2::aes(reference_id, query_id, fill = ani)) +
    ggplot2::geom_tile() +
    ggplot2::scale_fill_gradient(low = "white", high = "steelblue") +
    ggplot2::theme_bw() +
    ggplot2::labs(
      title = "ANI similarity among recovered MAGs",
      x = "Reference MAG",
      y = "Query MAG",
      fill = "ANI"
    ) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 90, hjust = 1, size = 5),
      axis.text.y = ggplot2::element_text(size = 5)
    )
}
