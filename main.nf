#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Transgene mapping
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULEs
//

include { filterBamSclen } from './modules/local/filterBamSclen.nf'
include { convertReadsToFastq } from './modules/local/convertReadsToFastq.nf'
include { mapReads } from './modules/local/mapReads.nf'
include { samIndex } from './modules/local/samIndex.nf'
include { bamCoverage } from './modules/local/bamCoverage.nf'
include { filterBamRlen } from './modules/local/filterBamRlen.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow{

    //
    // ****************************
    //
    // SECTION: Creating input Channel
    //
    // ****************************
    //

    inputData_ch=Channel.fromPath(params.inputFile)
                        .splitCsv(header: true)
                        .map { row ->
                            [[id: row.sample_name,genomePath: row.genomePath,genomeName: row.genomeName],row.bamPath]
                        }

    //
    // ****************************
    //
    // SECTION: filter alignment for clipped reads
    //
    // ****************************
    //

    //
    // CHANNEL: create channel from input channel
    //

    filterClipBam_ch = inputData_ch

    //
    // MODULE: filter input bam files for clipped bases
    //

    filterBamSclen(
        filterClipBam_ch.map{ meta, bam -> [meta, bam] }
        )

    convert_ch = filterBamSclen.out

    //
    // ****************************
    //
    // SECTION: Align clipped reads to genome
    //
    // ****************************
    //

    //
    // MODULE: Convert filter clipped reads to fastq
    //

    convertReadsToFastq(
        convert_ch.map{ meta, bam -> [meta, bam] }
        )
    ch_mapReads = convertReadsToFastq.out

    //
    // MODULE: Align clipped fastqs to genome
    //

    mapReads(
        ch_mapReads.map{ meta, fq -> [meta, fq] },
        ch_mapReads.map{ meta, fq -> meta.genomePath },
        ch_mapReads.map{ meta, fq -> meta.genomeName}
        )
    ch_mapped_bam = mapReads.out
    
    //
    // MODULE: index genome aligned clipped fastqs
    //

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

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
