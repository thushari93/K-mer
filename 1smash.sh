#!/bin/bash

# Input file name
input_file="Jor_extracted_fastq_linksf.txt"

# Output file name
output_file="Jor_output_sketches.txt"

# Ensure the input file is in Unix format
dos2unix "$input_file"

# Start number for sample naming
start_num=5954473

# Process each URL in the input file
while IFS= read -r URL; do
    SAMPLE="ERR${start_num}"
    curl -L "${URL}" | zcat | sourmash sketch dna -p scaled=10000,k=21 - -o "${SAMPLE}.sig"
    echo "${SAMPLE}.sig created from ${URL}" >> "$output_file"
    start_num=$((start_num + 1))
done < "$input_file"
