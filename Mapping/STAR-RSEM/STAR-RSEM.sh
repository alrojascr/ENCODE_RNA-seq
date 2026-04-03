#!/bin/bash
#SBATCH --job-name=STAR-RSEM
#SBATCH --output=STAR-RSEM_%j.out
#SBATCH --error=STAR-RSEM_%j.err
#SBATCH --nodelist=nodei-3
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=150G
#SBATCH --time=15-00:00:00
#SBATCH --partition=medium

# =============================
# CONFIG
# =============================
THREADS=24

# Record start time
start_time=$(date +%s)

# Define directories
fastq="/hpcfs/home/cursos/s.abril01/RNA-seq/Odon/Mapping/STAR-RSEM/Data"
genome_fasta="/hpcfs/home/cursos/s.abril01/RNA-seq/Odon/Mapping/STAR-RSEM/Genome/GRCh38.p14.genome.fa"
genome_anno="/hpcfs/home/cursos/s.abril01/RNA-seq/Odon/Mapping/STAR-RSEM/Genome/GRCh38.p14.genome.gtf"
rsem_idx="/hpcfs/home/cursos/s.abril01/RNA-seq/Odon/Mapping/STAR-RSEM/Genome/rsem_idx"
output="/hpcfs/home/cursos/s.abril01/RNA-seq/Odon/Mapping/STAR-RSEM/Results"

rsem_output="${output}/RSEM_results"
genome_bam="${output}/genome_bam"
transcriptome_bam="${output}/transcriptome_bam"

# Create output directories
mkdir -p "$output" "$rsem_output" "$genome_bam" "$transcriptome_bam"

# =============================
# PREPARE RSEM REFERENCE
# =============================
if [ ! -f "$rsem_idx/rsem_reference.grp" ]; then
    echo "Creating RSEM reference..."

    mkdir -p "$rsem_idx"

    rsem-prepare-reference \
        --gtf "$genome_anno" \
        --star \
        --star-sjdboverhang 149 \
        --num-threads $THREADS \
        "$genome_fasta" \
        "$rsem_idx/rsem_reference"

else
    echo "RSEM reference already exists."
fi

# =============================
# STAR + RSEM PER SAMPLE
# =============================
for fastq_file_R1 in "$fastq"/*_1.fq.gz; do
    # Ensure the file exists (prevents literal string errors if no files match)
    [ -e "$fastq_file_R1" ] || continue

    # Construct R2 name by replacing _1. with _2.
    fastq_file_R2="${fastq_file_R1%_1.fq.gz}_2.fq.gz"

    if [ ! -f "$fastq_file_R2" ]; then
        echo "Error: Pair $fastq_file_R2 not found for $fastq_file_R1"
        continue
    fi

    base_name=$(basename "$fastq_file_R1" _1.fq.gz)

    echo "==============================="
    echo "Processing sample: $base_name"
    echo "==============================="

    # ---------- STAR ----------
    STAR \
        --runMode alignReads \
        --runThreadN $THREADS \
        --genomeDir "$rsem_idx" \
        --readFilesIn "$fastq_file_R1" "$fastq_file_R2" \
        --readFilesCommand zcat \
        --sjdbScore 1 \
        --outFileNamePrefix "$output/${base_name}_" \
        --outSAMtype BAM SortedByCoordinate \
        --outSAMstrandField intronMotif \
        --outSAMattributes NH HI AS NM MD \
        --outSAMunmapped Within \
        --outSAMattrRGline ID:$base_name CN:Oxford SM:$base_name PL:illumina \
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
        --limitBAMsortRAM 80000000000

    # Move STAR outputs
    mv "$output/${base_name}_Aligned.sortedByCoord.out.bam" "$genome_bam/"
    mv "$output/${base_name}_Aligned.toTranscriptome.out.bam" "$transcriptome_bam/"

    # ---------- RSEM ----------
    rsem-calculate-expression \
        --num-threads $THREADS \
        --strandedness none \
        --alignments \
        --paired-end \
        "${transcriptome_bam}/${base_name}_Aligned.toTranscriptome.out.bam" \
        --estimate-rspd \
        --no-bam-output \
        "$rsem_idx/rsem_reference" \
        "${rsem_output}/${base_name}"

    echo "Finished sample: $base_name"
done

# =============================
# END TIMER
# =============================
end_time=$(date +%s)
runtime=$((end_time - start_time))

echo "=================================="
echo "Total runtime: $runtime seconds"
echo "=================================="

