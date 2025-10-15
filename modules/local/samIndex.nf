#!/usr/bin/env nextflow

process samIndex {
    
    input:
        tuple val(meta), path(mapBam)

    output:
        tuple val(meta), path("${mapBam}.bai")
    
    script:
    """
    samtools index $mapBam
    """
}