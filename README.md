# transgeneMapping
Nextflow workflow to identify Oxford nanopore long reads with more than 1000 soft-clipped or hard-clipped bases, extracting the reads and aligning the reads to the genome/fasta file provided. 

I have found success working on the initial BAM alignment files produced by the https://gitlab.com/l.teboul/cas9point4 pipeline. 

Installation guide:
The pipeline should be entirely self-contained apart from two dependencies:
* Nextflow
* docker

Currently the docker image is hard-coded into the config files, but it aims at a local installation. That needs to be fixed, but I need to upload the docker image first, then I will update the config files to point at a publicly available docker image.

Usage Guide:
The input file, an empty example has been provided, expects 4 inputs:
* sampleName - a unique ID for each sample being analysed
* bamPath - file path to your bam file you want to extract reads from
* genomePath - file path to your genome/fasta file you want to align extracted reads to
* genomeName - string to help you identify what genome you've aligned to

The pipeline will handle multiple entries, and process them together, so you can run many samples against the same genome, or the same sample against many genomes as long as each entry has a unique sampleName entry.

To do:
* Upload docker image
* Set up automatic generation of genomeName if none provided
