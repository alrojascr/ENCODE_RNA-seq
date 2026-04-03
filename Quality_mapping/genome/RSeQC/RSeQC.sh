#!/bin/bash
#SBATCH --job-name=RSeQC
#SBATCH --output=RSeQC_%j.out
#SBATCH --error=RSeQC_%j.err
#SBATCH --nodelist=nodei-10
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=15-00:00:00
#SBATCH --partition=long

# Capture start time
start_time=$(date +%s)

input_dir="/hpcfs/home/cursos/s.abril01/RNA-seq/Odon/Quality_mapping/Samtools/sort"
output_base_dir="/hpcfs/home/cursos/s.abril01/RNA-seq/Odon/Quality_mapping/RSeQC"
reference_bed="/hpcfs/home/cursos/s.abril01/RNA-seq/Odon/Quality_mapping/RSeQC/BED/hg38_GENCODE_V47.bed"

# Create directories for each RSeQC program
mkdir -p "${output_base_dir}/bam_stat"
mkdir -p "${output_base_dir}/infer_experiment"
mkdir -p "${output_base_dir}/inner_distance"
mkdir -p "${output_base_dir}/junction_annotation"
mkdir -p "${output_base_dir}/junction_saturation"
mkdir -p "${output_base_dir}/read_distribution"
mkdir -p "${output_base_dir}/read_duplication"

for bam_file in ${input_dir}/*.bam; do
    base_name=$(basename "$bam_file" .bam)
    base_name=${base_name%%_*}

    # Run bam_stat
    bam_stat_output="${output_base_dir}/bam_stat/${base_name}_bam_stat.txt"
    echo "Running bam_stat for $bam_file"
    python3 /hpcfs/home/cursos/s.abril01/.conda/envs/RNA-seq/bin/bam_stat.py -i "$bam_file" > "$bam_stat_output"

    # Run infer_experiment
    infer_experiment_output="${output_base_dir}/infer_experiment/${base_name}_infer_experiment.txt"
    echo "Running infer_experiment for $bam_file"
    python3 /hpcfs/home/cursos/s.abril01/.conda/envs/RNA-seq/bin/infer_experiment.py -i "$bam_file" -r "$reference_bed" > "$infer_experiment_output"

    # Run inner_distance
    inner_distance_output="${output_base_dir}/inner_distance/${base_name}"
    echo "Running inner_distance for $bam_file"
    python3 /hpcfs/home/cursos/s.abril01/.conda/envs/RNA-seq/bin/inner_distance.py -i "$bam_file" -r "$reference_bed" -o "$inner_distance_output"

    # Run junction_annotation
    junction_annotation_output="${output_base_dir}/junction_annotation/${base_name}"
    echo "Running junction_annotation for $bam_file"
    python3 /hpcfs/home/cursos/s.abril01/.conda/envs/RNA-seq/bin/junction_annotation.py -i "$bam_file" -r "$reference_bed" -o "$junction_annotation_output"

    # Run junction_saturation
    junction_saturation_output="${output_base_dir}/junction_saturation/${base_name}"
    echo "Running junction_saturation for $bam_file"
    python3 /hpcfs/home/cursos/s.abril01/.conda/envs/RNA-seq/bin/junction_saturation.py -i "$bam_file" -r "$reference_bed" -o "$junction_saturation_output"

    # Run read_distribution
    read_distribution_output="${output_base_dir}/read_distribution/${base_name}_read_distribution.txt"
    echo "Running read_distribution for $bam_file"
    python3 /hpcfs/home/cursos/s.abril01/.conda/envs/RNA-seq/bin/read_distribution.py -i "$bam_file" -r "$reference_bed" > "$read_distribution_output"

    # Run read_duplication
    read_duplication_output="${output_base_dir}/read_duplication/${base_name}"
    echo "Running read_duplication for $bam_file"
    python3 /hpcfs/home/cursos/s.abril01/.conda/envs/RNA-seq/bin/read_duplication.py -i "$bam_file" -o "$read_duplication_output"

done

# Capture end time
end_time=$(date +%s)

# Calculate execution time
execution_time=$((end_time - start_time))

echo "Processing complete!"
