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
import word2vec
import sys

import numpy

import ipdb
import scipy.io as sio

from os import listdir
from os.path import isfile, join

from pattern.en import parse
import unicodedata

from gensim.parsing.preprocessing import STOPWORDS

def tokenize(str):
    mystopwords = ['indoors', 'indoor', 'outdoors', 'outdoor', 'usually', 'outside', 'typically', 'inside', 'occasionally'];
    str = ' '.join(gensim.utils.tokenize(str, lower=True, errors='ignore'))
    parsed = parse(str, lemmata=True, collapse=False)
    result = []
    for sentence in parsed:
        for token, tag, _, _, lemma in sentence:
            if 2 <= len(lemma) <= 15 and not lemma.startswith('_') and lemma not in STOPWORDS and lemma not in mystopwords:
                result.append(lemma.encode('utf8'))
    return result

def save_result(output_file, scores, concepts):
    sorted_idx = sorted(range(len(scores)),key=lambda x:scores[x], reverse=True)
    output_dir = os.path.split(output_file)[0]
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        
    with open(output_file, "w") as f:
        for idx in sorted_idx:
            f.write ("%s - %s \n" % (concepts[idx], scores[idx]))    
            
root_dir = '/net/per610a/export/das11f/plsang/codes/summax-pooling-journal/lm'
#corpus_file = '/net/per900a/raid0/plsang/software/word2vec/trunk/text8'
corpus_file = '/net/per900a/raid0/plsang/software/word2vec/trunk/demo-train-big-model/word2vec/data.txt'
#corpus_file = '/net/per610a/export/das11f/plsang/codes/summax-pooling-journal/lm/mycorpus.txt'
model_file = root_dir + '/wiki_en__bow.mm'
tfidf_file = root_dir + '/wiki_en__tfidf.mm'
tfidf_model_file = root_dir + '/wiki_en__tfidf_model.mm'
lsi_model_file = root_dir + '/wiki_en__lsi.mm'
dict_file = root_dir + '/wiki_en__wordids.txt.bz2'

class Timer(object):
    def __init__(self, name=None): 
        self.name = name

    def __enter__(self):
        self.tstart = time.time()

    def __exit__(self, type, value, traceback):
        if self.name:
            print '[%s]' % self.name,
        print 'Elapsed: %s' % (time.time() - self.tstart)
        
logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.ERROR)

logging.info("Loading dictionary...")
# load id->word mapping (the dictionary), one of the results of step 2 above
dictionary = gensim.corpora.Dictionary.load_from_text(dict_file)
# load corpus iterator
logging.info("Loading bow corpus model...")
model = gensim.corpora.MmCorpus(model_file)

logging.info("Loading corpus tfidf model...")
corpus_tfidf = gensim.corpora.MmCorpus(tfidf_file)
#note that arcoding to http://pydoc.net/Python/gensim/0.10.2/gensim.scripts.make_wikicorpus/
#the saved tfidf model = tfidf[mm]
#so I have to cal the tfidf model again and save it

with Timer('tfidf'):
	if os.path.exists(tfidf_model_file):
		logging.info("Loading tfidf model...")
		tfidf = pickle.load( open( tfidf_model_file, "rb" ) )
	else:
		logging.info("Calculating tfidf model...")
		tfidf = TfidfModel(model, id2word=dictionary, normalize=True)
		pickle.dump( tfidf, open( tfidf_model_file, "wb" ) )
        
with Timer('lsi'):
    if os.path.exists(lsi_model_file):
        logging.info("Loading lsi model...")
        lsi = models.LsiModel.load(lsi_model_file)
    else:
        logging.info("Calculating lsi model...")
        lsi = models.LsiModel(corpus_tfidf, id2word=dictionary)
        lsi.save(lsi_model_file)

# mm = gensim.corpora.MmCorpus(bz2.BZ2File('wiki_en_tfidf.mm.bz2')) # use this if you compressed the TFIDF output (recommended)            

#word2vec_model = '/net/per900a/raid0/plsang/software/word2vec/trunk/vectors.bin'  # text8 model
#word2vec_model = '/net/per900a/raid0/plsang/software/word2vec/trunk/big-model/vectors.bin' #big model, trained on 3-phrases
word2vec_model = '/net/per920a/export/das14a/satoh-lab/plsang/word2vec/model/vectors.bin' #big model, trained on words

# synset_file = '/net/per610a/export/das11f/plsang/deepcaffe/caffe-rc/data/ilsvrc12/synset_words.txt'
# with open(synset_file) as f:
   # lines = f.readlines()

place1183_concept_list = '/net/per920a/export/das14a/satoh-lab/plsang/places205/hybridCNN_upgraded/categoryIndex_hybridCNN.combined.csv'

with open(place1183_concept_list) as f:
    concepts = f.read().splitlines()
    
# syndicts = {}    
# for line in lines:  
    # synset_id = line[0:line.find(' ')]
    # syndicts[synset_id] = line[line.find(' ')+1:].rstrip()
   
# synsets = []    
# for line in lines:  
   # synset_id = line[0:line.find(' ')]
   # synset_name = line[line.find(' ')+1:].rstrip()
   # synsets.append((synset_id, synset_name))

   
event_dir = '/net/per610a/export/das11f/plsang/trecvidmed14/view/eventtexts/'
event_files = [ f for f in listdir(event_dir) if isfile(join(event_dir,f)) ]

event_name_file = '/net/per610a/export/das11f/plsang/codes/summax-pooling-journal/lm/trecvidmed14.events.lst'
with open(event_name_file) as f:
    lines = f.readlines()
       
event_names = {}    
for line in lines:  
   splits = line.split(' >.< ')
   event_id = splits[0].strip();
   event_name = splits[1].strip();
   event_names[event_id] = event_name

with Timer('building sim set'):
    simset_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/concept_place1183_augmented.pickle'
    simset_cache_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/concept_place1183_augmented.cache.pickle'
    
    if os.path.exists(simset_file):
        logging.info("Loading sim set...")
        sim_sets = pickle.load( open( simset_file, "rb" ) )
    else:
        print 'load word2vec model ', word2vec_model
        model = word2vec.load(word2vec_model)
        
        print 'Augmenting synset concept...'
        sim_sets = {}   
        count = 0;
        cache = {}
        for concept in concepts:
        
            string2 = tokenize(concept)
            sim_concepts = string2[:];
            for tok in string2:
                if tok in model.vocab:
                    if tok in cache.keys():
                        simtoks = cache[tok]
                    else:    
                        indexes, metrics = model.cosine(tok)
                        simtoks = model.generate_response(indexes, metrics);
                        cache[tok] = simtoks
                        
                    for key, val in simtoks:
                        sim_concepts.extend(tokenize(key))
            
            sim_sets[count] = sim_concepts
            
            count += 1
            sys.stdout.write('{} '.format(count))
            sys.stdout.flush()
            
        pickle.dump( sim_sets, open( simset_file, "wb" ) )
        pickle.dump( cache, open( simset_cache_file, "wb" ) )


scores = numpy.zeros(shape=(len(concepts), len(event_names)))

all_concepts = []
for idx, val in enumerate(concepts):
    sim_concepts = sim_sets[idx];
    all_concepts = list(set(all_concepts) | set(sim_concepts))

#print all_concepts

for event_file in event_files:

    event_id = os.path.splitext(event_file)[0];
    
    with open(join(event_dir, event_file)) as f:
       string1 = f.readlines()
    
    string1 = ' '.join(string1)
    
    print 'Event {}: '.format(event_files.index(event_file)), string1
    
    list1 = tokenize(string1);
    
    for c in list1:
        if not c in all_concepts:
            list1.remove(c)
    
    if event_id == 'E009': 
        list1.extend(['disk', 'brake'])
    elif event_id == 'E016': 
        list1.extend(['crossword', 'puzzle', 'riddle'])
    elif event_id == 'E007': 
        list1.extend(['disk', 'brake'])    
    elif event_id == 'E008': 
        list1.extend(['palace'])    
        
    #ipdb.set_trace() 
    
    strvec1 = dictionary.doc2bow(list1)
        
    tfidf1 = tfidf[strvec1] 
   
    scores_tfidf = numpy.zeros(len(concepts))
    
#    for synset_id, synset_name in synsets.iteritems():
    for idx, val in enumerate(concepts):
        
        #ipdb.set_trace()
        
        sim_concepts = sim_sets[idx];
        
        strvec2 = dictionary.doc2bow(sim_concepts)
        tfidf2 = tfidf[strvec2]
        index = similarities.MatrixSimilarity([tfidf2],num_features=len(dictionary))
        sim_tfidf = index[tfidf1]
        scores_tfidf[idx] = sim_tfidf
        
        #print str(round(sim*100,2))+'% similar'
        #sorted_scores = sorted(scores.items(), key=operator.itemgetter(1), reverse=True)
        
    output_tfidf_file = '/net/per610a/export/das11f/plsang/trecvidmed14/view/eventsims-tfidf-place/%s-%s.sim.txt' % (event_id, event_names[event_id])
    
    save_result(output_tfidf_file, scores_tfidf, concepts);
    
    event_idx = event_files.index(event_file)
    scores[:,event_idx] = scores_tfidf
    
output_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/event_concept_place1183.pickle'    
pickle.dump(scores, open( output_file, "wb" ))    

output_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/event_concept_place1183.mat'    
sio.savemat(output_file,{'scores':scores})    