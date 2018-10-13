##########################################################
### GATK to filter SNPs in a VCF file
### Sanzhen Liu
### Kansas State University
### Update: 5/15/2014
##########################################################

##########################################################
### PART 1: Parameter input, subject to change
##########################################################
### select variants
### http://www.broadinstitute.org/gatk/gatkdocs/org_broadinstitute_sting_gatk_walkers_variantutils_SelectVariants.html#--excludeFiltered

refpath="/home/liu3zhen/teaching/SNP/reference"
ref="Ecoli_k12_MG1655.fasta"
#in_vcf="snp.snp.vcf"
in_vcf="snp.both.vcf"
#out_vcf="selected.snp.vcf"
out_vcf="selected.snp.only.vcf"

##########################################################
### PART 2: select SNPs based on input criteria
##########################################################
java -Xmx64g -jar /home/liu3zhen/packages/GATK/GenomeAnalysisTK-3.1-1/GenomeAnalysisTK.jar \
-T SelectVariants \
-R $refpath/$ref \
--variant $in_vcf \
-select 'QD >= 2.0' \
-select 'DP >= 3.0' \
--restrictAllelesTo BIALLELIC \
--selectTypeToInclude SNP \
--sample_expressions \
--excludeFiltered \
-o $out_vcf

