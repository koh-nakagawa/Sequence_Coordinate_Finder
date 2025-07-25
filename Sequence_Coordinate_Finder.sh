#!/usr/bin/env bash
set -euo pipefail

# 1) Check for target.fa
if [ ! -f target.fa ]; then
  echo "Error: target.fa not found."
  echo "Please provide your query sequences in FASTA format as target.fa. For example:"
  echo ">target1"
  echo "ACTGGA..."
  echo ">target2"
  echo "TGCACG..."
  exit 1
fi

# 2) Convert all .ab1 to .fastq
echo ">>> Converting ABI trace files to FASTQ..."
python3 << 'PYCODE'
import glob, os
from Bio import SeqIO

for ab1 in glob.glob("*.ab1"):
    record = SeqIO.read(ab1, "abi")
    fastq_file = os.path.splitext(ab1)[0] + ".fastq"
    SeqIO.write(record, fastq_file, "fastq")
    print(f"Converted {ab1} → {fastq_file}")
PYCODE

# 3) Convert all .fastq to .fasta
echo ">>> Converting FASTQ files to FASTA..."
for fq in *.fastq; do
    fa="${fq%.fastq}.fasta"
    seqkit fq2fa "$fq" -o "$fa"
    echo "Converted $fq → $fa"
done

# 4) Build a BLAST database for each .fasta
echo ">>> Building BLAST databases..."
for fa in *.fasta; do
    db="${fa%.fasta}"
    makeblastdb -in "$fa" -dbtype nucl -parse_seqids -out "$db"
    echo "Created database $db"
done

# 5) Run BLAST search of target.fa against each database
echo ">>> Running BLAST searches..."
for dbn in *.nin; do
    db="${dbn%.nin}"
    out="${db}_vs_targets.tsv"
    blastn \
      -task blastn-short \
      -query target.fa \
      -db "$db" \
      -outfmt "6 qseqid sseqid pident length qstart qend sstart send evalue bitscore" \
      -out "$out"
    echo "Generated $out"
done

# 6) Merge all results into a single TSV, skipping the merge-file itself
echo ">>> Merging results into all_vs_targets.tsv..."
{
  printf "sample\tqseqid\tsseqid\tpident\tlength\tqstart\tqend\tsstart\tsend\tevalue\tbitscore\n"
  for tsv in *_vs_targets.tsv; do
    # skip the file we're about to create
    if [[ "$tsv" == "all_vs_targets.tsv" ]]; then
      continue
    fi
    sample="${tsv%_vs_targets.tsv}"
    sed "s/^/${sample}\t/" "$tsv"
  done
} | sort -t$'\t' -k1,1V > all_vs_targets.tsv

echo ">>> Pipeline complete. Output: all_vs_targets.tsv"