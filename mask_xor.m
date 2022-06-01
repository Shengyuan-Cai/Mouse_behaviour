%{
    mask异或计算连续性，异或只能处理没跟丢的帧
%}
clear all
close all
%% mask xor
% 读取对应视频和mask
videopath = 'Z:\hanyaning\multi_mice_test\yolact\data\cocomice_1000\test_videos';
maskpath = 'Z:\hanyaning\multi_mice_test\yolact\data\cocomice_1000\result_videos\mask_cmp_20210626';
savepath = 'Z:\hanyaning\multi_mice_test\yolact\data\cocomice_1000\mask_videos\xor_label';
semipath = 'Z:\hanyaning\multi_mice_test\yolact\data\semi_cocomice_1000';
videoname = 'seg-1-mouse-day1-camera-1.avi';
maskname = 'mask_seg-1-mouse-day1-camera-1-20210626-filtered-label.avi';
savemaskname = [maskname(1,1:(end-4)),'-xor.avi'];
savevideoname = [videoname(1,1:(end-4)),'-xor.avi'];
vidobj = VideoReader([videopath,'\',videoname]);
maskobj = VideoReader([maskpath,'\',maskname]);
% writemaskobj = VideoWriter([savepath,'\',savemaskname]);
% writevidobj = VideoWriter([savepath,'\',savevideoname]);
% writemaskobj.FrameRate = maskobj.FrameRate;
% writevidobj.FrameRate = vidobj.FrameRate;
%% 双向异或判断离群帧
tic
forward_start_ref_frame = double(read(maskobj,1));
cmap = cbrewer2('Dark2',2);
forward_dist_swap_list = zeros(maskobj.NumFrames+1,3);
% open(writemaskobj)
% open(writevidobj)
for k = 1:maskobj.NumFrames
     %% 读取帧
    forward_mask = double(read(maskobj,k));
    %% 按位置计算连续性，前向
    logic_mask1 = forward_mask==1;
    logic_mask2 = forward_mask==2;
    logic_start_ref_frame1 = forward_start_ref_frame==1;
    logic_start_ref_frame2 = forward_start_ref_frame==2;
    dist_raw = sum(xor(logic_mask1,logic_start_ref_frame1)+...
        xor(logic_mask2,logic_start_ref_frame2),'all');
    dist_swap = sum(xor(logic_mask1,logic_start_ref_frame2)+...
        xor(logic_mask2,logic_start_ref_frame1),'all');
    if dist_raw>dist_swap
        forward_savemask = logic_mask1*2+logic_mask2;
        swap_index = 1;
    else
        forward_savemask = forward_mask;
        swap_index = 0;
    end
    forward_dist_swap_list(k,:) = [dist_raw,dist_swap,swap_index];
    %% 循环参考帧
    forward_start_ref_frame = forward_savemask;
%     overmaskframe = labeloverlay(read(vidobj,k),savemask,'Colormap',cmap);
    %% 保存视频
%     writeVideo(writemaskobj,uint8(savemask));
%     pause(0.01)
%     writeVideo(writevidobj,overmaskframe);
%     pause(0.01)
    if rem(k,200) == 0
        toc
        disp(k)
    end
    %% 临时显示
%     subplot(221)
%     imagesc(backward_mask)
%     title(k)
%     subplot(222)
%     imagesc(backward_savemask)
%     title([num2str(swap_index),'|distraw:',num2str(dist_raw),'|distswap:',num2str(dist_swap)])
%     subplot(223)
%     imshow(read(vidobj,maskobj.NumFrames-k+1),[])
%     subplot(224)
%     imshow(labeloverlay(read(vidobj,maskobj.NumFrames-k+1),backward_savemask,'Colormap',cmap),[])
%     pause
end
% 读取结束赋值
forward_mask = double(read(maskobj,maskobj.NumFrames));
logic_mask1 = forward_mask==1;
logic_mask2 = forward_mask==2;
logic_start_ref_frame1 = forward_start_ref_frame==1;
logic_start_ref_frame2 = forward_start_ref_frame==2;
dist_raw = sum(xor(logic_mask1,logic_start_ref_frame1)+...
    xor(logic_mask2,logic_start_ref_frame2),'all');
dist_swap = sum(xor(logic_mask1,logic_start_ref_frame2)+...
    xor(logic_mask2,logic_start_ref_frame1),'all');
if dist_raw>dist_swap
    forward_savemask = logic_mask1*2+logic_mask2;
    swap_index = 1;
else
    forward_savemask = forward_mask;
    swap_index = 0;
end
forward_dist_swap_list(maskobj.NumFrames+1,:) = [dist_raw,dist_swap,swap_index];
% close(writemaskobj)
% close(writevidobj)
%% 图像特征表征
all_dist_swap_list = [forward_dist_swap_list(1:(end-1),1:2),forward_dist_swap_list(2:end,1:2)];
%% 可视化距离列表
all_cmaplist_swap = zeros(size(all_dist_swap_list,1),3);
for k = 1:size(all_cmaplist_swap,1)
    all_cmaplist_swap(k,:) = cmap(forward_dist_swap_list(k,3)+1,:);
%     line(all_dist_swap_list(k,[1,3]),all_dist_swap_list(k,[2,4]),'Color',all_cmaplist_swap(k,:))
end
scatter(all_dist_swap_list(:,1),all_dist_swap_list(:,2),...
    5*ones(size(all_dist_swap_list,1),1),all_cmaplist_swap,'filled');
axis square
%% 聚成2类判断噪声帧
% cmap_k = cbrewer2('Dark2',2);
% f_num = 100;
% k_num = 2;
% [~,forward_fmap,forward_IDX] = distance_clustering(all_dist_swap_list(:,1:2),f_num,k_num);
% % [~,backward_fmap,backward_IDX] = distance_clustering(all_dist_swap_list(:,3:4),f_num,k_num);
% forward_cmaplist_k = zeros(size(all_dist_swap_list,1),3);
% backward_cmaplist_k = zeros(size(all_dist_swap_list,1),3);
% for k = 1:size(forward_cmaplist_k,1)
%     forward_cmaplist_k(k,:) = cmap_k(forward_IDX(k),:);
% %     backward_cmaplist_k(k,:) = cmap_k(backward_IDX(k),:);
% end
% % subplot(121)
% gscatter(all_dist_swap_list(:,1),all_dist_swap_list(:,2),forward_IDX);
% axis square
% scatter(all_dist_swap_list(:,1),all_dist_swap_list(:,2),[],forward_cmaplist_k);
% subplot(122)
% gscatter(all_dist_swap_list(:,1),all_dist_swap_list(:,2),backward_IDX);
% scatter(all_dist_swap_list(:,3),all_dist_swap_list(:,4),[],backward_cmaplist_k);
% %% kmeans比较
% forward_IDX = kmeans(forward_dist_swap_list(:,1:2),k_num);
% forward_cmaplist_k = zeros(size(forward_dist_swap_list,1),3);
% for k = 1:size(forward_cmaplist_k,1)
%     forward_cmaplist_k(k,:) = cmap_k(forward_IDX(k),:);
% end
% scatter(forward_dist_swap_list(:,1),forward_dist_swap_list(:,2),[],forward_cmaplist_k);
%% 直接阈值判断噪声帧
IDX = zeros(size(all_dist_swap_list,1),1);
for k = 1:size(IDX,1)
    if (all_dist_swap_list(k,1)<1500&all_dist_swap_list(k,2)>1500) | ...
           (all_dist_swap_list(k,2)<1500&all_dist_swap_list(k,1)>1500) 
        IDX(k,1) = 2;%噪声
    else
        IDX(k,1) = 1;%非噪声
    end
end
gscatter(all_dist_swap_list(:,1),all_dist_swap_list(:,2),IDX);
axis square
title(['噪声帧比例：',num2str(sum(IDX==1)/length(IDX))])
%% 转换coco数据集
%% 构建all_data_sample_cell，标记每一帧
categories.supercategory = 'mouse';
categories.name = 'mouse-1';
all_data_sample_cell = {'images-height','images-width','images-id','images-file_name',...
    'categories-supercategory','categories-id','categories-name',...
    'annotations-segmentation','annotations-iscrowd','annotations-image_id',....
    'annotations-bbox','annotations-area','annotations-category_id','annotations-id','is_good'};
single_data_sample_cell = cell(size(all_data_sample_cell));
a_id = 1;
is_good_list = forward_IDX;
is_good_list(forward_IDX==2) = 0;
tic
for k = 1:vidobj.NumFrames
    %% 计算annotations-segmentation
    maskframe = read(maskobj,k);
    unique_label = unique(maskframe);
    unique_label(unique_label==0) = [];
    for m = 1:length(unique_label)
        %%
        single_data_sample_cell{m,1} = vidobj.Height;
        single_data_sample_cell{m,2} = vidobj.Width;
        single_data_sample_cell{m,3} = k;
        single_data_sample_cell{m,4} = [num2str(k),'.jpg'];

        single_data_sample_cell{m,5} = categories.supercategory;
        single_data_sample_cell{m,6} = 1;
        single_data_sample_cell{m,7} = categories.name;
        
        %%
        tempmask = maskframe == unique_label(m);
        tempedge = edge(tempmask,'canny');
        [tempx,tempy] = find(tempedge==1);
        tempxy = [tempx;tempy];
        tempxy(1:2:end) = tempy;
        tempxy(2:2:end) = tempx;
        %% 边缘排序
        sortxy  = scatter2linepoint(tempxy);
        %%
        single_data_sample_cell{m,8} = sortxy;
        single_data_sample_cell{m,9} = 0;
        single_data_sample_cell{m,10} = k;
        
        stats = regionprops(tempmask,'BoundingBox','Area');
        single_data_sample_cell{m,11} = stats.BoundingBox;
        single_data_sample_cell{m,12} = stats.Area;
        single_data_sample_cell{m,13} = 1;
        single_data_sample_cell{m,14} = a_id;
        a_id = a_id+1;
        single_data_sample_cell{m,15} = is_good_list(k);
    end
    
    %% 合并
    all_data_sample_cell = [all_data_sample_cell;single_data_sample_cell];
    %% 进度控制
    if rem(k,200) == 0
        disp(k)
        toc
    end
end
% %% 边缘降采样，不能降
% subs_all_data_sample_cell = all_data_sample_cell;
% subs_points = 50;%保留几个点
% for k = 2:size(subs_all_data_sample_cell,1)
%     %%
%     tempx = all_data_sample_cell{k,8}(1:2:end);
%     tempy = all_data_sample_cell{k,8}(2:2:end);
%     %%
%     subs_inter = ceil(length(tempx)/subs_points);
%     %%
%     subsx = tempx(1:subs_inter:end);
%     subsy = tempy(1:subs_inter:end);
%     subsxy = [subsx;subsy];
%     subsxy(1:2:end) = subsx;
%     subsxy(2:2:end) = subsy;
%     %% 赋值
%     subs_all_data_sample_cell{k,8} = subsxy;
% end
%% 选择好帧train
sel_data_sample_cell = all_data_sample_cell;
sel_data_sample_cell([1;cell2mat(all_data_sample_cell(2:end,15))]==0,:) = [];
%% 导出图像train
trainimgpath = [semipath,'\images\train'];
valimgpath = [semipath,'\images\val'];
annopath = [semipath,'\annotations'];
mkdir(trainimgpath);
mkdir(valimgpath);
mkdir(annopath);
[unique_id,I_unique_id] = unique([sel_data_sample_cell{2:end,3}]);
% tic
for k = 1:size(unique_id,2)
    frame = read(vidobj,sel_data_sample_cell{1+I_unique_id(k),3});
    imwrite(frame,[trainimgpath,'\',sel_data_sample_cell{1+I_unique_id(k),4}]);
%     imwrite(frame,[valimgpath,'\',sel_data_sample_cell{1+I_unique_id(k),4}]);
    %% 进度控制
    if rem(k,200) == 0
        disp(k)
        toc
    end
end
%% 写入json文件train
fid = fopen([annopath,'\instance_train.json'], 'w+');
fprintf(fid,'%s\r\n','{');
% images
fprintf(fid,'%s\r\n','    "images": [');
for k = 1:size(I_unique_id,1)
    %%
    fprintf(fid,'%s\r\n','        {');
    fprintf(fid,'%s\r\n',['            "height": ',num2str(sel_data_sample_cell{1+I_unique_id(k),1}),',']);
    fprintf(fid,'%s\r\n',['            "width": ',num2str(sel_data_sample_cell{1+I_unique_id(k),2}),',']);
    fprintf(fid,'%s\r\n',['            "id": ',num2str(sel_data_sample_cell{1+I_unique_id(k),3}),',']);
    fprintf(fid,'%s\r\n',['            "file_name": "',num2str(sel_data_sample_cell{1+I_unique_id(k),4}),'"']);
    if k < size(I_unique_id,1)
        fprintf(fid,'%s\r\n','        },');
    else
        fprintf(fid,'%s\r\n','        }');
    end
end
fprintf(fid,'%s\r\n','    ],');
% categories
fprintf(fid,'%s\r\n','    "categories": [');
fprintf(fid,'%s\r\n','        {');
fprintf(fid,'%s\r\n',['            "supercategory": "',categories.supercategory,'",']);
fprintf(fid,'%s\r\n','            "id": 1,');
fprintf(fid,'%s\r\n',['            "name": "',categories.name,'"']);
fprintf(fid,'%s\r\n','        }');
fprintf(fid,'%s\r\n','    ],');
% annotations
tic
fprintf(fid,'%s\r\n','    "annotations": [');
for k = 2:size(sel_data_sample_cell,1)
    %%
    fprintf(fid,'%s\r\n','        {');
    fprintf(fid,'%s\r\n','            "segmentation": [');
    fprintf(fid,'%s\r\n','                [');
    tempseg = sel_data_sample_cell{k,8};
    for m = 1:size(tempseg,1)
        if m < size(tempseg,1)
            fprintf(fid,'%s\r\n',['                    ',num2str(tempseg(m)),',']);
        else
            fprintf(fid,'%s\r\n',['                    ',num2str(tempseg(m))]);
        end
    end
    fprintf(fid,'%s\r\n','                ]');
    fprintf(fid,'%s\r\n','            ],');
    fprintf(fid,'%s\r\n',['            "iscrowd": ',num2str(sel_data_sample_cell{k,9}),',']);
    fprintf(fid,'%s\r\n',['            "image_id": ',num2str(sel_data_sample_cell{k,10}),',']);
    %% box
    fprintf(fid,'%s\r\n','            "bbox": [');
    tempbbox = sel_data_sample_cell{k,11};
    for m = 1:length(tempbbox)
        if m < length(tempbbox)
            fprintf(fid,'%s\r\n',['                    ',num2str(tempbbox(m)),',']);
        else
            fprintf(fid,'%s\r\n',['                    ',num2str(tempbbox(m))]);
        end
    end
    fprintf(fid,'%s\r\n','            ],');
    fprintf(fid,'%s\r\n',['            "area": ',num2str(sel_data_sample_cell{k,12}),',']);
    fprintf(fid,'%s\r\n',['            "category_id": ',num2str(sel_data_sample_cell{k,13}),',']);
    fprintf(fid,'%s\r\n',['            "id": ',num2str(sel_data_sample_cell{k,14})]);
    %%
    if k < size(sel_data_sample_cell,1)
        fprintf(fid,'%s\r\n','        },');
    else
        fprintf(fid,'%s\r\n','        }');
    end
    %% 进度控制
    if rem(k,200) == 0
        disp(k)
        toc
    end
end
% 结尾
fprintf(fid,'%s\r\n','    ]');
fprintf(fid,'%s\r\n','}');
fclose(fid);























