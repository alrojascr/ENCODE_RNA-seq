#!/bin/bash
#SBATCH --job-name=sra_download                      
#SBATCH --output=sra_%j.out                           
#SBATCH --error=sra_%j.err
#SBATCH --nodelist=pujnodo2                            
#SBATCH --ntasks=1                                    
#SBATCH --cpus-per-task=4                             
#SBATCH --mem=8G                                      
#SBATCH --partition=debug                              


# Set the base path for logs and output
LOG_PATH="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Dataset"

# File with SRR accessions (one per line)
SRR_LIST="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Dataset/SRR.txt" 

# Start time of the script
START_TIME=$(date +%s)

echo "Job started at: $(date)"

# Create a directory for the downloaded data
OUTPUT_DIR="${LOG_PATH}/SRP449460"
mkdir -p ${OUTPUT_DIR}

# Navigate to the output directory
cd ${OUTPUT_DIR}

# Prefetch: Download each SRR listed in the SRR.txt file
echo "Starting data download from SRA using prefetch..."
while read -r SRR || [[ -n "$SRR" ]]; do
    if [[ -z "$SRR" ]]; then
        continue
    fi
    echo "Downloading $SRR..."
    prefetch --output-directory . "$SRR"
    if [ $? -ne 0 ]; then
        echo "Error downloading $SRR" >&2
        continue
    fi

    # Locate the .sra file
    SRA_FILE=$(find . -type f -name "${SRR}*.sra" | head -n1 || true)
    if [[ -z "$SRA_FILE" ]]; then
        echo "Could not find .sra file for $SRR; skipping conversion." >&2
        continue
    fi

    echo "Converting $SRA_FILE to FASTQ (paired-aware)"
    fastq-dump --split-files "$SRA_FILE"
    if [ $? -ne 0 ]; then
        echo "Error during FASTQ conversion for $SRA_FILE" >&2
        continue
    fi

    # Check output
    if [[ -f "${SRR}_1.fastq" && -f "${SRR}_2.fastq" ]]; then
        echo "Paired files for $SRR generated: ${SRR}_1.fastq and ${SRR}_2.fastq"
    fi
    if [[ -f "${SRR}.fastq" ]]; then
        echo "Singleton/unpaired reads for $SRR in: ${SRR}.fastq"
    fi
    if [[ ! -f "${SRR}_1.fastq" && ! -f "${SRR}_2.fastq" && ! -f "${SRR}.fastq" ]]; then
        echo "Warning: expected FASTQ output for $SRR not found." >&2
    fi

done < "$SRR_LIST"

echo "All downloads attempted."

# End time of the script
END_TIME=$(date +%s)

# Calculate execution time
EXECUTION_TIME=$((END_TIME - START_TIME))

echo "Job completed at: $(date)"
echo "Total execution time: $((EXECUTION_TIME / 60)) minutes and $((EXECUTION_TIME % 60)) seconds."

echo "Process completed."