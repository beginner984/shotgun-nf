#' Plot MAG completeness and contamination
#'
#' @param checkm2_df Output from read_checkm2().
#' @return ggplot object.
#' @export
plot_mag_quality <- function(checkm2_df) {
  if (nrow(checkm2_df) == 0) stop("checkm2_df is empty")

  completeness_col <- names(checkm2_df)[stringr::str_detect(tolower(names(checkm2_df)), "completeness")][1]
  contamination_col <- names(checkm2_df)[stringr::str_detect(tolower(names(checkm2_df)), "contamination")][1]

  if (is.na(completeness_col) || is.na(contamination_col)) {
    stop("Could not identify completeness/contamination columns")
  }

  plot_df <- checkm2_df |>
    dplyr::mutate(
      completeness = .data[[completeness_col]],
      contamination = .data[[contamination_col]],
      quality_class = dplyr::case_when(
        completeness >= 90 & contamination < 5 ~ "High-quality MAG",
        completeness >= 50 & contamination < 10 ~ "Medium-quality MAG",
        TRUE ~ "Low-quality bin"
      )
    )

  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = contamination, y = completeness, color = quality_class, label = sample)
  ) +
    ggplot2::geom_point(size = 3) +
    ggplot2::geom_hline(yintercept = 90, linetype = "dashed") +
    ggplot2::geom_hline(yintercept = 50, linetype = "dotted") +
    ggplot2::geom_vline(xintercept = 5, linetype = "dashed") +
    ggplot2::geom_vline(xintercept = 10, linetype = "dotted") +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::labs(
      title = "MAG quality assessment",
      x = "Contamination (%)",
      y = "Completeness (%)",
      color = "Quality"
    )
}
