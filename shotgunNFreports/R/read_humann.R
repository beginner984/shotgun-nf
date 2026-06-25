#' Read HUMAnN pathway abundance tables
#'
#' Reads HUMAnN pathabundance.tsv outputs and combines all samples.
#'
#' @param results_dir Shotgun-NF results directory
#' @return tibble with pathways x samples
#' @export

read_humann_pathways <- function(results_dir) {

  humann_dir <- file.path(results_dir, "humann")

  if (!dir.exists(humann_dir)) {
    warning("No HUMAnN directory found")
    return(tibble::tibble())
  }

  files <- list.files(
    humann_dir,
    pattern = "_pathabundance.tsv$",
    recursive = TRUE,
    full.names = TRUE
  )

  if (length(files) == 0) {
    warning("No HUMAnN pathway files found")
    return(tibble::tibble())
  }

  all_tables <- lapply(files, function(f) {

    sample_name <- basename(f)
    sample_name <- sub("_pathabundance.tsv$", "", sample_name)

    df <- readr::read_tsv(
      f,
      comment = "#",
      show_col_types = FALSE
    )

    colnames(df)[1] <- "pathway"
    colnames(df)[2] <- "abundance"

    df$sample <- sample_name

    df
  })

  dplyr::bind_rows(all_tables)
}


read_humann_pathways <- function(results_dir) {

  humann_dir <- file.path(results_dir, "humann")

  files <- list.files(
    humann_dir,
    pattern = "_pathabundance\\.tsv$",
    full.names = TRUE,
    recursive = TRUE
  )

  if (length(files) == 0) return(tibble::tibble())

  purrr::map_dfr(files, function(f) {

    sample <- basename(f)
    sample <- stringr::str_remove(sample, "_pathabundance\\.tsv$")

    df <- readr::read_tsv(
      f,
      comment = "#",
      col_names = c("pathway", "abundance"),
      show_col_types = FALSE
    )

    df |>
      dplyr::mutate(
        sample = sample,
        stratified = stringr::str_detect(pathway, "\\|")
      ) |>
      dplyr::filter(
        !stratified,
        !pathway %in% c("UNMAPPED", "UNINTEGRATED")
      ) |>
      dplyr::select(sample, pathway, abundance)
  })
}
