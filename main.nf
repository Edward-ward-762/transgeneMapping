#!/usr/bin/env nextflow

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Transgene mapping
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { convertReadsToFastq } from './modules/local/convertReadsToFastq.nf'
include { mapReads } from './modules/local/mapReads.nf'
include { samIndex } from './modules/local/samIndex.nf'
include { bamCoverage } from './modules/local/bamCoverage.nf'
include { filterBamRlen } from './modules/local/filterBamRlen.nf'


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { SAMTOOLS_FASTQ                        } from './modules/nf-core/samtools/fastq/main.nf'
include { MINIMAP2_ALIGN                        } from './modules/nf-core/minimap2/align/main.nf'
include { SAMTOOLS_INDEX                        } from './modules/nf-core/samtools/index/main.nf'
include { DEEPTOOLS_BAMCOVERAGE                 } from './modules/nf-core/deeptools/bamcoverage/main.nf'
include { SAMTOOLS_VIEW as SAM_VIEW_CLIP_FILTER } from './modules/nf-core/samtools/view/main.nf'
include { SAMTOOLS_FASTQ as SAM_FQ_CLIP_READS   } from './modules/nf-core/samtools/fastq/main.nf'
include { MINIMAP2_ALIGN as MAP_ALIGN_GENOME    } from './modules/nf-core/minimap2/align/main.nf'
include { SAMTOOLS_INDEX as SAM_INDEX_CLIP_MAP  } from './modules/nf-core/samtools/index/main.nf'
include { DEEPTOOLS_BAMCOVERAGE as BAM_COV_CLIP } from './modules/nf-core/deeptools/bamcoverage/main.nf'


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow{

    //
    // ****************************
    //
    // SECTION: Creating input Channels
    //
    // ****************************
    //

    ch_inputData = Channel.fromPath(params.inputFile)
                        .splitCsv(header: true)
                        .map { row ->
                            [[id: row.sample_name,genomePath: row.genomePath,genomeName: row.genomeName],row.bamPath]
                        }

    ch_versions = Channel.empty()

    //
    // ****************************
    //
    // SECTION: Map all reads to genome, index bam file, and create bedgraph for each
    //
    // ****************************
    //

    //
    // MODULE: Convert all reads to fastqs
    //

    SAMTOOLS_FASTQ(
        ch_inputData.map{ meta, bam -> [meta, bam] },
        false
    )
    ch_versions   = ch_versions.mix(SAMTOOLS_FASTQ.out.versions)
    ch_initial_fq = SAMTOOLS_FASTQ.out.other

    //
    // MODULE: Map all reads in input bams to genome
    //

    MINIMAP2_ALIGN(
        ch_initial_fq.map{ meta, fq -> [meta, fq] },
        ch_initial_fq.map{ meta, fq -> [meta, meta.genomePath] },
        true,
        false,
        false,
        false
    )
    ch_versions    = ch_versions.mix(MINIMAP2_ALIGN.out.versions)
    ch_initial_bam = MINIMAP2_ALIGN.out.bam

    //
    // MODULE: Index bam files of all reads mapped to genomes
    //

    SAMTOOLS_INDEX(
        ch_initial_bam.map{ meta, bam -> [meta, bam] }
        )
    ch_versions    = ch_versions.mix(SAMTOOLS_INDEX.out.versions)
    ch_initial_bai = SAMTOOLS_INDEX.out.bai

    //
    // CHANNEL: Combine BAM and BAI
    //
    ch_initial_bam_bai = ch_initial_bam
        .join(ch_initial_bai, by: [0])
        .map {
            meta, bam, bai ->
                if (bai) {
                    [ meta, bam, bai ]
                }
        }

    //
    // CHANNEL: Filter empty bams
    //
    ch_initial_bam_bai = ch_initial_bam_bai.filter { row -> 
            file(row[1]).size() >= params.min_bam_size 
            }

    //
    // MODULE: Create coverage bedgraph
    //

    DEEPTOOLS_BAMCOVERAGE(
        ch_initial_bam_bai.map{ meta, bam, bai -> [meta, bam, bai] },
        [],
        [],
        [[],[]]
    )

    //
    // ****************************
    //
    // SECTION: filter alignment for clipped reads
    //
    // ****************************
    //

    //
    // MODULE: filter input bam files for clipped bases
    //

    SAM_VIEW_CLIP_FILTER(
        ch_inputData.map{ meta, bam -> [meta, bam,[]] },
        [[],[]],
        [],
        'bai'
    )
    ch_versions    = ch_versions.mix(SAM_VIEW_CLIP_FILTER.out.versions)
    ch_clipped_bam = SAM_VIEW_CLIP_FILTER.out.bam

    //filterBamSclen(
    //    filterClipBam_ch.map{ meta, bam -> [meta, bam] }
    //   )

    //convert_ch = filterBamSclen.out

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

    SAM_FQ_CLIP_READS(
        ch_clipped_bam.map{ meta, bam -> [meta, bam] },
        false
    )
    ch_versions   = ch_versions.mix(SAM_FQ_CLIP_READS.out.versions)
    ch_clipped_fq = SAM_FQ_CLIP_READS.out.other

    //convertReadsToFastq(
    //    convert_ch.map{ meta, bam -> [meta, bam] }
    //    )
    //ch_mapReads = convertReadsToFastq.out

    //
    // MODULE: Align clipped fastqs to genome
    //

    MAP_ALIGN_GENOME(
        ch_clipped_fq.map{ meta, fq -> [meta, fq] },
        ch_clipped_fq.map{ meta, fq -> [meta, meta.genomePath] },
        true,
        false,
        false,
        false
    )
    ch_versions     = ch_versions.mix(MAP_ALIGN_GENOME.out.versions)
    ch_clip_map_bam = MAP_ALIGN_GENOME.out.bam 

    //mapReads(
    //    ch_mapReads.map{ meta, fq -> [meta, fq] },
    //    ch_mapReads.map{ meta, fq -> meta.genomePath },
    //    ch_mapReads.map{ meta, fq -> meta.genomeName}
    //    )
    //ch_mapped_bam = mapReads.out

    //
    // MODULE: index genome aligned clipped fastqs
    //

    SAM_INDEX_CLIP_MAP(
        ch_clip_map_bam.map{ meta, bam -> [meta, bam] }
    )
    ch_versions     = ch_versions.mix(SAM_INDEX_CLIP_MAP.out.versions)
    ch_clip_map_bai = SAM_INDEX_CLIP_MAP.out.bai


    //samIndex(
    //    ch_mapped_bam.map{ meta, bam -> [meta, bam] }
    //    )
    //ch_mapped_bai = samIndex.out

    //
    // CHANNEL: Combine BAM and BAI
    //
    ch_clip_map_bam_bai = ch_clip_map_bam
        .join(ch_clip_map_bai, by: [0])
        .map {
            meta, bam, bai ->
                if (bai) {
                    [ meta, bam, bai ]
                }
        }

    //
    // CHANNEL: Filter empty bams
    //
    ch_clip_map_bam_bai = ch_clip_map_bam_bai.filter { row -> 
            file(row[1]).size() >= params.min_bam_size 
            }

    //
    // MODULE: Create coverage bedgraph
    //

    BAM_COV_CLIP(
        ch_clip_map_bam_bai.map{ meta, bam, bai -> [meta, bam, bai] },
        [],
        [],
        [[],[]]
    )
    ch_versions     = ch_versions.mix(BAM_COV_CLIP.out.versions)

    //bamCoverage(
    //    ch_mapped_bam_bai.map{ meta, bam, bai -> [meta, bam, bai] }
    //)

}

/*
    //rlen_ch=Channel.of(params.rlenLength)

    //filterRlenBam_ch=mappedOut_ch.combine(rlen_ch)
    
    //filterBamRlen(filterRlenBam_ch)
 
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
