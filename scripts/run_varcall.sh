#!/usr/bin/bash

#This script will
#1) Take the output of run_alignment.sh (marked_duplicates.bam) and
#2) Generate

#HELP function
function HELP {
echo ""
echo "Usage:" $0
echo "                  -r path/to/reference/                   reference genome in fasta format"
echo "                  -i path/to/inputfile/                   input file in .bam format"
echo ""
echo "Example: $0 -r /path/to/refgenome.fasta -i /path/to/input.bam "
echo ""
exit 0
}

###Take arguments
#Run HELP if -h -? or invalid input
#Set REFERENCE to -r
#Set INPUTFILE to -i

while getopts ":hr:i:" option; do
        case ${option} in
                h)
                HELP
                ;;
                r)
                export REFERENCE=${OPTARG}
                ;;
                i)
                export INPUTFILE=${OPTARG}
                ;;
                \?)
                echo "Invalid option: ${OPTARG}" 1>&2
                HELP
                ;;
        esac
done

#Check if all parameters are filled
if [[ -z "${REFERENCE}" || -z "${INPUTFILE}" ]]; then
        echo ""
        echo "All flags required."
        HELP
fi

#Run bcftools mpileup to generate genotype likelihoods at each genomic position with coverage
echo ""
echo "Running mpileup and calling SNPs/indels using bcftools..."
echo ""
docker run -t --rm -u $(id -u):$(id -g) -v $(pwd):/data:rw -w /data staphb/bcftools bcftools mpileup -Ou -f ${REFERENCE} -d 8000 ${INPUTFILE} -o file.mpileup

#Run bcftools call to generate variant calls
docker run -t --rm -u $(id -u):$(id -g) -v $(pwd):/data:rw -w /data staphb/bcftools bcftools call -mv -Oz --ploidy 1 -o varcalls.vcf file.mpileup

if [ -d 03_varcall ]; then
        echo "03_varcall/ already exists"
        echo ""
else
        mkdir -v 03_variants/
fi

#move vcf files to 06_variants folder
mv *.vcf 03_variants/
rm file.mpileup
