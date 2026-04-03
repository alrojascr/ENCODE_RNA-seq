#!/bin/bash
#SBATCH --job-name=Picard
#SBATCH --output=Picard_%j.out
#SBATCH --error=Picard_%j.err
#SBATCH --nodelist=nodei-10
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=150G
#SBATCH --time=15-00:00:00
#SBATCH --partition=long

# Capture start time
start_time=$(date +%s)

input_dir="/hpcfs/home/cursos/s.abril01/RNA-seq/Odon/Quality_mapping/Samtools/sort"
output_base_dir="/hpcfs/home/cursos/s.abril01/RNA-seq/Odon/Quality_mapping/Picard"

mkdir -p "${output_base_dir}/Results"

for bam_file in ${input_dir}/*.bam; do
    base_name=$(basename "$bam_file" .bam)
    base_name="${base_name%%_*}"

    # Set the output BAM files for deduplication
    dedup_bam="${output_base_dir}/Results/${base_name}_dedup.bam"
    metrics_file="${output_base_dir}/Results/${base_name}_metrics.txt"
    
    echo "Marking duplicates for $bam_file into $dedup_bam"

    # Mark duplicates using Picard with the specified files
    picard MarkDuplicates \
        -Xmx140G \
        I="$bam_file" \
        O="$dedup_bam" \
        M="$metrics_file" \
        ASSUME_SORTED=true \
        REMOVE_DUPLICATES=false \
        CREATE_INDEX=true

done

# Capture end time
end_time=$(date +%s)

# Calculate execution time
execution_time=$((end_time - start_time))

# Convert to hours, minutes, seconds
hours=$((execution_time / 3600))
minutes=$(( (execution_time % 3600) / 60 ))
seconds=$((execution_time % 60))

echo "Processing complete!"
echo "Total execution time: ${hours}h ${minutes}m ${seconds}s"
