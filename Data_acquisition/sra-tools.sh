#!/bin/bash
#SBATCH --job-name=SRA_download
#SBATCH --output=SRA_%j.out
#SBATCH --error=SRA_%j.err
#SBATCH --nodelist=nodea-6
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=19G
#SBATCH --time=15-00:00:00
#SBATCH --partition=medium

# Record start time
start_time=$(date +%s)

# Set the base path for logs and output
LOG_PATH="/hpcfs/home/cursos/s.abril01/RNA-seq/Cente/Raw_data"

# Create a directory for the downloaded data
OUTPUT_DIR="${LOG_PATH}/Data"
mkdir -p "${OUTPUT_DIR}"
 
# Navigate to the output directory
cd "${OUTPUT_DIR}"
 
# File with SRR accessions (one per line)
SRR_LIST="/hpcfs/home/cursos/s.abril01/RNA-seq/Cente/Raw_data/SRR.txt"   
 
# Prefetch: Download each SRR listed in the SRR.txt file
echo "Starting data download from SRA using prefetch..."
while read -r SRR; do
    if [ -n "$SRR" ]; then
        echo "Downloading $SRR..."
        prefetch "$SRR"
        if [ $? -ne 0 ]; then
            echo "Error downloading $SRR" >&2
        fi
    fi
done < "$SRR_LIST"
 
echo "All downloads attempted."
 
# Fastq-dump: Convert downloaded .sra files to FASTQ format
echo "Converting SRA files to FASTQ format using fastq-dump..."
find . -name "*.sra" | while read -r SRA_FILE; do
    fastq-dump --split-3 "$SRA_FILE"
    if [ $? -ne 0 ]; then
        echo "Error during FASTQ conversion for $SRA_FILE" >&2
    fi
done
 
# Record end time
end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "Completed in $runtime seconds"
