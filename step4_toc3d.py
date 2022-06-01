# -*- coding: utf-8 -*-
"""
Created on Thu Jul 15 13:46:44 2021

@author: kangh
"""


import numpy as np
import pandas as pd
import scipy.io as scio
import glob
import os

import ezc3d


working_path = "Z:\\hanyaning\\multi_mice_test\\VIS_mice_data\\code\\Python\data\\"

csv3d_files = glob.glob(working_path + "valid.csv")
# csv3d_files = glob.glob(working_path + "rec-2-model-20210820143441_Cali_Data3d.csv")
n_csv3d_files = len(csv3d_files)
# cfg = scio.loadmat(working_path + "results/3Dskeleton/config.mat")
FPS = 30

for i in range(n_csv3d_files):
    
    c3d = ezc3d.c3d()
    data_raw = pd.read_csv(csv3d_files[i])
    data = data_raw.iloc[1:, :]

    n_frame = data.shape[0]
    n_feature = int((data.shape[1])/3)
    body_parts = data.iloc[:, 0:]
    body_parts = body_parts.to_numpy()
    body_parts = body_parts.astype(np.float)
    coord = np.zeros((4, n_feature, n_frame))
    
    for j in range(n_feature):
        coord[0, j, :] = body_parts[:, j*3]
        coord[1, j, :] = body_parts[:, j*3+1]
        coord[2, j, :] = body_parts[:, j*3+2] 
        coord[3, j, :] = n_feature*np.ones(n_frame)


    # Fill it 
    c3d['parameters']['POINT']['RATE']['value'] = [FPS]
    c3d['parameters']['POINT']['RATE']['SCALE'] = [FPS]
    c3d['parameters']['POINT']['LABELS']['value'] = tuple(data.columns[0:-1:3])
    c3d['data']['points'] = coord
    
    # c3d['parameters']['ANALOG']['RATE']['value'] = [30]
    # c3d['parameters']['ANALOG']['LABELS']['value'] = ('analog1', 'analog2', 'analog3', 'analog4', 'analog5', 'analog6')
    # c3d['data']['analogs'] = np.random.rand(1, 6, 30)
    # c3d['data']['analogs'][0, 0, :] = 4
    # c3d['data']['analogs'][0, 1, :] = 5
    # c3d['data']['analogs'][0, 2, :] = 6
    # c3d['data']['analogs'][0, 3, :] = 7
    # c3d['data']['analogs'][0, 4, :] = 8
    # c3d['data']['analogs'][0, 5, :] = 9
    
    # Add a custom parameter to the POINT group
    c3d.add_parameter("POINT", "newParam", [1, 2, 3])
    
    # Add a custom parameter a new group
    c3d.add_parameter("NewGroup", "newParam", ["MyParam1", "MyParam2"])
    
    # Write the data
    print('正在生成：', os.path.splitext(csv3d_files[i])[0] + ".c3d")
    c3d.write(os.path.splitext(csv3d_files[i])[0] + ".c3d")
    

    
    
    
    
    
