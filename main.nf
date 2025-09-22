#!/usr/bin/env nextflow

include { filterBamSclen } from './modules/local/filterBamSclen.nf'
include { convertReadsToFastq } from './modules/local/convertReadsToFastq.nf'
include { mapReads } from './modules/local/mapReads.nf'
include { samIndex } from './modules/local/samIndex.nf'
include { bamCoverage } from './modules/local/bamCoverage.nf'
include { filterBamRlen } from './modules/local/filterBamRlen.nf'

params.inputFile='inputFile_main_placeholder'
params.sclenLength='1000'
params.hclenLength='1000'
params.rlenLength='400'

workflow{
    inputData_ch=Channel.fromPath(params.inputFile)
                        .splitCsv(header: true)
                        .map { row ->
                            tuple( row.sample_name, row.bamPath, row.genomePath, row.genomeName )
                        }

    sclen_ch=Channel.of(params.sclenLength)

    hclen_ch=Channel.of(params.hclenLength)

    filterClipBam_ch=inputData_ch.combine(sclen_ch)
                                .combine(hclen_ch)

    filterBamSclen(filterClipBam_ch)

    convert_ch=inputData_ch.join(filterBamSclen.out)

    convertReadsToFastq(convert_ch)

    mapReads_ch=inputData_ch.join(convertReadsToFastq.out)

    mapReads(mapReads_ch)

    mappedOut_ch=inputData_ch.join(mapReads.out)

    samIndex(mappedOut_ch)

    bamCoverage(mappedOut_ch)

    //rlen_ch=Channel.of(params.rlenLength)

    //filterRlenBam_ch=mappedOut_ch.combine(rlen_ch)
    
    //filterBamRlen(filterRlenBam_ch)
 
}
