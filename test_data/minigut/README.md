# MiniGut test dataset

This directory contains a small shotgun metagenomics test dataset for validating Shotgun-NF.

Contents:
- Two paired-end metagenomic samples
- Example samplesheet: samplesheet.csv
- Total size: approximately 10 MB

Run from the main Shotgun-NF repository directory:

1. Copy the configuration template:

cp conf/template.config my.config

2. Edit my.config and replace the example database paths with your local database paths.

3. Run the test:

nextflow run beginner984/shotgun-nf -profile local -c my.config --input test_data/minigut/samplesheet.csv --outdir test_results

Expected result:
The pipeline should complete successfully and create the test_results directory.

This dataset is for installation and workflow validation only, not biological interpretation.
