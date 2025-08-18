# RNA-Seq Pipeline Using ENCODE Standards

This pipeline provides a comprehensive framework for analyzing RNA sequencing (RNA-seq) data according to ENCODE standards. It covers the complete workflow from raw data acquisition to gene expression quantification, incorporating optimized tools for high-quality results.

## Table of Contents
- [Data Acquisition](#data-acquisition)
- [Quality Control](#quality-control)
- [Ribosomal RNA Filtering](#ribosomal-rna-filtering)
- [Mapping](#mapping)
- [Mapping Quality](#mapping-quality)
- [Gene Biotype Analysis](#gene-biotype-analysis)
- [Quantification](#quantification)
- [MultiQC](#multiqc)
- [How to Run](#how-to-run)
- [Acknowledgements](#acknowledgements)

## Data Acquisition
**Description:** Downloading and preparing sequencing data from public repositories or sequencing facilities.

**Tools:**
- **SRA Toolkit**
  - **Description:** Tools for downloading and converting data from NCBI's Sequence Read Archive (SRA).
  - **GitHub Repository:** [SRA Toolkit GitHub](https://github.com/ncbi/sra-tools)
  - **Command Examples:**
    ```bash
    # Download SRA file
    prefetch SRR123456
    
    # Convert to FASTQ format
    fasterq-dump SRR123456 --split-files
    
    # For paired-end data
    fastq-dump --split-files SRR123456
    ```

## Quality Control
**Description:** Comprehensive preprocessing including adapter trimming, quality filtering, and quality assessment.

**Tools:**
- **FastQC**
  - **Description:** Initial quality assessment of raw sequencing data.
  - **GitHub Repository:** [FastQC GitHub](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
  - **Command Example:
    ```bash
    fastqc input.fastq -o output_dir/
    ```

- **fastp**
  - **Description:** Ultra-fast all-in-one FASTQ preprocessor with adapter trimming, quality filtering, and comprehensive QC reporting.
  - **GitHub Repository:** [fastp GitHub](https://github.com/OpenGene/fastp)
  - **Command Example:
    ```bash
    fastp -i input_R1.fastq -I input_R2.fastq \
    -o clean_R1.fastq -O clean_R2.fastq \
    --html report.html --json report.json \
    --thread 8 --length_required 25 --qualified_quality_phred 20
    ```

## Ribosomal RNA Filtering
**Description:** Removal of ribosomal RNA sequences to improve detection of mRNA transcripts.

**Tools:**
- **SortMeRNA**
  - **Description:** Highly accurate rRNA filtering tool with low false positive rates.
  - **GitHub Repository:** [SortMeRNA GitHub](https://github.com/biocore/sortmerna)
  - **Command Example:
    ```bash
    sortmerna --ref rRNA_databases --reads input.fastq \
    --aligned rRNA --other clean --fastx -a 4
    ```

## Mapping
**Description:** Alignment of processed reads to a reference genome using optimized aligners.

**Tools:**
- **STAR**
  - **Description:** Spliced Transcripts Alignment to a Reference, optimized for RNA-seq data.
  - **GitHub Repository:** [STAR GitHub](https://github.com/alexdobin/STAR)
  - **Command Example:
    ```bash
    STAR --genomeDir genome_index \
    --readFilesIn clean_R1.fastq clean_R2.fastq \
    --runThreadN 8 \
    --outSAMtype BAM SortedByCoordinate \
    --outFileNamePrefix aligned_
    ```

## Mapping Quality
**Description:** Comprehensive assessment of alignment quality including coverage statistics, duplicate detection, library complexity, and alignment characteristics.

**Tools:**
- **Samtools**
  - **Description:** Essential utilities for processing and analyzing alignment files.
  - **GitHub Repository:** [Samtools GitHub](https://github.com/samtools/samtools)
  - **Command Examples:
    ```bash
    # Basic alignment statistics
    samtools flagstat aligned.bam > flagstat_report.txt
    
    # Detailed alignment metrics
    samtools stats aligned.bam > alignment_stats.txt
    
    # Index BAM file
    samtools index aligned.bam
    ```

- **Picard**
  - **Description:** Provides detailed metrics about alignment quality, insert size, and duplicate reads.
  - **GitHub Repository:** [Picard GitHub](https://github.com/broadinstitute/picard)
  - **Command Examples:
    ```bash
    # Collect alignment summary metrics
    java -jar picard.jar CollectAlignmentSummaryMetrics \
      I=aligned.bam \
      O=alignment_metrics.txt \
      R=reference.fa
    
    # Mark duplicate reads
    java -jar picard.jar MarkDuplicates \
      I=aligned.bam \
      O=aligned_marked_duplicates.bam \
      M=mark_duplicates_metrics.txt
    
    # Collect RNA-seq specific metrics
    java -jar picard.jar CollectRnaSeqMetrics \
      I=aligned.bam \
      O=rna_metrics.txt \
      REF_FLAT=ref_flat.txt \
      STRAND=SECOND_READ_TRANSCRIPTION_STRAND
    ```

- **Preseq**
  - **Description:** Estimates library complexity and predicts the yield of distinct reads from additional sequencing.
  - **GitHub Repository:** [Preseq GitHub](https://github.com/smithlabcode/preseq)
  - **Command Examples:
    ```bash
    # Complexity curve estimation
    preseq c_curve -B aligned.bam -o preseq_c_curve.txt
    
    # Future yield estimation
    preseq lc_extrap -B aligned.bam -o preseq_lc_extrap.txt
    ```

- **RSeQC**
  - **Description:** Provides RNA-seq specific quality control metrics including read distribution, coverage uniformity, and strand specificity.
  - **GitHub Repository:** [RSeQC GitHub](https://github.com/hasherm/seqc)
  - **Command Examples:
    ```bash
    # Read distribution across genomic features
    read_distribution.py -i aligned.bam -r annotation.bed > read_distribution.txt
    
    # Infer experiment type (strandedness)
    infer_experiment.py -i aligned.bam -r annotation.bed > strand_info.txt
    
    # Junction annotation
    junction_annotation.py -i aligned.bam -o junction_results -r annotation.bed
    
    # Inner distance between read pairs
    inner_distance.py -i aligned.bam -o inner_distance -r annotation.bed
    ```

- **Qualimap**
  - **Description:** Generates comprehensive visual reports of alignment quality metrics.
  - **GitHub Repository:** [Qualimap GitHub](https://github.com/ualib-ros/Qualimap)
  - **Command Example:
    ```bash
    # RNA-seq specific QC
    qualimap rnaseq -bam aligned.bam \
      -gtf annotation.gtf \
      -outdir qualimap_results \
      -pe
    ```

## Gene Biotype Analysis
**Description:** Classification and quantification of reads by gene biotype categories.

**Tools:**
- **featureCounts**
  - **Description:** Efficient read counting with biotype classification.
  - **GitHub Repository:** [featureCounts GitHub](https://github.com/subreadteam/subread)
  - **Command Example:
    ```bash
    featureCounts -a annotation.gtf \
    -o gene_counts.txt \
    -t exon -g gene_biotype \
    aligned.bam
    ```

## Quantification
**Description:** Precise quantification of gene and transcript expression levels.

**Tools:**
- **RSEM**
  - **Description:** Accurate transcript-level quantification.
  - **GitHub Repository:** [RSEM GitHub](https://github.com/deweylab/RSEM)
  - **Command Example:
    ```bash
    rsem-calculate-expression --paired-end \
    --bam \
    --estimate-rspd \
    aligned.bam \
    reference_prefix \
    output_prefix
    ```

## MultiQC
**Description:** Aggregated quality control reporting across all pipeline steps.

**Tools:**
- **MultiQC**
  - **Description:** Unified quality control visualization.
  - **GitHub Repository:** [MultiQC GitHub](https://github.com/ewels/MultiQC)
  - **Command Example:
    ```bash
    multiqc ./
    ```

## How to Run
Execute pipeline scripts on an HPC cluster using SLURM:

```bash
sbatch <script_name>.sh
```

## Acknowledgements

This pipeline has benefited from the resources and support of the **High Performance Computing (HPC) Cluster at Pontificia Universidad Javeriana**. Special thanks to the staff for their continuous assistance and services that made this computational work possible.

For any questions or issues related to the pipeline, please feel free to open an issue or contact the contributors.
