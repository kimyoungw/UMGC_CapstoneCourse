# Unified Analysis Variant Pipeline
Prokaryote variant calling pipeline for Illumina short-reads. Almost exclusively uses Docker containers wrapped up in a shell script workflow.

Developed by Siddhant Bose, Crystal Girod, Justin Kim, Sandra Shannon, and Rachael Vogel.

## TOC
* [Install](#install)
* [Workflow](#workflow)
* [Usage](#usage)
* [Resources](#resources)

## Install
Navigate to your home directory and git clone the repository.
```bash
$ git clone https://github.com/kimyoungw/umgc_capstonecourse_2022
```
Adding the workflow to your $PATH is an option if you are comfortable with doing so.

:warning: You **need** Docker Desktop installed and running for the next step. :warning:

Windows installation: https://docs.docker.com/desktop/install/windows-install/

Mac installation: https://docs.docker.com/desktop/install/mac-install/

Linux installation: https://docs.docker.com/desktop/install/linux-install/

Once the repository is cloned, navigate to the umgc_capstonecourse_2022 directory, and run `install.sh` to download the required docker containers and github repos.
Or alternatively, feel free to do them manually.

### Docker container images
 ```bash                         
$ docker pull pegi3s/fastqc
$ docker pull pegi3s/picard
$ docker pull pegi3s/qualimap
$ docker pull staphb/bwa
$ docker pull staphb/bcftools
$ docker pull staphb/samtools
$ docker pull staphb/trimmomatic
```               

### Github
**Note**: If you are installing fastq-info manually, it must be cloned such that the executable can be found by this path: `umgc_capstonecourse_2022/fastq-info/bin/fastqinfo-2.0.sh`

```bash
$ git clone https://github.com/raymondkiu/fastq-info
```

**Note**: One last thing - Confirm you have read-write-execute permissions for the scripts. If not:
```bash
chmod +x for_each_script.sh
```

## Workflow

Overview of pipeline, its three main subprocesses, and what's running in each:

* `run_vc-pipeline.sh`
  * Read QC and trimming - run_readcheck.sh:
    * FastQC - quality check reads
    * Trimmomatic - trim reads (set to TruSeq)
    * Fastq-info - check coverage (10x min.)
  * Read alignment - run_alignment.sh:
    *  Bwa index/bwa mem - create index files and align
    *  Samtools - convert and sort .sam to sorted.bam
    *  QualiMap - quality check alignment
    *  Picard - mark and remove duplicate reads
  *  Variant calling - run_varcall.sh:
     * Bcftools - call variants with mpileup and call

### What it does:
* Takes 3 required arguments:
  * **NOTE**: All three files need to be together in your **current** working directory. This is because of the way the storage is mounted between the local machine's filesystem and the Docker containers'. All outputs are by default directed to your current working directory.
  1. `-r reference.fasta` - the reference genome in .fasta format
  2. `-p short_read_1.fastq.gz` - read 1 in .fastq or .fastq.gz format
  3. `-q short_read_2.fastq.gz` - read 2 in .fastq or .fastq.gz format
* Runs `run_readcheck.sh`
```bash
#Output (abbreviated):
01_reads_qc_trim
├── reference/
│   └── ref.fasta
└── shortreads/
    └── fastqc/
    └── trimmomatic0.39/
    └── shortread_1.fastq.gz
    └── shortread_2.fastq.gz
```
* Runs `run_alignment.sh`
```bash
#Output (abbreviated):
02_alignment
└── bwamem_output_raw.sorted_stats/
└── indexfiles/
└── bwamem_output_raw.sorted.bam
└── marked_duplicates.bam
```
* Runs `run_varcall.sh`
```bash
#Output (abbreviated):
03_varcall
└── varcalls.vcf
```

## Usage
You can either call `run_vc-pipeline.sh` to run the entire workflow or each subprocess individually if you have the required inputs already from one step but ran into a machine error in another.

Help/usage statement for each script can be pulled up by running `whateveryourerunning.sh -h`

`run_vc-pipiline.sh`:
```bash
Usage: /path/to/umgc_capstonecourse_2022/workflow/run_vc-pipeline.sh
   -r reference.fasta   reference genome in fasta format
   -p read_1.fastq      read1 in fastq format
   -q read_2.fastq      read2 in fastq format

Example: /path/to/umgc_capstonecourse_2022/workflow/run_vc-pipeline.sh -r refgenome.fasta -p read_1.fastq -q read_2.fastq
```

`run_readcheck.sh`
```bash
Usage: /path/to/umgc_capstonecourse_2022/scripts/run_readcheck.sh
   -i path/to/dir/   directory holding reads

Example: /path/to/umgc_capstonecourse_2022/scripts/run_readcheck.sh -i /path/to/dirwithreads
```

`run_alignment.sh`
```bash
Usage: /path/to/umgc_capstonecourse_2022/scripts/run_alignment.sh
   -r path/to/reference/        reference genome in fasta format
   -p path/to/read1/		read1 in fastq format (qc'd and trimmed)
   -q path/to/read2/		read2 in fastq format (qc'd and trimmed)

Example: /path/to/umgc_capstonecourse_2022/scripts/run_alignment.sh -r /path/to/ref.fasta -p /path/to/read_1.fastq -q /path/to/read_2.fastq
```

`run_varcall.sh`
```bash
Usage: /path/to/umgc_capstonecourse_2022/scripts/run_varcall.sh
   -r path/to/reference/        reference genome in fasta format
   -i path/to/.bam/             sorted and duplicates marked .bam

Example: /path/to/umgc_capstonecourse_2022/scripts/run_varcall.sh -r /path/to/ref.fasta -i sorted.duplicatesmarked.bam
```

## Resources
* Fastq-info: Kiu R, fastq-info: compute estimated sequencing depth (coverage) of prokaryotic genomes, GitHub https://github.com/raymondkiu/fastq-info
* State Public Health Bioinformatics Workgroup (StaphB): https://github.com/StaPH-B
* Phenotypic Evolution Group (pegi3s): https://github.com/pegi3s
