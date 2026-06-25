#' Plot BGC class counts
#'
#' @param bgc_df Output from read_antismash().
#' @return ggplot object.
#' @export
plot_bgc_class_counts <- function(bgc_df) {
  if (nrow(bgc_df) == 0) stop("bgc_df is empty")

  plot_df <- bgc_df |>
    tidyr::separate_rows(product_class, sep = ";|,") |>
    dplyr::mutate(product_class = stringr::str_trim(product_class)) |>
    dplyr::filter(!is.na(product_class), product_class != "") |>
    dplyr::count(sample, product_class, name = "bgc_count")

  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = sample, y = bgc_count, fill = product_class)
  ) +
    ggplot2::geom_col() +
    ggplot2::coord_flip() +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::labs(
      title = "antiSMASH BGC classes per sample",
      x = "Sample",
      y = "BGC count",
      fill = "BGC class"
    )
}

#' Plot BGC class heatmap
#'
#' @param bgc_df Output from read_antismash().
#' @return ggplot object.
#' @export
plot_bgc_heatmap <- function(bgc_df) {
  if (nrow(bgc_df) == 0) stop("bgc_df is empty")

  plot_df <- bgc_df |>
    tidyr::separate_rows(product_class, sep = ";|,") |>
    dplyr::mutate(product_class = stringr::str_trim(product_class)) |>
    dplyr::filter(!is.na(product_class), product_class != "") |>
    dplyr::count(sample, product_class, name = "n")

  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = sample, y = product_class, fill = n)
  ) +
    ggplot2::geom_tile() +
    ggplot2::scale_fill_viridis_c() +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::labs(
      title = "BGC class heatmap",
      x = "Sample",
      y = "BGC class",
      fill = "Count"
    )
}
