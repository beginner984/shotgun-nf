# Test dataset validation

## Dataset

A public paired-end Illumina shotgun metagenomic dataset was used as a lightweight functional test case for the workflow.

- Accession: SRR2584869
- Source: ENA/SRA
- Format: paired-end FASTQ.gz
- Local test folder: `test_data/cami_toy/`
- Samplesheet: `test_data/cami_toy/samplesheet_cami_toy_abs.csv`

## Purpose

This dataset was used to test whether the Nextflow DSL2 shotgun metagenomics workflow can run from raw paired-end FASTQ input through the main analysis branches, including:

- read preprocessing
- taxonomic profiling
- functional profiling
- metagenome assembly
- binning
- bin quality assessment
- annotation
- antimicrobial resistance screening
- biosynthetic gene cluster detection
- strain-level profiling

## Notes

The FASTQ files themselves are not committed to Git because they are large sequencing data files. Only the samplesheet and documentation are tracked.

## Manuscript wording

For functional validation of the shotgun metagenomics workflow, a publicly available paired-end Illumina shotgun metagenomic dataset was used as a lightweight test case. Reads from accession SRR2584869 were downloaded from the European Nucleotide Archive/SRA in compressed FASTQ format and organised into a Nextflow-compatible samplesheet. This dataset was used to verify workflow execution from raw paired-end reads through preprocessing, taxonomic profiling, assembly, binning, bin quality assessment, annotation, antimicrobial resistance screening, biosynthetic gene cluster detection, and strain-level profiling.
