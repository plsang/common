import os
import numpy as np
import matplotlib.pyplot as plt
import time
import logging
import pandas as pd
import re
import glob
from os.path import basename
import subprocess
import ipdb
import pickle
import math
import sys

def cosine_similarity(v1,v2):
    "compute cosine similarity of v1 to v2: (v1 dot v1)/{||v1||*||v2||)"
    sumxx, sumxy, sumyy = 0, 0, 0
    for i in range(len(v1)):
        x = v1[i]; y = v2[i]
        sumxx += x*x
        sumyy += y*y
        sumxy += x*y
    return sumxy/math.sqrt(sumxx*sumyy)

if (len(sys.argv) < 4):
    print sys.argv[0] + " <set> <start video> <end video> ";
    exit()

dataset = sys.argv[1]
start_video = int(sys.argv[2])
end_video = int(sys.argv[3])

#logging
logging.basicConfig(filename= "%s.%s.log.txt" % (__file__[:-3], dataset), format='%(asctime)s : %(levelname)s : %(message)s')
logging.root.setLevel(level=logging.INFO)
logging.info("running [%s]" % ' '.join(sys.argv))
  

keyframe_dir = '/net/per610a/export/das11f/plsang/trecvidmed13/keyframes'
output_dir = '/net/per610a/export/das11f/plsang/trecvidmed/feature/keyframes/deepcaffe_eventsim_hybrid'
kffeat_dir = '/net/per610a/export/das11f/plsang/trecvidmed/feature/keyframes/placehybridCNN.full'
meta_dir='/net/per610a/export/das11f/plsang/trecvidmed/metadata/med14/'


def get_video_list_file(x):
    return {
        'event': meta_dir + 'event_video_list.txt',
        'eventbg': meta_dir + 'eventbg_list.txt',
        'kindredtest14': meta_dir + 'kindredtest14_list.txt',
        'medtest14': meta_dir + 'medtest14_list.txt',
        'med2012': '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med12/med2012.txt'
    }[x]

class Timer(object):
    def __init__(self, name=None):
        self.name = name

    def __enter__(self):
        self.tstart = time.time()

    def __exit__(self, type, value, traceback):
        if self.name:
            print '[%s]' % self.name,
            logging.info('Run [%s]. Elapsed: %s' % (self.name, time.time() - self.tstart))
        
if __name__=="__main__":
    
    #video_list_file = '/net/per610a/export/das11f/plsang/overfeat/overfeat/src/event_video_list.txt' # 6964
    
    #video_list_file='/net/per610a/export/das11f/plsang/trecvidmed/metadata/med14/medtest14_list.txt'  # 14,708
    video_list_file = get_video_list_file(dataset)
    
    event_sim_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/event_concept_place1183.pickle'    
    scores = pickle.load(open( event_sim_file, "rb" ))    
    n_event = scores.shape[1]
    print n_event
    
    with open(video_list_file, 'r') as fh:
        data = fh.readlines()
    
    with Timer('_'.join(sys.argv)):
        for ii in range(start_video, end_video):
            
            line = data[ii];
            words = line.split()
            vid = words[0]
            ldcpat = os.path.splitext(words[1])[0]
            
            print '{}/{} '.format(ii, end_video-start_video)
            
            kfs = glob.glob("{}/{}/*.jpg".format(keyframe_dir, ldcpat))
            
            for kf_file in kfs:
                head, tail = os.path.split(kf_file)	
                kf_name = os.path.splitext(tail)[0]
                
                output_file = '{}/{}/{}.cosinesim.txt'.format(output_dir, ldcpat, kf_name)
                if os.path.exists(output_file):
                    continue
                    
                input_file = '{}/{}/{}.txt'.format(kffeat_dir, ldcpat, kf_name)
                if not os.path.exists(input_file):
                    print 'File [{}] does not already exist'.format(input_file);
                    sys.exit(0);
                
                #get the feature vector of 1000d    
                with open(input_file) as f:
                    lines = f.read().splitlines()
                
                kf_feat = [float(line) for line in lines]
                
                #ipdb.set_trace() 
                sims = np.zeros(n_event)
                
                output_vdir = '{}/{}'.format(output_dir, ldcpat)
                if not os.path.exists(output_vdir):
                    os.makedirs(output_vdir)
                    
                for jj in range(0, n_event):
                    sims[jj] = cosine_similarity(scores[:, jj], kf_feat)
                
                with open(output_file, 'w') as fh:
                    for sim in sims:
                        fh.write('{}\n'.format(sim))
                
            
                