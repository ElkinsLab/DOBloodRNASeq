# Strip globin reads from BAM
# Replace transcript ID with gene ID in both alignments and header
# Use transcript maxLength in header (LN:)
# Add BC tag
#
# Pipe input and output
# e.g., samtools view -h -F4 file.bam | perl dedup_preprocess_v2.pl - | samtools view -Sb - > file_stripped.bam
#
# Transcripts to be removed:
# 	ENSMUST00000093207	Hba-a2
# 	ENSMUST00000093209	Hba-a1
# 	ENSMUST00000142555	Hba-a1
# 	ENSMUST00000023934	Hbb-bs
# 	ENSMUST00000131960	Hbb-bs
# 	ENSMUST00000147010	Hba-a2
# 	ENSMUST00000098192	Hbb-bt
#
# @SQ	SN:ENSMUST00000005218_A	LN:5613 gets changed to
# @SQ	SN:ENSMUSG00000005087	LN:5613 where 5613 is max length

# NB551406:124:HK7YFBGXB:1:13211:11577:7060_ATGTCTTACG_CGCCCAGATGAT	0	ENSMUST00000005218_A	3973	255	97M	*	...  changed to
# NB551406:124:HK7YFBGXB:1:13211:11577:7060_ATGTCTTACG_CGCCCAGATGAT	0	ENSMUSG00000005087	3973	255	97M	*	...
#
# Annotation info in GBRS_SQ_transcript_gene_lengths.txt
#
# maxLength_transcript	parent	length	gene
# ENSMUST00000000001	F	3264	ENSMUSG00000000001
# ENSMUST00000000003	A	902	ENSMUSG00000000003
# ENSMUST00000000010	A	2576	ENSMUSG00000020875
#
use strict;
# read and hash transcript info
open IN, "GBRS_SQ_transcript_gene_lengths.txt" or
	die "Can't find GBRS_SQ_transcript_gene_lengths.txt ($!)\n";
my $line = <IN>; # header
my %info;
my %used;
while ($line = <IN>) {
	chomp $line;
	my @data = split /\t/, $line;
	$info{$data[0]} = [ @data[2..3] ];
}
die "Incomplete %info hash!\n" unless
	(keys %info = 115125);
while (<>) {
	if (/ENSMUST00000093207|ENSMUST00000093209|ENSMUST00000142555|ENSMUST00000023934|ENSMUST00000131960|ENSMUST00000147010|ENSMUST00000098192/) { # globin
		next;
	} elsif (/^\@/) { # this is a header line
		if (/\@SQ/) { # this is a seqence header
			$_ =~ /SN:(ENSMUST\d+)/;
			my $gene = $info{$1}->[1];
			if (exists $used{$gene}) { # this gene has be added --> skip
				next;
			} else {
				$used{$gene} = '';
			}
			my $length = $info{$1}->[0];
			print "\@SQ\tSN:$gene\tLN:$length\n";
		} else {
			print "$_"; # unchomped
		}
		next;
	} else { #
		chomp;
		my @sam = split /\t/, $_;
		unless ($sam[2] =~ /(ENSMUST\d+)_[ABCDEFGH]/) {
			die "$_\n";
		}
		$sam[2] = $info{$1}->[1];
		my @id = split /_/, $sam[0];
		die "No barcode in read name!\n" unless (@id == 3);
		my $string = join "\t", @sam;
		print "$string\tBC:Z:$id[1]\n";
	}
}
