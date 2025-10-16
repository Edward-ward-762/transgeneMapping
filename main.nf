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

    filterClipBam_ch = inputData_ch

    filterBamSclen(
        filterClipBam_ch.map{ meta, bam -> [meta, bam] }
        )

    convert_ch = filterBamSclen.out

    convertReadsToFastq(
        convert_ch.map{ meta, bam -> [meta, bam] }
        )
    ch_mapReads = convertReadsToFastq.out

    mapReads(
        ch_mapReads.map{ meta, fq -> [meta, fq] },
        ch_mapReads.map{ meta, fq -> meta.genomePath },
        ch_mapReads.map{ meta, fq -> meta.genomeName}
        )
    ch_mapped_bam = mapReads.out
    
    samIndex(
        ch_mapped_bam.map{ meta, bam -> [meta, bam] }
        )
    ch_mapped_bai = samIndex.out

    //
    // CHANNEL: Combine BAM and BAI
    //
    ch_mapped_bam_bai = ch_mapped_bam
        .join(ch_mapped_bai, by: [0])
        .map {
            meta, bam, bai ->
                if (bai) {
                    [ meta, bam, bai ]
                }
        }

    //
    // CHANNEL: Filter empty bams
    //
    ch_mapped_bam_bai = ch_mapped_bam_bai.filter { row -> 
            file(row[1]).size() >= params.min_bam_size 
            }

    bamCoverage(
        ch_mapped_bam_bai.map{ meta, bam, bai -> [meta, bam, bai] }
    )

    //rlen_ch=Channel.of(params.rlenLength)

    //filterRlenBam_ch=mappedOut_ch.combine(rlen_ch)
    
    //filterBamRlen(filterRlenBam_ch)
 
}
