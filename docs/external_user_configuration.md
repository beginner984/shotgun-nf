# External user configuration

Shotgun-NF separates workflow logic from environment-specific configuration.

External users should copy `conf/template.config`, replace database and container paths with local paths, and run the workflow without editing `main.nf`.

Example:

```bash
nextflow run main.nf \
-c conf/template.config \
--input samplesheet.csv \
--outdir results \
--run_strainphlan false


Database paths can also be provided directly on the command line:


nextflow run main.nf \
-c conf/template.config \
--input samplesheet.csv \
--kraken2_db /data/db/kraken2 \
--checkm2_db /data/db/checkm2/uniref100.KO.1.dmnd \
--humann_protein_db /data/db/uniref \
--humann_nucleotide_db /data/db/chocophlan

