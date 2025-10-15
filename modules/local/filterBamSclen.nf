#!/usr/bin/env nextflow

process filterBamSclen {

    publishDir "output/${bamPath.baseName}", mode: 'copy'

    input:
        tuple val(meta), path(bamPath)
        
    output:
        tuple val(meta), path("${bamPath.baseName}_clipped_reads.bam")

    script:
    """
    samtools view -e 'sclen >= $params.sclenLength || hclen >= $params.hclenLength' $bamPath > '${bamPath.baseName}_clipped_reads.bam'
    """

}
