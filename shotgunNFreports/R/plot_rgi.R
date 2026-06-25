#' Plot AMR drug class counts
#'
#' @param rgi_df Output from read_rgi().
#' @return ggplot object.
#' @export
plot_amr_drug_class <- function(rgi_df) {
  if (nrow(rgi_df) == 0) stop("rgi_df is empty")

  drug_col <- names(rgi_df)[stringr::str_detect(tolower(names(rgi_df)), "drug.class|drug_class")][1]

  if (is.na(drug_col)) {
    stop("Could not identify Drug Class column")
  }

  plot_df <- rgi_df |>
    dplyr::mutate(drug_class = as.character(.data[[drug_col]])) |>
    tidyr::separate_rows(drug_class, sep = ";|,") |>
    dplyr::mutate(drug_class = stringr::str_trim(drug_class)) |>
    dplyr::filter(!is.na(drug_class), drug_class != "") |>
    dplyr::count(sample, drug_class, name = "n_hits")

  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = sample, y = n_hits, fill = drug_class)
  ) +
    ggplot2::geom_col() +
    ggplot2::coord_flip() +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::labs(
      title = "RGI/CARD AMR drug class hits",
      x = "Sample",
      y = "Hit count",
      fill = "Drug class"
    )
}

#' Plot AMR gene family heatmap
#'
#' @param rgi_df Output from read_rgi().
#' @return ggplot object.
#' @export
plot_amr_heatmap <- function(rgi_df, top_n = 30) {
  if (nrow(rgi_df) == 0) stop("rgi_df is empty")

  family_col <- names(rgi_df)[stringr::str_detect(tolower(names(rgi_df)), "gene.family|amr_gene_family")][1]

  if (is.na(family_col)) {
    stop("Could not identify AMR Gene Family column")
  }

  counts <- rgi_df |>
    dplyr::mutate(amr_family = as.character(.data[[family_col]])) |>
    tidyr::separate_rows(amr_family, sep = ";|,") |>
    dplyr::mutate(amr_family = stringr::str_trim(amr_family)) |>
    dplyr::filter(!is.na(amr_family), amr_family != "") |>
    dplyr::count(sample, amr_family, name = "n")

  top_families <- counts |>
    dplyr::group_by(amr_family) |>
    dplyr::summarise(total = sum(n), .groups = "drop") |>
    dplyr::slice_max(total, n = top_n) |>
    dplyr::pull(amr_family)

  plot_df <- counts |>
    dplyr::filter(amr_family %in% top_families)

  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = sample, y = amr_family, fill = n)
  ) +
    ggplot2::geom_tile() +
    ggplot2::scale_fill_viridis_c() +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::labs(
      title = "AMR gene family heatmap",
      x = "Sample",
      y = "AMR gene family",
      fill = "Hits"
    )
}
