#!/usr/bin/perl 

### Author: Petri Jooste
### Revision: 2012-09-10
###	Normalisation level: 3 b
#
#	Get rid of lines which does not contribute typical valid uttarances in the target language:
#	- CRUDE:  drop lines with less that 30 characters ending in a digit
#	- TODO: Drop English lines from Afrikaans corpus and vice versa

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

my $outfilesuffix = ".dropped-non-sentences";  # Used when no outputfilename is given to this script

my $newline = "\n";

my $infile = $ARGV[0];
my $outfile;

if (scalar(@ARGV) < 2) {   # outfile not specified - assign it
	$outfile = "$infile$outfilesuffix";
} else {
	$outfile = $ARGV[1];
}

# CRUDE: determine document language in order to pick stoplist for exluding lines
my $doclang = 'not-set';
if ($infile =~ /Eng\./) { $doclang = 'Eng' }
elsif ($infile =~ /Afr\./) { $doclang = 'Afr' }

    # $infile is the file used on this iteration of the loop
    open(INFILE, '<', "$infile") or die "Can't open '$infile'";
    open(OUTFILE, '>', "$outfile") or die "Can't create '$outfile'";
    print "Writing output to $outfile\n";
    my $t;
    my $mustprint;
    while (<INFILE>) {
	chomp;
	$t = $_;
	$mustprint = 1;
	if (	$t =~ /^.$/	||	# lines with a single character
		$t =~ /^[^ ]+\s*$/	||	# lines with no spaces (which may have a space as the last character)
		$t =~ /^[A-Z]{3,}/	|| # lines starting with 3 or more UPPERCASE characters
		$t =~ /^[.0-9]+/	||	# lines starting with numbers
		$t =~ /(.)\1{5,}/	||	# lines containing 5 or more of the same consecutive character .......
		$t =~ /^.{1,30}[0-9]\s*$/ )	# lines with less that 30 characters ending in a digit (NOTE: ending in . is not matched)
 	{ $mustprint = 0; }
	elsif ($doclang eq 'Eng')	{
		if ( $t =~ /ŉ | en | te | wat | vir | jy / )
		{ $mustprint = 0; }
	}
	elsif ($doclang eq 'Afr') {
		if ( $t =~ /[Tt]he | and | that | you | with | have | page |^[Pp]age / )
		{ $mustprint = 0; }
	}

	if ($mustprint == 1)     {
		print OUTFILE "$t\n";
	}
    }
    
    close INFILE;
    close OUTFILE;






