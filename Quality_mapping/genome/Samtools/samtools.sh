#!/bin/bash
#SBATCH --job-name=Samtools
#SBATCH --output=Samtools_%j.out
#SBATCH --error=Samtools_%j.err
#SBATCH --nodelist=nodei-10
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=15-00:00:00
#SBATCH --partition=long

start_time=$(date +%s)

input_dir="/hpcfs/home/cursos/s.abril01/RNA-seq/Odon/Mapping/STAR-RSEM/Results/genome_bam"
output_base_dir="/hpcfs/home/cursos/s.abril01/RNA-seq/Odon/Quality_mapping/Samtools"

mkdir -p "${output_base_dir}/sort"
mkdir -p "${output_base_dir}/stats"

for bam_file in ${input_dir}/*.bam; do
    base_name=$(basename "$bam_file" .bam)
    base_name=${base_name%%_*}

    sorted_bam="${output_base_dir}/sort/${base_name}_sorted.bam"

    echo "Sorting $bam_file"
    samtools sort -@ ${SLURM_CPUS_PER_TASK} "$bam_file" -o "$sorted_bam"

    echo "Indexing $sorted_bam"
    samtools index -@ ${SLURM_CPUS_PER_TASK} "$sorted_bam"

    stats_file="${output_base_dir}/stats/${base_name}_stats.txt"
    samtools stats "$sorted_bam" > "$stats_file"

    idxstats_file="${output_base_dir}/stats/${base_name}_idxstats.txt"
    samtools idxstats "$sorted_bam" > "$idxstats_file"
done

end_time=$(date +%s)
execution_time=$((end_time - start_time))

echo "Processing complete!"
