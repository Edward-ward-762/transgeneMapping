# transgeneMapping
Nextflow workflow to filter aligned Oxford nanopore long reads with soft-clipped or hard-clipped bases (1000 bases or more by default) and align the clipped reads to the genome/fasta file provided. 

I have found success working from the initial BAM alignment files produced by the https://gitlab.com/l.teboul/cas9point4 pipeline.

But you can run this from your own aligned BAM file. If you have reads aligned to a sequence, you can run this on the bam alignment and it will map any reads with clipping to the genome.

## Installation guide:
The pipeline should be entirely self-contained apart from two dependencies:
* Nextflow (NOTE nextflow version 25.10.5 is the latest supported version)
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

## Workflow parameters

### Output Options

- **`outdir`**  
  _Default:_ `./results`  
  **Description:** Directory where the pipeline's results will be saved.

- **`tracedir`**  
  _Default:_ `.${params.outdir}/pipeline_info`  
  **Description:** Directory where the pipeline info (run reports, software versions) will be saved.

- **`publish_dir_mode`**  
  _Default:_ `copy`  
  **Description:** Mode Nextflow will use when handling output of processes.

  **Known possible values:**
  - `copy` - default value
  - `copyNoFollow`
  - `link`
  - `move`
  - `rellink`
  - `symlink`

For more information regarding how each option will function please consult: https://www.nextflow.io/docs/latest/reference/process.html#publishdir

- **`debug`**  
  _Default:_ `false`  
  **Description:** Enables debug mode if set to true.

### Max Resource Options

- **`max_memory`**  
  _Default:_ `128.GB`  
  **Description:** Maximum memory allocation for the pipeline **per process**. Processes may request less.

- **`max_cpus`**  
  _Default:_ `16`  
  **Description:** Maximum number of CPUs that can be used **per process**. Processes may request less.

- **`max_time`**  
  _Default:_ `240.h`  
  **Description:** Maximum time allocation for the pipeline **per process**. Processes may request less.

### Workflow parameters

- **`inputFile`**
  _Default:_ `inputFile_main_placeholder`
  **Description:** File path to input csv file.

- **`sclenLength`**
  _Default:_ `1000`
  **Description:** Minimum number of soft-clipped bases to include when filtering.

- **`hclenLength`**
  _Default:_ `1000`
  **Description:** Minimum number of hard-clipped bases to include when filtering.

- **`rlenLenght`**
  _Default:_ `1000`
  **Description:** Minimum number of genome aligned bases to keep reads.

- **`min_bam_size`**
  _Default:_ `500`  
  **Description:** Minimum bam file size in bytes for an empty bam file. Used in filtering out empty bam files.

- **`bedgraph_bin_size`**
  _Default:_ `10000`
  **Description:** Bin size used when creating bedgraph file. Genome will be split into bins of this size, and the number of reads counted in each bin.
