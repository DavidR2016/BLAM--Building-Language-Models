#!/usr/bin/perl
use warnings;
use strict;

use open IO => ':encoding(UTF-8)'; # declare default layers utf8
use open ':std'; # converts the standard filehandles (STDIN, STDOUT,
		# STDERR) to comply with encoding selected for
		# input/output handles
use utf8; # enable UTF-8 in source code

use Unicode::Normalize;
use Encode qw(encode decode);
#use feature 'unicode_strings'; # tells the compiler to use Unicode semantics in
# all string operations executed

# copied from http://search.cpan.org/~jhi/perl-5.8.0/pod/perluniintro.pod
sub nice_string {
join("",
	map {
	  if (chr($_) =~ /[[:cntrl:]]/ )	# if control character ...
	    { sprintf("\\x%02X", $_)  }	# \x..
	  else { sprintf("\\x{%04X}", $_) 
	  }	# \x{...}
						#chr($_) # else as themselves
	} unpack("U*", $_[0])); # unpack Unicode characters
}

#open TMP, "$ARGV[0]";
my $c;
while(<>) {
chomp;
foreach $c (split //) {
	printf "'$c' -> '%s'\n",nice_string($c);
	}
}
printf "%s\n",chr(0x0149);
printf "%s\n",chr(0xc589);
