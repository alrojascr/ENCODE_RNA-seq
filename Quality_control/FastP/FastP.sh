#!/bin/bash
#SBATCH --job-name=Fastp_Trim                      
#SBATCH --output=fastp_%j.out                        
#SBATCH --error=fastp_%j.err                           
#SBATCH --nodelist=pujnodo1
#SBATCH --ntasks=1                                    
#SBATCH --cpus-per-task=6                          
#SBATCH --mem=18G                             
#SBATCH --partition=debug                              

# Directories
INPUT_DIR="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Quality_control/FastQC_Raw"
OUTPUT_DIR="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Quality_control/Fastp/Results"

# Create output directory if it doesn't exist
mkdir -p "${OUTPUT_DIR}"

# Start timing the execution
start_time=$(date +%s)

# Loop through all fastq.gz files in the input directory
for file1 in "${INPUT_DIR}"/*_1.fq.gz; do
  # Extract the sample name (removes _1.fq.gz)
  sample_name=$(basename "$file1" _1.fq.gz)

  # Define the corresponding reverse read file
  file2="${INPUT_DIR}/${sample_name}_2.fq.gz"

  # Define output file names
  out_file1="${OUTPUT_DIR}/${sample_name}_trimmed_1.fq.gz"
  out_file2="${OUTPUT_DIR}/${sample_name}_trimmed_2.fq.gz"
  json_report="${OUTPUT_DIR}/${sample_name}_fastp.json"
  html_report="${OUTPUT_DIR}/${sample_name}_fastp.html"

  # Run fastp with adapter auto-detection and poly-X trimming
  fastp --in1 "${file1}" --in2 "${file2}" \
        --out1 "${out_file1}" --out2 "${out_file2}" \
        --qualified_quality_phred 30 \
        --length_required 30 \
        --detect_adapter_for_pe \
        --trim_poly_g \
        --trim_poly_x \
        --cut_right --cut_right_window_size 4 --cut_right_mean_quality 30 \
        --thread 6 \
        --json "${json_report}" \
        --html "${html_report}" 

done

# End timing the execution
end_time=$(date +%s)

# Calculate elapsed time
elapsed_time=$((end_time - start_time))

# Print the elapsed time
echo "Execution time: ${elapsed_time} seconds"