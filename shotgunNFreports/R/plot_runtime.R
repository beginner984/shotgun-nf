#' Plot Nextflow process runtime summary
#'
#' @param trace_df Nextflow trace table.
#' @return ggplot object.
#' @export
plot_runtime_by_process <- function(trace_df) {
  if (nrow(trace_df) == 0) stop("trace_df is empty")

  if (!"name" %in% names(trace_df) || !"duration" %in% names(trace_df)) {
    stop("Trace table must contain name and duration columns")
  }

  parse_duration_minutes <- function(x) {
    x <- as.character(x)
    out <- rep(NA_real_, length(x))

    sec_idx <- stringr::str_detect(x, "s$") & !stringr::str_detect(x, "m|h|d")
    min_idx <- stringr::str_detect(x, "m")
    hour_idx <- stringr::str_detect(x, "h")
    day_idx <- stringr::str_detect(x, "d")

    out[sec_idx] <- readr::parse_number(x[sec_idx]) / 60
    out[min_idx] <- readr::parse_number(x[min_idx])
    out[hour_idx] <- readr::parse_number(x[hour_idx]) * 60
    out[day_idx] <- readr::parse_number(x[day_idx]) * 24 * 60

    out
  }

  plot_df <- trace_df |>
    dplyr::mutate(
      process = stringr::str_remove(name, "\\s*\\(.+\\)$"),
      duration_min = parse_duration_minutes(duration)
    ) |>
    dplyr::filter(!is.na(duration_min)) |>
    dplyr::group_by(process) |>
    dplyr::summarise(
      mean_duration_min = mean(duration_min, na.rm = TRUE),
      max_duration_min = max(duration_min, na.rm = TRUE),
      n_tasks = dplyr::n(),
      .groups = "drop"
    ) |>
    dplyr::arrange(desc(max_duration_min))

  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = stats::reorder(process, max_duration_min), y = max_duration_min)
  ) +
    ggplot2::geom_col(fill = "grey40") +
    ggplot2::coord_flip() +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::labs(
      title = "Maximum runtime by Nextflow process",
      x = "Process",
      y = "Maximum runtime (minutes)"
    )
}

#' Plot Nextflow peak memory by process
#'
#' @param trace_df Nextflow trace table.
#' @return ggplot object.
#' @export
plot_memory_by_process <- function(trace_df) {
  if (nrow(trace_df) == 0) stop("trace_df is empty")

  mem_col <- names(trace_df)[stringr::str_detect(tolower(names(trace_df)), "peak_rss")][1]
  if (is.na(mem_col)) stop("Could not identify peak_rss column")

  parse_mem_gb <- function(x) {
    x <- as.character(x)
    x[x == "-" | x == "" | is.na(x)] <- NA_character_

    val <- suppressWarnings(readr::parse_number(x))

    dplyr::case_when(
      stringr::str_detect(x, "TB") ~ val * 1024,
      stringr::str_detect(x, "GB") ~ val,
      stringr::str_detect(x, "MB") ~ val / 1024,
      stringr::str_detect(x, "KB") ~ val / (1024^2),
      TRUE ~ NA_real_
    )
  }

  plot_df <- trace_df |>
    dplyr::mutate(
      process = stringr::str_remove(name, "\\s*\\(.+\\)$"),
      peak_memory_gb = parse_mem_gb(.data[[mem_col]])
    ) |>
    dplyr::filter(!is.na(peak_memory_gb), is.finite(peak_memory_gb)) |>
    dplyr::group_by(process) |>
    dplyr::summarise(
      max_peak_memory_gb = max(peak_memory_gb, na.rm = TRUE),
      n_tasks = dplyr::n(),
      .groups = "drop"
    ) |>
    dplyr::arrange(desc(max_peak_memory_gb))

  if (nrow(plot_df) == 0) {
    return(
      ggplot2::ggplot() +
        ggplot2::theme_void(base_size = 12) +
        ggplot2::labs(title = "Peak memory by Nextflow process") +
        ggplot2::annotate(
          "text",
          x = 0,
          y = 0,
          label = "No peak memory values were available in trace.tsv",
          size = 5
        )
    )
  }

  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = stats::reorder(process, max_peak_memory_gb), y = max_peak_memory_gb)
  ) +
    ggplot2::geom_col(fill = "grey40") +
    ggplot2::coord_flip() +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::labs(
      title = "Peak memory by Nextflow process",
      x = "Process",
      y = "Peak RSS memory (GB)"
    )
}

