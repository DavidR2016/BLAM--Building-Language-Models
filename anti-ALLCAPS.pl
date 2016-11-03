#!/usr/bin/perl

# Convert a file to word-based lowercasing of headings (which excludes acronyms and codes which may be pronounced letter-by-letter)
# THIS IS A HEADING ABOUT SANLAM AND EKNP111  --> this is a heading about SANLAM and EKNP111 

use warnings;
use strict;

use open IO => ':encoding(utf8)';
use open ':std';
use utf8;

if (((@ARGV + 0) != 2) and ((@ARGV + 0) != 4) and ((@ARGV + 0) != 5)) {
  print "Usage: ./anti-ALLCAPS.pl <in:vocab> <in:filelist> (in:indir) (out:outdir) (min count)\n";
  print "       The files in filelist should exist in indir.\n";	
  exit 1;
}

my $in_dir = "";
my $out_dir = "";
my $min_cnt = 0;
my $vocab 	= $ARGV[0];
my $file_list	= $ARGV[1];

if (scalar(@ARGV) == 4) {
  $in_dir = $ARGV[2];
  $out_dir = $ARGV[3];
  # min_cnt stays at default
}
if (scalar(@ARGV) == 5) {
  $in_dir = $ARGV[2];
  $out_dir = $ARGV[3];
  $min_cnt = $ARGV[4];
}


my @tokens;
my %words;

#open TEXT, "$text" or die "Error opening file $text";
#while(<TEXT>) {
#  chomp;
#  @tokens = split(/[\d\W]+/,$_);
#  foreach my $word (@tokens) {
#    $words{$word} += 1  # Add the word to the hash
#	unless ( $word =~ /\p{^IsAlpha}/ )   # ignore tokens containing non-alphabetic characters
# or
#	unless ($word =~ /\p{IsUpper}\p{IsUpper}+/); # ignore tokens with consecutive uppercase characters
#  }
#}
#close(TEXT);

open VOCAB_IN, "<$vocab" or die "Can't open '$vocab' for reading!\n";
while (<VOCAB_IN>) {
	chomp;
	my ($word, $count) = split /\s+/;
	$words{$word} += $count;
}	
close(VOCAB_IN);

# Process files from file list
  my $try = 0;
  my $try2 = 0;
  open FLIST, "<", "$file_list" or die "Can't open '$file_list' for reading!\n";
  while(<FLIST>) {
	chomp;
	my $nextfile = $_;
	open NEXTFILE, "<", "$in_dir/$nextfile"   or die "Error opening file $nextfile for reading.";
	open OUTFILE, ">", "$out_dir/$nextfile"   or die "Error opening file $nextfile.out for writing.";
	while(<NEXTFILE>) {
	    chomp;
	    my @tokens = split(/\s+/,$_);
	    foreach my $word (@tokens) {
		if ($word =~ /\p{IsUpper}\p{IsUpper}+/) { # consider tokens with consecutive uppercase characters
		   my $try = lc($word);
		   if (exists($words{$try})) { print OUTFILE "$try"; }
		   elsif (($try2 = ucfirst($try)) and (exists($words{$try2}))) { print OUTFILE "$try2"; }
			else { 
				my @subtokens = split(/([\s\d\P{Word}ŉ])/,$word);  # keep delimiters
				foreach $word (@subtokens) {
				$try = lc($word);
				   if (exists($words{$try})) { print OUTFILE "$try"; }  # do not add space
				   elsif (($try2 = ucfirst($try)) and (exists($words{$try2}))) { print OUTFILE "$try2"; }
					else { 
						print OUTFILE "$word"; 
					}
				}
			}
	 	} else {
		   print OUTFILE "$word";
		}
		print OUTFILE " "; # replace the space removed at split
	    }
    	    print OUTFILE "\n";
	}
	close(NEXTFILE);
	close(OUTFILE);
  }
  close(FLIST);
# Done processing the files from file_list

