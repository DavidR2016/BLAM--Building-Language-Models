#!/usr/bin/perl 

### Author: Petri Jooste
###	Normalisation level: 3
### Revision: 2013-03-07
#	- 
#	- normalise apostrophes:
#		- the Afrikaans indefinite article 'n --> ŉ  or  _n
#			See the definition of the variable $lidw below. Uncomment the one you want
#		- change apostrophes to _  
#			e.g. Afrikaans: hy's --> hy_s;  ek't --> ek_t;  'k --> _k;  s'n --> s_n
#			e.g. English:	we've --> we_ve;  "'The boys' toys'." --> The boys_ toys.
#		  - First strip quotes while leaving apostrophes
#		    (?<![\pL\s])'   # no letters or whitespace before single quote
#		    '(?![\pL\s])    # no letters or whitespace after single quote
#		  - Then replace ' with _


### Revision: 2012-09-10
#	- Treat the ellipsis as a word by using the utf-8 symbol "…"
#	- normalise apostrophes:
#		- the Afrikaans indefinite article 'n --> ŉ  or  _n
#		- strip apostrophes (collapse) e.g.  hy's --> hys;  ek't --> ekt;  'k --> k;  s'n --> sn
#	- repair characters with diacritics  ^e --> ê etc.
#	- replace hyphens with spaces except at the end of a line after a word
#	- remove repeated --- ___ 
use warnings;
use strict;
#use Getopt::Long;
#use feature "switch";
#use Encode;
#use locale;
#use open ':encoding(utf8)'; # input/output default encoding will be UTF-8

use open IO => ':encoding(UTF-8)';
use open ':std';
use utf8; # enable UTF-8 in source code of this script


#my $help;
#my $lc = 0; # lowercase the corpus?
#my $enc = "utf8"; # encoding of the input and output files
    # set to anything else you wish, but I have not tested it yet
#my $lang = "en"; 
my $outfilesuffix = ".apstrf";  # Used when no outputfilename is given to this script

my $lidw = pack("U", 0x0149);  #  $lidw = "\N{LATIN SMALL LETTER N PRECEDED BY APOSTROPHE}
# my $lidw = "_n"

my $ellipsis = pack("U", 0x2026);  #	… HORIZONTAL ELLIPSIS
my $u2018 = pack ("U", 0x2018);	# 	‘ 
my $u2019 = pack ("U", 0x2019);	#	’
my $u201A = pack ("U", 0x201A); #	‚
my $u201B = pack ("U", 0x201B); #	‛

my $newline = "\n";

# Quote marks from the General Punctuation unicode block
#U+2018	‘	e2 80 98	LEFT SINGLE QUOTATION MARK
#U+2019	’	e2 80 99	RIGHT SINGLE QUOTATION MARK
#U+201A	‚	e2 80 9a	SINGLE LOW-9 QUOTATION MARK
#U+201B	‛	e2 80 9b	SINGLE HIGH-REVERSED-9 QUOTATION MARK
#U+201C	“	e2 80 9c	LEFT DOUBLE QUOTATION MARK
#U+201D	”	e2 80 9d	RIGHT DOUBLE QUOTATION MARK
#U+201E	„	e2 80 9e	DOUBLE LOW-9 QUOTATION MARK
#U+201F	‟	e2 80 9f	DOUBLE HIGH-REVERSED-9 QUOTATION MARK
#U+2032	′	e2 80 b2	PRIME
#U+2033	″	e2 80 b3	DOUBLE PRIME
#U+2034	‴	e2 80 b4	TRIPLE PRIME
#U+2035	‵	e2 80 b5	REVERSED PRIME
#U+2036	‶	e2 80 b6	REVERSED DOUBLE PRIME
#U+2037	‷	e2 80 b7	REVERSED TRIPLE PRIME



#GetOptions(
#  "help" => \$help,
#  "lowercase|lc" => \$lc,
#  "encoding=s" => \$enc,
#  "language|lang=s" => \$lang,
#) or exit(1);

#if (scalar(@ARGV) < 1 || $help) {
#    print "syntax: normalise-apostrophe-and-diacritics.pl [options] inputfile [outputfile]\n";
#    print "Options: \n";
#    print "	--help \n";
#    print "	--lowercase | --lc \n";
#    print "	--encoding=x  (x defaults to utf8) \n";
#    print "	--language=y | --lang=y  (y defaults to en) \n";
#    print "Notes:\n";
#    print "	an output file will be created\n";
#    print "	existing file with the same name will be overwritten\n";
#    exit;
#}

my $infile = $ARGV[0];
my $outfile;

if (scalar(@ARGV) < 2) {   # outfile not specified - assign it
	$outfile = "$infile$outfilesuffix";
} else {
	$outfile = $ARGV[1];
}

    # $infile is the file used on this iteration of the loop
    open(INFILE, '<', "$infile") or die "Can't open '$infile'";
    open(OUTFILE, '>', "$outfile") or die "Can't create '$outfile'";
#    print "Writing output to $outfile\n";

    my $doclang = substr $infile, 10, 1; # use 11th char   # e.g. filename: JURI_424_PEC_2012.doc.txt

    while (<INFILE>) {
	chomp;
	my $t = $_;
        
	# Level 2a:
	if ($doclang eq "A") {
		# First normalise the Afrikaans indefinite article: ŉ
		$t =~ s/(^|\s)['`´’‘’’‛′‵]n\s/ $lidw /g;
	}
	
	$t =~ s/(?<![\pL\s\b])['’’’]|['’’’](?![\pL\s\b])//gx; # Option 1: no letters or whitespace before (or after) single quote
#	$t =~ s/(:?(^\s*'|'$))//g; 	# Option 2:  note: (:?) prevent non-needed capture
#	$t =~ s/([^A-Za-z]'

	$t =~ s/['’’’]/_/g; # replace apostrophe with _
	$t =~ s/[`´‘‛′‵]|["‚“”„‟″‴‶‷]//g; # strip other single quotes and double quotes

#	$t =~ s/([^.])[.][.][.]([^.])/$1 $ellipsis $2/g;  # 
	$t =~ s/[-_][-_]+/ /g;	# strip repeated characters used to create lines and leaders

#	$t =~ s/[-_]+([^\d])/ $1/g;  # replace all hyphen, n-dash, m-dash, underscore (that is not the last char in the line)

#	$t =~ s/ŉ/\_n/g;  # requested by Charl for his scripts 
#				HOWEVER, when the next step uses the standalone_tts_normalizer, then the _ is removed, 
#				so keep ŉ here

	# strip accents (e.g. é) but leave ^ and " and ` on (e.g. ë è ê)
	# Strip acute accents
	$t =~ tr/[áéíóúýÁÉÍÓÚÝń]/[aeiouyAEIOUYŉ]/;

        # repair Afrikaans diacritics
        # e.g.:  ho¨er  lˆe  hˆe  ko¨rdinate 
        # but note: di´e   n´og -- single quote will be removed later
        $t =~ s/¨a/ä/g;
        $t =~ s/¨e/ë/g;
        $t =~ s/¨[iı]/ï/g;
        $t =~ s/¨o/ö/g;
        $t =~ s/¨u/ü/g;
        $t =~ s/[ˆ^]a/â/g;
        $t =~ s/[ˆ^]e/ê/g;
        $t =~ s/[ˆ^][iı]/î/g;
        $t =~ s/[ˆ^]o/ô/g;
        $t =~ s/[ˆ^]u/û/g;
        $t =~ s/¨A/Ä/g;
        $t =~ s/¨E/Ë/g;
        $t =~ s/¨I/Ï/g;
        $t =~ s/¨O/Ö/g;
        $t =~ s/¨U/Ü/g;
        $t =~ s/[ˆ^]A/Â/g;
        $t =~ s/[ˆ^]E/Ê/g;
        $t =~ s/[ˆ^]I/Î/g;
        $t =~ s/[ˆ^]O/Ô/g;
        $t =~ s/[ˆ^]U/Û/g;

#	$t =~ s/[ìí]/i/g;

#	# add space before the last . in a line to indicate a sentence stop rather than an abbreviation stop.
#	$t =~ s/[.]\s*$/ ./;

	# The following instruction belongs perhaps in step01
	$t =~ s/PAGEREF\s+[_]*Toc[0-9]*\s+\\h/ /g;


	# remove extra whitespace - replace with a single normal space character
	$t =~ s/\p{IsSpace}+/ /g; 
	# remove space at start of line
	$t =~ s/^\p{IsSpace}+//g; 

	print OUTFILE "$t\n"  unless  $t =~ /^$/;
    }
    
    close INFILE;
    close OUTFILE;






