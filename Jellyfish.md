## Process [ENA](https://www.ebi.ac.uk/ena/browser/view/PRJEB29238) sequence files using Jellyfish
 Step 1: Install Jellyfish
 ```bash
pip install jellyfish
````
Step 2: Obtain 15-mer counts
 ```bash
jellyfish count -m 15 -s 100M -t 10 -C ERR2848501.fastq -o mer_counts_ERR2848501.jf
````
Step 3: Convert output file ( '.jf' ) file to text file

 ```bash
jellyfish dump mer_counts_ERR2848501.jf > output_ERR2848501.txt
````

Step 5: Read the text file to count k-mers

```python
import itertools
def read_kmers_from_file(file_path):
    """Read k-mers and their counts from a text file."""
    kmers = {}
    with open(file_path, 'r') as file:
        kmer = None
        for line in file:
            line = line.strip()
            if line.startswith('>'):
                count = int(line.lstrip('>'))
            else:
                kmer = line
                kmers[kmer] = count
    return kmers
```
Instead of Step 3 and 4, we can read directly from the Jellyfish (.jf) file using the code below.

```python

import numpy as np
import itertools
import time
import mmap
import struct

#Function to find the starting point
def find_starting_point(binary_data):
    # Decode the byte string to a regular string
    string = binary_data.decode('utf-8',errors='ignore')
    # Find the position of the '{' character
    position = string.find('{')
    # Extract the substring up to that position
    result = string[:position]
    start = int(result)+len(result)
    return start



def read_kmers_from_file(file_path):
    """Read k-mers and their counts from a binary file."""
    kmers = {}
    
    with open(file_path, "rb") as f1:
        data1 = f1.read()
        
        starting_point = find_starting_point(data1)
        num_kmers = (len(data1) - starting_point) // 8
        
        format_str = '4sI'  # 4 bytes for k-mer, 4 bytes for count (uint32)
        struct_size = struct.calcsize(format_str)
        
        for i in range(num_kmers):
            offset = starting_point + i * struct_size
            kmer, count = struct.unpack_from(format_str, data1, offset)
            kmers[tuple(kmer)] = count

    return kmers
```

Step 4: Calculate distance using fractional common k-mer distance
```math
distance = \frac{\sum_{\text{common } k\text{-mers}} \min(C_1(K_i), C_2(K_i))}{\min\left(\sum_{\text{all } k\text{-mers}} C_1(K_j), \sum_{\text{all } k\text{-mers}} C_2(K_j) \right)}
```

```python
def fractional_common_kmer_count(file1, file2):
    """Calculate the fractional common k-mer count between two files."""
    kmers1 = read_kmers_from_file(file1)
    print('1st kmer :', file1)
    #Print first 5 elements for kmers1
    N = 5
    out = dict(itertools.islice(kmers1.items(), N)) 
    print("kmers1 : " + str(out))      
    kmers2 = read_kmers_from_file(file2)
    print('2nd kmer :', file2)
    #Print first 5 elements for kmers2
    out = dict(itertools.islice(kmers2.items(), N))
    print("kmers2 : " + str(out))
    #common_kmers = set(kmers1.keys()).intersection(set(kmers2.keys()))
    common_kmers = (key for key in kmers1 if key in kmers2)### Alternate method
    common_kmers_list = list(common_kmers)
    common_count = sum(min(kmers1[kmer], kmers2[kmer]) for kmer in common_kmers_list)
    
    total_count = min(sum(kmers1.values()), sum(kmers2.values()))
    
    if total_count == 0:
        return 0.0
    return common_count / total_count

# Example usage
file1 = '.../output_ERR2848501.txt'
file2 = '.../output_ERR2848504.txt'

fractional_count = fractional_common_kmer_count(file1, file2)
print(f"Fractional Common k-mer Count: {fractional_count}")
print('With new intersection')
```
