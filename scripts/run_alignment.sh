#!/usr/bin/bash

#This script will
#1) Take the output of QC subprocess
#2) Create an index using bwa index
#3) Align to a reference genome using bwa mem and Illumina short reads
#4) Generate a raw .sam
#5) Format and convert .sam to .bam
#6) Sort, quality check, and remove duplicates from raw .bam using samtools, QualiMap, and Picard

#HELP function
function HELP {
echo ""
echo "Usage:" $0
echo "			-r path/to/reference/			reference genome in fasta format"
echo "			-p path/to/read1/			read1 in fastq format"
echo "			-q path/to/read2/			read2 in fastq format"
echo ""
echo "Example: $0 -r /path/to/refgenome.fasta -a /path/to/read1.fastq -b path/to/read2.fastq"
echo ""
exit 0
}

###Take arguments
#Run HELP if -h -? or invalid input
#Set REFERENCE to -r
#Set READ1 to -p
#Set READ2 to -q
#TODO: Get standard output format from SP1 and change exports
while getopts ":hr:p:q:" option; do
	case ${option} in
		h)
		HELP
		;;
		r)
		export REFERENCE=${OPTARG}
		;;
		p)
		export READ1=${OPTARG}
		;;
		q)
		export READ2=${OPTARG}
		;;
		\?)
		echo "Invalid option: ${OPTARG}" 1>&2
		HELP
		;;
	esac
done

#Check if all parameters are filled
if [[ -z "${REFERENCE}" || -z "${READ1}" || -z "${READ2}" ]]; then
	echo ""
	echo "All flags required."
	HELP
fi

#Check if files exist and print out variables
if [[ -e $REFERENCE && -e $READ1 && -e $READ2 ]]; then
	echo ""
	echo "$0"
	echo "Reference genome set to: " ${REFERENCE}
	echo "Read 1 set to: " ${READ1}
	echo "Read 2 set to: " ${READ2}
	echo ""
else
	echo ""
	echo "Could not validate files. Please check and try again."
	HELP
fi

#Path to genome indexes including prefix
db_prefix=$(basename ${REFERENCE})
echo "Prefix set to: " $db_prefix
echo ""

#Run bwa index on reference genome
echo "Creating index files for reference genome..."
echo ""
docker run -t --rm -u $(id -u):$(id -g) -v $(pwd):/data:rw -w /data staphb/bwa:latest bwa index -p ${db_prefix} ${REFERENCE}

#Get path to directory + prefix for genome index files
#thisDir=$(dirname $0)
#index_path=$(pwd)/$db_prefix
#echo ""
#echo "Path to index files set to:" $index_path

#Run bwa mem
echo ""
echo "Aligning using bwa-mem..."
echo ""
docker run -t --rm -u $(id -u):$(id -g) -v $(pwd):/data:rw -w /data staphb/bwa:latest bwa mem -M -v 0 ./${db_prefix} ${READ1} ${READ2} > bwamem_output_raw.sam

#Create alignment directory and clean up files
if [ -d 02_alignment ]; then
	echo "02_alignment/ already exists"
	echo ""
else
	mkdir -v 02_alignment/
fi

if [ -d 02_alignment/indexfiles/ ]; then
	echo "indexfiles/ already exists"
	echo ""
else
	mkdir -pv 02_alignment/indexfiles/
fi

# mv bwamem_output_raw.sam 02_alignment/
echo "Moving indexfiles to 02_alignment/indexfiles/..."
mv ${db_prefix}.* 02_alignment/indexfiles/

#Remove any lines from .sam file that start with bracket (docker directs the terminal outputs to the .sam, corrupting the header/format)
sed -i '/^\[/d' bwamem_output_raw.sam

#Convert bwamem_output_raw.sam to .bam format with samtools
echo ""
echo "Converting .sam to .bam using samtools..."
echo ""
docker run -t --rm -u $(id -u):$(id -g) -v $(pwd):/data:rw -w /data staphb/samtools:latest samtools view -bS -o bwamem_output_raw.bam bwamem_output_raw.sam

#Sort .bam file
echo "Sorting .bam file..."
echo ""
docker run -t --rm -u $(id -u):$(id -g) -v $(pwd):/data:rw -w /data staphb/samtools:latest samtools sort bwamem_output_raw.bam -o bwamem_output_raw.sorted.bam

#Run QualiMap on bwamem_output_raw.sorted.bam
echo ""
echo "Running bamqc on .bam file using QualiMap..."
echo "Final output: 02_alignment/bwamem_output_raw.sorted.bam/"
echo ""
docker run -t --rm -u $(id -u):$(id -g) -v $(pwd):/data:rw -w /data pegi3s/qualimap qualimap bamqc -bam bwamem_output_raw.sorted.bam -outdir .

#Move qualimap directory to 02_alignment/
mv bwamem_output_raw.sorted_stats 02_alignment/

#Remove duplicate reads with Picard
echo ""
echo "Removing duplicate reads using Picard..."
echo ""
docker run -t --rm -u $(id -u):$(id -g) -v $(pwd):/data:rw -w /data pegi3s/picard MarkDuplicates -I=bwamem_output_raw.sorted.bam -O=marked_duplicates.bam -M=marked_up_metrics.txt --REMOVE_DUPLICATES

#Clean up files
mv bwamem_output_raw.sam 02_alignment/
mv bwamem_output_raw.bam 02_alignment/
mv bwamem_output_raw.sorted.bam 02_alignment/
mv marked* 02_alignment/
