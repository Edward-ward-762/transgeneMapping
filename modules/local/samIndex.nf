#!/usr/bin/env nextflow

process samIndex {
    
    publishDir "output/${bamPath.baseName}", mode: 'copy'

    input:
        tuple val(ID), path(bamPath), path(genomePath), val(genomeName), path(mapBam)

    output:
        path "${mapBam}.bai"
    
    script:
    """
    samtools index $mapBam
    """
}