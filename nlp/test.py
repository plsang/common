#ref: http://graus.nu/thesis/string-similarity-with-tfidf-and-python/

# class to timing, ref: http://stackoverflow.com/questions/5849800/tic-toc-functions-analog-in-python

### this is a test modul, model is trained from  python -m gensim.scripts.make_wiki
import time
import gensim
import gensim.parsing
import pickle
import os
from gensim import corpora, models, similarities
from gensim.models import TfidfModel
import logging, gensim, bz2
import operator
import sys

from os import listdir
from os.path import isfile, join
from gensim.parsing.preprocessing import STOPWORDS

import ipdb; 

from pattern.en import parse
import unicodedata


def tokenize(str):
    
    mystopwords = ['indoors', 'indoor', 'outdoors', 'outdoor', 'usually', 'outside', 'typically', 'inside', 'occasionally', 'safety'];
    
    str = ' '.join(gensim.utils.tokenize(str, lower=True, errors='ignore'))
    parsed = parse(str, lemmata=True, collapse=False)
    result = []
    for sentence in parsed:
        for token, tag, _, _, lemma in sentence:
            if 2 <= len(lemma) <= 15 and not lemma.startswith('_') and lemma not in STOPWORDS and lemma not in mystopwords:
                result.append(lemma.encode('utf8'))
    return result
    
event_dir = '/net/per610a/export/das11f/plsang/trecvidmed14/view/eventtexts/'
event_files = [ f for f in listdir(event_dir) if isfile(join(event_dir,f)) ]

for event_file in event_files:

    event_id = os.path.splitext(event_file)[0];
    
    with open(join(event_dir, event_file)) as f:
       string1 = f.readlines()
    
    concepts = []
    for str in string1:
        if ':' in str:
            parts = str.split(':')
            type = parts[0].strip().lower()
            val = parts[1].strip().lower()
            
            if type == 'scene':
                tmplist = tokenize(val)
                concepts.extend(tmplist)
                
            if type == 'objects/people' or type == 'people/objects': 
                tmplist = tokenize(val)
                concepts.extend(tmplist)
                
    print event_id, concepts 
    #ipdb.set_trace()
    
    # sim_concepts = concepts[:];
    
    # for tok in string2:
        # if tok in model.vocab:
            # indexes, metrics = model.cosine(tok)
            # simtoks = model.generate_response(indexes, metrics);
            # for key, val in simtoks:
                # sim_concepts.extend(tokenize(key))
    
    # sim_sets[synset_id] = sim_concepts
    
     
    #string1 = ' '.join(string1)