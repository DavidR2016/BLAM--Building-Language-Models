#!/usr/bin/perl
use strict;
use Getopt::Long;
use feature "switch";
use Encode;

# This script expects as parameter the name of a directory which contains documents
# in any of the following formats:  .doc,  .docx,  .pdf

# For each file in the direcory, this script creates a new file which is plain text with all formatting removed:
# 
#	- catdoc		is used for .doc 
#	- docx2txt		is used for .docx
#$DOCX2TXT = /usr/local/bin/docx2txt.sh
#$DOCX2TXT = /usr/local/bin/docx2txt.sh
#	- pdftotext		is used for .pdf
#
# It also needs a helper script to filter out invalid UTF-8 encodings
# Note: catdoc has options to treat character sets (input and output)
# The 'file' utility can give some insight


my $help;
my $lc = 0; # lowercase the corpus?
my $enc = "utf-8"; # encoding of the input and output files
    # set to anything else you wish, but I have not tested it yet
my $lang = "en"; 
my $bashLANG = "en_ZA.utf8";

GetOptions(
  "help" => \$help,
  "lowercase|lc" => \$lc,
  "encoding=s" => \$enc,
  "language|lang=s" => \$lang,
) or exit(1);

if (scalar(@ARGV) < 2 || $help) {
    print "syntax: dir-convert_doc-docx-pdf.pl [options] inputdir outputdir\n";
    print "Options: \n";
    print "	--help \n";
    print "	--lowercase | --lc \n";
    print "	--encoding=x  (x defaults to utf-8) \n";
    print "	--language=y | --lang=y  (y defaults to en) \n";
    print "Notes:\n";
    print "	outputdir will be created\n";
    print "	existing files in outputdir will be overwritten\n";
    exit;
}

my $inputdir = $ARGV[0];
my $outputdir = $ARGV[1];
my $filetype;
my $txtfiletype;
my $doctype;
my $infilebase;

system("mkdir -p $outputdir"); #|| die "Could not create $outputdir";

opendir (DH, $inputdir) or die "Could not read $inputdir";
my @inputfiles = readdir(DH);

foreach my $infile (@inputfiles)
{
   print "$infile\n";
   
	# TODO: check if we can handle the format - perhaps the utility file
   $filetype = `file -b $inputdir/$infile `;
   if ($filetype =~ /directory/) {print  "skipping $filetype" ;  }
    elsif( ($filetype =~ /Composite Document File/) || ($infile =~ /\.doc$/)) {
#	print "$infile is being converted with catdoc\n";
	system("catdoc -x -w $inputdir/$infile > $outputdir/$infile.txt"); 
		#Note: -x outputs unknown UNICODE character as \xNNNN
	$txtfiletype = `file -b $outputdir/$infile.txt `;
	if ($txtfiletype =~ /^ISO-8859/) {
		system("mv $outputdir/$infile.txt $outputdir/$infile.ISO-8859.txt");
		system("iconv -f ISO-8859 -t UTF-8 $outputdir/$infile.ISO-8859.txt > $outputdir/$infile.txt");		}
    # Note: the unwanted artifacts of this conversion method
		#	- empty lines, space at start or end of lines
		#	- remnants of bullets  ( E )
		#	- PAGEREF\s_Toc[0-9 ]*[\h]*
	# The resulting file is UTF-8 but not all editors recognise this:
	# Editors and viewers that work:	vim gvim mc
	# 					gedit (works and warns about invalid UTF-8)
	#					less (works if the current locale uses UTF-8)
	# Editors that do not work:	geany leafpad

    }
    elsif($infile =~ /\.docx$/) {
   	$infilebase = $infile;
   	$infilebase =~ s/.docx$//;
#	print "$infile is converted with docx2txt\n";
	system("LANG=en_ZA.UTF-8 docx2txt.pl $inputdir/$infile $outputdir/$infile.txt ");
	# Older versions of docx2txt always used the same dir for in and out files
	#system("LANG=en_ZA.UTF-8 docx2txt.sh $inputdir/$infile");
	#system("cat $inputdir/$infilebase.txt  > $outputdir/$infile.txt");
	#system("rm $inputdir/$infilebase.txt");
    }

    elsif($infile =~ /\.pdf$/) {
#	print "$infile is converted with pdftotext\n";
	system("LANG=en_ZA.UTF-8 pdftotext -nopgbrk -raw -enc UTF-8 $inputdir/$infile $outputdir/$infile.txt");
    # Try to handle unwanted artifacts of this conversion method
    #	Without -raw: Diacritics remain but letters are lost:
    #		n´g   ho¨r  lˆ  hˆ	ko¨rdinate bo¨ geometrie¨ algebra¨	di¨lektrika di´ dro¨
    #   With -raw: Diacritics go before the character with which it should be combined:
    #	 n´og   ho¨er  lˆe  hˆe  ko¨rdinate 
    #  So at the moment -raw  is used	
    }
# Now strip unwanted characters from txt file
#	$doctype = `file $outputdir/$infile.txt`;
#	if ($doctype =~ /UTF-8/) {
#	}

}

closedir(DH);
