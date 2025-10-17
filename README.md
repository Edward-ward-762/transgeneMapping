# transgeneMapping
Nextflow workflow to filter aligned Oxford nanopore long reads with soft-clipped or hard-clipped bases (1000 bases or more by default) and align the clipped reads to the genome/fasta file provided. 

I have found success working from the initial BAM alignment files produced by the https://gitlab.com/l.teboul/cas9point4 pipeline.

But you can run this from your own aligned BAM file. If you have reads aligned to a sequence, you can run this on the bam alignment and it will map any reads with clipping to the genome.

## Installation guide:
The pipeline should be entirely self-contained apart from two dependencies:
* Nextflow
* docker

I have only tested support for using a docker container, but there are other profiles available which might work for you. If you don't wish to install docker, then you will need 3 programmes, listed below, and their dependencies installed and added to the path environment variable.

Required programmes without docker (other container methods unverified):
* Samtools (version >= 1.19)
* Minimap2
* bamCoverage (part of deepTools)

## Usage Guide:
The input file, an empty example has been provided, expects 4 inputs:
* sampleName - a unique ID for each sample being analysed
* bamPath - file path to your bam file you want to extract reads from
* genomePath - file path to your genome/fasta file you want to align extracted reads to
* genomeName - string to help you identify what genome you've aligned to

Including in the github repository is a bash script, transgene_mapping.sh, which can be used to run the pipeline.
It first pulls the latest version of the main repository. Then runs the downloaded pipeline with the default docker profile.
You will need to change the inputFile parameter to a " " enclosed string of the file path to your sample sheet. eg: "/drive/file.csv"

You can remove the profile line if you wish to run without the docker container.

The pipeline will handle multiple entries, and process them together, so you can run many samples against the same genome, or the same sample against many genomes as long as each entry has a unique sampleName entry.

## Proposed developments:
* Create test dataset to check successful installation
* Add input file validation checks
* Add an initial step to align all the reads in your input Bam file to your genome/fasta
* Add a final filtering step to remove short genome alignments
* Include an optional bam file QC step
* Include an optional initial alignment to your transgene sequence so you can start from fastq/unaligned bam
