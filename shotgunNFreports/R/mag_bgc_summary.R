summarise_trusted_mag_bgc <- function(checkm2_df, bgc_df) {

  trusted <- filter_high_quality_mags(checkm2_df) |>
    dplyr::select(
      sample,
      bin_id = Name,
      Completeness,
      Contamination,
      quality
    )

  bgc_df |>
    dplyr::inner_join(trusted, by = c("sample", "bin_id")) |>
    dplyr::group_by(sample, bin_id, quality, product_class) |>
    dplyr::summarise(
      n_bgcs = dplyr::n(),
      .groups = "drop"
    )
}

plot_trusted_mag_bgc <- function(bgc_df) {

  if (nrow(bgc_df) == 0) return(NULL)

  plot_df <- bgc_df |>
    dplyr::mutate(
      mag = paste(sample, bin_id, quality, sep = " | "),
      product_class = stringr::str_trunc(product_class, 35)
    )

  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = mag, y = n_bgcs, fill = product_class)
  ) +
    ggplot2::geom_col() +
    ggplot2::coord_flip() +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      legend.position = "bottom",
      legend.text = ggplot2::element_text(size = 7)
    ) +
    ggplot2::labs(
      title = "BGC classes in trusted MAGs",
      x = "Trusted MAG",
      y = "antiSMASH BGC count",
      fill = "BGC class"
    )
}
