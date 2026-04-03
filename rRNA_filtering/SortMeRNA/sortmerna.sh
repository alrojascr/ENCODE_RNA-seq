#!/bin/bash
#SBATCH --job-name=SortMeRNA
#SBATCH --output=SortMeRNA_%j.out
#SBATCH --error=SortMeRNA_%j.err
#SBATCH --nodelist=nodei-2
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=36
#SBATCH --mem=150G
#SBATCH --time=15-00:00:00
#SBATCH --partition=medium

# ==================================================
# Strict bash mode (exit on error, undefined vars, pipe failures)
# ==================================================
set -euo pipefail

# ==================================================
# Start runtime measurement
# ==================================================
START_TIME=$(date +%s)

# ==================================================
# Define input, database, index and output directories
# ==================================================
FASTQ_DIR="/hpcfs/home/cursos/s.abril01/RNA-seq/Odon/Quality_control/FastP/Results"
DATABASE_DIR="/hpcfs/home/cursos/s.abril01/RNA-seq/Odon/rRNA_removal/SortMeRNA/rRNA_databases_v4"
OUTPUT_DIR="/hpcfs/home/cursos/s.abril01/RNA-seq/Odon/rRNA_removal/SortMeRNA/Results"
IDX_DIR="/hpcfs/home/cursos/s.abril01/RNA-seq/Odon/rRNA_removal/SortMeRNA/rRNA_databases_v4/idx"

# Create output and idx directory if missing
mkdir -p "$OUTPUT_DIR"
mkdir -p "$IDX_DIR"

# ==================================================
# Enable safe globbing (avoid literal patterns if no files exist)
# ==================================================
shopt -s nullglob

# ==================================================
# Check if SortMeRNA index directory is empty
# ==================================================
if [ -z "$(ls -A "$IDX_DIR" 2>/dev/null)" ]; then
    echo "[INFO] WARNING: IDX directory is empty."
    echo "[INFO] SortMeRNA will build indexes automatically (first run may be slow)."
fi

# ==================================================
# Main loop: Detect R1 FASTQ files (supports fastq, fastq.gz, fq.gz)
# ==================================================
for FASTQ_FILE1 in "$FASTQ_DIR"/*_1.{fastq,fastq.gz,fq.gz}; do

    [[ -e "$FASTQ_FILE1" ]] || continue

    # Detect paired R2 file automatically
    FASTQ_FILE2="${FASTQ_FILE1/_1./_2.}"

    if [[ ! -f "$FASTQ_FILE2" ]]; then
        echo "[WARNING] Pair not found for $FASTQ_FILE1"
        continue
    fi

    # ==================================================
    # Extract sample name
    # ==================================================
    BASENAME=$(basename "$FASTQ_FILE1")
    BASENAME=${BASENAME%%_1.*}
    BASENAME=${BASENAME%_trimmed}

    # ==================================================
    # Define per-sample output directories
    # ==================================================
    SAMPLE_OUTPUT_DIR="$OUTPUT_DIR/$BASENAME"
    rRNA_DIR="$SAMPLE_OUTPUT_DIR/rRNA"
    non_rRNA_DIR="$SAMPLE_OUTPUT_DIR/non_rRNA"

    mkdir -p "$rRNA_DIR" "$non_rRNA_DIR"

    echo "[INFO] Processing sample: $BASENAME"

    # ==================================================
    # Run SortMeRNA rRNA filtering
    # ==================================================
    sortmerna \
        --ref "$DATABASE_DIR/smr_v4.3_fast_db.fasta" \
        --ref "$DATABASE_DIR/smr_v4.3_default_db.fasta" \
        --ref "$DATABASE_DIR/smr_v4.3_sensitive_db.fasta" \
        --ref "$DATABASE_DIR/smr_v4.3_sensitive_db_rfam_seeds.fasta" \
        --reads "$FASTQ_FILE1" \
        --reads "$FASTQ_FILE2" \
        --workdir "$SAMPLE_OUTPUT_DIR" \
        --idx-dir "$IDX_DIR" \
        --paired_in \
        --fastx \
        --aligned "$rRNA_DIR/${BASENAME}" \
        --out2 "$rRNA_DIR/${BASENAME}" \
        --other "$non_rRNA_DIR/${BASENAME}" \
        --out2 "$non_rRNA_DIR/${BASENAME}" \
        --threads 36

    echo "[INFO] SortMeRNA completed for $BASENAME"

    # ==================================================
    # Rename non_rRNA output files to standard R1/R2 naming
    # ==================================================
    shopt -s nullglob
    files=("$non_rRNA_DIR"/*.fq.gz "$non_rRNA_DIR"/*.fastq.gz)

    for file in "${files[@]}"; do
        filename=$(basename "$file")

        if [[ "$filename" == *_fwd.f*q.gz ]]; then
            newname="${filename/_fwd/_1}"

        elif [[ "$filename" == *_rev.f*q.gz ]]; then
            newname="${filename/_rev/_2}"

        else
            continue
        fi

        if [[ -f "$non_rRNA_DIR/$newname" ]]; then
            echo "[INFO] Target exists, skipping: $newname"
            continue
        fi

        mv "$file" "$non_rRNA_DIR/$newname"
        echo "[INFO] Renamed: $filename → $newname"
    done

    echo "[INFO] Rename completed for $BASENAME"
    echo ""

done

# ==================================================
# Disable nullglob (restore default shell behavior)
# ==================================================
shopt -u nullglob

# ==================================================
# Report total runtime
# ==================================================
END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))

echo "[INFO] Total execution time: $ELAPSED_TIME seconds"

