#!/usr/bin/env nextflow

process convertReadsToFastq {
    
    input:
        tuple val(meta), path(bamPath)
    
    output:
        tuple val(meta), path("${bamPath.baseName}.fastq")

    script:
    """
    samtools fastq $bamPath > '${bamPath.baseName}.fastq'
    """
}