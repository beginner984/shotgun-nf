#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(pwd)"
CONDA_SH="/opt/software/pkgs/Anaconda3/2024.02-1/etc/profile.d/conda.sh"

run_tool_check() {
    local label="$1"
    local pattern="$2"
    local version_cmd="$3"

    echo
    echo "=============================="
    echo "TOOL: $label"
    echo "SEARCH PATTERN: $pattern"

    local cmdsh
    cmdsh=$(grep -R -l "$pattern" work/*/*/.command.sh 2>/dev/null | head -n 1 || true)

    if [[ -z "${cmdsh:-}" ]]; then
        echo "No matching task found for $label"
        return 0
    fi

    local taskdir
    taskdir="$(dirname "$cmdsh")"

    echo "TASK DIR: $taskdir"
    echo "--- .command.sh (first 20 lines) ---"
    head -n 20 "$taskdir/.command.sh" || true

    echo "--- environment hints from .command.run ---"
    grep -nE 'conda activate|apptainer exec|docker|singularity|PATH=' "$taskdir/.command.run" || true

    # Case 1: named conda env
    local env_name
    env_name=$(grep -oP 'conda activate \K\S+' "$taskdir/.command.run" | head -n 1 || true)

    if [[ -n "${env_name:-}" ]]; then
        echo "--- running version in conda env: $env_name ---"
        bash -lc "source '$CONDA_SH'; conda activate '$env_name'; $version_cmd" || true
        return 0
    fi

    # Case 2: apptainer image in command.sh
    local sif
    sif=$(grep -oP '/\S+\.sif' "$taskdir/.command.sh" | head -n 1 || true)

    if [[ -n "${sif:-}" ]]; then
        echo "--- running version in container: $sif ---"
        bash -lc "apptainer exec '$sif' $version_cmd" || true
        return 0
    fi

    # Case 3: direct shell command
    echo "--- running version directly in shell ---"
    bash -lc "$version_cmd" || true
}

echo "PROJECT ROOT: $PROJECT_ROOT"

echo
echo "===== ALWAYS-CONFIRMED GLOBAL TOOLS ====="
nextflow -version || true
java -version || true

run_tool_check "MEGAHIT"      "megahit"        "megahit --version"
run_tool_check "MetaBAT2"     "metabat"        "metabat2 --version"
run_tool_check "CheckM2"      "checkm2"        "checkm2 --version"
run_tool_check "PROKKA"       "prokka"         "prokka --version"
run_tool_check "RGI"          "rgi"            "rgi main --version"
run_tool_check "MetaPhlAn"    "metaphlan"      "metaphlan --version"
run_tool_check "StrainPhlAn"  "strainphlan"    "strainphlan -v"
run_tool_check "sample2markers" "sample2markers.py" "sample2markers.py -h | head"
run_tool_check "antiSMASH"    "antismash"      "antismash --version"
run_tool_check "GTDB-Tk"      "gtdbtk"         "gtdbtk -h | head -n 3"
