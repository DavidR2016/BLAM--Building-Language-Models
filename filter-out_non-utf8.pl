#!/usr/bin/perl -l -n
#use locale; 
#use utf8; 	# To indicate that Perl source itself is in UTF-8
#use Encode;	# See 'man perlunitut'  and   'man perluniintro'


#binmode(STDOUT, ":utf8");

#-----
use warnings;
use strict;

use open IO => ':encoding(utf8)'; # declare default layers utf8
use open ':std'; # converts the standard filehandles (STDIN, STDOUT,
# STDERR) to comply with encoding selected for
# input/output handles
use utf8; # enable UTF-8 in source code

use Unicode::Normalize;
use Encode qw(encode decode);
#use feature 'unicode_strings'; # tells the compiler to use Unicode semantics in
# all string operations executed


#----



# using hex values
s/([\x00-\x7F])              
   |([\xC2-\xDF][\x80-\xBF])   
   |((([\xE0][\xA0-\xBF])|([\xED][\x80-\x9F])|([\xE1-\xEC\xEE-\xEF][\x80-\xBF]))([\x80-\xBF])) 
   |((([\xF0][\x90-\xBF])|([\xF1-\xF3][\x80-\xBF])|([\xF4][\x80-\x8F]))([\x80-\xBF]{2})) 
  //g;
print; 

# using octal values
#s/(|[\000-\177]                
#   |[\300-\337][\200-\277]      
#   |[\340-\357][\200-\277]{2}   
#   |[\360-\367][\200-\277]{3}   
#   |[\370-\373][\200-\277]{4}   
#   |[\374-\375][\200-\277]{5} )//g;
#print;

#      [\000-\177]                 # 1-byte pattern
#     |[\300-\337][\200-\277]      # 2-byte pattern
#     |[\340-\357][\200-\277]{2}   # 3-byte pattern
#     |[\360-\367][\200-\277]{3}   # 4-byte pattern
#     |[\370-\373][\200-\277]{4}   # 5-byte pattern
#     |[\374-\375][\200-\277]{5}   # 6-byte pattern
