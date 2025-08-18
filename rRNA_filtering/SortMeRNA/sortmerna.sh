#!/bin/bash
#SBATCH --job-name=sortmerna           
#SBATCH --output=sortmerna_%A.out      
#SBATCH --error=sortmerna_%A.err
#SBATCH --nodelist=pujnodo0       
#SBATCH --cpus-per-task=10
#SBATCH --mem=19G
#SBATCH --partition=debug             

# Start time measurement
START_TIME=$(date +%s)

# Input and output directories
FASTQ_DIR="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/RNA_ribosomal/Trim_fastq"
DATABASE_DIR="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/RNA_ribosomal/SortMeRNA/rRNA_databases_v4"
OUTPUT_DIR="./sortmerna_output"
IDX_DIR="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/RNA_ribosomal/SortMeRNA/rRNA_databases_v4/idx"

# Create the output directory
mkdir -p "$OUTPUT_DIR"

# Loop through FASTQ files
for FASTQ_FILE1 in "$FASTQ_DIR"/*_1.fastq; do
    # Define the second file in the pair (for _1, the pair is _2)
    FASTQ_FILE2="${FASTQ_FILE1/_1.fastq/_2.fastq}"
    
    # Check if R2 file exists
    if [[ ! -f "$FASTQ_FILE2" ]]; then
        echo "Warning: Pair for $FASTQ_FILE1 not found. Skipping."
        continue
    fi

    BASENAME=$(basename "$FASTQ_FILE1" _1.fastq)

    SAMPLE_OUTPUT_DIR="$OUTPUT_DIR/$BASENAME"
    
    # Create output subdirectories for rRNA and non-rRNA
    rRNA_DIR="$SAMPLE_OUTPUT_DIR/rRNA"
    non_rRNA_DIR="$SAMPLE_OUTPUT_DIR/non_rRNA"
    mkdir -p "$rRNA_DIR" "$non_rRNA_DIR"

    echo "Processing $FASTQ_FILE1 and $FASTQ_FILE2..."

    # Run the SortMeRNA command for each reference
    sortmerna --ref "$DATABASE_DIR/smr_v4.3_fast_db.fasta" \
              --ref "$DATABASE_DIR/smr_v4.3_default_db.fasta" \
              --ref "$DATABASE_DIR/smr_v4.3_sensitive_db.fasta" \
              --ref "$DATABASE_DIR/smr_v4.3_sensitive_db_rfam_seeds.fasta" \
              --reads "$FASTQ_FILE1" \
              --reads "$FASTQ_FILE2" \
              --workdir "$SAMPLE_OUTPUT_DIR" \
              --idx-dir "$IDX_DIR" \
              --paired_in \
              --fastx \
              --aligned "$rRNA_DIR/${BASENAME}_1" \
              --out2 "$rRNA_DIR/${BASENAME}_2" \
              --other "$non_rRNA_DIR/${BASENAME}_1" \
              --out2 "$non_rRNA_DIR/${BASENAME}_2" \
              --threads 10

    echo "Finished processing $BASENAME. Output saved to $SAMPLE_OUTPUT_DIR."

done

# End time measurement
END_TIME=$(date +%s)

# Calculate total elapsed time
ELAPSED_TIME=$((END_TIME - START_TIME))

# Print total execution time in seconds
echo "Total execution time: $ELAPSED_TIME seconds"

