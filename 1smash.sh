#!/bin/bash

# Input file name
input_file="Jor_extracted_fastq_links.txt"

# Output file name
output_file="Jor_output_sketches.txt"

# Ensure the input file is in Unix format
dos2unix "$input_file"

# Empty the output file if it exists
> "$output_file"

# Process each URL in the input file
while IFS= read -r URL; do
    # Extract the base name from the URL
    base_name=$(basename "${URL}" .fastq.gz)
    
    # Sketch the DNA and save the .sig file with the extracted base name
    curl -L "${URL}" | zcat | sourmash sketch dna -p scaled=10000,k=21 - -o "${base_name}.sig"
    
    # Record the creation in the output file
    echo "${base_name}.sig created from ${URL}" >> "$output_file"
done < "$input_file"
