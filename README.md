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

## Install
Navigate to your home directory and git clone the repository.
```bash
$ git clone https://github.com/kimyoungw/UMGC_CapstoneCourse
```
Adding the workflows to your $PATH is an option if you are comfortable with doing so.

:warning: You **need** Docker Desktop installed and running for the next step. :warning:
Windows installation: https://docs.docker.com/desktop/install/windows-install/
Mac installation: https://docs.docker.com/desktop/install/mac-install/
Linux installation: https://docs.docker.com/desktop/install/linux-install/

Once the repository is cloned, run `install.sh` to download the required docker containers and github repos.
Or alternatively, feel free to do them manually.
