import os
import numpy as np
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
import scipy
from scipy import stats

def cosine_similarity(v1,v2):
    "compute cosine similarity of v1 to v2: (v1 dot v1)/{||v1||*||v2||)"
    sumxx, sumxy, sumyy = 0, 0, 0
    for i in range(len(v1)):
        x = v1[i]; y = v2[i]
        sumxx += x*x
        sumyy += y*y
        sumxy += x*y
    return sumxy/math.sqrt(sumxx*sumyy)
        
caffe_root = '/net/per610a/export/das11f/plsang/deepcaffe/caffe-rc' 
nc = 1000

import sys
sys.path.insert(0, caffe_root + '/python')

import caffe 

if (len(sys.argv) < 4):
    print sys.argv[0] + " <set> <start video> <end video> ";
    exit()

dataset = sys.argv[1]
start_video = int(sys.argv[2])
end_video = int(sys.argv[3])

#logging
logging.basicConfig(filename= "%s/%s.log.txt" % (__file__[:-3], dataset), format='%(asctime)s : %(levelname)s : %(message)s')
logging.root.setLevel(level=logging.INFO)
logging.info("running [%s]" % ' '.join(sys.argv))
    
REPO_DIRNAME = caffe_root
                           
# Set the right path to your model definition file, pretrained model weights,
# and the image you would like to classify.
MODEL_FILE = '{}/models/bvlc_reference_caffenet/deploy.prototxt'.format(REPO_DIRNAME)
PRETRAINED = '{}/models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel'.format(REPO_DIRNAME)

net = caffe.Classifier(MODEL_FILE, PRETRAINED,
                       mean=np.load(caffe_root + '/python/caffe/imagenet/ilsvrc_2012_mean.npy'),
                       channel_swap=(2,1,0),
                       raw_scale=255,
                       image_dims=(256, 256))

net.set_phase_test()
net.set_mode_cpu()

default_args = {
    'model_def_file': (
        '{}/models/bvlc_reference_caffenet/deploy.prototxt'.format(REPO_DIRNAME)),
    'pretrained_model_file': (
        '{}/models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel'.format(REPO_DIRNAME)),
    'mean_file': (
        '{}/python/caffe/imagenet/ilsvrc_2012_mean.npy'.format(REPO_DIRNAME)),
    'class_labels_file': (
        '{}/data/ilsvrc12/synset_words.txt'.format(REPO_DIRNAME)),
}
for key, val in default_args.iteritems():
    if not os.path.exists(val):
        raise Exception(
            "File for {} is missing. Should be at: {}".format(key, val))
            
default_args['image_dim'] = 227
default_args['raw_scale'] = 255.
default_args['gpu_mode'] = False

with open(default_args['class_labels_file']) as f:
    labels_df = pd.DataFrame([
        {
            'synset_id': l.strip().split(' ')[0],
            #'name': ' '.join(l.strip().split(' ')[1:]).split(',')[0]
            'name': ' '.join(l.strip().split(' ')[1:])
        }
        for l in f.readlines()
    ])
labels = labels_df.sort('synset_id')['name'].values

keyframe_dir = '/net/per610a/export/das11f/plsang/trecvidmed13/keyframes'
output_dir = '/net/per610a/export/das11f/plsang/trecvidmed/feature/keyframes/deepcaffe_eventsim.kl'
kffeat_dir = '/net/per610a/export/das11f/plsang/trecvidmed/feature/keyframes/deepcaffe_1000'
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
    
    event_sim_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/event_concept_sim3.pickle'    
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
                
                input_file = '{}/{}/{}.deepcaffe.txt'.format(kffeat_dir, ldcpat, kf_name)
                if not os.path.exists(input_file):
                    print 'File [{}] does not already exist'.format(input_file);
                    sys.exit(0);
                
                #get the feature vector of 1000d    
                with open(input_file, 'r') as f:
                    lines = f.readlines()
                
                kf_feat = np.zeros(nc)
                for idx, featline in enumerate(lines):
                    kf_feat[idx] = float(featline.split(':')[1].strip())
                
                #ipdb.set_trace() 
                
                sims = np.zeros(n_event)
                
                output_file = '{}/{}/{}.cosinesim.txt'.format(output_dir, ldcpat, kf_name)
                output_vdir = '{}/{}'.format(output_dir, ldcpat)
                if not os.path.exists(output_vdir):
                    os.makedirs(output_vdir)
                
                #ipdb.set_trace() 
                
                for jj in range(0, n_event):
                    sims[jj] = scipy.stats.entropy(kf_feat, scores[:, jj] + sys.float_info.epsilon)
                
                with open(output_file, 'w') as fh:
                    for sim in sims:
                        fh.write('{}\n'.format(sim))
                
            
                