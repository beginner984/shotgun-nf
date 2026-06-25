plot_gtdbtk_phylum <- function(gtdbtk) {
  if (nrow(gtdbtk) == 0 || !"classification" %in% names(gtdbtk)) return(NULL)

  df <- gtdbtk |>
    tidyr::separate(
      classification,
      into = c("domain", "phylum", "class", "order", "family", "genus", "species"),
      sep = ";",
      fill = "right",
      remove = FALSE
    ) |>
    dplyr::mutate(phylum = sub("^p__", "", phylum)) |>
    dplyr::count(sample, phylum, name = "n_mags")

  ggplot2::ggplot(df, ggplot2::aes(x = sample, y = n_mags, fill = phylum)) +
    ggplot2::geom_col() +
    ggplot2::theme_bw() +
    ggplot2::labs(
      x = "Sample",
      y = "Number of MAGs",
      fill = "GTDB phylum",
      title = "GTDB-Tk taxonomic classification of recovered MAGs"
    ) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
}
