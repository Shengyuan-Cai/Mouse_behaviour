# -*- coding: utf-8 -*-
"""
Created on Tue Aug 31 09:26:58 2021
sbmvis数据集转换为vistr数据集
@author: Administrator
"""
#%%
import json
import os
import numpy as np
# import PIL.Image
# import base64
# from labelme import utils
# from labelme import LabelFile
# import pycocotools.mask as pymsk
# import PIL.Image
# import matplotlib.pyplot as plt
# from tqdm import tqdm
import random
from pathlib import Path
import cv2

random.seed(a=0, version=2)

def file_name(file_dir,fileformat):  
  L=[]  
  for root, dirs, files in os.walk(file_dir): 
    for file in files: 
      if os.path.splitext(file)[1] == fileformat: 
        L.append(os.path.join(root, file)) 
  return L
#%% 设置路径和参数
sbmvispath = 'Z:\\hanyaning\\multi_mice_test\\VIS_mice_data\\SBM-VIS'
savevistrpath = 'Z:\\hanyaning\\multi_mice_test\\VIS_mice_data'
#%% 读取数据
folderlist = ['train','valid','test']
vidnum = [500,5,5]#生成数据的数量
# vidnum = [5,1,1]#生成数据的数量
numcount = 0
for tempfolder in folderlist:
    #%% 读取json文件
    labelpath = sbmvispath + '\\annotations\\'  + tempfolder + '_instance.json'
    with open(labelpath, 'r') as f:
        visjson = json.load(f)
    #%% 创建存储路径
    saverootpath = savevistrpath + '\\SBM-VIS-VIStR-12'
    if Path(saverootpath).exists():
        print('path exists!')
    else:
        os.mkdir(saverootpath)
    saveannopath = saverootpath + '\\annotations'
    if Path(saveannopath).exists():
        print('path exists!')
    else:
        os.mkdir(saveannopath)
    savedatapath = saverootpath + '\\' + tempfolder
    if Path(savedatapath).exists():
        print('path exists!')
    else:
        os.mkdir(savedatapath)
    #%% 创建新的json
    newjson = {}
    newjson['info'] = visjson['info']
    newjson['info']['description'] = 'SBM-VIS-VIStR'
    newjson['licenses'] = visjson['licenses']
    newjson['categories'] = visjson['categories']
    #%% 按索引生成新的存储
    idx_range = [15,18]
    newjson['videos'] = []
    newjson['annotations'] = []
    annocount = 1
    vidcount = 1
    for tempvid in visjson['videos']:
        idxlist = np.zeros([vidnum[numcount],2])
        for k in range(0,vidnum[numcount]):
            temprange = random.randint(idx_range[0],idx_range[1])#随机长度切割
            idxlist[k,0] = random.randint(0,len(tempvid['file_names'])-1-temprange)
            idxlist[k,1] = idxlist[k,0] + temprange
        for tempidx in idxlist:
            tempnewjsonvideos = {}
            tempnewjsonvideos['coco_url'] = tempvid['coco_url']
            tempnewjsonvideos['data_captured'] = tempvid['data_captured']
            tempnewjsonvideos['flickr_url'] = tempvid['flickr_url']
            tempnewjsonvideos['height'] = tempvid['height']
            tempnewjsonvideos['width'] = tempvid['width']
            tempnewjsonvideos['license'] = tempvid['license'] 
            tempnewjsonvideos['length'] = int(tempidx[1] - tempidx[0])
            tempnewjsonvideos['id'] = vidcount
            tempnewjsonvideos['file_names'] = []
            vidcount += 1
            selvidframe = tempvid['file_names'][int(tempidx[0]):int(tempidx[1])]
            framecount = 0
            #%% 获取视频内实例
            for tempanno in visjson['annotations']:
                if tempanno['video_id'] == tempvid['id']:
                    tempnewanno = {}
                    tempnewanno['id'] = annocount
                    annocount += 1
                    tempnewanno['areas'] = tempanno['areas'][int(tempidx[0]):int(tempidx[1])]
                    tempnewanno['bboxes'] = tempanno['bboxes'][int(tempidx[0]):int(tempidx[1])]
                    tempnewanno['category_id'] = tempanno['category_id']
                    tempnewanno['height'] = tempanno['height']
                    tempnewanno['iscrowd'] = tempanno['iscrowd']
                    tempnewanno['length'] = tempanno['length']
                    tempnewanno['segmentations'] = tempanno['segmentations'][int(tempidx[0]):int(tempidx[1])]
                    tempnewanno['video_id'] = tempnewjsonvideos['id']
                    tempnewanno['width'] = tempanno['width']
                    newjson['annotations'].append(tempnewanno)
            #%% 
            for framename in selvidframe:
                #%% 读取原图像
                tempimg = cv2.imread(sbmvispath + '\\'  + tempfolder +\
                                     '\\' + framename)
                #%% 保存至新路径
                if not Path(savedatapath + '\\JPEGImages').exists():
                    os.mkdir(savedatapath + '\\JPEGImages')
                if not Path(savedatapath + '\\JPEGImages\\' + str(tempnewjsonvideos['id'])).exists():
                    os.mkdir(savedatapath + '\\JPEGImages\\' + str(tempnewjsonvideos['id']))
                #%% 写入图像，改名字
                newimgname = str(framecount).zfill(5) + '.jpg'            
                cv2.imwrite(savedatapath + '\\JPEGImages\\' + str(tempnewjsonvideos['id']) + '\\' + newimgname,\
                            tempimg)
                #%% 保存新的json文件名
                tempnewname = str(tempnewjsonvideos['id']) + '\\' + newimgname
                tempnewname = tempnewname.replace('\\', '/')
                tempnewjsonvideos['file_names'].append(tempnewname)
                framecount = framecount+1
            newjson['videos'].append(tempnewjsonvideos)
    numcount += 1
    #%% 保存newjson
    with open(saveannopath + '\\instances_'  + tempfolder + '_sub.json', 'w') as f:
        json.dump(newjson, f,sort_keys=True, indent=2)
    print(saveannopath + '\\instances_'  + tempfolder + '_sub.json' + ' finished!')   
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
