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

from os import listdir
from os.path import isfile, join

from pattern.en import parse
import unicodedata

def tokenize(str):
    str = ' '.join(gensim.utils.tokenize(str, lower=True, errors='ignore'))
    parsed = parse(str, lemmata=True, collapse=False)
    result = []
    for sentence in parsed:
        for token, tag, _, _, lemma in sentence:
            if 2 <= len(lemma) <= 15 and not lemma.startswith('_'):
                result.append(lemma.encode('utf8'))
    return result

def save_result(output_file, scores):
    sorted_scores = sorted(scores.items(), key=operator.itemgetter(1), reverse=True)
    with open(output_file, "w") as f:
        for k,v in sorted_scores:
            f.write ("%s - %s \n" % (synsets[k], scores[k]))    
            
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

synset_file = '/net/per610a/export/das11f/plsang/deepcaffe/caffe-rc/data/ilsvrc12/synset_words.txt'
with open(synset_file) as f:
   lines = f.readlines()

synsets = {}    
for line in lines:  
   synset_id = line[0:line.find(' ')]
   synsets[synset_id] = line[line.find(' ')+1:].rstrip()

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
       
for event_file in event_files:

    event_id = os.path.splitext(event_file)[0];
    
    with open(join(event_dir, event_file)) as f:
       string1 = f.readlines()
    
    string1 = ' '.join(string1)
    
    print string1
    strvec1 = dictionary.doc2bow(tokenize(string1))
    tfidf1 = tfidf[strvec1]
    lsi1 = lsi[strvec1]
    #strvec2 = dictionary.doc2bow(gensim.parsing.preprocess_string(string2))
    
    scores_lsi = {}
    scores_tfidf = {}
    for synset_id, synset_name in synsets.iteritems():
        string2 = synset_name
        strvec2 = dictionary.doc2bow(tokenize(string2))
        tfidf2 = tfidf[strvec2]
        lsi2 = lsi[strvec2]
        
        index = similarities.MatrixSimilarity([lsi2],num_features=len(dictionary))
        sim_lsi = index[lsi1]
        scores_lsi[synset_id] = sim_lsi
        
        index = similarities.MatrixSimilarity([tfidf2],num_features=len(dictionary))
        sim_tfidf = index[tfidf1]
        scores_tfidf[synset_id] = sim_tfidf
        
        #print str(round(sim*100,2))+'% similar'
    #sorted_scores = sorted(scores.items(), key=operator.itemgetter(1), reverse=True)

    output_lsi_file = '/net/per610a/export/das11f/plsang/trecvidmed14/view/eventsims-lsi/%s-%s.sim.txt' % (event_id, event_names[event_id])
    output_tfidf_file = '/net/per610a/export/das11f/plsang/trecvidmed14/view/eventsims-tfidf/%s-%s.sim.txt' % (event_id, event_names[event_id])
    
    save_result(output_lsi_file, scores_lsi);
    save_result(output_tfidf_file, scores_tfidf);
    
    