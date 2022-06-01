# -*- coding: utf-8 -*-
"""
Created on Sun Aug 29 13:05:01 2021
创建mask视频
@author: Administrator
"""
#%%
import json
import os
import numpy as np
import PIL.Image
import base64
from labelme import utils
from labelme import LabelFile
import pycocotools.mask as pymsk
import PIL.Image
import matplotlib.pyplot as plt
from tqdm import tqdm
import scipy.io as scio  
def file_name(file_dir,fileformat):  
  L=[]  
  for root, dirs, files in os.walk(file_dir): 
    for file in files: 
      if os.path.splitext(file)[1] == fileformat: 
        L.append(os.path.join(root, file)) 
  return L
#%% 设置路径
jsonpath = 'Z:\\hanyaning\\multi_mice_test\\VIS_mice_data\\SBM-VIS-Easy\\annotations'
jsonname = 'valid_instance.json'
savemaskpath = 'Z:\\hanyaning\\multi_mice_test\\VIS_mice_data\\code\\Python\\data'
with open(jsonpath + '\\' + jsonname, 'r') as f:
    tempjson = json.load(f)
#%% 生成视频
for tempvideo in tempjson['videos']:
    videoname,temp = tempvideo['file_names'][0].split('\\',1)
    videoid = tempvideo['id']
    labellist = []
    for tempanno in tempjson['annotations']:
        if tempanno['video_id'] == videoid:
            labellist.append(tempanno)
    #%
    allmasklist = []
    for k in range(len(labellist[0]['areas'])):
        masklist = []
        for m in range(len(labellist)):
            templabel = labellist[m]
            rlemask = templabel['segmentations'][k]
            #rlemask['counts'] = rlemask['counts'].encode('utf-8')
            if rlemask is not None:
                masklist.append(np.array(pymsk.decode(rlemask)))
            else:
                 masklist.append('NaN')
                 print(k)
                 print('NaN')
        masklist.append('NaN')
        allmasklist.append(masklist)
    print(videoid)
    scio.savemat(savemaskpath + '\\' + videoname + '.mat', {'mask': allmasklist})  
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
