#!/bin/bash
#SBATCH --job-name=fastqscreen                       
#SBATCH --output=fastqscreen_%j.out                      
#SBATCH --error=fastqscreen_%j.err
#SBATCH --nodelist=pujnodo0                    
#SBATCH --ntasks=1                                     
#SBATCH --cpus-per-task=10                          
#SBATCH --mem=16G                                      
#SBATCH --partition=debug                             

# Define directories and parameters
FASTQ_DIR="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Quality_control/FastQC_Raw" 
OUTPUT_DIR="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Quality_control/FastQ_Screen/FastQ_Screen_Output"
CONF_FILE="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Quality_control/FastQ_Screen/FastQ_Screen_Genomes/fastq_screen.conf"

# Log start time
echo "Starting FastQ Screen processing for .fastq files in $FASTQ_DIR with custom configuration"

# Loop through all .fastq files in the directory
for INPUT in $FASTQ_DIR/*.fastq; do
    # Extract the base name of the file (e.g., Control.X from Control.X.fastq)
    BASENAME=$(basename "$INPUT" .fastq)

    # Define a unique output directory for this sample
    OUTPUT="$OUTPUT_DIR/$BASENAME"

    # Create the output directory if it doesn't exist
    mkdir -p $OUTPUT

    # Log processing of the single .fastq file
    echo "Processing .fastq file: $INPUT"
    echo "Output will be saved to: $OUTPUT"

    # Run FastQ Screen with the custom config file
    fastq_screen --aligner bowtie2 --conf "$CONF_FILE" "$INPUT" --outdir "$OUTPUT"

done

# Log end time
echo "Finished FastQ Screen processing for all .fastq files in $FASTQ_DIR"

