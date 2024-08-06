#!/bin/bash
#Convert file format
dos2unix URLs_535_544.txt

#Extract the fastq_ftp links from the file
awk -F'\t' '{print $7}' filereport_read_run_PRJEB29238_tsv.txt > extracted_fastq_links.txt

start_num=2848535

#Process each extracted URL
while IFS= read -r URL; do
    SAMPLE="ERR${start_num}"
    curl -L "${URL}" | zcat | sourmash sketch dna -p scaled=10000,k=15 - -o "${SAMPLE}.sig"
    start_num=$((start_num + 1))
done < extracted_fastq_links.txt