## Quality control with Fastqc

for i in *gz; do fastqc $i; done

## Check quality by summarizing fastqc ouptut with multiqc

multiqc .

## Use trimommatic to remove adapters

for i in *1.fastq.gz; do java -jar /home/linuxbrew/.linuxbrew/Cellar/trimmomatic/0.36/libexec/trimmomatic-0.36.jar PE -threads 15 -phred33 $i ${i%1.fastq.gz}2.fastq.gz ${i%1.fastq.gz}1_paired.fastq.gz ${i%1.fastq.gz}1_unpaired.fastq.gz ${i%1.fastq.gz}2_paired.fastq.gz ${i%1.fastq.gz}2_unpaired.fastq.gz ILLUMINACLIP:/home/linuxbrew/.linuxbrew/Cellar/trimmomatic/0.36/share/trimmomatic/adapters/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36; done

## Merge foward paired reads

pigz -d -c  *_1_paired.fastq.gz | pigz -c > merged_1.fq.gz

## Merge reverse foward reads

pigz -d -c  *_2_paired.fastq.gz | pigz -c > merged_2.fq.gz

## The assembly is made with spades, depending of the size of the merged files, it may fail due to a lack of memory (-m parameter)

spades.py -1 merged_1.fq.gz -2 merged_2.fq.gz --meta -t 15 -m 100 -o AssemblyTara

### If the assembly fails due to a lack of memory, 3 options : choose anoter computer with more memory, use bbnorm.sh (bbmap software suite) to normalize the reads or use the megahit assembler

bbnorm.sh in=merged_1.fq.gz in2=merged_2.fq.gz target=100 mindepth=2 out=norm_1.fq.gz out2=norm2.fq.gz threads=15

megahit -1 merged_1.fq.gz -2 merged_2.fq.gz -t 16 -m 0.9

## After spades is finished, the stats.sh script from the bbmap software can be used to assess the assembly

stats.sh in=scaffold.fasta

## Select contings above 500 bp or more

bioawk -c fastx '{ if(length($seq) > 500){ print ">"$name; print $seq }}' scaffolds.fasta > scaffolds_500.fasta

## Create sam/bam files to determine how the reads are mapped on the contigs

bwa index scaffolds_500.fasta

for i in *_1_paired.fastq.gz; do echo bwa mem -t 15 scaffolds_500.fasta $i ${i%_1_paired.fastq.gz}_2_paired.fastq.gz \> ${i%_1_paired.fastq.gz}.sam; done

for i in *sam; do samtools view -bS -@ 15 $i | samtools sort -@ 15 - -o ${i%sam}bam; done

for i in *bam; do samtools index $i; done

for i in *sam; do rm $i; done

## Use Metabat2 to reconstructing single genomes from complex microbial communities

runMetabat.sh -t 15 scaffolds_500.fasta ERR599041.bam  ERR599061.bam  ERR599134.bam  ERR599155.bam

## Use checkm to assess the quality of the bins

checkm lineage_wf -t 15 -x fa scaffolds_500.fasta.metabat-bins15 bins_checkm > bins_output.txt

## use gtdbtk to taxonomically classify the bins (the --min_perc_aa is used to make sure that the bins have at least 1 of the 120 single copy proteins)

gtdbtk classify_wf --genome_dir scaffolds_500.fasta.metabat-bins15/ --cpus 15 --out_dir gtdbk --extension fa --min_perc_aa 1

## Use checkm to obtain the coverage of the bins in each sample

checkm coverage ./bins coverage.tsv ERR599041.bam  ERR599061.bam  ERR599134.bam  ERR599155.bam

checkm profile coverage.tsv > profile.tsv

