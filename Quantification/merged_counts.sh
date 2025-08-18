#!/bin/bash

# Define base path
COUNTS="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Quantification/RSEM"

# Define input directories
GENES="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Quantification/genes"
ISOFORMS="/opt/data/HPC01A/alexis_rojasc/OSA_RNA-seq/Quantification/isoforms"

# Create output directories for final merged results
echo "Creating output directories for final merged results..."
mkdir -p "$GENES" "$ISOFORMS"

# Process gene results
# Get the first gene file to extract header for gene_ids.txt
echo "Processing gene results..."
cut -f 1,2 $(find $COUNTS -type f -name "*.genes.results" | head -n 1) > gene_ids.txt

for fileid in $(find $COUNTS -type f -name "*.genes.results"); do
    samplename=$(basename "$fileid" | sed 's/\.genes.results$//')
    echo "Processing sample: $samplename"
    
    echo "$samplename" > "${GENES}/${samplename}.counts.txt"
    cut -f 5 "$fileid" | tail -n+2 >> "${GENES}/${samplename}.counts.txt"
    
    echo "$samplename" > "${GENES}/${samplename}.tpm.txt"
    cut -f 6 "$fileid" | tail -n+2 >> "${GENES}/${samplename}.tpm.txt"
done

# Process isoform results
# Get the first isoform file to extract header for transcript_ids.txt
echo "Processing isoform results..."
cut -f 1,2 $(find $COUNTS -type f -name "*.isoforms.results" | head -n 1) > transcript_ids.txt

for fileid in $(find $COUNTS -type f -name "*.isoforms.results"); do
    samplename=$(basename "$fileid" | sed 's/\.isoforms.results$//')
    echo "Processing sample: $samplename"
    
    echo "$samplename" > "${ISOFORMS}/${samplename}.counts.txt"
    cut -f 5 "$fileid" | tail -n+2 >> "${ISOFORMS}/${samplename}.counts.txt"
    
    echo "$samplename" > "${ISOFORMS}/${samplename}.tpm.txt"
    cut -f 6 "$fileid" | tail -n+2 >> "${ISOFORMS}/${samplename}.tpm.txt"
done

# Merge the results into final output files in the same directory
echo "Merging results into final output files..."
paste gene_ids.txt "${GENES}"/*.counts.txt > "$GENES/rsem.merged.gene_counts.tsv"
paste gene_ids.txt "${GENES}"/*.tpm.txt > "$GENES/rsem.merged.gene_tpm.tsv"
paste transcript_ids.txt "${ISOFORMS}"/*.counts.txt > "$ISOFORMS/rsem.merged.transcript_counts.tsv"
paste transcript_ids.txt "${ISOFORMS}"/*.tpm.txt > "$ISOFORMS/rsem.merged.transcript_tpm.tsv"

echo "Merge completed. Results saved in:"
echo "Gene counts: $GENES/rsem.merged.gene_counts.tsv"
echo "Gene TPM: $GENES/rsem.merged.gene_tpm.tsv"
echo "Isoform counts: $ISOFORMS/rsem.merged.transcript_counts.tsv"
echo "Isoform TPM: $ISOFORMS/rsem.merged.transcript_tpm.tsv"
echo "Script finished successfully."

