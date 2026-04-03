#!/bin/bash
#SBATCH --job-name=Preseq
#SBATCH --output=Preseq_%j.out
#SBATCH --error=Preseq_%j.err
#SBATCH --exclude=pujnodo0
#SBATCH --nodes=2
#SBATCH --ntasks=4
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=4
#SBATCH --mem=20G
#SBATCH --partition=debug

# Capture start time
start_time=$(date +%s)

input_dir="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Quality_mapping/transcriptome/Samtools/sort"
output_base_dir="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Quality_mapping/transcriptome/Preseq/lc_extrap"

# Ensure output directory exists
mkdir -p "$output_base_dir"

# Loop through sorted BAM files and process each with Preseq
for bam_file in ${input_dir}/*.bam; do
    base_name=$(basename "$bam_file" .bam)
    base_name=${base_name%%_*}
    preseq_output="${output_base_dir}/${base_name}_lc_extrap.txt"

    echo "Running preseq lc_extrap for $bam_file"
    preseq lc_extrap -bam "$bam_file" -output "$preseq_output"
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

