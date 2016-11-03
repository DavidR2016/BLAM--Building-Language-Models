#!/usr/bin/perl
# Changes by Petri:  
#	Changed:	encoding(utf8) --> encoding(UTF-8)
#	Added:		use open ':std';

use warnings;
use strict;

use open IO => ':encoding(UTF-8)';
use open ':std';

# Lowercase all transcriptions

my $text  	= $ARGV[0];
my $min_cnt 	= $ARGV[1];
my $vocab 	= $ARGV[2];

if (((@ARGV + 0) != 3) and ((@ARGV + 0) != 4)) {
  print "Usage: ./create_vocab.pl <text> <min count> <out:vocab> (in:dev-txt)\n";
  exit 1;
}

my $dev_txt = 0;

if (scalar(@ARGV) == 4) {
  $dev_txt = $ARGV[3];
}

my @tokens;
my %words;

open TEXT, "$text" or die "Error opening file $text for reading";
while(<TEXT>) {
  chomp;
  @tokens = split(/\s/,$_);  # split on white space
  foreach my $word (@tokens) {
    $words{$word} += 1;
  }
}
close(TEXT);

open FILE_OUT, ">$vocab" or die "Can't open '$vocab' for writing!\n";
my @sorted = sort {$words{$b} <=> $words{$a}} keys %words;
my $cnt = 0;
foreach my $word (@sorted) {
  if ($words{$word} >= $min_cnt) {
    printf FILE_OUT "%s\t%d\n", $word,$words{$word};
    $cnt += 1;
  }
}
close(FILE_OUT);

print "VOCAB SIZE: $cnt\n";

# Measure OOV if dev txt provided
if (scalar(@ARGV) == 4) {
  my %dev;
  my $tot_num_words = 0;
  open DEV, "$dev_txt" or die "Can't open '$dev_txt' for reading!\n";
  while(<DEV>) {
    chomp;
    my @tokens = split(/\s+/,$_);
    foreach my $word (@tokens) {
      $dev{$word} += 1;
      $tot_num_words += 1;
    }
  }
  close(DEV);

  my $num_oovs = 0;
  foreach my $word (sort keys %dev) {
    if (!exists($words{$word}) or (exists($words{$word}) and ($words{$word} < $min_cnt))) {
      if (!exists($words{$word})) {
        $num_oovs += 1;
      } else {
        $num_oovs += $words{$word};
      }
    }
  }
  printf "Num oovs: '$num_oovs/$tot_num_words' = %.2f\n",(100*$num_oovs/$tot_num_words);
}

