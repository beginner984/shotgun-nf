filter_high_quality_mags <- function(checkm2_df) {

  checkm2_df |>
    dplyr::filter(
      Completeness >= 50,
      Contamination <= 10
    ) |>
    dplyr::mutate(
      quality = dplyr::case_when(
        Completeness >= 90 & Contamination <= 5 ~ "High-quality",
        TRUE ~ "Medium-quality"
      )
    ) |>
    dplyr::arrange(
      dplyr::desc(Completeness),
      Contamination
    )
}
