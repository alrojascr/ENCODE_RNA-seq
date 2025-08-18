#!/bin/bash
#SBATCH --job-name=ribodetector           
#SBATCH --output=ribo_%A.out      
#SBATCH --error=ribo_%A.err
#SBATCH --nodelist=pujnodo0       
#SBATCH --cpus-per-task=10
#SBATCH --mem=19G
#SBATCH --partition=debug             


# Start time measurement
START_TIME=$(date +%s)

# Input and output directories
INPUT_DIR="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/RNA_ribosomal/Trim_fastq"
OUTPUT_DIR="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/RNA_ribosomal/Ribodetector/ribo_output"

# Find and process paired-end FASTQ files
for R1_FILE in "$INPUT_DIR"/*_1.fastq; do
  # Derive the corresponding R2 file name
  R2_FILE="${R1_FILE/_1.fastq/_2.fastq}"

  # Check if the R2 file exists
  if [[ ! -f "$R2_FILE" ]]; then
    echo "Error: Paired file for $R1_FILE not found! Skipping."
    continue
  fi

  # Extract base name (without path and suffix)
  BASE_NAME=$(basename "$R1_FILE" _1.fastq)

  # Define output file names
  OUTPUT_FILE_R1="$OUTPUT_DIR/${BASE_NAME}_1.fastq"
  OUTPUT_FILE_R2="$OUTPUT_DIR/${BASE_NAME}_2.fastq"

  # Start time for each file pair
  FILE_START_TIME=$(date +%s)

  # Print the file pair being processed and its start time
  echo "Processing files: $R1_FILE and $R2_FILE"
  echo "Start time: $(date)"

  # Run Ribodetector on the paired FASTQ files
  ribodetector_cpu -l 140 -i "$R1_FILE" "$R2_FILE" -e rrna -o "$OUTPUT_FILE_R1" "$OUTPUT_FILE_R2" -t 10 --chunk_size 250 --log "$OUTPUT_FILE_R1".log

  # End time for the current file pair
  FILE_END_TIME=$(date +%s)

  # Calculate elapsed time for the current file pair
  FILE_ELAPSED_TIME=$((FILE_END_TIME - FILE_START_TIME))

  # Print the end time and elapsed time for the current file pair
  echo "End time for $R1_FILE and $R2_FILE: $(date)"
  echo "Elapsed time: $FILE_ELAPSED_TIME seconds"
done

# End overall execution time tracking
END_TIME=$(date +%s)

# Calculate total elapsed time for all files
TOTAL_ELAPSED_TIME=$((END_TIME - START_TIME))

# Print total elapsed time for the entire processing
echo "Total processing time for all file pairs: $TOTAL_ELAPSED_TIME seconds"
