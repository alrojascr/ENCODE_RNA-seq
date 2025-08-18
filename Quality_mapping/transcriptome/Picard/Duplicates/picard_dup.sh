#!/bin/bash
#SBATCH --job-name=Picard
#SBATCH --output=Picard_%j.out
#SBATCH --error=Picard_%j.err
#SBATCH --exclude=pujnodo0
#SBATCH --nodes=2
#SBATCH --ntasks=4
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=4
#SBATCH --mem=20G
#SBATCH --partition=debug

# Capture start time
start_time=$(date +%s)

# Input and output directories
input_dir="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Quality_mapping/transcriptome/Samtools/sort"
output_base_dir="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Quality_mapping/transcriptome/Picard/Duplicates"

# Create output directory for read group and deduplicated files
mkdir -p "${output_base_dir}/read_groups"
mkdir -p "${output_base_dir}/dedup"

for bam_file in ${input_dir}/*.bam; do
    base_name=$(basename "$bam_file" .bam)
    base_name="${base_name%%_*}"

    # Set the output BAM files for read groups and deduplication
    read_group_bam="${output_base_dir}/read_groups/${base_name}_readgroup.bam"
    dedup_bam="${output_base_dir}/dedup/${base_name}_dedup.bam"
    metrics_file="${output_base_dir}/dedup/${base_name}_metrics.txt"
    
    echo "Adding read groups to $bam_file into $read_group_bam"

    # Add or replace read groups using Picard
    picard AddOrReplaceReadGroups \
        -Xmx20G \
        I="$bam_file" \
        O="$read_group_bam" \
        RGID="$base_name" \
        RGLB="lib1" \
        RGPL="Illumina" \
        RGPU="unit1" \
        RGSM="$base_name"

    echo "Marking duplicates for $read_group_bam into $dedup_bam"

    # Mark duplicates using Picard with the specified files
    picard MarkDuplicates \
        -Xmx20G \
        I="$read_group_bam" \
        O="$dedup_bam" \
        M="$metrics_file" \
        ASSUME_SORTED=true \
        REMOVE_DUPLICATES=false

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
