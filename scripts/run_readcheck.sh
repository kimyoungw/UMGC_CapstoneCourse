#!/usr/bin/bash

#This script will
#1) Quality check a set of short-reads with FastQC
#2) Trim the reads with Trimmomatic
#3) Check if coverage is at least 10x

#HELP function
function HELP {
echo ""
echo "Usage:" $0
echo "			-i path/to/dir/			directory holding reads"
echo ""
echo "Example: $0 -i /path/to/dir"
echo ""
exit 0
}

#Take arguments
#Run HELP if -h -? or invalid input
#Set READS to -i
while getopts ":hi:" option; do
	case ${option} in
		h)
		HELP
		;;
		i)
		export READS=${OPTARG}
		;;
		\?)
		echo "Invalid option: ${OPTARG}" 1>&2
		HELP
		;;
	esac
done

#Check if all parameters are filled
if [[ -z "${READS}" ]]; then
	echo ""
	echo "All flags required."
	HELP
fi

#Check if directory exists
if [[ -d ${READS} ]]; then
	echo ""
	echo "Path to reads set to: " $READS
	echo ""
else
	echo ""
	echo "Could not validate directory. Please check and try again."
	HELP
fi

#Quality check reads with FastQC
docker run -t --rm -u $(id -u):$(id -g) -v $(pwd):/data:rw -w /data pegi3s/fastqc -t 6 --extract ${READS}/*.fastq*

#Clean up FastQC files
echo ""
mkdir -pv ${READS}/fastqc/
rm -r ${READS}/*.zip
mv ${READS}/*_fastqc* ${READS}/fastqc
echo ""

#Get input reads file paths for trimmomatic
read1=$(ls ${READS} | sed -n '/_1/p')
read2=$(ls ${READS} | sed -n '/_2/p')

#Trim reads using trimmomatic
docker run -t --rm -u $(id -u):$(id -g) -v $(pwd):/data:rw staphb/trimmomatic trimmomatic PE ${READS}/${read1} ${READS}/${read2} output_forward_paired.fq.gz output_forward_unpaired.fq.gz output_reverse_paired.fq.gz output_reverse_unpaired.fq.gz ILLUMINACLIP:/Trimmomatic-0.39/adapters/TruSeq3-PE.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:36

#Clean up trimmomatic output
gzip -d output_forward_paired.fq.gz
gzip -d output_reverse_paired.fq.gz
echo ""
mkdir -pv ${READS}/trimmomatic0.39/
mv output* ${READS}/trimmomatic0.39/

#fastqinfor-2.0.sh must be downloaded into the file
#REF file to be downloaded into the folder 

#Kiu R, fastq-info: compute estimated sequencing depth (coverage) of prokaryotic genomes, GitHub https://github.com/raymondkiu/fastq-info
# modified to output

thisDir=$(dirname $0)

bash ${thisDir}/../fastq-info/bin/fastqinfo-2.0.sh -r 250 01_reads_qc_trim/shortreads/trimmomatic0.39/output_forward_paired.fq 01_reads_qc_trim/shortreads/trimmomatic0.39/output_reverse_paired.fq 01_reads_qc_trim/reference/ref.fasta > coverage.txt

#add a parse of coverage.txt to determine if row 2 column 5 is >10x, if not end script

tail -1 coverage.txt | awk -F"\t" '{print$5}' > coverageout.txt
coveragevalue=$(cat coverageout.txt)
if [[ $coveragevalue -le 10 ]]; then
	echo "Less than 10x coverage"
	rm coverageout.txt
	exit 1
else
	mv coverage.txt 01_reads_qc_trim/
	rm coverageout.txt
fi