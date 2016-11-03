#!/usr/bin/perl

use warnings;
use strict;

use open IO => ':encoding(UTF-8)';
use open ':std';
use utf8; # enable UTF-8 in source code of this script

#	- characters from \p{IsPunct} should be removed:
#	- choose a suitable form for ŉ
	

my $t;
my @tokens;

while(<>) {
  chomp;
  @tokens = split(//,$_);  # split each character as individual word
  foreach my $t (@tokens) {
	if ( $t =~ /[_]/ ) {
		print $t;
	} elsif ( $t =~ /\p{^IsPunct}/ ) {   # Consider all except Punctuation
		# Only allow the following in the output ...
#	    	if ( $t =~ /\p{InBasicLatin}|\p{IsSpace}|\p{IsPunct}|\p{InLatin1Supplement}|[ŉń]/ )
#		{	# ... but strip the following
			$t =~ s/[µ¨ß¥å¢°`ã]|\x{00AD}|\x{005E}|\x{0024}|\x{00BA}/ /g;  # includes ^ and $
			$t =~ s/[܀~¿¹²³½¼¾¡×÷+=±‡«»¤†_•·¯®©¸¦|¶‰›‹㜀¬ðÐ᐀ª§Þþ]//g;
			$t =~ s/\p{InLatin1Supplement}\p{InLatin1Supplement}+/ /g;  # consecutive chars from Latin1Supplement
			### Replacement characters
			$t =~ s/ŉ|ń/_n/g;
			$t =~ s/\x{00E6}/ae/g;
# $t =~ s/[0-9£ˆàäëêüûèìîïòôöìîůù]/ /g;  # vanaf Pieter op 2013-06-27 vir HTK probleme
			$t =~ s/[ÂÁÀÃÅ]/A/g;
			$t =~ s/[âáàãå]/a/g;
			$t =~ s/[ÉÈ]/E/g;
			$t =~ s/[ÍÌ]/I/g;
			$t =~ s/[íì]/i/g;
			$t =~ tr/ÇçÑñ/CcNn/;
			$t =~ s/ÓÒÕØ/O/g;
			$t =~ s/óòõø/o/g;
			$t =~ s/ů/u/g;
			### Other cleanup
			$t =~ s/\s+/ /g;
			print $t;
#    		}
		
	}
  }
  print "\n";
}

