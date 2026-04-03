#!/bin/bash
#SBATCH --job-name=QualiMap
#SBATCH --output=QualiMap_%j.out
#SBATCH --error=QualiMap_%j.err
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
output_base_dir="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Quality_mapping/transcriptome/Qualimap/qualimap_results"
gtf_file="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Quality_mapping/genome/Qualimap/GTF/GRCh38.p14.genome.gtf"

# Loop through BAM files and process each with QualiMap
for bam_file in ${input_dir}/*.bam; do
    base_name=$(basename "$bam_file" .bam)
    base_name=${base_name%%_*}
    output_dir="${output_base_dir}/${base_name}_qualimap"

    # Create output directory for the current BAM file
    mkdir -p "$output_dir"

    echo "Running QualiMap for $bam_file"
    qualimap rnaseq --java-mem-size=16G -bam $bam_file -gtf $gtf_file -outdir $output_dir
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

