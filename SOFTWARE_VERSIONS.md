# Software Versions

## Read preprocessing
- fastp: 0.23.4

## Taxonomic classification
- Kraken2: 2.1.5
- Kraken2 database: local (standard build, ~27.5 GB)

## Functional profiling
- HUMAnN: 3.7
- ChocoPhlAn database: v2019 (local installation)
- UniRef: uniref90_201901b_full.dmnd

## Reporting
- MultiQC: 1.19

## Workflow engine
- Nextflow: 25.10.4
- Java: OpenJDK 17.0.2

## Assembly and binning
- MEGAHIT: 1.2.9
- MetaBAT2: 2.18

## Bin quality assessment and filtering
- CheckM2: 1.1.0
- Filtering thresholds:
  - minimum completeness: 50
  - maximum contamination: 10

## Annotation and AMR
- Prokka: 1.14.6
- RGI: 6.0.3
- CARD database: local installation (`localDB`)

## Taxonomy and strain analysis
- MetaPhlAn: 4.2.4
- StrainPhlAn: 4.2.4
- sample2markers.py: bundled with MetaPhlAn/StrainPhlAn 4.2.4
- MetaPhlAn database: mpa_vJan25_CHOCOPhlAnSGB_202503

## BGC detection
- antiSMASH: 8.0.4
- Execution: Apptainer container
- Image: /users/fi0001/scratch/kerry/antismash_standalone.sif

## MAG taxonomy
- GTDB-Tk: 2.7.0

## Notes
All versions were extracted directly from the actual Nextflow task environments 
(conda environments or containers) via `.command.sh` and `.command.run`, 
ensuring full traceability and reproducibility.
