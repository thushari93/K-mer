## Process ENA sequence files using Kraken2

Step 1: Install Kraken2

```bash
conda install -c bioconda kraken2
```

Step 2: Create 'fasta' files using 'fasta.gz'

```bash
conda install -c bioconda seqtk
zcat ERR2848501.fastq.gz | seqtk seq -a - > library/ERR2848501.fasta
```
Step 3: Add Taxnomy ID to in the 'fasta' file.

```python
def add_taxonomy_to_fasta(input_file, output_file, taxid):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            if line.startswith('>'):
                # Split the header line into the sequence ID part and the rest
                parts = line.split(' ', 1)
                sequence_id = parts[0]
                rest_of_header = parts[1] if len(parts) > 1 else ''
                
                # Modify the sequence ID to include the taxid
                new_header = f"{sequence_id}|kraken:taxid|{taxid} {rest_of_header}"
                
                # Write the modified header to the output file
                outfile.write(new_header)
            else:
                # Write the sequence lines as they are
                outfile.write(line)

# Define input and output file paths and the taxon ID
input_file = 'ERR2848501.fasta'
output_file = 'ERR2848501_modified.fasta'
taxid = '256318'

# Call the function to modify the fasta file
add_taxonomy_to_fasta(input_file, output_file, taxid)
```
Step 4: Add 'fasta' file to the library

```bash
kraken2-build --add-to-library library/ERR2848501_modified.fasta --db .
```

Step 5: Build database

```bash
kraken2-build --build --db .
```

Step 6: Classify another sequence using the database.
```bash
kraken2 --db . --report k2_report.txt --output k2_output.txt library ERR2848504_modified.fasta
```



