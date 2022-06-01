# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
# In[import deeplabcut]
import deeplabcut
import os
import multiprocessing
# In[define function] 
def get_all_path(open_file_path):
    rootdir = open_file_path
    path_list = []
    templist = os.listdir(rootdir)  # 列出文件夹下所有的目录与文件
    for i in range(0, len(templist)):
        com_path = os.path.join(rootdir, templist[i])
        #print(com_path)
        if os.path.isfile(com_path):
            path_list.append(com_path)
        if os.path.isdir(com_path):
            path_list.extend(get_all_path(com_path))
    #print(path_list)
    return path_list
# In[video analysis]
config_path = 'Z:\ck\mouse_behavior\matlab_pose3d\dlc\Mouse2Dproject-CK-2020-04-11\config3.yaml'
ana_video_path = 'Z:\\hanyaning\\multi_mice_test\\VIS_mice_data\\code\\MATLAB\\data\\dlc_add_data'
ana_video_name = get_all_path(ana_video_path)
deeplabcut.analyze_videos(config_path,[ana_video_path], \
                          shuffle=1, save_as_csv=True, videotype='.avi',\
                              gputouse='0')
# In[filterpredictions]
# deeplabcut.filterpredictions(config_path,[ana_video_path], videotype='.avi')
# # In[plot_trajectories]
# deeplabcut.plot_trajectories(config_path,ana_video_name)
# # In[create labeled video]
# #deeplabcut.create_labeled_video(config_path,ana_video_name)
# # In[ignore error]
# config_path = 'Z:\ck\mouse_behavior\matlab_pose3d\dlc\Mouse2Dproject-CK-2020-04-11\config3.yaml'
# ana_video_path = 'Z:\\hanyaning\\multi_mice_test\\VIS_mice_data\\code\\MATLAB\\data\\dlc_test'
# ana_video_name = get_all_path(ana_video_path)
# deeplabcut.create_labeled_video(config_path,ana_video_name,videotype='mp4')

# In[test code]
# import cv2
# im = cv2.imread('G:/SIAT_PROJECT/机器学习本能行为/img00436.png')