# Source directory containing the original .fastq files
source_dir="/opt/data/HPC01A/alexis_rojasc/OSA_miRNAs/Dataset/SRP319371"

# Destination directory for the symbolic links
dest_dir="/opt/data/HPC01A/alexis_rojasc/OSA_miRNAs/Quality_control/FastQC_Raw"

# New names for the files
new_names=("Control.1" "Control.2" "Control.3" "Control.4" "Control.5" "OSA.1" "OSA.2" "OSA.3" "OSA.4" "OSA.5")

# List all .fastq files in the source directory
files=("$source_dir"/*.fastq)

# Check if the number of files matches the number of new names
if [[ ${#files[@]} -ne ${#new_names[@]} ]]; then
    echo "Error: The number of files and new names does not match."
    exit 1
fi

# Create symbolic links with new names
for i in "${!files[@]}"; do
    original_file="${files[i]}"
    new_name="${new_names[i]}"
    ln -s "$original_file" "$dest_dir/$new_name.fastq"
    echo "Symbolic link created: $original_file -> $dest_dir/$new_name.fastq"
done

