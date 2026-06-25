plot_humann_stratified <- function(strat_df, top_n_pathways = 1, top_n_species = 12) {

  top_pathways <- strat_df |>
    dplyr::group_by(pathway) |>
    dplyr::summarise(total = sum(abundance), .groups = "drop") |>
    dplyr::slice_max(total, n = top_n_pathways) |>
    dplyr::pull(pathway)

  plot_df <- strat_df |>
    dplyr::filter(pathway %in% top_pathways)

  top_species <- plot_df |>
    dplyr::group_by(species) |>
    dplyr::summarise(total = sum(abundance), .groups = "drop") |>
    dplyr::slice_max(total, n = top_n_species) |>
    dplyr::pull(species)

  plot_df <- plot_df |>
    dplyr::mutate(
      species_plot = dplyr::if_else(
        species %in% top_species,
        species,
        "Other"
      )
    ) |>
    dplyr::group_by(sample, pathway, species_plot) |>
    dplyr::summarise(
      abundance = sum(abundance),
      .groups = "drop"
    )

  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(
      x = sample,
      y = abundance,
      fill = species_plot
    )
  ) +
    ggplot2::geom_col() +
    ggplot2::facet_wrap(~ pathway, scales = "free_y") +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
    ) +
    ggplot2::labs(
      title = "Species-stratified HUMAnN pathway contributions",
      x = "Sample",
      y = "Pathway abundance",
      fill = "Species"
    )
}
