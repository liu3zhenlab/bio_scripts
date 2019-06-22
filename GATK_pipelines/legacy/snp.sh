##########################################################
### GATK to discover SNPs and INDELs
### Sanzhen Liu
### Kansas State University
### Update: 5/15/2014
##########################################################

##########################################################
### PART 1: Parameter input, subject to change
##########################################################
###
### specify the alignment folder
###
alignment_folder="/home/liu3zhen/teaching/SNP/alignment"
bam1="MG1655.parse.bam"
bam2="DH10B.parse.bam"

### note:
### Follow aligner to perform a proper alignment and filtering
### Group ID and name need to be added to avoid the error during GATK running.
### In BWA, -R '@RG\tID:foo\tSM:bar' can be added with a change for ID and SM
###
### specify the reference path and file name
###
refpath="/home/liu3zhen/teaching/SNP/reference"
ref="Ecoli_k12_MG1655.fasta"
refname="Ecoli_k12_MG1655"
#refname=$(echo $ref | sed 's/.fasta//g')

###
### Index the reference genome:
###
picardpath="/home/liu3zhen/packages/picard/picard-tools-1.96"
rm $refpath/$refname.dict
java -jar $picardpath/CreateSequenceDictionary.jar \
	R=$refpath/$ref O=$refpath/$refname.dict
samtools faidx $refpath/$ref

###
### output path
###
outpath="."
out="snp.both.vcf"

###
### GATK path
###
gatkpath="/home/liu3zhen/packages/GATK/GenomeAnalysisTK-3.1-1"

##########################################################


##########################################################
### PART 2: SNP discovery
##########################################################	
### using UnifiedGenotyper module from GATK to call SNPs
### and INDELs.

# Indel :
java -Xmx16g -jar $gatkpath/GenomeAnalysisTK.jar \
	-T UnifiedGenotyper \
	-R $refpath/$ref \
	-I $alignment_folder"/"$bam1 \
	-I $alignment_folder"/"$bam2 \
	--heterozygosity 0.5 \
	-stand_call_conf 50.0 \
	-stand_emit_conf 20.0 \
	-glm BOTH \
	--num_threads 16 \
	-ploidy 1 \
	-o $outpath"/"$out \

