#!/bin/bash
#SBATCH --job-name=featureCounts
#SBATCH --output=featureCounts_%j.out
#SBATCH --error=featureCounts_%j.err
#SBATCH --exclude=pujnodo0
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --partition=debug

# Define paths
ANNOTATION="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Mapping/STAR-RSEM/genome/GRCh38.p14.genome.gtf"
BAM_DIR="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Mapping/STAR-RSEM/output/genome_bam"
OUTPUT_DIR="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Gene_biotype/feature_results" 

# Create the output directory for featureCounts results if it doesn't exist
mkdir -p $OUTPUT_DIR

# Check if BAM files exist in the BAM directory
if [ ! "$(ls $BAM_DIR/*.bam 2>/dev/null)" ]; then
    echo "No BAM files found in $BAM_DIR"
    exit 1
fi

# Record the start time
start_time=$(date +%s)

# Loop through BAM files and process each one
for BAM in $BAM_DIR/*.bam; do
    BASENAME=$(basename "$BAM" .bam)
    BASENAME=${BASENAME%%_*}  

    OUTPUT="${OUTPUT_DIR}/${BASENAME}_counts.txt" 
    
    # Run featureCounts with verbose output
    featureCounts -a $ANNOTATION -o $OUTPUT -T 8 -p -s 0 $BAM
done

# Record the end time
end_time=$(date +%s)

# Calculate elapsed time
elapsed_time=$((end_time - start_time))
hours=$((elapsed_time / 3600))
minutes=$(((elapsed_time % 3600) / 60))
seconds=$((elapsed_time % 60))

# Output execution time in HH:MM:SS format
printf "Execution Time: %02d:%02d:%02d\n" $hours $minutes $seconds

