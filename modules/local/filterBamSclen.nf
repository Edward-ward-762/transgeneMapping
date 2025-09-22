#!/usr/bin/env nextflow

process filterBamSclen {

    publishDir "output/${bamPath.baseName}", mode: 'copy'

    input:
        tuple val(ID), path(bamPath), path(genomePath), val(genomeName), val(sclenLength), val(hclenLength)
        
    output:
        tuple val(ID), path("${bamPath.baseName}_clipped_reads.txt")

    script:
    """
    samtools view -e 'sclen >= $sclenLength || hclen >= $hclenLength' $bamPath | cut -f1 | sort | uniq > '${bamPath.baseName}_clipped_reads.txt'
    """

}
