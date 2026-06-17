#!/bin/bash
set -euo pipefail

INPUT=$1
SAMPLE=$2

if [[ "$INPUT" == *.gz ]]; then
    gunzip -c "$INPUT" > "${SAMPLE}.fa"
    INPUT="${SAMPLE}.fa"
fi

antismash \
  "${INPUT}" \
  --output-dir "${SAMPLE}_antismash" \
  --taxon bacteria \
  --genefinding-tool prodigal \
  --cb-general \
  --cb-knownclusters \
  --cb-subclusters \
  --fullhmmer \
  --cpus 4
