# -*- coding: utf-8 -*-
"""
Created on Sat Aug 21 14:17:28 2021
COCO数据转换为labelme格式
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
def file_name(file_dir,fileformat):  
  L=[]  
  for root, dirs, files in os.walk(file_dir): 
    for file in files: 
      if os.path.splitext(file)[1] == fileformat: 
        L.append(os.path.join(root, file)) 
  return L
#%% 设置路径
imgpath = 'Z:\\hanyaning\\multi_mice_test\\VIS_mice_data\\raw_video_annotation\\test\\test_seg-1-mouse-day1-camera-5'
alljsonname = imgpath+'\\init_train.json'
# tempjsonname = 'Z:\\hanyaning\\multi_mice_test\\VIS_mice_data\\raw_video_annotation\\train\\00000.json'
# with open(tempjsonname, 'r') as f:
#     tempjson = json.load(f)
imgnames = file_name(imgpath,'.jpg')
with open(alljsonname, 'r') as f:
    alljson = json.load(f)
#%% 文件转换
for imgname in imgnames:
    #%% 搜索图片号
    for tempimages in alljson['images']:
        if imgname == imgpath + '\\' + tempimages['file_name']:
            imginfo = tempimages
            break
    #%% 根据图片号搜索segmentation
    anno = []
    for tempseg in alljson['annotations']:
        if imginfo['id'] == tempseg['image_id']:
            anno.append(tempseg)
    #%% 整理为labelme json格式
    newjson = {}
    newjson['flags'] = {}
    image_pil = LabelFile.load_image_file(imgname)
    newjson['imageData'] = base64.b64encode(image_pil).decode('utf-8')
    newjson['imageHeight'] = imginfo['height']
    newjson['imagePath'] = imginfo['file_name']
    newjson['imageWidth'] = imginfo['width']
    newjson['shapes'] = []
    for tempanno in anno:
        tempshape = {}
        tempshape['flags'] = {}
        tempshape['group_id'] = None
        tempshape['label'] = 'mouse'
        tempshape['points'] = []
        temppoints = np.array(tempanno['segmentation']).reshape(-1,2)
        for k in range(np.size(temppoints,axis=0)):
            tempshape['points'].append(temppoints[k,:].tolist())
        tempshape['shape_type'] = 'polygon'
        newjson['shapes'].append(tempshape)
    newjson['version'] = '4.5.7'
    #%% 保存newjson
    with open(imgname[0:-4] + '.json', 'w') as f:
        json.dump(newjson, f,sort_keys=True, indent=2)
    print(imgname[0:-4] + '.json' + ' finished!')
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
