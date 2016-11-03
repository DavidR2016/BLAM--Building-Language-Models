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
## Normalization routines.                                                          ##
##                                                                                  ##
######################################################################################


import sys
import re
import math
import codecs
import json
import collections


class Normalizer(object):
    SYM_FIRST          = "<\\w*<"
    SYM_REST           = ">\\w*>"
    SYM_ORIG           = "=\\w*="
    SYM_SPLIT          = "#\\w*#"
    SYM_ALL            = "&\\w*&"
    SYM_EXPAND         = "@\\w*@"
    
    
    def __init__(self, norm_json_filepath, alphaexp_json_filepath, numexp_rule_filepath, lexicon_dict=None):
        f = file(norm_json_filepath, "rb")
        norm_json = json.load(f, encoding="utf-8", object_pairs_hook=collections.OrderedDict)
        f.close()
        
        self._norm_classes = collections.OrderedDict()
        
        if lexicon_dict and len(lexicon_dict) > 0:
            self._norm_classes["lexicon"] = collections.OrderedDict([(re.compile("^" + re.escape(word) + "$", flags=re.UNICODE), text) for word, text in lexicon_dict.items()])
        
        for cls in norm_json["norm-classes"]:
            self._norm_classes[cls] = collections.OrderedDict([(re.compile(pattern, flags=re.UNICODE), text) for pattern, text in norm_json["norm-classes"][cls].items()])
        
        self._alphaexp = AlphaExpander(alphaexp_json_filepath)
        self._numexp = NumberExpander(numexp_rule_filepath)
        
        # initialise regex FSMs
        self._regex_first = re.compile(Normalizer.SYM_FIRST)
        self._regex_rest = re.compile(Normalizer.SYM_REST)
        self._regex_orig = re.compile(Normalizer.SYM_ORIG)
        self._regex_split = re.compile(Normalizer.SYM_SPLIT)
        self._regex_all = re.compile(Normalizer.SYM_ALL)
        self._regex_expand = re.compile(Normalizer.SYM_EXPAND)
    
    
    def _normalize_r(self, token, cls, lvl=0):
        normalizeable = False # is the token normalizable, i.e. is it a NSW or a SW which should simply be let through?
        normalized = "" # normalized text as output
        
        #sys.stderr.write("%s-----------------------------------\n" % ("  "*lvl))
        #sys.stderr.write("%slvl %d:\n" % ("  "*lvl, lvl))
        #sys.stderr.write(("%stoken = [%s]\n" % ("  "*lvl, token)).encode("utf8"))
        #sys.stderr.write("%sclass = %s\n" % ("  "*lvl, cls))
        
        if not cls in self._norm_classes:
            return token
        
        i = 0
        for class_regex, text in self._norm_classes[cls].items():
            i += 1
            #sys.stderr.write("%srule %d = " % ("  "*lvl, i))
            
            class_match = class_regex.search(token)
            if class_match:
                #sys.stderr.write("match\n")
                #sys.stderr.write(("%stext before = [%s]\n" % ("  "*lvl, text)).encode("utf8"))
                
                normalizeable = True
                
                match_first = self._regex_first.search(text)
                match_rest = self._regex_rest.search(text)
                match_orig = self._regex_orig.search(text)
                match_split = self._regex_split.search(text)
                match_all = self._regex_all.search(text)
                match_expand = self._regex_expand.search(text)
                
                # recurse with substitutions, if any (multiple substitutions are allowed)
                while True:
                    if match_first:
                        #sys.stderr.write("%sbranching %s\n" % ("  "*lvl, match_first.group()))
                        newcls = match_first.group()[1:-1] # remove leading and trailing substitution delimiters
                        text = self._regex_first.sub(self._normalize_r(class_match.group(), newcls, lvl+1), text, 1) # replace first match only
                        match_first = self._regex_first.search(text)
                        #sys.stderr.write(("%stext after  = [%s]\n" % ("  "*lvl, text)).encode("utf8"))
                    
                    elif match_rest:
                        #sys.stderr.write("%sbranching %s\n" % ("  "*lvl, match_rest.group()))
                        newcls = match_rest.group()[1:-1] # remove leading and trailing substitution delimiters
                        text = self._regex_rest.sub(self._normalize_r(class_regex.sub("", token), newcls, lvl+1), text, 1) # replace first match only
                        match_rest = self._regex_rest.search(text)
                        #sys.stderr.write(("%stext after  = [%s]\n" % ("  "*lvl, text)).encode("utf8"))
                        
                    elif match_orig:
                        #sys.stderr.write("%sbranching %s\n" % ("  "*lvl, match_orig.group()))
                        newcls = match_orig.group()[1:-1] # remove leading and trailing substitution delimiters
                        text = self._regex_orig.sub(self._normalize_r(token, newcls, lvl+1), text, 1) # replace first match only
                        match_orig = self._regex_orig.search(text)
                        #sys.stderr.write(("%stext after  = [%s]\n" % ("  "*lvl, text)).encode("utf8"))
                        
                    elif match_split:
                        #sys.stderr.write("%sbranching %s\n" % ("  "*lvl, match_split.group()))
                        newcls = match_split.group()[1:-1] # remove leading and trailing substitution delimiters
                        splitseq = ""
                        for c in class_match.group():
                            splitseq += self._normalize_r(c, newcls, lvl+1)
                        text = self._regex_split.sub(splitseq, text, 1) # replace first match only
                        match_split = self._regex_split.search(text)
                        #sys.stderr.write(("%stext after  = [%s]\n" % ("  "*lvl, text)).encode("utf8"))
                        
                    elif match_all:
                        #sys.stderr.write("%sbranching %s\n" % ("  "*lvl, match_all.group()))
                        newcls = match_all.group()[1:-1] # remove leading and trailing substitution delimiters
                        allseq = ""
                        for substr in class_regex.findall(token):
                            allseq += self._normalize_r(substr, newcls, lvl+1)
                        text = self._regex_all.sub(allseq, text, 1) # replace first match only
                        match_all = self._regex_all.search(text)
                        #sys.stderr.write(("%stext after  = [%s]\n" % ("  "*lvl, text)).encode("utf8"))
                        
                    elif match_expand:
                        #sys.stderr.write("%sbranching %s\n" % ("  "*lvl, match_expand.group()))
                        newcls = match_expand.group()[1:-1] # remove leading and trailing substitution delimiters
                        if newcls in self._alphaexp.rulesets():
                            exp = self._alphaexp.expand(class_match.group(), newcls)
                        elif ("%" + newcls) in self._numexp.rulesets():
                            exp = self._numexp.expand(int(class_match.group()), ("%" + newcls))
                        else:
                            exp = "" # replace with empty string if unknown class
                        text = self._regex_expand.sub(exp, text, 1) # replace first match only
                        match_expand = self._regex_expand.search(text)
                        #sys.stderr.write(("%stext after  = [%s]\n" % ("  "*lvl, text)).encode("utf8"))
                        
                    else:
                        break
                
                normalized += text
                
            #else:
                #sys.stderr.write("no match\n")
            
            #sys.stderr.write(("%snormalized  = [%s]\n" % ("  "*lvl, normalized)).encode("utf8"))
        
        #sys.stderr.write("%s-----------------------------------\n" % ("  "*lvl))
        
        if normalizeable:
            return normalized # this should NOT be split!
        else:
            return token
    
    
    def normalize(self, token, cls):
        return self._normalize_r(token, cls).split()


class AlphaExpander(object):
    def __init__(self, alphaexp_json_filepath):
        f = file(alphaexp_json_filepath, "rb")
        alphaexp_json = json.load(f, encoding="utf-8", object_pairs_hook=collections.OrderedDict)
        f.close()
        
        self._alphaexps = alphaexp_json["alphaexp-classes"]
    
    
    def rulesets(self):
        return self._alphaexps.keys()
    
    
    def expand(self, alpha, cls):
        return self._alphaexps[cls].get(alpha, "")


class NumberExpander(object):
    ID_RULESET         = r"^%%?[a-zA-Z0-9_]+$"
    ID_RULESET_PUBLIC  = r"^%[a-zA-Z0-9_]+$"
    ID_RULESET_PRIVATE = r"^%%[a-zA-Z0-9_]+$"
    DELIM_RULE         = r";"
    DELIM_BASE         = r":"
    DELIM_RADIX        = r"/"
    DELIM_GROUP        = r"[ ,.]"
    SYM_MAJOR          = r"<%?%?[a-zA-Z0-9_]*<"
    SYM_MINOR          = r">%?%?[a-zA-Z0-9_]*>"
    SYM_SAME           = r"=%?%?[a-zA-Z0-9_]*="
    
    ROUNDOFF_ERROR_TOLERANCE = 0.000000001
    
    
    def __init__(self, numexp_rule_filepath):
        # parse the ruleset file
        f = codecs.open(numexp_rule_filepath, "rb", "utf-8")
        content = f.read()
        f.close()
        
        # initialise regex FSMs
        self._regex_public = re.compile(NumberExpander.ID_RULESET_PUBLIC, flags=re.MULTILINE)
        self._regex_ruleset = re.compile(NumberExpander.ID_RULESET, flags=re.MULTILINE)
        self._regex_rule = re.compile(NumberExpander.DELIM_RULE)
        self._regex_base = re.compile(NumberExpander.DELIM_BASE)
        self._regex_radix = re.compile(NumberExpander.DELIM_RADIX)
        self._regex_group = re.compile(NumberExpander.DELIM_GROUP)
        self._regex_major = re.compile(NumberExpander.SYM_MAJOR)
        self._regex_minor = re.compile(NumberExpander.SYM_MINOR)
        self._regex_same = re.compile(NumberExpander.SYM_SAME)
        
        # split rule sets according to rule name
        names = self._regex_ruleset.findall(content)
        sets = self._regex_ruleset.split(content)[1:] # exclude leading element of empty string
        assert len(names) == len(sets), "NumberExpander.__init__: FATAL ERROR: number of rule sets and names do not agree!"
        
        # for each rule set, split rule texts to divide set into dict of {base:(radix,rule)}
        self._rulenames = names
        self._rules = {}
        self._bases = {}
        for i in range(len(names)):
            self._rules[names[i]] = {}
            rule_texts = self._regex_rule.split(sets[i])[:-1] # split rules; exclude trailing element of whitespace (because of the final rule"s semi-colon)
            base = 0
            for rule_text in rule_texts: # for each rule line...
                radix = 10
                match_base = self._regex_base.search(rule_text)
                if match_base != None: # is there a match for the base delimiter, i.e. is a base specified?
                    base, rule_text = self._regex_base.split(rule_text)
                    
                    match_radix = self._regex_radix.search(base)
                    if match_radix != None: # is there a match for the radix delimiter, i.e. is a radix specified?
                        base, radix = self._regex_radix.split(base)
                    
                    radix = int(radix)
                    base = int(self._regex_group.sub("", base)) # remove any intra-number group delimiters from the base
                
                self._rules[names[i]][base] = (radix, rule_text.strip()) # assign the dict: rules[rule set name][rule base] = (rule radix, rule text)
                
                base += 1
            
            self._bases[names[i]] = self._rules[names[i]].keys()
            self._bases[names[i]].sort() # sort the rule bases ascendingly for proper search during expansion
    
    
    def rulesets(self):
        return self._rulenames
    
    
    def _findBase(self, num, ruleset):
        # find the largest base in the rule set less than or equal to num
        for i in range(len(self._bases[ruleset])-1, -1, -1):
            if self._bases[ruleset][i] <= num:
                return self._bases[ruleset][i]
    
    
    def expand(self, num, ruleset):
        # expand num according to the rules in ruleset (a slight modification of pp.12-13,8 in NumberGeneration.pdf)
        base = self._findBase(num, ruleset)
        text = self._rules[ruleset][base][1]
        
        match_major = self._regex_major.search(text)
        match_minor = self._regex_minor.search(text)
        match_same = self._regex_same.search(text)
        
        if match_major or match_minor:
            # TODO: this assertion should be moved to constructor
            assert base > 0, "NumberExpander.expand: FATAL ERROR: rule for base of zero cannot have major and/or minor substitutions!"
            
            radix = self._rules[ruleset][base][0]
            
            pow = math.log(base, radix) # radix**pow ~= base
            if (math.ceil(pow) - pow) < NumberExpander.ROUNDOFF_ERROR_TOLERANCE: # cater for roundoff errors
                pow = int(math.ceil(pow))
            else:
                pow = int(math.floor(pow))
            
            subst_major = num / (radix**pow) # major substitution value
            subst_minor = num % (radix**pow) # minor substitution value
            
            # rule roll-back exception for numbers which are multiples of (radix**pow) and without their own rules
            if (subst_minor == 0) and (num not in self._bases[ruleset]) and match_major and match_minor:
                base = radix**pow #self._bases[ruleset][self._bases[ruleset].index(base) - 1]
                text = self._rules[ruleset][base][1]
        
        # recurse with substitutions, if any (multiple substitutions are allowed)
        while True:
            if match_major:
                altset = match_major.group()[1:-1] # remove leading and trailing substitution delimiters
                if len(altset) > 0: # only change rule set if explicitly specified in substitution
                    newset = altset
                else:
                    newset = ruleset
                
                text = self._regex_major.sub(self.expand(subst_major, newset), text,1) # replace first match only
                match_major = self._regex_major.search(text) # search for next match
            
            elif match_minor:
                altset = match_minor.group()[1:-1]
                if len(altset) > 0:
                    newset = altset
                else:
                    newset = ruleset
                
                text = self._regex_minor.sub(self.expand(subst_minor, newset), text,1)
                match_minor = self._regex_minor.search(text)
            
            elif match_same:
                altset = match_same.group()[1:-1]
                if len(altset) > 0:
                    newset = altset
                else:
                    newset = ruleset
                
                text = self._regex_same.sub(self.expand(num, newset), text,1)
                match_same = self._regex_same.search(text)
            
            else:
                break
        
        return text
