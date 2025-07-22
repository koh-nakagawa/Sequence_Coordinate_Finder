# Sequence Coordinate Finder Pipeline

This pipeline processes Sanger sequencing results (ABI `.ab1` files) and searches for coordinates of any target sequence(s) specified in a FASTA file.

## Files

- **`Sequence_Coordinate_Finder.sh`**  
  The main pipeline script. It performs all steps from ABI conversion to result merging.

- **`target.fa`**  
  FASTA file containing query sequences to search for (e.g., gRNA or any custom sequence).

## Features

1. **ABI to FASTQ**: Converts all `.ab1` files in the directory to `.fastq` using Biopython.  
2. **FASTQ to FASTA**: Converts all `.fastq` files to `.fasta` using `seqkit fq2fa`.  
3. **BLAST DB Creation**: Builds a BLAST nucleotide database for each `.fasta` file.  
4. **Target Search**: Runs `blastn-short` to find coordinates (start/end) of each sequence in `target.fa`.  
5. **Results Merge**: Combines individual TSV outputs into a single `all_vs_targets.tsv` file.

## Prerequisites

- `bash`
- `python3` with Biopython installed  
- `seqkit` (with the `fq2fa` subcommand)  
- BLAST+ tools (`makeblastdb`, `blastn`)

## Usage

1. Place all `.ab1` trace files and `target.fa` in the working directory.  
2. Make the pipeline script executable:

   ```bash
   chmod +x Sequence_Coordinate_Finder.sh
   ```

3. Run the pipeline:

   ```bash
   ./Sequence_Coordinate_Finder.sh
   ```

4. After completion, check `all_vs_targets.tsv` for a merged summary of sequence coordinates.

## Output

- **`*.fastq`**: Converted Sanger trace files  
- **`*.fasta`**: Converted FASTQ files  
- **`<sample>`**: BLAST database files for each `.fasta` sample  
- **`<sample>_vs_targets.tsv`**: BLAST results for each sample  
- **`all_vs_targets.tsv`**: Combined results across all samples

## Example `target.fa`

```fa
>target1
ACTGGA...
>target2
TGCACG...
```
