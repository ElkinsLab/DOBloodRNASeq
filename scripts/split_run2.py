##### from herrinca on GitHub -- https://github.com/herrinca
##### modified by REB (barcode tag is BC, not CB as originally written)
##### also added print statement (line 36) to cross reference file names
###
##### Code has not been tested on unsorted bam files, sort on barcode (CB):
##### samtools sort -t BC unsorted.bam > sorted_tags.bam
###
##### INPUT: .bam file to be sorted and output directory to place split BC
##### OUTPUT: .bam file for each unique barcode, best to make a new directory

### Python 3.6.8
import pysam

### Input varibles to set
# file to split on
unsplit_file = "/home/rb42w/umw_richard_baker/byGene_run2-3/101900-002_R1_trimmed_bwt_preprocess_deduped_BCtag_sorted.bam"
# where to place output files
out_dir = "/home/rb42w/umw_richard_baker/byGene_run2-3/run2_splits/"

# variable to hold barcode index
CB_hold = 'unset'
itr = 0
# read in upsplit file and loop reads by line
samfile = pysam.AlignmentFile( unsplit_file, "rb")
for read in samfile.fetch( until_eof=True):
    # barcode itr for current read
    CB_itr = read.get_tag( 'BC')
    # if change in barcode or first line; open new file
    if( CB_itr!=CB_hold or itr==0):
        # close previous split file, only if not first read in file
        if( itr!=0):
            split_file.close()
        CB_hold = CB_itr
        itr+=1
        split_file = pysam.AlignmentFile( out_dir + "CB_{}.bam".format( itr), "wb", template=samfile)
        print(str(itr) + '\t' + CB_hold)

    # write read with same barcode to file
    split_file.write( read)
split_file.close()
samfile.close()
