# UMGC_CapstoneCourse
Prokaryote variant calling pipeline made up of shell scripts using Docker containers.

**There are 3 major subprocesses wrapped under a single workflow:**
* `run_vc-pipeline.sh`
  * Read QC and trimming:
    * FastQC - quality check reads
    * Trimmomatic - trim reads
    * Fastq-info - check coverage (10x min.)
  * Read alignment:
    *  Bwa index/bwa mem - create index files and align
    *  Samtools - convert and sort .sam to sorted.bam
    *  QualiMap - quality check alignment
    *  Picard - mark and remove duplicate reads
  *  Variant calling:
     *  GATK-4 HaplotypeCaller - short variant discovery
## TOC
* [Install](#install)
