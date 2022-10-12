# UMGC_CapstoneCourse
Variant calling pipeline made up of shell scripts using Docker containers.

**There are 3 major subprocesses wrapped under a single workflow:**
* `run_vc-pipeline.sh`
  *Read QC and Trimming:
   * FastQC
   * Trimmomatic
   * Fastq-info
