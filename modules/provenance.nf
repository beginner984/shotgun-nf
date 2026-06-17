process PROVENANCE {

    publishDir "${params.outdir}/provenance", mode: 'copy'

    input:
    val outdir

    output:
    path "ro-crate-metadata.json"
    path "README_provenance.txt"

    script:
    """
    cat > ro-crate-metadata.json <<EOF
{
  "@context": "https://w3id.org/ro/crate/1.1/context",
  "@graph": [
    {
      "@id": "ro-crate-metadata.json",
      "@type": "CreativeWork",
      "about": {
        "@id": "./"
      }
    },
    {
      "@id": "./",
      "@type": "Dataset",
      "name": "Shotgun-NF provenance package",
      "description": "Workflow provenance and reproducibility metadata for Shotgun-NF",
      "hasPart": [
        { "@id": "pipeline_info/trace.tsv" },
        { "@id": "pipeline_info/report.html" },
        { "@id": "pipeline_info/timeline.html" },
        { "@id": "pipeline_info/dag.html" }
      ]
    }
  ]
}
EOF

    cat > README_provenance.txt <<EOF
Shotgun-NF provenance package

Included reproducibility evidence:
- Nextflow trace
- execution report
- timeline
- DAG
- MultiQC
- workflow outputs

This is a lightweight RO-Crate-style provenance implementation.
EOF
    """
}
