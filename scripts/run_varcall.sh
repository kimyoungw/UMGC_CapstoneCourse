#!/usr/bin/bash

#Check if all parameters are filled
if [[ -z "${REFERENCE}" || -z "${INPUTFILE}" ]]; then
        echo ""
        echo "All flags required."
        HELP
fi

#Run bcftools
echo ""
echo "checking for SNPs/indels using samtools/bcftools..."
echo ""
bcftools mpileup -f ${REFERENCE} -d 250 ${INPUTFILE} | bcftools call -m - > bcftools_finaloutput.vcf

if [ -d 06_variants ]; then
        echo "06_variants/ already exists"
        echo ""
else
        mkdir -v 06_variants/
fi

#move vcf files to 06_variants folder
mv *.vcf 06_variants/


