#' Read antiSMASH JSON outputs
#'
#' @param results_dir Shotgun-NF results directory.
#' @return Tibble of BGC regions.
#' @export
read_antismash <- function(results_dir) {
  antismash_dir <- file.path(results_dir, "antismash")

  files <- list.files(
    antismash_dir,
    pattern = "\\.json$",
    recursive = TRUE,
    full.names = TRUE
  )

  if (length(files) == 0) {
    warning("No antiSMASH JSON files found")
    return(tibble::tibble())
  }

  purrr::map_dfr(files, function(f) {
    j <- tryCatch(jsonlite::fromJSON(f, simplifyVector = FALSE), error = function(e) NULL)
    if (is.null(j) || is.null(j$records)) return(tibble::tibble())

    parts <- strsplit(f, "/")[[1]]

    sample_dir <- parts[stringr::str_detect(parts, "_antismash$")][1]
    sample <- stringr::str_remove(sample_dir, "_antismash$")

    bin_id <- basename(dirname(f))

    purrr::map_dfr(j$records, function(rec) {
      contig <- rec$id %||% rec$name %||% NA_character_

      if (!is.null(rec$areas) && length(rec$areas) > 0) {
        purrr::map_dfr(rec$areas, function(a) {
          products <- a$products %||% a$product %||% NA_character_
          product_class <- paste(unlist(products), collapse = ";")

          tibble::tibble(
            sample = sample,
            bin_id = bin_id,
            contig = as.character(contig),
            bgc_id = as.character(a$id %||% a$region %||% NA),
            start = suppressWarnings(as.numeric(a$start %||% NA)),
            end = suppressWarnings(as.numeric(a$end %||% NA)),
            product_class = product_class,
            source_file = f
          )
        })
      } else {
        tibble::tibble()
      }
    })
  }) |>
    dplyr::mutate(
      product_class = dplyr::if_else(
        is.na(product_class) | product_class == "",
        "Unknown",
        product_class
      )
    )
}
