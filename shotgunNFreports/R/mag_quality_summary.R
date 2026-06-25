summarise_mag_quality <- function(checkm2_df) {

  checkm2_df |>
    dplyr::mutate(
      quality_class = dplyr::case_when(
        Completeness >= 90 & Contamination <= 5 ~ "High-quality MAG",
        Completeness >= 50 & Contamination <= 10 ~ "Medium-quality MAG",
        TRUE ~ "Low-quality bin"
      )
    )
}

plot_mag_quality_counts <- function(checkm2_df) {

  q <- summarise_mag_quality(checkm2_df)

  ggplot2::ggplot(
    q,
    ggplot2::aes(x = sample, fill = quality_class)
  ) +
    ggplot2::geom_bar() +
    ggplot2::coord_flip() +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::labs(
      title = "MAG quality classes from CheckM2",
      x = "Sample",
      y = "Number of bins",
      fill = "Quality class"
    )
}
