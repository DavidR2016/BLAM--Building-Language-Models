#!/usr/bin/env python
######################################################################################
## Copyright (c) 2012 The Department of Arts and Culture,                           ##
## The Government of the Republic of South Africa.                                  ##
##                                                                                  ##
## Contributors:  Meraka Institute, CSIR, South Africa.                             ##
##                                                                                  ##
## Permission is hereby granted, free of charge, to any person obtaining a copy     ##
## of this software and associated documentation files (the "Software"), to deal    ##
## in the Software without restriction, including without limitation the rights     ##
## to use, copy, modify, merge, publish, distribute, sublicense, and#or sell        ##
## copies of the Software, and to permit persons to whom the Software is            ##
## furnished to do so, subject to the following conditions:                         ##
## The above copyright notice and this permission notice shall be included in       ##
## all copies or substantial portions of the Software.                              ##
##                                                                                  ##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR       ##
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,         ##
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE      ##
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER           ##
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,    ##
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN        ##
## THE SOFTWARE.                                                                    ##
##                                                                                  ##
######################################################################################
##                                                                                  ##
## AUTHOR  : Georg Schlunz                                                          ##
## DATE    : January 2012                                                           ##
##                                                                                  ##
######################################################################################
##                                                                                  ##
## Tokenization routines.                                                           ##
##                                                                                  ##
######################################################################################


import sys
import re
import codecs
import json
import collections
from StringIO import StringIO


class ClassFoundException(Exception):
    pass


class WordTokenizer(object):
    def __init__(self, token_json_filepath, lexicon_list=None):
        f = file(token_json_filepath, "rb")
        token_json = json.load(f, encoding="utf-8", object_pairs_hook=collections.OrderedDict)
        f.close()
        
        self._token_classes = collections.OrderedDict()
        
        if lexicon_list and len(lexicon_list) > 0:
            self._token_classes["lexicon"] = {}
            self._token_classes["lexicon"]["mask"] = [re.compile("^" + re.escape(word) + "(?=(\\W|$))", flags=re.UNICODE) for word in lexicon_list]
        
        for cls in token_json["token-classes"]:
            self._token_classes[cls] = {}
            self._token_classes[cls]["mask"] = [re.compile(pattern, flags=re.UNICODE) for pattern in token_json["token-classes"][cls]["mask"]]
            if "collocs" in token_json["token-classes"][cls]:
                self._token_classes[cls]["collocs"] = {}
                self._token_classes[cls]["collocs"]["before"] = [re.compile(pattern, flags=re.UNICODE) for pattern in token_json["token-classes"][cls]["collocs"]["before"]]
                self._token_classes[cls]["collocs"]["after"] = [re.compile(pattern, flags=re.UNICODE) for pattern in token_json["token-classes"][cls]["collocs"]["after"]]
                self._token_classes[cls]["collocs"]["anywhere"] = [re.compile(pattern, flags=re.UNICODE) for pattern in token_json["token-classes"][cls]["collocs"]["anywhere"]]
        
        self._whitespace = self._token_classes.pop("whitespace")
        self._prepunc = self._token_classes.pop("prepunc")
        self._postpunc = self._token_classes.pop("postpunc")
    
    
    def tokenize(self, text):
        # NB precondition: text must be unicode object for proper indexing
        self._orig_text = text
        self._tokens = []
        self._classes = []
        self._puncs = []
        
        prev_text = None
        offset = 0 # offset of running text in original text
        while len(text) > 0:
            #sys.stderr.write("-----------------------------------\n")
            #sys.stderr.write(("text                     >>> %s\n" % text).encode("utf8"))
            #sys.stderr.write(("self._orig_text[offset:] >>> %s\n" % self._orig_text[offset:]).encode("utf8"))
            prev_text = text
            punc = {}
            valid_token = False
            
            # search for whitespace
            for regex in self._whitespace["mask"]:
                match = len(text) > 0 and regex.search(text)
                if match:
                    #sys.stderr.write(("whitespace >>> %s\n" % match.group()).encode("utf8"))
                    punc["whitespace"] = match.group()
                    text = text[match.end():]
                    offset += match.end()
                    break
            
            # search for prepunc
            for regex in self._prepunc["mask"]:
                match = len(text) > 0 and regex.search(text)
                if match:
                    #sys.stderr.write(("prepunc >>> %s\n" % match.group()).encode("utf8"))
                    punc["prepunc"] = match.group()
                    text = text[match.end():]
                    offset += match.end()
                    break
            
            # search for custom classes
            try:
                for cls in self._token_classes:
                    for class_regex in self._token_classes[cls]["mask"]:
                        class_match = len(text) > 0 and class_regex.search(text)
                        if class_match:
                            #sys.stderr.write(("class match >>> %s | subtext >>> %s\n" % (cls, class_match.group())).encode("utf8"))
                            if not "collocs" in self._token_classes[cls]: # no collocations
                                #sys.stderr.write(("  no collocations\n").encode("utf8"))
                                valid_token = True
                            else:
                                #sys.stderr.write(("  collocations:\n").encode("utf8"))
                                collocs = self._token_classes[cls]["collocs"]
                                valid_token = False
                                for colloc_regex in collocs["before"]:
                                    #sys.stderr.write(("    before: %s\n" % self._orig_text[:offset + class_match.start()]).encode("utf8"))
                                    if colloc_regex.search(self._orig_text[:offset + class_match.start()]):
                                        #sys.stderr.write(("      match\n").encode("utf8"))
                                        valid_token = True
                                        break
                                
                                if not valid_token:
                                    for colloc_regex in collocs["after"]:
                                        #sys.stderr.write(("    after: %s\n" % self._orig_text[offset + class_match.end():]).encode("utf8"))
                                        if colloc_regex.search(self._orig_text[offset + class_match.end():]):
                                            #sys.stderr.write(("      match\n").encode("utf8"))
                                            valid_token = True
                                            break
                                
                                if not valid_token:
                                    for colloc_regex in collocs["anywhere"]:
                                        #sys.stderr.write(("    anywhere: %s\n" % self._orig_text).encode("utf8"))
                                        if colloc_regex.search(self._orig_text):
                                            #sys.stderr.write(("      match\n").encode("utf8"))
                                            valid_token = True
                                            break
                                
                            if valid_token:
                                #sys.stderr.write(("token >>> %s | class >>> %s\n" % (class_match.group(), cls)).encode("utf8"))
                                self._tokens.append(class_match.group())
                                self._classes.append(cls)
                                text = text[class_match.end():]
                                offset += class_match.end()
                                raise ClassFoundException
            
            except ClassFoundException, e:
                pass
            
            # search for postpunc
            for regex in self._postpunc["mask"]:
                match = len(text) > 0 and regex.search(text)
                if match:
                    #sys.stderr.write(("postpunc >>> %s\n" % match.group()).encode("utf8"))
                    punc["postpunc"] = match.group()
                    text = text[match.end():]
                    offset += match.end()
                    break
            
            if valid_token:
                self._puncs.append(punc)
            
            assert text != prev_text, ("WordTokenizer.tokenize: FATAL ERROR: no token class could be assigned to text at: %s (missing or malformed unknown regex?)" % text).encode("utf8")
        
        return (self._tokens, self._classes, self._puncs)


class SentenceTokenizer(object):
    def __init__(self, sentence_json_filepath, text_filepath=None):
        f = file(sentence_json_filepath, "rb")
        sentence_json = json.load(f, encoding="utf-8", object_pairs_hook=collections.OrderedDict)
        f.close()
        
        self._sent_boundaries = [re.compile(pattern, flags=re.UNICODE) for pattern in sentence_json["sentence-boundaries"]]
        self._sent_nonboundaries = [re.compile(pattern, flags=re.UNICODE) for pattern in sentence_json["sentence-nonboundaries"]]
        
        if text_filepath:
            self._ftext = codecs.open(text_filepath, "rb", "utf-8")
            self._buffer = self._ftext.readline()
            self._lookahead = self._ftext.readline() # readline() returns empty string at EOF
        else:
            self._ftext = None
            self._buffer = ""
            self._lookahead = ""
    
    
    def __iter__(self):
        return self
    
    
    def next(self):
        # read file into buffer one line at a time with one line lookahead (work around a linebreak)
        while len(self._lookahead) > 0:
            self._buffer += self._lookahead
            
            self._bounds = sorted([(match.start(), match.end()) for regex in self._sent_boundaries for match in regex.finditer(self._buffer)], key=lambda x: x[0]) # temporal order of matches is important
            self._nonbounds = [(match.start(), match.end()) for regex in self._sent_nonboundaries for match in regex.finditer(self._buffer)] # here, order is not important
            
            valid_boundary = False
            for bound_start, bound_end in self._bounds: # (incl, excl)
                # if boundary candidate overlaps with any nonboundary section, do not split
                valid_boundary = True
                for nonbound_start, nonbound_end in self._nonbounds: # (incl, excl)
                    if not (bound_end <= nonbound_start or bound_start >= nonbound_end): # if bound_end > nonbound_start and bound_start < nonbound_end:
                        valid_boundary = False
                        break
                
                if valid_boundary:
                    sent = self._buffer[:bound_start]
                    self._buffer = self._buffer[bound_end:]
                    break
            
            self._lookahead = self._ftext.readline()
            
            if valid_boundary:
                return sent
        
        # flush remainder of buffer
        if len(self._buffer) > 0:
            self._bounds = sorted([(match.start(), match.end()) for regex in self._sent_boundaries for match in regex.finditer(self._buffer)], key=lambda x: x[0]) # temporal order of matches is important
            self._nonbounds = [(match.start(), match.end()) for regex in self._sent_nonboundaries for match in regex.finditer(self._buffer)] # here, order is not important
            
            valid_boundary = False
            for bound_start, bound_end in self._bounds: # (incl, excl)
                # if boundary candidate overlaps with any nonboundary section, do not split
                valid_boundary = True
                for nonbound_start, nonbound_end in self._nonbounds: # (incl, excl)
                    if not (bound_end <= nonbound_start or bound_start >= nonbound_end): # if bound_end > nonbound_start and bound_start < nonbound_end:
                        valid_boundary = False
                        break
                
                if valid_boundary:
                    sent = self._buffer[:bound_start]
                    self._buffer = self._buffer[bound_end:]
                    break
            
            if not valid_boundary:
                sent = self._buffer
                self._buffer = ""
            
            return sent
        
        # cleanup
        if self._ftext and not self._ftext.closed: # condition allows for repeated calls to next() beyond EOF (iterator protocol)
            self._ftext.close()
        
        raise StopIteration
    
    
    def tokenize_iter(self):
        return self
    
    
    def tokenize(self, text):
        self._ftext = StringIO(text)
        self._buffer = self._ftext.readline()
        self._lookahead = self._ftext.readline() # readline() returns empty string at EOF
        
        return [sent for sent in self.tokenize_iter()]
