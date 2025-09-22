# transgeneMapping
Nextflow workflow to identify Oxford nanopore long reads with more than 1000 soft-clipped or hard-clipped bases, extracting the reads and aligning the reads to the genome/fasta file provided. 

I have found success working on the initial BAM alignment files produced by the https://gitlab.com/l.teboul/cas9point4 pipeline. 

# Installation guide:
The pipeline should be entirely self-contained apart from two dependencies:
* Nextflow
* docker

The included bash file will allow for easy running of the pipeline with default parameters. It will pull down the latest version of the pipeline, then run it as outlined below.

# Usage Guide
Nextflow profiles:
* docker

There are currently 2 profiles, docker, and test. The docker profile will pull the relevant docker container from dockerhub to ensure the pipeline works. The test profile will pull the same docker container, but currently doesn't work because I need to create some dummy data.

Parameters:
* --inputFile
* --sclenLength - default 1000 bases
* --hclenLength - default 1000 bases

The inputFile is the filepath to the input file, more details about which can be found below.
The sclenLength and hclenLength parameters can be adjusted to change the reads filtered from your original alignment. The filter logic is "greater than or equal to" the parameter, so keep this in mind when changing the value.

The input file, an empty example has been provided, expects 4 inputs:
* sampleName - a unique ID for each sample being analysed
* bamPath - file path to your bam file you want to extract reads from
* genomePath - file path to your genome/fasta file you want to align extracted reads to
* genomeName - string to help you identify what genome you've aligned to


The pipeline will handle multiple entries, and process them together, so you can run many samples against the same genome, or the same sample against many genomes as long as each entry has a unique sampleName entry.


# To do:
* Set up automatic generation of genomeName if none provided
* After mapping all soft- and hard-clipped reads, filter again to reduce noise/unwanted alignments
