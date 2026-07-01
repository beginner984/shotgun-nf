# Getting Started with Shotgun-NF

## Introduction

Shotgun-NF is a Nextflow DSL2 pipeline for comprehensive shotgun metagenomics analysis. It can be executed on local workstations or HPC clusters using either Conda or Apptainer.

---

# 1. Prerequisites

Before running Shotgun-NF, ensure that the following software is installed:

- Java (17 or later)
- Nextflow
- Git

Depending on how you intend to run the pipeline:

- Conda (Miniconda or Mambaforge)
- Apptainer/Singularity (optional)

---

# 2. Clone the repository

```bash
git clone https://github.com/beginner984/shotgun-nf.git
cd shotgun-nf
```

---

# 3. Download reference databases

Shotgun-NF does not distribute third-party databases.

Download the required databases by following the instructions in:

```
DATABASES.md
```

Alternatively, a helper script is provided:

```bash
bash scripts/download_reference_assets.sh databases
```

The helper script generates download instructions and an example database configuration file. Alternatively, users can create their own configuration from conf/user.config.example.

---

# 4. Configure the pipeline

Create your own configuration file.

```bash
cp conf/user.config.example my.config
```

Edit `my.config` and replace the placeholder database paths with the locations on your system.

For example:

```groovy
checkm2_db       = "/data/checkm2/uniref100.KO.1.dmnd"
kraken2_db       = "/data/kraken2"
card_db          = "/data/CARD/localDB"
metaphlan_db_dir = "/data/metaphlan"
```

**Important**

`my.config` should only contain user-specific parameters such as database paths and analysis options.

Do **not** modify execution settings (executor, Conda, Apptainer, etc.). Those are selected using Nextflow profiles.

---

# 5. Prepare the input samplesheet

The samplesheet must contain three columns:

| sample | fastq_1 | fastq_2 |

Example:

```text
sample,fastq_1,fastq_2
Sample1,/path/to/Sample1_R1.fastq.gz,/path/to/Sample1_R2.fastq.gz
Sample2,/path/to/Sample2_R1.fastq.gz,/path/to/Sample2_R2.fastq.gz
```

---

# 6. Choose an execution profile

Shotgun-NF separates user configuration from execution.

Choose the profile appropriate for your system. Execution profiles determine how Shotgun-NF is executed (local workstation, HPC cluster, Conda or Apptainer). my.config should only contain user-specific parameters such as database paths and analysis options.

## Local workstation (Conda)

```bash
nextflow run beginner984/shotgun-nf \
    -profile local \
    -c my.config \
    --input path/to/samplesheet.csv \
    --outdir results \
    -resume
```

## HPC cluster using Conda

Example (Eureka2):

```bash
nextflow run beginner984/shotgun-nf \
    -profile conda,eureka2 \
    -c my.config \
    --input path/to/samplesheet.csv \
    --outdir results \
    -resume
```

## HPC cluster using Apptainer

Example (Eureka2):

```bash
nextflow run beginner984/shotgun-nf \
    -profile apptainer,eureka2 \
    -c my.config \
    --input path/to/samplesheet.csv \
    --outdir results \
    -resume
```

---

# 7. Optional modules

Optional analyses can be enabled or disabled in `my.config`.

Examples include:

- HUMAnN
- GTDB-Tk
- FastANI
- StrainPhlAn
- eggNOG
- antiSMASH

See the README for all available parameters.

---

# 8. Output

Shotgun-NF produces:

- Quality-control reports
- Taxonomic profiles
- Assemblies
- MAGs
- Functional annotation
- AMR prediction
- BGC prediction
- Comparative genomics
- MultiQC report
- Pipeline provenance
- Optional HTML report

---

# 9. Troubleshooting

If a required database path is missing, the pipeline will terminate during the database validation step with an informative error message.

If a previous execution exists, rerun the same command with `-resume` to continue from completed steps.

---

# 10. Citation

If you use Shotgun-NF in your research, please cite the accompanying publication together with the GitHub repository and release version.
