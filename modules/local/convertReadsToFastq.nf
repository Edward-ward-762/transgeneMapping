#!/usr/bin/env nextflow

process convertReadsToFastq {
    
    publishDir "output/${bamPath.baseName}", mode: 'copy'

    input:
        tuple val(ID), path(bamPath), path(genomePath), val(genomeName), path(readNames)
    
    output:
        tuple val(ID), path("${bamPath.baseName}_clipped.fastq")

    script:
    """
    samtools view -h -N $readNames $bamPath | samtools fastq > '${bamPath.baseName}_clipped.fastq'
    """
}