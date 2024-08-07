## Process ENA sequence files using Sourmash

Step 1: Install Sourmash
 ```bash
pip install sourmash
```

Step 2: Generate Signature files
 ```bash
sourmash sketch dna -p scaled=10000,k=21 ERR2848510.fastq.gz -o ERR2848510-reads.sig
```

Instead of Step 2, it is possible to access the sequence files without downloading them.
```bash
while IFS= read -r URL; do
err_name=$(echo "$URL" | grep -oP 'ERR\d+'| tail -1)
curl -L "${URL}" | zcat | sourmash sketch dna -p scaled=1000,k=15 - -o "${err_name}.sig"
done < URLs_datasets.txt
```

Step 3: Compare Signature files

```bash
sourmash compare *.sig -o cmp
```
