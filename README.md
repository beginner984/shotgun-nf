# Shotgun-NF

## Introduction

Shotgun-NF is a Nextflow DSL2 pipeline for comprehensive shotgun metagenomics analysis.

The pipeline integrates read quality control, taxonomic profiling, metagenome assembly, genome binning, MAG quality assessment, functional annotation, antimicrobial resistance detection, biosynthetic gene cluster prediction, strain-level profiling and comparative genomics into a single reproducible workflow.

The pipeline is portable across HPC systems and local workstations through Conda and Apptainer environments.

## Pipeline summary

Depending on the selected options, Shotgun-NF can perform:

- Read quality control (fastp)
- Host removal
- Taxonomic profiling (Kraken2 + Bracken + Krona)
- Functional profiling (HUMAnN3)
- Metagenome assembly (MEGAHIT)
- Genome binning (MetaBAT2)
- MAG quality assessment (CheckM2)
- MAG filtering
- Genome annotation (Prokka)
- Antimicrobial resistance prediction (RGI/CARD)
- Biosynthetic gene cluster prediction (antiSMASH)
- MAG taxonomic classification (GTDB-Tk)
- Whole-genome similarity analysis (FastANI)
- Strain-level phylogeny (MetaPhlAn + StrainPhlAn)
- MultiQC reporting
- Automatic HTML report generation

All major analyses can be independently enabled or disabled using pipeline parameters.	

## Modular execution

Shotgun-NF is designed as a modular workflow. Individual analyses can be enabled or disabled according to the study design, sample type, and available computational resources.

| Module                                         | Default        | Can be skipped                     |
| ---------------------------------------------- | -------------- | ---------------------------------- |
| fastp                                          | Yes            | No                                 |
| Host removal                                   | User-dependent | Yes                                |
| Kraken2 / Bracken / Krona                      | Yes            | Yes                                |
| HUMAnN                                         | Yes            | Yes                                |
| MEGAHIT assembly                               | Yes            | Yes                                |
| MetaBAT2 binning                               | Yes            | No (if the MAG branch is executed) |
| CheckM2 quality assessment                     | Yes            | No                                 |
| Prokka annotation                              | Yes            | Yes                                |
| RGI antimicrobial resistance detection         | Yes            | Yes                                |
| antiSMASH biosynthetic gene cluster prediction | Yes            | Yes                                |
| GTDB-Tk taxonomic classification               | No             | Yes                                |
| FastANI comparative genomics                   | No             | Yes                                |
| StrainPhlAn strain-level phylogeny             | Yes            | Yes                                |
| eggNOG-mapper functional annotation            | No             | Yes                                |
| MultiQC summary report                         | Yes            | Yes                                |
| Automatic HTML report                          | No             | Yes                                |

### Example use cases

**Human-associated metagenomes (host removal enabled):**

```bash
--skip_host_removal false
```

**Environmental metagenomes without a host reference genome:**

```bash
--skip_host_removal true
```

**Run without eggNOG functional annotation:**

```bash
--run_eggnog false
```

**Enable eggNOG functional annotation:**

```bash
--run_eggnog true
```

Shotgun-NF supports both complete end-to-end analysis and modular execution, allowing users to enable or disable components such as host removal, HUMAnN, eggNOG-mapper, GTDB-Tk, FastANI, antiSMASH, and strain-level profiling according to their experimental design and computational requirements.



# Typical usage

# Full pipeline

nextflow run beginner984/shotgun-nf \
-profile conda \
--input samples.csv \
--outdir results

# Taxonomic profiling only

--run_humann false \
--run_antismash false \
--run_gtdbtk false \
--run_fastani false \
--run_strainphlan false

# MAG analysis only

--run_strainphlan false \
--run_humann false

## Workflow overview

The pipeline processes paired-end shotgun metagenomics FASTQ files through assembly, binning, quality filtering, annotation, AMR detection, BGC detection, taxonomic profiling, strain-level analysis, and MAG taxonomy.

```text id="wf001"
Input:
  paired-end FASTQ files
        |
        v
  MEGAHIT
        |
        v
  MetaBAT
        |
        v
  CheckM2
        |
        v
  FILTER_BINS
        |
        v
  COLLECT_PASSED_BINS
        |
        +---------------------> PROKKA
        |                         |
        |                         v
        |                        annotation outputs
        |
        +---------------------> RGI
        |                         |
        |                         v
        |                        AMR outputs
        |
        +---------------------> antiSMASH
        |                         |
        |                         v
        |                        BGC outputs
        |
        +---------------------> GTDB-Tk
                                  |
                                  v
                                 MAG taxonomy outputs

Parallel read-based branch:
  FASTQ
    |
    v
  MetaPhlAn
    |
    v
  sample2markers
    |
    v
  StrainPhlAn clade discovery
    |
    v
  StrainPhlAn phylogeny
```

## Expected outputs per step

This section describes the expected main output from each pipeline step.

### Workflow logic

The workflow has two major branches:

1. **MAG-based branch**

   * FASTQ → assembly → bins → quality-filtered MAGs
   * Downstream analyses on passed MAGs:

     * Annotation
     * AMR detection
     * BGC detection
     * MAG taxonomy

2. **Read-based strain branches**

   * FASTQ → MetaPhlAn → marker extraction → clade discovery → strain phylogeny

This separation is intentional:

* MAG-based analyses operate on reconstructed genomes
* Strain-level analyses operate on marker information derived directly from reads


### 1. Input

**Input: ** paired-end FASTQ files listed in the samplesheet

**Expected input format:**

* `sample`
* `fastq_1`
* `fastq_2`
* `instrument_platform`
* `run_accession`

---

### 2. MEGAHIT

**Purpose: ** metagenome assembly

**Input: ** paired-end FASTQ files

**Main output: **

* Assembled contigs for each sample

**Output location: **

* `results/assembly/`

---

### 3. MetaBAT

**Purpose: ** bin contigs into draft genomes

**Input: ** assembled contigs

**Main output: **

* Raw genome bins per sample

**Output location: **

* `results/bins/`

---

### 4. CheckM2

**Purpose: ** estimate bin quality

**Input: ** raw genome bins

**Main output: **

* Completeness and contamination estimate per bin
* `quality_report.tsv`

**Output location: **

* `results/checkm2/`

---

### 5. FILTER_BINS

**Purpose: ** retain bins meeting quality thresholds

**Input: ** CheckM2 `quality_report.tsv`

**Default thresholds: **

* completeness ≥ 50
* contamination < 10

**Main output: **

* Per-sample TSV listing bins that passed filtering

**Output location: **

* `results/filtered_bins/`

---

### 6. COLLECT_PASSED_BINS

**Purpose: ** copy retained MAGs into a clean downstream folder

**Input: ** filtered bin list + raw bins

**Main output: **

* high-quality passed MAG FASTA files

**Output location: **

* `results/passed_bins/`

---

### 7. PROKKA

**Purpose: ** genome annotation of passed MAGs

**Input: ** passed MAG FASTA files

**Main output: **

* Annotated genome files, including:

  * `.gff`
  * `.faa`
  * `.ffn`
  * `.gbk`

**Output location: **

* `results/prokka/`

---

### 8. RGI

**Purpose: ** AMR gene detection

**Input: ** passed MAG FASTA files

**Main output: **

* AMR predictions based on CARD/RGI

**Output location: **

* `results/rgi/`

---

### 9. antiSMASH

**Purpose: ** biosynthetic gene cluster detection

**Input: ** passed MAG FASTA files

**Main output: **

* antiSMASH reports per sample and per retained bin
* region `.gbk` files
* `index.html` reports for each analysed bin

**Output location: **

* `results/antismash/`

---

### 10. MetaPhlAn

**Purpose: ** taxonomic profiling and read-based marker mapping

**Input: ** paired-end FASTQ files

**Main output: **

* Taxonomic profile
* mapping/alignment output for marker extraction

**Output location: **

* `results/strainphlan/metaphlan/`

---

### 11. sample2markers

**Purpose: ** extract marker information for strain analysis

**Input: ** MetaPhlAn alignment output

**Main output: **

* Marker JSON files per sample

**Output location: **

* `results/strainphlan/markers/`

---

### 12. StrainPhlAn clade discovery

**Purpose: ** identify clades with sufficient data for strain phylogeny

**Input: ** sample marker JSON files

**Main output: **

* `print_clades_only.tsv`

**Output location: **

* `results/strainphlan/clades/`

---

### 13. StrainPhlAn phylogeny

**Purpose: ** infer strain-level phylogeny for selected clades

**Input: ** marker JSON files + selected clade

**Main output: **

* RAxML tree files
* Concatenated alignment
* Polymorphism summary
* Clade info file

**Output location: **

* `results/strainphlan/final/`

---

### 14. GTDB-Tk

**Purpose: ** assign taxonomy to passed MAGs

**Input: ** passed MAG FASTA files

**Main output: **

* GTDB-Tk taxonomy summary files for MAGs

**Output location: **

* `results/gtdbtk/`

---

### 15. Pipeline provenance outputs

**Purpose: ** record execution metadata for reproducibility and audit

**Generated only when enabled with Nextflow `-with-*` flags**

**Main output: **

* `execution_report.html`
* `trace.tsv`
* `timeline.html`
* `dag.html`

**Output location: **

* `results/pipeline_info/`
## Input

A CSV samplesheet:

sample,fastq_1,fastq_2,instrument_platform,run_accession

Example:

USG1_C2_25,raw_fastq/sample_R1.fq.gz,raw_fastq/sample_R2.fq.gz,ILLUMINA,USG1_C2_25

---

## How to run

### Standard execution (with full traceability)

```bash
module load Java/17
cd /parallel_scratch/USERNAME/shotgun_nf_pipeline
mkdir -p results/pipeline_info

nextflow run main.nf \
  -profile eureka2 \
  --input samplesheet.csv \
  --outdir results \
  -resume \
  -with-report results/pipeline_info/execution_report.html \
  -with-trace results/pipeline_info/trace.tsv \
  -with-timeline results/pipeline_info/timeline.html \
  -with-dag results/pipeline_info/dag.html
```

## Minimal vs full run

The pipeline can be run in two main modes depending on the purpose.

### Minimal run

Use this for:

* Quick debugging
* Development
* Testing whether the workflow runs correctly on a subset of samples

Typical characteristics:

* Small test samplesheet
* Fewer samples
* May omit full production metadata if only debugging

Example:

```bash id="run001"
nextflow run main.nf \
  -profile eureka2 \
  --input samplesheet_test4.csv \
  --outdir results \
  -resume
```

---

### Full run

Use this for:

* Final analysis
* Deliverable generation
* Reproducibility and audit trail
* Preparing publication or regulatory documentation

This mode should always include the Nextflow reporting flags.

Example:

```bash id="run002"
mkdir -p results/pipeline_info

nextflow run main.nf \
  -profile eureka2 \
  --input samplesheet.csv \
  --outdir results \
  -resume \
  -with-report results/pipeline_info/execution_report.html \
  -with-trace results/pipeline_info/trace.tsv \
  -with-timeline results/pipeline_info/timeline.html \
  -with-dag results/pipeline_info/dag.html
```

---

### Important distinction

* **Minimal run** checks whether the workflow works
* **Full run** generates both scientific outputs and reproducibility / traceability outputs

The `results/pipeline_info/` directory is only populated when the `-with-report`, `-with-trace`, `-with-timeline`, and `-with-dag` flags are used.


### Important

The `pipeline_info/` directory is **only populated when the `-with-*` flags are provided**.

If these flags are omitted, no execution metadata will be generated.


## Reproducibility and Traceability

This pipeline can generate full execution provenance (when enabled via Nextflow reporting flags) using Nextflow built-in reporting:

* `execution_report.html` → summary of pipeline execution, resources, and status
* `trace.tsv` → per-process audit table (CPU, memory, runtime, exit status)
* `timeline.html` → execution timeline of all tasks
* `dag.html` → workflow structure and dependencies

These files are stored in:

```
results/pipeline_info/
```

The `trace.tsv` file provides complete traceability of all computational steps and is the primary record for reproducibility and regulatory audit.


## Key parameters

* `--min_completeness` (default: 50)
* `--max_contamination` (default: 10)
* `--card_db`
* `--metaphlan_db_dir`
* `--strainphlan_pkl`
* `--antismash_sif`
* `--gtdbtk_db`

---

## Quality filtering

Bins are retained if:

* completeness ≥ min_completeness
* contamination < max_contamination

(Default: ≥50% completeness and <10% contamination)

---
## Outputs

See OUTPUT_MAP.md for detailed explanation of output folders.

---

## Status

Pipeline components validated:

* MAG recovery
* AMR detection
* antiSMASH BGC detection
* strain-level phylogeny

GTDB-Tk: pending database completion

## Error handling

Process failure is detected by Nextflow using task exit status and validation of expected output files. Failed tasks are recorded in `.nextflow.log`, `trace.tsv`, and the corresponding task work directory under `work/`.

For critical analysis steps, the pipeline is intended to terminate on failure to prevent propagation of invalid intermediate results. Where appropriate, controlled retry behaviour may be enabled for infrastructure-related failures.
