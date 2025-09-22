#!/usr/bin/env nextflow

process filterBamRlen {

    publishDir "output/${bamPath.baseName}", mode: 'copy'

    input:
        tuple val(ID), path(bamPath), path(genomePath), val(genomeName), path(mapBam), val(rlenLength)

    output:
        tuple val(ID), path("${mapBam.baseName}_mapping_reads.txt"), emit: mapping_reads_ID
        tuple val(ID), path("${mapBam.baseName}_mapping_reads.bam"), emit: mapping_reads_bam
        path('${mapBam.baseName}_mapping_reads.bam.bai')
        path('${mapBam.baseName}_mapping_reads_coverage.bedgraph')

    script:
    """
    samtools view -e 'rclen >= $rlenLength' $mapBam | cut -f1 | sort | uniq > '${mapBam.baseName}_mapping_reads.txt'
    samtools view -h -N '${mapBam.baseName}_mapping_reads.txt' $mapBam | samtools sort -n -o '${mapBam.baseName}_mapping_reads.bam'
    samtools index '${mapBam.baseName}_mapping_reads.bam'
    bamCoverage -b '${mapBam.baseName}_mapping_reads.bam' -of bedgraph -bs 10000 -o '${mapBam.baseName}_mapping_reads_coverage.bedgraph'
    """

}
