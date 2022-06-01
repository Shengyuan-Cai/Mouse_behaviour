# -*- coding: utf-8 -*-
"""
Created on Sat Aug 28 13:35:10 2021
labelme转VIS
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
def file_name(file_dir,fileformat):  
  L=[]  
  for root, dirs, files in os.walk(file_dir): 
    for file in files: 
      if os.path.splitext(file)[1] == fileformat: 
        L.append(os.path.join(root, file)) 
  return L
def mask2box(mask):
    '''从mask反算出其边框
    mask：[h,w]  0、1组成的图片
    1对应对象，只需计算1对应的行列号（左上角行列号，右下角行列号，就可以算出其边框）
    '''
    # np.where(mask==1)
    index = np.argwhere(mask == 1)
    rows = index[:, 0]
    clos = index[:, 1]
    # 解析左上角行列号
    left_top_r = np.min(rows)  # y
    left_top_c = np.min(clos)  # x

    # 解析右下角行列号
    right_bottom_r = np.max(rows)
    right_bottom_c = np.max(clos)

    # return [(left_top_r,left_top_c),(right_bottom_r,right_bottom_c)]
    # return [(left_top_c, left_top_r), (right_bottom_c, right_bottom_r)]
    # return [left_top_c, left_top_r, right_bottom_c, right_bottom_r]  # [x1,y1,x2,y2]
    return [left_top_c, left_top_r, right_bottom_c - left_top_c,
            right_bottom_r - left_top_r]  # [x1,y1,w,h] 对应COCO的bbox格式

def polygons_to_mask(img_shape, polygons):
    mask = np.zeros(img_shape, dtype=np.uint8)
    mask = PIL.Image.fromarray(mask)
    xy = list(map(tuple, polygons))
    PIL.ImageDraw.Draw(mask).polygon(xy=xy, outline=1, fill=1)
    mask = np.array(mask, dtype=bool)
    return mask
#%% 设置路径
datasetname = 'valid'
vidimgfolder = 'Z:/hanyaning/multi_mice_test/VIS_mice_data/raw_video_annotation/'+datasetname+'/labelme2vis'
imgpath = os.listdir(vidimgfolder)
tempjsonname = 'Z:\\hanyaning\\multi_mice_test\\VIS_mice_data\\code\\Python\\data\\train.json'
with open(tempjsonname, 'r') as f:
    tempjson = json.load(f)
tempjson_info = tempjson['info']
tempjson_licenses = tempjson['licenses']
tempjson_videos = tempjson['videos']
tempjson_categories = tempjson['categories']
#%%
tempjson_anno_0 = tempjson['annotations'][0]
#%% 转换开始
newjson = {}
newjson['info'] = {\
                   'contributor': 'yaninghan',\
                   'data_created': '2021-08-28 00:00:00',\
                   'description': 'Social-Black-Mice-VIS',\
                   'url': 'behavioratlas.tech',\
                   'version': '1.0',\
                   'year': 2021}
newjson['licenses'] = tempjson_licenses[0]
newjson['videos'] = []
vid_id = 1
for imgfolder in imgpath:
    #%% newjson['videos']
    tempnewjsonvideos = {}
    tempnewjsonvideos['coco_url'] = ''
    tempnewjsonvideos['data_captured'] = '2021-08-28 00:00:00'
    imgnames = file_name(vidimgfolder + '/' + imgfolder,'.jpg')
    tempnewjsonvideos['file_names'] = []
    for imgname in imgnames:
        tempimgname = imgname[(1+len(vidimgfolder)):]
        tempimgname = tempimgname.replace('\\', '/')
        tempnewjsonvideos['file_names'].append(tempimgname)
    tempnewjsonvideos['flickr_url'] = ''
    jsonname = imgname[0:-4]+'.json'
    with open(jsonname, 'r') as f:
        labelmejson = json.load(f)
    tempnewjsonvideos['height'] = labelmejson['imageHeight']
    tempnewjsonvideos['id'] = vid_id
    vid_id+=1
    tempnewjsonvideos['length'] = len(tempnewjsonvideos['file_names'])
    tempnewjsonvideos['license'] = 1
    tempnewjsonvideos['width'] = labelmejson['imageWidth']
    newjson['videos'].append(tempnewjsonvideos)
newjson['categories'] = [{'supercategory': 'object', 'id': 1, 'name': 'mouse'}]
newjson['annotations'] = []
anno_id = 1
for m in range(len(newjson['videos'])):
    tempvideo = newjson['videos'][m]
    for n in range(len(newjson['categories'])):
        tempcat = newjson['categories'][n]
        #%% 计算一个视频中每帧最多的实例个数
        max_ins = 0
        for tempfilename in tempvideo['file_names']:
            jsonname = vidimgfolder + '\\' + tempfilename[0:-4]+'.json'
            with open(jsonname, 'r') as f:
                labelmejson = json.load(f)
            if max_ins<len(labelmejson['shapes']):
                max_ins = len(labelmejson['shapes'])
        #%% 增加标注
        for k in range(max_ins):
            tempnewjsonanno = {}
            tempnewjsonanno['category_id'] = n+1
            tempnewjsonanno['video_id'] = m+1
            tempnewjsonanno['height'] = tempnewjsonvideos['height']
            tempnewjsonanno['width'] = tempnewjsonvideos['width']
            tempnewjsonanno['iscrowd'] = 0
            tempnewjsonanno['length'] = 1
            tempnewjsonanno['areas'] = []
            tempnewjsonanno['bboxes'] = []
            tempnewjsonanno['segmentations'] = []
            tempnewjsonanno['id'] = anno_id
            print(anno_id)
            anno_id += 1
            for tempfilename in tempvideo['file_names']:
                jsonname = vidimgfolder + '\\' + tempfilename[0:-4]+'.json'
                with open(jsonname, 'r') as f:
                    labelmejson = json.load(f)
                labelmeshapes = labelmejson['shapes']
                try:
                    temppolseg = labelmeshapes[k]
                    maskimg = polygons_to_mask([tempnewjsonanno['height'],tempnewjsonanno['width']], temppolseg['points'])
                    tempbbox = list(map(float, mask2box(maskimg)))
                    temprle = pymsk.encode(np.asfortranarray(maskimg))
                    temprle['counts'] = temprle['counts'].decode("utf-8")
                    temparea = int(np.sum(maskimg))
                    tempnewjsonanno['areas'].append(temparea)
                    tempnewjsonanno['bboxes'].append(tempbbox)
                    tempnewjsonanno['segmentations'].append(temprle)
                except:
                    tempnewjsonanno['areas'].append(None)
                    tempnewjsonanno['bboxes'].append(None)
                    tempnewjsonanno['segmentations'].append(None)
            newjson['annotations'].append(tempnewjsonanno)
#%% 保存newjson
with open(vidimgfolder + '\\'+datasetname+'_instance.json', 'w') as f:
    json.dump(newjson, f,sort_keys=True, indent=2)
print(vidimgfolder + '\\'+datasetname+'_instance.json' + ' finished!')            








