# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
# In[import deeplabcut]
import deeplabcut
import os
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

# In[set path]
videopath = 'Z:\hanyaning\mulldling_data_analysis\liunan_analysis\dlc_train\dlc_videopath'
videoname = get_all_path(videopath)
deeplabcut.create_new_project('AN_project','AN_nose', \
  videoname,\
working_directory='Z:\hanyaning\mulldling_data_analysis\liunan_analysis\dlc_train',copy_videos=True)#第一次运行此处要写True
# In[read config]
config_path = 'Z:\ck\mouse_behavior\matlab_pose3d\dlc\Mouse2Dproject-CK-2020-04-11\config3.yaml'
deeplabcut.extract_frames(config_path,'automatic','kmeans',crop=False, userfeedback=False)

# In[label frame]
import deeplabcut  
config_path = 'Z:\ck\mouse_behavior\matlab_pose3d\dlc\Mouse2Dproject-CK-2020-04-11\config3.yaml'
deeplabcut.label_frames(config_path)

# In[check labels]
deeplabcut.check_labels(config_path)
# In[create training dataset]
deeplabcut.create_training_dataset(config_path, num_shuffles=1)
# In[train network]
import deeplabcut
config_path = 'Z:\ck\mouse_behavior\matlab_pose3d\dlc\Mouse2Dproject-CK-2020-04-11\config3.yaml'
deeplabcut.train_network(config_path,shuffle=1,trainingsetindex=0,gputouse=None,\
                         max_snapshots_to_keep=5, displayiters=1000,saveiters=20000,\
                         maxiters=1400000)
# In[train network]

#     # In[]
# addvideopath = 'Z:\\hanyaning\\multi_mice_test\\VIS_mice_data\\code\\MATLAB\\data\\dlc_add_data'
# config_path = 'Z:\ck\mouse_behavior\matlab_pose3d\dlc\Mouse2Dproject-CK-2020-04-11\config3.yaml'
# addvideoname = get_all_path(addvideopath)
# deeplabcut.add_new_videos(config_path, addvideoname)
