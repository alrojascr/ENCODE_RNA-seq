#!/bin/bash
#SBATCH --output=fastqscreen_%j.out
#SBATCH --error=fastqscreen_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=16G
#SBATCH --partition=debug

# Define directories and parameters
FASTQ_DIR="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/RNA_ribosomal/Ribodetector/ribo_output"
OUTPUT_DIR="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/RNA_ribosomal/FastQ_Screen/Ribodetector/FastQ_Screen_Output"
CONF_FILE="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Quality_control/FastQ_Screen/FastQ_Screen_Genomes/fastq_screen.conf"

# Log start time
echo "$(date): Starting FastQ Screen processing for .fastq files in $FASTQ_DIR with configuration $CONF_FILE"

# Loop through each .fastq file in the directory
for INPUT in "$FASTQ_DIR"/*.fastq; do
    # Ensure the file exists
    if [[ -f "$INPUT" ]]; then
        # Extract the base name of the FASTQ file (without extension)
        FILE_NAME=$(basename "$INPUT" .fastq)

        # Define output directory based on the FASTQ file name
        OUTPUT="$OUTPUT_DIR/$FILE_NAME"

        # Create the output directory if it doesn't exist
        mkdir -p "$OUTPUT"

        # Log the current file being processed
        echo "$(date): Processing .fastq file: $INPUT"
        echo "$(date): Output will be saved to: $OUTPUT"

        # Run FastQ Screen with the custom configuration file
        fastq_screen --aligner bowtie2 --conf "$CONF_FILE" "$INPUT" --outdir "$OUTPUT"
    fi
done

# Log end time
echo "$(date): Finished FastQ Screen processing for all .fastq files in $FASTQ_DIR"

#SBATCH --output=fastqscreen_%j.log                      

