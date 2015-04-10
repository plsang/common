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
        
logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)

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

# test
string1 = """Event name: Tuning a musical instrument

Definition: One or more people tune a musical instrument

Explication: Tuning is the process of adjusting the pitch of tones
from musical instruments to establish typical intervals between these
tones based on a fixed reference pitch. There are a number of methods
for tuning an instrument, including tuning to a pitch with one's voice
(or "tuning by ear"), turning pegs to increase or decrease the tension
on strings so as to control the pitch, or modifying the length or
width of the tube of a wind instrument, brass instrument, pipe, bell,
or similar instrument to adjust the pitch. Tuning may be also be done
aurally by sounding two pitches and adjusting one of them to match the
other, such as with a tuning fork or electronic tuning device that
produces the reference pitch(es) - matching in this context may mean
bringing two sounds to the same pitch or may involve tuning the two
pitches to a desired interval and then fine-tuning the interval to
adjust the beat frequency to a desired frequency. Using an electronic
tuning device may, rather than comparing pitches by ear, involve
adjusting the pitch from the musical instrument until the electronic
device indicates the measured pitch is as desired. In the case of an
orchestra or wind band, the reference pitch is usually played by an
oboe, which everyone else then tunes to by comparing their
instrument's pitch to the pitch of the oboe.

Tuning a piano involves using a specialized wrench (often called a
tuning hammer) to adjust the tension of one string at a time (altering
its pitch) and the use of rubber or felt mutes to control which string
is producing sound (so that a single string at a time can be
tuned). Piano tuners may use an electronic device or a program running
on a laptop computer or smart phone, but may instead tune the piano
entirely "by ear" (aural tuning) sometimes using only a tuning fork as
an initial pitch reference. It is not unusual to tune part of a piano
using a device and the rest by ear.

Tuning a pipe organ will involve one person to play the notes from the
organ keyboard/pedalboard (the console) and another to tune the pipes.

Tuning tympani (kettle drums) will usually involve a pedal on each
drum, with the pedal adjusting the pitch.

Evidential description:

 scene: indoors (stage, concert venue, store) or outdoors (concert
 stage, park, sidewalk)

 objects/people: musical instruments (guitar, piano, drums, trumpet,
 saxophone, etc.), tuning device (tuning fork, electronic tuner, piano
 tuning wrench, etc.), capo

 activities: tuning, playing musical instrument

 audio: crowd reaction, playing of instrument, musician talking to
 audience, musician narrating instructions."""

 
#string2 = """ n01496331 great white shark, white shark, man-eater, man-eating shark, Carcharodon carcharias"""
synset_file = '/net/per610a/export/das11f/plsang/deepcaffe/caffe-rc/data/ilsvrc12/synset_words.txt'

event_dir = '/net/per610a/export/das11f/plsang/trecvidmed14/view/eventtexts/'
event_files = [ f for f in listdir(event_dir) if isfile(join(event_dir,f)) ]

event_name_file = '/net/per610a/export/das11f/plsang/codes/summax-pooling-journal/lm/trecvidmed14.events.lst'
with open(event_name_file) as f:
    lines = f.readlines()
       
event_names = {}    
for line in lines:  
   splits = line.split(' >.< ')
   event_names[splits[0]] = splits[1]
       
for event_file in event_files:

    event_id = os.path.splitext(event_file)[0];
    
    with open(join(event_dir, event_file)) as f:
       string1 = f.readlines()
    
    string1 = ' '.join(string1)
    
    print string1
    strvec1 = dictionary.doc2bow(gensim.parsing.preprocess_string(string1))
    tfidf1 = tfidf[strvec1]
    lsi1 = lsi[strvec1]
    #strvec2 = dictionary.doc2bow(gensim.parsing.preprocess_string(string2))


    with open(synset_file) as f:
       lines = f.readlines()

    synsets = {}    
    for line in lines:  
       synset_id = line[0:line.find(' ')]
       synsets[synset_id] = line[line.find(' ')+1:].rstrip()

    scores = {}
    for synset_id, synset_name in synsets.iteritems():
        string2 = synset_name
        strvec2 = dictionary.doc2bow(gensim.parsing.preprocess_string(string2))
        tfidf2 = tfidf[strvec2]
        
        lsi2 = lsi[strvec2]
        index = similarities.MatrixSimilarity([lsi2],num_features=len(dictionary))
        sim = index[lsi1]
        
        # index = similarities.MatrixSimilarity([tfidf2],num_features=len(dictionary))
        # sim = index[tfidf1]
        
        scores[synset_id] = sim
        
        #print str(round(sim*100,2))+'% similar'
    sorted_scores = sorted(scores.items(), key=operator.itemgetter(1), reverse=True)

    output_sim_file = '/net/per610a/export/das11f/plsang/trecvidmed14/view/eventsims/%s-%s.sim.txt' % (event_id, event_names[event_id])
    with open(output_sim_file, "w") as f:
        for k,v in sorted_scores:
            f.write ("%s - %s \n" % (synsets[k], scores[k]))