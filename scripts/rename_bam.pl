# usage: perl rename_bam.pl bamfile_xref.tsv sample_xref.tsv
# BAM files in directory ./run1_splits
#
use strict;
#####################################
### set BAM file directory here!
my $bam_dir = "./run3_splits";
#####################################
open IN, "$ARGV[1]" or die "Problem with sample_xref.tsv ($!)\n";
<IN>; # header
# hash sample barcodes
my (%barcodes, @line);
while (<IN>) {
	chomp;
	@line = split /\t/, $_;
	$barcodes{$line[2]} = "S$line[0]";
}
#foreach (keys %barcodes) { print "$_\t$barcodes{$_}\n";}
#die;
close IN;
open IN, "$ARGV[0]" or die "Problem with bamfile_xref.tsv ($!)\n";
while (<IN>) {
	chomp;
	@line = split /\t/, $_;
	my $oldname = "$bam_dir/CB_$line[0].bam";
	my $thisBC = $line[1];
	my $newname = "$bam_dir/$barcodes{$thisBC}.bam";
	system "mv $oldname $newname"; # change to mv after debugging
	#print "mv $oldname $newname\n";
}
