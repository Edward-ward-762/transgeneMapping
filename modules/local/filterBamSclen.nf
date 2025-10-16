#!/usr/bin/env nextflow

process filterBamSclen {

    input:
        tuple val(meta), path(bamPath)
        
    output:
        tuple val(meta), path("${bamPath.baseName}_clipped_reads.bam")

    script:
    """
    samtools view -h -e 'sclen >= $params.sclenLength || hclen >= $params.hclenLength' $bamPath > '${bamPath.baseName}_clipped_reads.bam'
    """
}
