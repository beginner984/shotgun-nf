#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = FALSE)

file_arg <- "--file="
script_path <- sub(file_arg, "", args[grep(file_arg, args)])
script_dir <- dirname(normalizePath(script_path))
project_dir <- normalizePath(file.path(script_dir, ".."))

trailing <- commandArgs(trailingOnly = TRUE)

get_arg <- function(flag, default = NULL) {
  hit <- which(trailing == flag)
  if (length(hit) == 0) return(default)
  trailing[hit + 1]
}

results_dir <- get_arg("--results", "results")
outdir <- get_arg("--outdir", "report")

r_files <- list.files(file.path(script_dir, "R"), pattern = "\\.R$", full.names = TRUE)
invisible(lapply(r_files, source))

make_shotgunnf_report(
  results_dir = results_dir,
  outdir = outdir
)
