read_humann_stratified <- function(results_dir) {

  files <- list.files(
    file.path(results_dir, "humann"),
    pattern = "_pathabundance.tsv$",
    recursive = TRUE,
    full.names = TRUE
  )

  purrr::map_dfr(files, function(f) {

    sample <- basename(f)
    sample <- stringr::str_remove(sample, "_pathabundance.tsv$")

    readr::read_tsv(
      f,
      comment = "#",
      show_col_types = FALSE,
      col_names = c("feature", "abundance")
    ) |>

      dplyr::filter(
        stringr::str_detect(feature, "\\|g__"),
        !stringr::str_detect(feature, "^UNINTEGRATED")
      ) |>

      tidyr::separate(
        feature,
        into = c("pathway", "species"),
        sep = "\\|",
        extra = "merge"
      ) |>

      dplyr::mutate(
        sample = sample,
        species = stringr::str_remove(species, "^g__"),
        species = stringr::str_replace(species, "\\.s__.*", "")
      ) |>

      dplyr::select(sample, pathway, species, abundance)
  })
}
