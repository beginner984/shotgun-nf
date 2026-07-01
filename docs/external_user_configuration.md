# External user configuration

Shotgun-NF separates workflow logic from environment-specific configuration.

Users should **not edit files inside the repository**. Instead, create a personal configuration file from the provided example.

```bash
cp conf/user.config.example my.config
```

Edit `my.config` and replace the placeholder database and container paths with those on your system.

Run the pipeline using your personal configuration file:

```bash
nextflow run beginner984/shotgun-nf \
    -profile local \
    -c my.config \
    --input path/to/samplesheet.csv \
    --outdir results
```

Database paths can also be overridden directly on the command line if desired:

```bash
nextflow run beginner984/shotgun-nf \
    -profile local \
    -c my.config \
    --input path/to/samplesheet.csv \
    --kraken2_db /data/db/kraken2 \
    --checkm2_db /data/db/checkm2/uniref100.KO.1.dmnd \
    --humann_protein_db /data/db/uniref \
    --humann_nucleotide_db /data/db/chocophlan
```
