# MAG comparative genomics extension plan

## Purpose

This extension will turn high-quality or medium-quality MAGs into publication-grade comparative genomics evidence.

Current Shotgun-NF already produces:

- cleaned reads
- taxonomic profiles
- HUMAnN functional profiles
- assemblies
- MAGs
- CheckM2 quality metrics
- Prokka annotations
- RGI AMR hits
- antiSMASH BGC regions
- automated evidence report

The next extension will add:

- ANI comparison
- pan-genome analysis
- core/accessory genome analysis
- phylogenomic comparison
- COG/functional diversity summary

## Biological question

Instead of only asking:

"Which MAGs were recovered?"

this extension asks:

"How similar are recovered MAGs to related public genomes, and do they show distinct accessory functional content?"

## Input

Primary input:

- trusted MAG FASTA files from filtered bins

Optional comparative input:

- related public genomes downloaded from NCBI/GTDB
- one species-focused genome set, for example all genomes related to one recovered MAG

## Proposed workflow

1. Select trusted MAGs
   - use CheckM2 completeness and contamination thresholds
   - keep medium/high quality MAGs

2. Identify species or closest relatives
   - GTDB-Tk or Mash/fastANI screen
   - choose one candidate species for deep comparison

3. Collect related genomes
   - download 10-20 public genomes for the selected species
   - combine public genomes with recovered MAG

4. Annotate all genomes consistently
   - Prokka or Bakta
   - optional eggNOG-mapper/COG annotation

5. ANI analysis
   - fastANI all-vs-all
   - output ANI matrix and ANI heatmap

6. Pan-genome analysis
   - Panaroo or anvi'o
   - identify core genes
   - accessory genes
   - singleton genes
   - gene presence/absence matrix

7. Phylogeny
   - core gene alignment
   - FastTree or IQ-TREE
   - compare tree structure with pan-genome clustering

8. Functional divergence
   - summarize accessory genes by COG/eggNOG category
   - identify functions enriched in accessory genome
   - compare core/accessory ratio between clades

## Expected outputs

Tables:

- trusted_MAGs_for_comparative_genomics.csv
- fastani_pairwise_results.csv
- ANI_matrix.csv
- pan_genome_gene_presence_absence.csv
- core_accessory_summary.csv
- accessory_function_summary.csv

Figures:

- ANI_heatmap.png
- pan_genome_presence_absence_heatmap.png
- core_accessory_barplot.png
- phylogenomic_tree.png
- accessory_function_barplot.png

## Tools

- CheckM2: MAG quality filtering
- GTDB-Tk or Mash: closest relative/species assignment
- fastANI: average nucleotide identity
- Prokka or Bakta: genome annotation
- Panaroo/anvi'o: pan-genome analysis
- FastTree/IQ-TREE: phylogeny
- eggNOG-mapper/COG: functional annotation

## Publication value

This module moves the pipeline from descriptive metagenomics to comparative MAG genomics.

It supports statements such as:

- the recovered MAG is closely related to public genomes
- the MAG belongs to a specific species-level cluster
- recovered genomes contain shared core genes and variable accessory genes
- accessory genes suggest functional divergence between clades
- MAG-level functional potential can be interpreted beyond taxonomy alone
