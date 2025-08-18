#!/bin/bash
#SBATCH --output=fastqscreen_%j.out                      
#SBATCH --error=fastqscreen_%j.err
#SBATCH --nodelist=pujnodo0                    
#SBATCH --ntasks=1                                     
#SBATCH --cpus-per-task=10                          
#SBATCH --mem=16G                                      
#SBATCH --partition=debug                             

# Define directories and parameters
FASTQ_DIR="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/RNA_ribosomal/SortMeRNA/sortmerna_output" 
OUTPUT_DIR="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/RNA_ribosomal/FastQ_Screen/SortMeRNA/FastQ_Screen_Output"
CONF_FILE="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Quality_control/FastQ_Screen/FastQ_Screen_Genomes/fastq_screen.conf"

# Log start time
echo "Starting FastQ Screen processing for .fq files in $FASTQ_DIR with custom configuration"

# Loop through subdirectories under FASTQ_DIR (matching "/*/*non*/")
for DIR in "$FASTQ_DIR"/*/*non*/; do
    # Exclude "MultiQC_Report" directory
    PARENT_DIR=$(basename "$(dirname "$DIR")")
    if [[ "$PARENT_DIR" != "MultiQC_Report" ]]; then
        # Loop through all .fq files in the subdirectory
        for INPUT in "$DIR"/*.fq; do
            # Check if .fq file exists
            if [[ -f "$INPUT" ]]; then
                # Extract the base name of the FASTQ file (without extension)
                FILE_NAME=$(basename "$INPUT" .fq)

                # Define output directory based on the FASTQ file name
                OUTPUT="$OUTPUT_DIR/$FILE_NAME"

                # Create the output directory if it doesn't exist
                mkdir -p "$OUTPUT"

                # Log processing of the current .fq file
                echo "Processing .fq file: $INPUT"
                echo "Output will be saved to: $OUTPUT"

                # Run FastQ Screen with the custom config file
                fastq_screen --aligner bowtie2 --conf "$CONF_FILE" "$INPUT" --outdir "$OUTPUT"
            fi
        done
    fi
done

# Log end time
echo "Finished FastQ Screen processing for all .fq files in $FASTQ_DIR"


