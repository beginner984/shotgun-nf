# DATABASES.md

# Shotgun-NF Database Requirements

Shotgun-NF requires several external reference databases. These databases are not distributed with the repository and must be downloaded separately before running the pipeline.

The database versions listed below were used during development, validation, benchmarking, and manuscript generation. Users may use newer releases, although results may differ from those reported in the manuscript.

## Quick Setup

Copy the template configuration:

```bash
cp conf/template.config my.config
```

Edit the database paths:

```bash
nano my.config
```

Run the workflow:

```bash
nextflow run . \
    -c my.config \
    --input samplesheet.csv \
    --outdir results
```

---

# Core Databases

## Kraken2

Used by:

* Kraken2 taxonomic classification

Tool version:

* Kraken2 v2.1.5

Database used in manuscript:

* Kraken2 Standard Database

Download:

```bash
kraken2-build --standard --db kraken2_db
```

Configuration:

```groovy
kraken2_db = "/path/to/kraken2_db"
```

---

## CheckM2

Used by:

* CheckM2 MAG quality assessment

Tool version:

* CheckM2 v1.1.0

Database used in manuscript:

* uniref100.KO.1.dmnd

Download:

```bash
checkm2 database --download
```

Configuration:

```groovy
checkm2_db = "/path/to/CheckM2_database/uniref100.KO.1.dmnd"
```

Source:
https://github.com/chklovski/CheckM2

---

## CARD

Used by:

* RGI antimicrobial resistance detection

Tool version:

* RGI v6.0.3

Database:

* CARD database compatible with RGI v6.0.3

Download:

```bash
rgi load --card_json
```

Configuration:

```groovy
card_db = "/path/to/card_database"
```

Source:
https://card.mcmaster.ca/

---

## MetaPhlAn

Used by:

* MetaPhlAn taxonomic profiling
* StrainPhlAn strain-level analysis

Tool version:

* MetaPhlAn v4.2.4

Database used in manuscript:

* mpa_vJan25_CHOCOPhlAnSGB_202503

Install:

```bash
metaphlan --install
```

Configuration:

```groovy
metaphlan_db_dir = "/path/to/metaphlan_database"
metaphlan_index  = "mpa_vJan25_CHOCOPhlAnSGB_202503"
```

Source:
https://github.com/biobakery/MetaPhlAn

---

## Krona Taxonomy

Used by:

* Krona visualisation

Download:

```bash
ktUpdateTaxonomy.sh
```

Configuration:

```groovy
krona_taxonomy = "/path/to/krona_taxonomy"
```

Source:
https://github.com/marbl/Krona

---

# Additional Databases Required for Specific Modules

## StrainPhlAn

Required when:

```groovy
run_strainphlan = true
```

Tool version:

* StrainPhlAn v4.2.4

Reference database used in manuscript:

* mpa_vJan25_CHOCOPhlAnSGB_202503.pkl

Configuration:

```groovy
strainphlan_pkl = "/path/to/metaphlan_database/mpa_vJan25_CHOCOPhlAnSGB_202503.pkl"
```

The PKL file is generated as part of the MetaPhlAn database installation.

---

## HUMAnN

Required when:

```groovy
run_humann = true
```

Tool version:

* HUMAnN v3.7

Databases used in manuscript:

Nucleotide database:

* ChocoPhlAn v2019

Protein database:

* UniRef90 (uniref90_201901b_full.dmnd)

Download:

```bash
humann_databases --download chocophlan full /path/to/databases

humann_databases --download uniref uniref90_diamond /path/to/databases
```

Configuration:

```groovy
humann_nucleotide_db = "/path/to/chocophlan"
humann_protein_db    = "/path/to/uniref"
humann_sif           = "/path/to/humann.sif"
```

---

## antiSMASH

Required when:

```groovy
run_antismash = true
```

Tool version:

* antiSMASH v8.0.4

Configuration:

```groovy
antismash_sif = "/path/to/antismash.sif"
```

Source:
https://antismash.secondarymetabolites.org/

---

## GTDB-Tk

Required when:

```groovy
run_gtdbtk = true
```

Tool version:

* GTDB-Tk v2.7.0

Database used in manuscript:

* GTDB release r226

Configuration:

```groovy
gtdbtk_db = "/path/to/gtdbtk_database"
```

Source:
https://ecogenomics.github.io/GTDBTk/

---

## Host Genome Removal

Required when:

```groovy
skip_host_removal = false
```

Configuration:

```groovy
host_index = "/path/to/bowtie2_index"
```

---

# Summary

| Parameter            | Purpose                             |
| -------------------- | ----------------------------------- |
| kraken2_db           | Kraken2 classification database     |
| checkm2_db           | CheckM2 quality assessment database |
| card_db              | CARD AMR database for RGI           |
| metaphlan_db_dir     | MetaPhlAn database directory        |
| metaphlan_index      | MetaPhlAn database index            |
| krona_taxonomy       | Krona taxonomy database             |
| strainphlan_pkl      | StrainPhlAn reference database      |
| humann_nucleotide_db | HUMAnN ChocoPhlAn database          |
| humann_protein_db    | HUMAnN UniRef database              |
| humann_sif           | HUMAnN container                    |
| antismash_sif        | antiSMASH container                 |
| gtdbtk_db            | GTDB-Tk database                    |
| host_index           | Host genome Bowtie2 index           |

