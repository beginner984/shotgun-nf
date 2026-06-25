#' Plot top taxa from Bracken output
#'
#' @param bracken_df Output from read_bracken().
#' @param top_n Number of taxa to show.
#' @return ggplot object.
#' @export
plot_taxa_barplot <- function(bracken_df, top_n = 15) {
  if (nrow(bracken_df) == 0) stop("bracken_df is empty")

  name_col <- if ("name" %in% names(bracken_df)) "name" else names(bracken_df)[1]
  abundance_col <- dplyr::case_when(
    "fraction_total_reads" %in% names(bracken_df) ~ "fraction_total_reads",
    "new_est_frac" %in% names(bracken_df) ~ "new_est_frac",
    "fraction" %in% names(bracken_df) ~ "fraction",
    TRUE ~ NA_character_
  )

  if (is.na(abundance_col)) {
    stop("Could not identify abundance column in Bracken table")
  }

  top_taxa <- bracken_df |>
    dplyr::group_by(.data[[name_col]]) |>
    dplyr::summarise(mean_abundance = mean(.data[[abundance_col]], na.rm = TRUE), .groups = "drop") |>
    dplyr::slice_max(mean_abundance, n = top_n) |>
    dplyr::pull(.data[[name_col]])

  plot_df <- bracken_df |>
    dplyr::mutate(
      taxon = dplyr::if_else(.data[[name_col]] %in% top_taxa, .data[[name_col]], "Other"),
      abundance = .data[[abundance_col]]
    ) |>
    dplyr::group_by(sample, taxon) |>
    dplyr::summarise(abundance = sum(abundance, na.rm = TRUE), .groups = "drop")

  ggplot2::ggplot(plot_df, ggplot2::aes(x = sample, y = abundance, fill = taxon)) +
    ggplot2::geom_col() +
    ggplot2::coord_flip() +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::labs(
      title = "Top taxa from Bracken",
      x = "Sample",
      y = "Relative abundance",
      fill = "Taxon"
    )
}
