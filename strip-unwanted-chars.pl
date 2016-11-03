#!/usr/bin/perl
# Changes by Petri:  
#	Changed:	encoding(utf8) --> encoding(UTF-8)
#	Added:		use open ':std';

use warnings;
use strict;

use open IO => ':encoding(UTF-8)';
use open ':std';
use utf8; # enable UTF-8 in source code of this script


# Notes:Instead of [áéíóúýÁÉÍÓÚÝ] [äëïöüÄËÜÖÜ] [àèìòùÀÈÌÒÙ] [âêîôûÂÊÎÔÛ] 
#	characters from \p{InLatin1Supplement} could be included as a group
# 	But then strip the following  ##  TODO: define a CHARACTER CLASS FOR THEM
#		chars (and ranges) from Latin1Supplement: 
#		 [¡-¿]  but perhaps here we want to keep some, such as currency symbols, degrees, µ :  
#		[áéíóúýÁÉÍÓÚÝ]|[äëïöüÄËÜÖÜ]|[àèìòùÀÈÌÒÙ]|[âêîôûÂÊÎÔÛ][̀]/ ) 

#	characters from \p{InBasicLatin} that should be removed:
#	
#my $lidw = pack("U", 0x0149);  #  $lidw = "\N{LATIN SMALL LETTER N PRECEDED BY APOSTROPHE}
#my $ellipsis = pack("U", 0x2026);  #	… HORIZONTAL ELLIPSIS
#my $u2018 = pack ("U", 0x2018);	# 	‘ 
#my $u2019 = pack ("U", 0x2019);	#	’
#my $u201A = pack ("U", 0x201A); #	‚
#my $u201B = pack ("U", 0x201B); #	‛

# Latin 1 Ligatures:
my $ligatureff = pack("U", 0xFB00);  # ﬀ
my $ligaturefi = pack("U", 0xFB01);  # ﬁ
my $ligaturefl = pack("U", 0xFB02);  # ﬂ
my $ligatureffi = pack("U", 0xFB03);  # ﬃ
my $ligatureffl = pack("U", 0xFB04);  # ﬄ

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

my $line;
my $t;
my @tokens;
while(<STDIN>) {  
  chomp;
  @tokens = split(//,$_);  # split each character as individual word
  foreach my $t (@tokens) {
	if ( $t =~ /\p{^IsCntrl}|\t/ ) {   # Consider all except Control Characters
		# Only allow the following in the output ...
	    	if ( $t =~ /\p{InBasicLatin}|\p{IsSpace}|\p{InLatin1Supplement}|[‘’‚‛“”„‟]|[′″‴‵‶‷]|[ˆŉńı]/ )
		{	# ... but strip the following
			$t =~ s/[ ܀~¿¹²³½¼¾¡×÷+=±‡«»¤†•·¯®©¸¦|¶‰›‹㜀¬ðÐ᐀ª§Þþ]/ /g; # 1st char here is U+00A0 NO-BREAK SPACE 
			# ... and strip unwanted diacritics (included in Latin1Supplement)
			$t =~ tr/ÂâÃãÅåÇçÑñÕõØø/AaAaAaCcNnOoOo/;
			$t =~ s/[­]//g;  # Remove U+00AD­ SOFT HYPHEN
			$t =~ s/\p{IsSpace}+/ /g; # consecutive whitespace chars becomes one normal space
			print $t;
    		} 
		# normalise ligatures (sometimes used by latex in pdf files)
		if ( ($t =~ s/$ligatureff/ff/g) 
		or ($t =~ s/$ligaturefi/fi/g) 
		or ($t =~ s/$ligaturefl/fl/g)
		or ($t =~ s/$ligatureffi/ffi/g)
		or ($t =~ s/$ligatureffl/ffl/g)
		or ($t =~ s/$ligatureff/ff/g) 	) { print $t; }
	}
  }
  print "\n";
}

