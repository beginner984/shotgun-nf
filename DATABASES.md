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
