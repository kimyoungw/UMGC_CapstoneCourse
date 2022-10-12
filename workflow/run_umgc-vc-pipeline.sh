#!/usr/bin/bash

#This is the wrapper script for the UMGC Variant Calling pipeline.
#In the working directory you are calling this script there should be:
#1. Your input reads in fastq or fastq.gz format
#2. Your reference genome in fasta format

#HELP function
function HELP {
echo ""
echo "Usage:" $0
echo "			-r reference.fasta		reference genome in fasta format"
echo "			-p read_1.fastq			read1 in fastq format"
echo "			-q read_2.fastq			read2 in fastq format"
echo ""
echo "Example: $0 -r refgenome.fasta -p read_1.fastq -q read_2.fastq"
echo ""
exit 0
}

###Take arguments
#Run HELP if -h -? or invalid input
#Set REFERENCE to -r
#Set READ1 to -p
#Set READ2 to -q
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

thisDir=$(dirname $0)

#Make subprocess 1 directories
if [ -d 01_reads_qc_trim/shortreads ]; then
	echo "01_reads_qc_trim/ already exists"
	echo ""
else
	mkdir -pv 01_reads_qc_trim/shortreads/
fi

if [ -d 01_reads_qc_trim/reference ]; then
	echo "01_reads_qc_trim/ already exists"
	echo ""
else
	mkdir -pv 01_reads_qc_trim/reference/
fi

echo "Moving reads to 01_reads_qc_trim/shortreads/"
echo "Renaming and moving reference genome to 01_reads_qc_trim/reference/ref.fasta"
read1=$(basename ${READ1})
read2=$(basename ${READ2})
mv $READ1 01_reads_qc_trim/shortreads/
mv $READ2 01_reads_qc_trim/shortreads/
mv $REFERENCE ref.fasta
mv ref.fasta 01_reads_qc_trim/reference/

#Run subprocess 1: run_readcheck.sh
bash ${thisDir}/../scripts/run_readcheck.sh -i 01_reads_qc_trim/shortreads

#Run subprocess 2: run_alignment.sh
bash ${thisDir}/../scripts/run_alignment.sh -r 01_reads_qc_trim/reference/ref.fasta -p 01_reads_qc_trim/shortreads/${read1} -q 01_reads_qc_trim/shortreads/${read2}

#Run subprocess 3: run_varcall.sh
bash ${thisDir}/../scripts/run_alignment.sh -r 01_reads_qc_trim/reference/ref.fasta -i 02_alignment/marked_duplicates.bam

#remove random .java dir that gets created
rm -r \?/
