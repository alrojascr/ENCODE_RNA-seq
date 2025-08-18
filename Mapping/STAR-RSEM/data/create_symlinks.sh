# Source directory containing the original .fastq files

source_dir="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/RNA_ribosomal/SortMeRNA/sortmerna_output"

# Destination directory for the symbolic links
target_dir="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Mapping/STAR/data"

# List all .fastq files in the source directory

files=("$source_dir"/*/*non*/*.fq)

# Create symbolic links with original names
for file in "${files[@]}"; do
    # Extract the filename (without the directory)
    filename=$(basename "$file")
    ln -s "$file" "${target_dir}/${filename}"
    echo "Symbolic link created: $file -> ${target_dir}/${filename}.fastq"
done
