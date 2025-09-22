#!/usr/bin/env nextflow

process bamCoverage {
    
    publishDir "output/${bamPath.baseName}", mode: 'copy'

    input: 
        tuple val(ID), path(bamPath), path(genomePath), val(genomeName), path(mapBam)

    output:
        path "${mapBam.baseName}_coverage.bedgraph"
    
    script:
    """
    samtools index $mapBam
    bamCoverage -b $mapBam -of bedgraph -bs 10000 -o "${mapBam.baseName}_coverage.bedgraph"
    """
}