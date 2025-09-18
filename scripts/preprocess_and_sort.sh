#!/bin/bash
#BSUB -J "preprocess_and_sort"
#BSUB -n 4
#BSUB -q long
#BSUB -W 8:00
#BSUB -R "rusage[mem=2048]"
#BSUB -R "span[hosts=1]"
#BSUB -oo preprocess_and_sort.out
#BSUB -eo preprocess_and_sort.err

module load samtools/0.1.19
module load perl/5.18.1

samtools view -h -F4 101900-002_R1_pA-trimmed_bwt.bam | perl dedup_preprocess_v2.pl - | samtools view -Sb - > 101900-002_R1_pA-trimmed_bwt_preprocessed.bam
samtools sort -@ 4 101900-002_R1_pA-trimmed_bwt_preprocessed.bam 101900-002_R1_pA-trimmed_bwt_preprocessed_sorted
samtools index 101900-002_R1_pA-trimmed_bwt_preprocessed_sorted.bam

samtools view -h -F4 101900-003_R1_pA-trimmed_bwt.bam | perl dedup_preprocess_v2.pl - | samtools view -Sb - > 101900-003_R1_pA-trimmed_bwt_preprocessed.bam
samtools sort -@ 4 101900-003_R1_pA-trimmed_bwt_preprocessed.bam 101900-003_R1_pA-trimmed_bwt_preprocessed_sorted
samtools index 101900-003_R1_pA-trimmed_bwt_preprocessed_sorted.bam
