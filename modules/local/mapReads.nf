#!/usr/bin/env nextflow

process mapReads {
	
    publishDir "output/${bamPath.baseName}", mode: 'copy'

	input:
		tuple val(ID), path(bamPath), path(genomePath), val(genomeName), path(filteredFastq)		

	output:
		tuple val(ID), path("${bamPath.baseName}_mt_${genomeName}.bam")

	script:
	"""
	minimap2 -ax map-ont $genomePath $filteredFastq --MD |
	samtools view -bS |
	samtools sort -o ${bamPath.baseName}_mt_${genomeName}.bam
	"""
}
