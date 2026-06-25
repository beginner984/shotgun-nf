read_metaphlan <- function(results_dir) {

  metaphlan_dir <- file.path(results_dir, "strainphlan", "metaphlan")

  files <- list.files(
    metaphlan_dir,
    pattern = "_profile\\.txt$",
    full.names = TRUE,
    recursive = TRUE
  )

  if (length(files) == 0) {
    return(tibble::tibble())
  }

  purrr::map_dfr(files, function(f) {

    sample <- basename(f)
    sample <- stringr::str_remove(sample, "_profile\\.txt$")

    readr::read_tsv(
      f,
      comment = "#",
      col_names = c(
        "clade_name",
        "ncbi_tax_id",
        "relative_abundance",
        "additional_species"
      ),
      show_col_types = FALSE
    ) |>

      dplyr::mutate(

        sample = sample,

        n_levels = stringr::str_count(clade_name, "\\|") + 1,

        rank = dplyr::case_when(
          clade_name == "UNCLASSIFIED" ~ "unclassified",
          n_levels == 1 ~ "kingdom",
          n_levels == 2 ~ "phylum",
          n_levels == 3 ~ "class",
          n_levels == 4 ~ "order",
          n_levels == 5 ~ "family",
          n_levels == 6 ~ "genus",
          n_levels >= 7 ~ "species",
          TRUE ~ "other"
        ),

        taxon = dplyr::case_when(
          rank == "kingdom" ~ stringr::str_remove(stringr::word(clade_name, 1, sep = "\\|"), "^[a-z]__"),
          rank == "phylum"  ~ stringr::str_remove(stringr::word(clade_name, 2, sep = "\\|"), "^[a-z]__"),
          rank == "class"   ~ stringr::str_remove(stringr::word(clade_name, 3, sep = "\\|"), "^[a-z]__"),
          rank == "order"   ~ stringr::str_remove(stringr::word(clade_name, 4, sep = "\\|"), "^[a-z]__"),
          rank == "family"  ~ stringr::str_remove(stringr::word(clade_name, 5, sep = "\\|"), "^[a-z]__"),
          rank == "genus"   ~ stringr::str_remove(stringr::word(clade_name, 6, sep = "\\|"), "^[a-z]__"),
          rank == "species" ~ stringr::str_remove(stringr::word(clade_name, -1, sep = "\\|"), "^[a-z]__"),
          TRUE ~ clade_name
        )

      )

  })

}
