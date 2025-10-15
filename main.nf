#!/usr/bin/env nextflow

include { filterBamSclen } from './modules/local/filterBamSclen.nf'
include { convertReadsToFastq } from './modules/local/convertReadsToFastq.nf'
include { mapReads } from './modules/local/mapReads.nf'
include { samIndex } from './modules/local/samIndex.nf'
include { bamCoverage } from './modules/local/bamCoverage.nf'
include { filterBamRlen } from './modules/local/filterBamRlen.nf'

workflow{
    inputData_ch=Channel.fromPath(params.inputFile)
                        .splitCsv(header: true)
                        .map { row ->
                            [[id: row.sample_name,genomePath: row.genomePath,genomeName: row.genomeName],row.bamPath]
                        }

    filterClipBam_ch=inputData_ch

    filterBamSclen(
        filterClipBam_ch.map{ meta, bam -> [meta, bam] }
        )

    convert_ch=filterBamSclen.out

    convertReadsToFastq(
        convert_ch.map{ meta, bam -> [meta, bam] }
        )

    //mapReads_ch=inputData_ch.join(convertReadsToFastq.out)

    //mapReads(mapReads_ch)

    //mappedOut_ch=inputData_ch.join(mapReads.out)

    //samIndex(mappedOut_ch)

    //bamCoverage(mappedOut_ch)

    //rlen_ch=Channel.of(params.rlenLength)

    //filterRlenBam_ch=mappedOut_ch.combine(rlen_ch)
    
    //filterBamRlen(filterRlenBam_ch)
 
}
