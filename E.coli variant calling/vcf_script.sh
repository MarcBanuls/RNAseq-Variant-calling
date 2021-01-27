#!/bin/bash
set -e

wd_genome=/home/marc/Programs/proj2/ref
genome=/home/marc/Programs/proj2/ref/ecoli.fasta

hisat2-build $genome  /home/marc/Programs/proj2/ref/ecoli


for fastq in /home/marc/Programs/proj2/fastq_zip/*.fastq.gz
do
    echo "Working with file $fastq"

    base=$(basename $fastq .fastq.gz)
    echo "Base name is $base"

    
    sam=/home/marc/Programs/proj2/aligned/sam/${base}.aligned.sam
    bam=/home/marc/Programs/proj2/aligned//bam/${base}.aligned.bam
    sorted_bam=/home/marc/Programs/proj2/aligned/bam/${base}.aligned.sorted.bam
    raw_bcf=/home/marc/Programs/proj2/results/bcf/${base}_raw.bcf
    variants=/home/marc/Programs/proj2/results/bcf/${base}_variants.vcf
    final_variants=/home/marc/Programs/proj2/results/vcf/${base}_final_variants.vcf
    echo "Starting alignment of $base"
    hisat2 -x $wd_genome/ecoli -U $fastq -S $sam
    echo "Done"

    echo "Passing to bam file"
    samtools view -S -b $sam > $bam
    echo "Done"

    echo "Sorting bam file"
    samtools sort -o $sorted_bam $bam
    echo "Done"

    echo "Obtaining bcf file from sorted bam"
    bcftools mpileup -O b -o $raw_bcf -f $genome $sorted_bam
    echo "Done"

    echo "Obtaining vcf"
    bcftools call -vm -o $variants $raw_bcf
    echo "Done"

    echo "Filtering vcf"
    bcftools filter $variants > $final_variants
    echo "Done"

    
	   
done