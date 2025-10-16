#!/usr/bin/env nextflow

process mapReads {

	input:
		tuple val(meta), path(filteredFastq)
		path(genomePath)
		val(genomeName)	

	output:
		tuple val(meta), path("${filteredFastq.baseName}_mt_${genomeName}.bam")

	script:
	"""
	minimap2 -ax map-ont $genomePath $filteredFastq --MD |
	samtools view -bS |
	samtools sort -o ${filteredFastq.baseName}_mt_${genomeName}.bam
	"""
}
