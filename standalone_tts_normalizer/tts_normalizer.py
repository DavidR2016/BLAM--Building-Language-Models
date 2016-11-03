#!/usr/bin/env python

import sys
import os.path
import codecs
import json
import collections

from tokenization import WordTokenizer, SentenceTokenizer
from normalization import Normalizer

UTTERANCE_DELIM = "\n"
WORD_DELIM = " "

if __name__ == "__main__":
    if len(sys.argv) < 4:
        sys.stderr.write("Usage: python %s <language> <in:raw_text_filepath> <out:normalized_text_filepath>\n" % sys.argv[0])
        sys.exit(1)
    
    # ========================
    # setup
    # ========================
    lang_path = sys.argv[1]
    raw_text_filepath = sys.argv[2]
    normalized_text_filepath = sys.argv[3]
    
    # abbreviations
    abbrev_json_filepath = os.path.join(lang_path, "abbrev.json")
    fin = open(abbrev_json_filepath, "rb")
    abbrev_json = json.load(fin, encoding="utf-8", object_pairs_hook=collections.OrderedDict)
    fin.close()
    abbrevs = abbrev_json["abbreviation-entries"].keys()
    
    # word tokenizer
    token_json_filepath = os.path.join(lang_path, "token.json")
    wordtok = WordTokenizer(token_json_filepath, abbrev_json["abbreviation-entries"].keys())
    
    # normalizer
    norm_json_filepath = os.path.join(lang_path, "norm.json")
    alphaexp_json_filepath = os.path.join(lang_path, "alphaexp.json")
    numexp_rule_filepath = os.path.join(lang_path, "numexp.rule")
    norm = Normalizer(norm_json_filepath, alphaexp_json_filepath, numexp_rule_filepath, abbrev_json["abbreviation-entries"])
    
    # sentence tokenizer
    sentence_json_filepath = os.path.join(lang_path, "sentence.json")
    senttok = SentenceTokenizer(sentence_json_filepath, raw_text_filepath)
    
    # ========================
    # run
    # ========================
    utts = []
    for sent in senttok.tokenize_iter():
        tokens, classes, puncs = wordtok.tokenize(sent)
        
        words = []
        for token, cls, punc in zip(tokens, classes, puncs):
            words.extend(norm.normalize(token, cls))
        
        utts.append(WORD_DELIM.join(words).lower())
    
    with codecs.open(normalized_text_filepath, "wb", "utf-8") as fout:
        fout.write(UTTERANCE_DELIM.join(utts))
