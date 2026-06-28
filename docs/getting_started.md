# Getting Started with Shotgun-NF

## Introduction

This guide explains how to install, configure, and execute Shotgun-NF on a local workstation or high-performance computing (HPC) cluster.

The pipeline is modular and allows users to execute either the complete workflow or selected analysis modules according to their study design.

---

# 1. Requirements

Before running Shotgun-NF, ensure that the following software is installed:

* Java (version 17 or later)
* Nextflow
* Conda (Miniconda or Mambaforge)
* Apptainer/Singularity (required for selected modules)
* Git

---

# 2. Clone the repository

```bash
git clone https://github.com/beginner984/shotgun-nf.git
cd shotgun-nf
```

---

# 3. Download required databases

Shotgun-NF does not distribute third-party databases.

Please follow the instructions in `DATABASES.md` to download and configure:

* Kraken2 database
* CheckM2 database
* MetaPhlAn database
* HUMAnN nucleotide database
* HUMAnN protein database
* CARD database
* GTDB-Tk database
* antiSMASH container (optional)

---

## Configure Shotgun-NF

Shotgun-NF is configured through a user-specific configuration file. The recommended approach is to create a personal copy of the provided template and modify it according to your local environment.

Create your own configuration file:

```bash
cp conf/example.config my.config
```

Open `my.config` in your preferred text editor and update the database paths to match your system.

For example:

```groovy
checkm2_db = "/data/databases/checkm2/uniref100.KO.1.dmnd"
kraken2_db = "/data/databases/kraken2"
card_db    = "/data/databases/CARD/localDB"
gtdbtk_db  = "/data/databases/gtdbtk/release226"
```

You may also customise which modules are executed by changing the corresponding boolean parameters. For example:

```groovy
run_gtdbtk      = true
run_fastani     = true
run_eggnog      = false
run_strainphlan = false
skip_host_removal = true
```

The original `conf/example.config` should remain unchanged so that it can be reused as a clean template. All user-specific modifications should be made in `my.config`.

The pipeline can then be executed using:

```bash
nextflow run beginner984/shotgun-nf \
    -profile local \
    -c my.config \
    --input samplesheet.csv \
    --outdir results
```
# 5. Prepare the input samplesheet

The input samplesheet must contain three columns:

| sample | fastq_1 | fastq_2 |
| ------ | ------- | ------- |

Example:

```text
sample,fastq_1,fastq_2
Sample1,/path/to/Sample1_R1.fastq.gz,/path/to/Sample1_R2.fastq.gz
Sample2,/path/to/Sample2_R1.fastq.gz,/path/to/Sample2_R2.fastq.gz
```

---

# 6. Run the complete pipeline

```bash
nextflow run beginner984/shotgun-nf \
-profile local \
-c my.config \
--input samplesheet.csv \
--outdir results
```

---

# 7. Modular execution

Individual modules can be enabled or disabled according to the experimental design.

Examples include:

* host removal
* HUMAnN functional profiling
* eggNOG annotation
* antiSMASH
* GTDB-Tk
* FastANI
* StrainPhlAn

See the README for the available parameters.

---

# 8. Resume interrupted analyses

Shotgun-NF supports automatic execution resumption.

```bash
nextflow run beginner984/shotgun-nf \
-profile local \
-c my.config \
--input samplesheet.csv \
--outdir results \
-resume
```

---

# 9. Output structure

The output directory contains results organised by analysis module, including:

* quality control reports
* taxonomic profiling
* assemblies
* MAGs
* genome annotations
* antimicrobial resistance predictions
* biosynthetic gene cluster predictions
* strain-level analyses
* comparative genomics results
* MultiQC summaries
* execution reports

---

# 10. Troubleshooting

If a required database path is missing or incorrect, the pipeline will terminate with an informative error message.

If an execution is interrupted, rerun the same command with the `-resume` option to continue from completed steps.

For additional configuration examples, see:

* `conf/example.config`
* `docs/external_user_configuration.md`

---

# 11. Citation

If you use Shotgun-NF in your research, please cite the associated publication together with the GitHub repository and release version.


