#!/bin/bash
#SBATCH --job-name=Samtools
#SBATCH --output=Samtools_%j.out
#SBATCH --error=Samtools_%j.err
#SBATCH --exclude=pujnodo0
#SBATCH --nodes=2
#SBATCH --ntasks=4
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=4
#SBATCH --mem=20G
#SBATCH --partition=debug

# Capture start time
start_time=$(date +%s)

input_dir="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Mapping/STAR-RSEM/output/transcriptome_bam"
output_base_dir="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Quality_mapping/transcriptome/Samtools"

mkdir -p "${output_base_dir}/sort"
mkdir -p "${output_base_dir}/stats"

for bam_file in ${input_dir}/*.bam; do
    base_name=$(basename "$bam_file" .bam)
    base_name="${base_name%%_*}"

    sorted_bam="${output_base_dir}/sort/${base_name}_sorted.bam"
    echo "Sorting $bam_file into $sorted_bam"
    samtools sort "$bam_file" -o "$sorted_bam"

    stats_file="${output_base_dir}/stats/${base_name}_stats.txt"
    echo "Generating statistics for $sorted_bam into $stats_file"
    samtools stats "$sorted_bam" > "$stats_file"

    idxstats_file="${output_base_dir}/stats/${base_name}_idxstats.txt"
    echo "Generating idxstats for $sorted_bam into $idxstats_file"
    samtools idxstats "$sorted_bam" > "$idxstats_file"
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
