# Databases used in the pipeline

## Kraken2 database
- Tool: Kraken2 v2.1.5
- Database: standard Kraken2 database (~27.5 GB)
- Location: /parallel_scratch/fi0001/databases/kraken2
- Notes: pre-built local database

## HUMAnN databases
- Tool: HUMAnN v3.7

### ChocoPhlAn (nucleotide database)
- Location: /parallel_scratch/fi0001/kerry/shutgun/databases/chocophlan
- Version: v2019
- Notes: used for nucleotide-level alignment

### UniRef (protein database)
- File: uniref90_201901b_full.dmnd
- Location: /parallel_scratch/fi0001/kerry/shutgun/databases/uniref
- Notes: used for translated search (DIAMOND)

## CheckM2 database
- Tool: CheckM2 v1.1.0
- Database: uniref100.KO.1.dmnd
- Source: https://github.com/chklovski/CheckM2
- Notes: default CheckM2 database

## CARD database (RGI)
- Tool: RGI v6.0.3
- Database: CARD
- Source: https://card.mcmaster.ca/
- Notes: local installation via `rgi load`

## MetaPhlAn database
- Tool: MetaPhlAn v4.2.4
- Database: mpa_vJan25_CHOCOPhlAnSGB_202503
- Source: https://github.com/biobakery/MetaPhlAn

## StrainPhlAn reference
- File: mpa_vJan25_CHOCOPhlAnSGB_202503.pkl
- Derived from MetaPhlAn database

## antiSMASH
- Version: 8.0.4
- Container: antismash_standalone.sif
- Source: https://antismash.secondarymetabolites.org/

## GTDB-Tk database
- Tool: GTDB-Tk v2.7.0
- Database: GTDB release r226
- Source: https://gtdb.ecogenomic.org/

# Database Requirements and Installation

For reproducibility, Shotgun-NF requires several external reference databases. Users must download and configure these databases before running the pipeline.

## Required Documentation

The repository should clearly specify:

1. Which databases are required.
2. Which database versions were used in the publication.
3. Where each database can be downloaded.
4. Which configuration parameter corresponds to each database.

## Recommended Database Table

| Parameter        | Database                  | Version used in paper               | Download source |
| ---------------- | ------------------------- | ----------------------------------- | --------------- |
| kraken2_db       | Kraken2 Standard Database | Version used in manuscript          | Kraken2         |
| checkm2_db       | CheckM2 Database          | uniref100.KO.1.dmnd                 | CheckM2 GitHub  |
| card_db          | CARD Database             | CARD version used by RGI 6.0.3      | CARD            |
| metaphlan_db_dir | MetaPhlAn Database        | mpa_vJan25_CHOCOPhlAnSGB_202503     | MetaPhlAn       |
| strainphlan_pkl  | MetaPhlAn PKL Reference   | mpa_vJan25_CHOCOPhlAnSGB_202503.pkl | MetaPhlAn       |
| gtdbtk_db        | GTDB-Tk Database          | GTDB r226                           | GTDB-Tk         |
| krona_taxonomy   | Krona Taxonomy            | Latest compatible release           | Krona           |

## Example Database Setup Instructions

### MetaPhlAn

Install MetaPhlAn database:

```bash
metaphlan --install
```

This creates a database such as:

```text
mpa_vJan25_CHOCOPhlAnSGB_202503
```

Configuration:

```groovy
metaphlan_db_dir = "/path/to/metaphlan"
metaphlan_index  = "mpa_vJan25_CHOCOPhlAnSGB_202503"
```

## Future Improvements

A future release may provide a helper script:

```bash
./bin/download_databases.sh
```

which automatically downloads and configures all required databases.

For version 1.0.0, a comprehensive `DATABASES.md` together with `conf/template.config` is sufficient. This approach is common among published bioinformatics pipelines and provides users with all information required to reproduce the analysis environment.

