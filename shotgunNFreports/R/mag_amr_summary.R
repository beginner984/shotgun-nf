shorten_amr_label <- function(x) {
  x |>
    stringr::str_replace_all("antibiotic efflux pump", "efflux") |>
    stringr::str_replace_all("resistance-nodulation-cell division \\(RND\\)", "RND") |>
    stringr::str_replace_all("major facilitator superfamily \\(MFS\\)", "MFS") |>
    stringr::str_replace_all("ATP-binding cassette \\(ABC\\)", "ABC") |>
    stringr::str_replace_all("phosphoethanolamine transferase", "transferase") |>
    stringr::str_replace_all(
      "General Bacterial Porin with reduced permeability to beta-lactams",
      "porin/reduced permeability"
    ) |>
    stringr::str_trunc(45)
}

summarise_trusted_mag_amr <- function(checkm2_df, rgi_df) {

  trusted <- filter_high_quality_mags(checkm2_df) |>
    dplyr::select(
      sample,
      bin_id = Name,
      Completeness,
      Contamination,
      quality
    )

  rgi_df |>
    dplyr::inner_join(trusted, by = c("sample", "bin_id")) |>
    dplyr::group_by(sample, bin_id, quality, `AMR Gene Family`, `Drug Class`) |>
    dplyr::summarise(
      n_hits = dplyr::n(),
      .groups = "drop"
    )
}

plot_trusted_mag_amr <- function(amr_df) {

  if (nrow(amr_df) == 0) return(NULL)

  plot_df <- amr_df |>
    dplyr::group_by(sample, bin_id, quality, `AMR Gene Family`) |>
    dplyr::summarise(n_hits = sum(n_hits), .groups = "drop") |>
    dplyr::mutate(
      mag = paste(sample, bin_id, quality, sep = " | "),
      amr_label = shorten_amr_label(`AMR Gene Family`)
    )

  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = mag, y = n_hits, fill = amr_label)
  ) +
    ggplot2::geom_col() +
    ggplot2::coord_flip() +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      legend.position = "bottom",
      legend.text = ggplot2::element_text(size = 7)
    ) +
    ggplot2::labs(
      title = "AMR gene families in trusted MAGs",
      x = "Trusted MAG",
      y = "RGI hit count",
      fill = "AMR gene family"
    )
}
