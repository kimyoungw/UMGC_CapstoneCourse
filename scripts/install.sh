#!/usr/bin/bash

#This script will check if git and Docker are installed.
#Docker desktop must be running when executing this script.

#Check if Docker and Git are installed
if [[ -x "$(command -v docker)" ]]; then
	echo "Docker installed."
	if docker --version; then
		echo "Docker is running."
	else
		echo "Docker is not running. Please start Docker Desktop before proceeding."
	fi
else
	echo "Install Docker Desktop before proceeding: https://docs.docker.com/desktop/"
fi

if [[ -x "$(command -v git)" ]]; then
	echo "Git installed."
	git --version
else
	echo "Install Git before proceeding."
fi

#Clone git repositories
git clone https://github.com/raymondkiu/fastq-info

#Pull Docker images
#fastqc
if docker pull pegi3s/fastqc; then
	echo " "
else
	echo "Error pulling image. Exiting..."
	exit 1
fi
#picard
if docker pull pegi3s/picard; then
	echo " "
else
	echo "Error pulling image. Exiting..."
	exit 1
fi
#qualimap
if docker pull pegi3s/qualimap; then
	echo " "
else
	echo "Error pulling image. Exiting..."
	exit 1
fi
#bwa
if docker pull staphb/bwa; then
	echo " "
else
	echo "Error pulling image. Exiting..."
	exit 1
fi
#samtools
if docker pull staphb/samtools; then
	echo " "
else
	echo "Error pulling image. Exiting..."
	exit 1
fi
#trimmomatic
if docker pull staphb/trimmomatic; then
	echo " "
else
	echo "Error pulling image. Exiting..."
	exit 1
fi


