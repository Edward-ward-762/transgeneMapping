#!/usr/bin/env nextflow

process bamCoverage {
    
    input: 
        tuple val(meta), path(mapBam), path(mapBai)

    output:
        path "${mapBam.baseName}_coverage.bedgraph"
    
    script:
    """
    bamCoverage -b $mapBam -of bedgraph -bs $params.bedgraph_bin_size -o "${mapBam.baseName}_coverage.bedgraph"
    """
}