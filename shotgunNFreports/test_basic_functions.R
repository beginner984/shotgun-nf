library(dplyr)
library(ggplot2)

source("R/utils.R")
source("R/read_fastp.R")
source("R/read_bracken.R")
source("R/plot_taxonomy.R")
source("R/plot_diversity.R")

results_dir <- "../results"
outdir <- "../paper/results_evidence/final/r_package_test"
dir.create(outdir, recursive = TRUE, showWarnings = FALSE)

fastp <- read_fastp_summary(results_dir)
bracken_species <- read_bracken(results_dir, level = "species")

alpha <- calculate_alpha_diversity(bracken_species)
pcoa <- calculate_beta_pcoa(bracken_species)

readr::write_csv(fastp, file.path(outdir, "fastp_summary.csv"))
readr::write_csv(bracken_species, file.path(outdir, "bracken_species.csv"))
readr::write_csv(alpha, file.path(outdir, "alpha_diversity.csv"))
readr::write_csv(pcoa, file.path(outdir, "beta_pcoa.csv"))

p_taxa <- plot_taxa_barplot(bracken_species, top_n = 15)
p_alpha <- plot_alpha_diversity(alpha)
p_pcoa <- plot_beta_pcoa(pcoa)

ggsave(file.path(outdir, "taxonomy_barplot.png"), p_taxa, width = 9, height = 6, dpi = 300)
ggsave(file.path(outdir, "alpha_diversity.png"), p_alpha, width = 9, height = 6, dpi = 300)
ggsave(file.path(outdir, "beta_pcoa.png"), p_pcoa, width = 7, height = 6, dpi = 300)

message("Done. Outputs written to: ", outdir)
