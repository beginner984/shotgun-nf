#!/usr/bin/env bash
set -euo pipefail

DB_ROOT="${1:-databases}"

mkdir -p "${DB_ROOT}"

echo "Shotgun-NF reference asset helper"
echo "Database root: ${DB_ROOT}"
echo

echo "This script creates directories and gives exact commands for the databases used in the manuscript."
echo "Some databases require large downloads, licenses, or manual registration."
echo

mkdir -p \
  "${DB_ROOT}/kraken2_standard" \
  "${DB_ROOT}/checkm2" \
  "${DB_ROOT}/card" \
  "${DB_ROOT}/metaphlan_vJun23" \
  "${DB_ROOT}/humann/chocophlan" \
  "${DB_ROOT}/humann/uniref" \
  "${DB_ROOT}/gtdbtk/release226" \
  "${DB_ROOT}/krona_taxonomy" \
  "${DB_ROOT}/containers"

cat > "${DB_ROOT}/README_download_commands.txt" <<'EOF'
# Shotgun-NF database download guide

These are the reference assets used or expected by the manuscript configuration.

## Kraken2 standard database

kraken2-build --standard --db databases/kraken2_standard

## CheckM2 database

checkm2 database --download --path databases/checkm2

Expected final file:
databases/checkm2/CheckM2_database/uniref100.KO.1.dmnd

## CARD database for RGI

Download CARD from:
https://card.mcmaster.ca/

Then load it using RGI, for example:

rgi load --card_json card.json --local

Set the config path to the resulting local CARD database directory.

## MetaPhlAn / StrainPhlAn database

The manuscript analysis used:

mpa_vJun23_CHOCOPhlAnSGB_202307

Install/download the matching MetaPhlAn database into:

databases/metaphlan_vJun23

The StrainPhlAn PKL should be:

databases/metaphlan_vJun23/mpa_vJun23_CHOCOPhlAnSGB_202307.pkl

## HUMAnN databases

humann_databases --download chocophlan full databases/humann
humann_databases --download uniref uniref90_diamond databases/humann

Expected configuration paths:
humann_nucleotide_db = "databases/humann/chocophlan"
humann_protein_db    = "databases/humann/uniref"

## GTDB-Tk

Download GTDB-Tk release r226 from the official GTDB-Tk database source.

Set:
gtdbtk_db = "databases/gtdbtk/release226"

## Krona taxonomy

ktUpdateTaxonomy.sh databases/krona_taxonomy

## antiSMASH

Use an antiSMASH 8.0.4 Apptainer/Singularity image.

Example path:
containers/antismash_8.0.4.sif

EOF

cat > "${DB_ROOT}/shotgun_nf_database_paths.config" <<EOF
params {
    kraken2_db           = "${DB_ROOT}/kraken2_standard"
    checkm2_db           = "${DB_ROOT}/checkm2/CheckM2_database/uniref100.KO.1.dmnd"
    card_db              = "${DB_ROOT}/card/localDB"

    metaphlan_db_dir     = "${DB_ROOT}/metaphlan_vJun23"
    metaphlan_index      = "mpa_vJun23_CHOCOPhlAnSGB_202307"
    strainphlan_pkl      = "${DB_ROOT}/metaphlan_vJun23/mpa_vJun23_CHOCOPhlAnSGB_202307.pkl"

    humann_nucleotide_db = "${DB_ROOT}/humann/chocophlan"
    humann_protein_db    = "${DB_ROOT}/humann/uniref"

    gtdbtk_db            = "${DB_ROOT}/gtdbtk/release226"
    krona_taxonomy       = "${DB_ROOT}/krona_taxonomy"

    antismash_sif        = "${DB_ROOT}/containers/antismash_8.0.4.sif"

    skip_host_removal    = true
    host_index           = null
}
EOF

echo "Created:"
echo "  ${DB_ROOT}/README_download_commands.txt"
echo "  ${DB_ROOT}/shotgun_nf_database_paths.config"
echo
echo "Next:"
echo "  1. Follow ${DB_ROOT}/README_download_commands.txt"
echo "  2. Edit ${DB_ROOT}/shotgun_nf_database_paths.config if needed"
echo "  3. Run:"
echo
echo "nextflow run . -c ${DB_ROOT}/shotgun_nf_database_paths.config --input samplesheet.csv --outdir results"
