#!/bin/bash
#SBATCH --job-name=STAR-RSEM_pipeline
#SBATCH --output=STAR-RSEM_%j.out
#SBATCH --error=STAR-RSEM_%j.err
#SBATCH --exclude=pujnodo0
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=19G  
#SBATCH --partition=debug

# Record start time
start_time=$(date +%s)

# Define directories as variables
fastq="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Mapping/STAR-RSEM/data"
genome_fasta="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Mapping/STAR-RSEM/genome/GRCh38.p14.genome.fa"
genome_anno="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Mapping/STAR-RSEM/genome/GRCh38.p14.genome.gtf"
rsem_idx="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Mapping/STAR-RSEM/genome/rsem_idx"
output="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Mapping/STAR-RSEM/output"
rsem_output="${output}/RSEM_results"
genome_bam="${output}/genome_bam"
transcriptome_bam="${output}/transcriptome_bam"

# Ensure output directories exist
mkdir -p "$output" "$rsem_output" "$genome_bam" "$transcriptome_bam"

# Prepare RSEM reference if not already done
if [ ! -d "$rsem_idx" ]; then
    echo "Creating RSEM reference directory: $rsem_idx"
    mkdir -p "$rsem_idx"

    echo "Running rsem-prepare-reference..."
    rsem-prepare-reference \
        --gtf "$genome_anno" \
        --star \
        --star-sjdboverhang 149 \
        --num-threads 12 \
        "$genome_fasta" \
        "$rsem_idx/rsem_reference"
else
    echo "RSEM reference directory already exists."
fi

# Loop over all paired-end .fastq files in the fastq directory
for fastq_file_R1 in "$fastq"/*_1.fq; do
    # Determine the corresponding R2 file
    fastq_file_R2="${fastq_file_R1/_1.fq/_2.fq}"
    echo "Checking files: $fastq_file_R1 and $fastq_file_R2"
    if [ ! -f "$fastq_file_R2" ]; then
        echo "Error: Paired file for $(basename "$fastq_file_R1") not found. Skipping..."
        continue
    fi

    base_name=$(basename "$fastq_file_R1" _1.fq)
    echo "Running STAR alignment for $base_name..."

    # Run STAR alignment with added and previous parameters
    STAR --runMode alignReads \
         --runThreadN 12 \
         --genomeDir "$rsem_idx" \
         --readFilesIn "$fastq_file_R1" "$fastq_file_R2" \
         --sjdbScore 1 \
         --outFileNamePrefix "$output"/"$base_name"_ \
         --outSAMtype BAM SortedByCoordinate \
         --outSAMstrandField intronMotif \
         --outSAMattributes NH HI AS NM MD \
         --outSAMunmapped Within \
         --outSAMattrRGline ID:$base_name CN:Oxford SM:$base_name PL:illumina \
         --outSAMheaderHD @HD VN:1.4 SO:coordinate \
         --outFilterType BySJout \
         --outFilterMultimapNmax 20 \
         --outFilterMismatchNmax 999 \
         --outFilterMismatchNoverReadLmax 0.04 \
         --alignSJoverhangMin 8 \
         --alignSJDBoverhangMin 1 \
         --alignIntronMin 20 \
         --alignIntronMax 1000000 \
         --alignMatesGapMax 1000000 \
         --quantMode TranscriptomeSAM \
         --limitBAMsortRAM 10000000000
    # Move STAR outputs to respective directories
    mv "$output"/"$base_name"_Aligned.sortedByCoord.out.bam "${genome_bam}/"
    mv "$output"/"$base_name"_Aligned.toTranscriptome.out.bam "${transcriptome_bam}/"

    echo "Running RSEM calculation for $base_name..."
    
    # Run rsem-calculate-expression
    rsem-calculate-expression \
        --num-threads 12 \
        --strandedness none \
        --alignments \
        --paired-end \
        "${transcriptome_bam}/${base_name}_Aligned.toTranscriptome.out.bam" \
        --estimate-rspd \
        --no-bam-output \
        "$rsem_idx/rsem_reference" \
        "${rsem_output}/${base_name}"
    
    echo "RSEM processing complete for $base_name."
done

# Record end time
end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo "Execution Time: $execution_time seconds"

