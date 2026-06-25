#' Calculate alpha diversity from Bracken abundance data
#'
#' @param bracken_df Output from read_bracken().
#' @return Tibble with richness, Shannon, and Simpson diversity.
#' @export
calculate_alpha_diversity <- function(bracken_df) {
  if (nrow(bracken_df) == 0) stop("bracken_df is empty")

  name_col <- if ("name" %in% names(bracken_df)) "name" else names(bracken_df)[1]
  abundance_col <- dplyr::case_when(
    "fraction_total_reads" %in% names(bracken_df) ~ "fraction_total_reads",
    "new_est_frac" %in% names(bracken_df) ~ "new_est_frac",
    "fraction" %in% names(bracken_df) ~ "fraction",
    TRUE ~ NA_character_
  )

  if (is.na(abundance_col)) stop("Could not identify abundance column")

  mat <- bracken_df |>
    dplyr::select(sample, taxon = .data[[name_col]], abundance = .data[[abundance_col]]) |>
    tidyr::pivot_wider(names_from = taxon, values_from = abundance, values_fill = 0) |>
    as.data.frame()

  rownames(mat) <- mat$sample
  mat <- as.matrix(mat[, -1, drop = FALSE])

  tibble::tibble(
    sample = rownames(mat),
    richness = vegan::specnumber(mat),
    shannon = vegan::diversity(mat, index = "shannon"),
    simpson = vegan::diversity(mat, index = "simpson")
  )
}

#' Plot alpha diversity
#'
#' @param alpha_df Output from calculate_alpha_diversity().
#' @return ggplot object.
#' @export
plot_alpha_diversity <- function(alpha_df) {
  alpha_long <- alpha_df |>
    tidyr::pivot_longer(-sample, names_to = "metric", values_to = "value")

  ggplot2::ggplot(alpha_long, ggplot2::aes(x = sample, y = value)) +
    ggplot2::geom_col() +
    ggplot2::facet_wrap(~metric, scales = "free_y") +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)) +
    ggplot2::labs(title = "Alpha diversity", x = "Sample", y = "Value")
}

#' Calculate Bray-Curtis PCoA from Bracken data
#'
#' @param bracken_df Output from read_bracken().
#' @return Tibble with PCoA coordinates.
#' @export
calculate_beta_pcoa <- function(bracken_df) {
  if (nrow(bracken_df) == 0) stop("bracken_df is empty")

  name_col <- if ("name" %in% names(bracken_df)) "name" else names(bracken_df)[1]
  abundance_col <- dplyr::case_when(
    "fraction_total_reads" %in% names(bracken_df) ~ "fraction_total_reads",
    "new_est_frac" %in% names(bracken_df) ~ "new_est_frac",
    "fraction" %in% names(bracken_df) ~ "fraction",
    TRUE ~ NA_character_
  )

  if (is.na(abundance_col)) stop("Could not identify abundance column")

  mat <- bracken_df |>
    dplyr::select(sample, taxon = .data[[name_col]], abundance = .data[[abundance_col]]) |>
    tidyr::pivot_wider(names_from = taxon, values_from = abundance, values_fill = 0) |>
    as.data.frame()

  rownames(mat) <- mat$sample
  mat <- as.matrix(mat[, -1, drop = FALSE])

  dist <- vegan::vegdist(mat, method = "bray")
  pcoa <- stats::cmdscale(dist, k = 2, eig = TRUE)

  tibble::tibble(
    sample = rownames(mat),
    PC1 = pcoa$points[, 1],
    PC2 = pcoa$points[, 2]
  )
}

#' Plot Bray-Curtis PCoA
#'
#' @param pcoa_df Output from calculate_beta_pcoa().
#' @return ggplot object.
#' @export
plot_beta_pcoa <- function(pcoa_df) {
  if (nrow(pcoa_df) == 0) stop("pcoa_df is empty")

  p <- ggplot2::ggplot(pcoa_df, ggplot2::aes(PC1, PC2, label = sample)) +
    ggplot2::geom_point(size = 3) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::labs(title = "Bray-Curtis PCoA", x = "PCoA1", y = "PCoA2") +
    ggplot2::theme(
      plot.margin = ggplot2::margin(10, 35, 10, 35),
      panel.grid.minor = ggplot2::element_blank()
    )

  if (requireNamespace("ggrepel", quietly = TRUE)) {
    p <- p + ggrepel::geom_text_repel(
      size = 3,
      max.overlaps = Inf,
      box.padding = 0.5,
      point.padding = 0.3
    )
  } else {
    p <- p + ggplot2::geom_text(vjust = -0.7, size = 3)
  }

  p
}


plot_shannon_diversity <- function(metaphlan_df, rank = "genus") {

  df <- metaphlan_df |>
    dplyr::filter(rank == !!rank)

  if (nrow(df) == 0) return(NULL)

  div_df <- df |>
    dplyr::group_by(sample) |>
    dplyr::summarise(
      shannon = vegan::diversity(relative_abundance, index = "shannon"),
      richness = dplyr::n_distinct(taxon),
      .groups = "drop"
    )

  p <- ggplot2::ggplot(
    div_df,
    ggplot2::aes(
      x = sample,
      y = shannon,
      fill = sample
    )
  ) +
    ggplot2::geom_col(show.legend = FALSE) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::labs(
      title = paste0("Shannon diversity (", rank, "-level MetaPhlAn)"),
      x = "Sample",
      y = "Shannon diversity"
    )

  return(p)
}
