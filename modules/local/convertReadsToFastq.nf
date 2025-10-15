#!/usr/bin/env nextflow

process convertReadsToFastq {
    
    input:
        tuple val(meta), path(bamPath)
    
    output:
        tuple val(meta), path("${bamPath.baseName}_clipped.fastq")

    script:
    """
    samtools $bamPath fastq > '${bamPath.baseName}_clipped.fastq'
    """
}