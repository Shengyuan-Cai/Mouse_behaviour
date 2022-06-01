%{
    旷场视频分析代码
%}
%% 清除变量
clear all
close all
%%%定义resize
framesize = [512 512];
%% 设置参数
lightfb = 120;%补偿光线反馈变量
threshold = 0.5;%阈值
showflag = 0;%是否显示图像
remframe = 4;%抽帧数
se = strel('disk',7);%去噪
%% 批量导入处理,可以借鉴
path_work = 'Z:\caishengyuan\double_op\';
skeleton_folder = [path_work,'10\freemoving-10-1day/'];
behaviour_namelist = dir([skeleton_folder,'*.avi']);
data_name =natsort({behaviour.name});
data_name =data_name';
%% 读取视频
fileName = 'freemoving_10_1day_1.avi';%视频名
path_name = 'Z:\caishengyuan\double_op\10\freemoving-10-1day/';%文件路径
x=[path_name,fileName];
obj = VideoReader(x);
numFrames = obj.NumFrames;% 帧的总数
height = obj.Height;
width = obj.Width;
Rate = obj.FrameRate;
%% 设置存储mat文件和excel文件名字
% 
newdir = '.\data';
mkdir(newdir);
me_name = [newdir '\result_' fileName(1:end - 4)];%为啥end减4,等会需要改格式
%% 手动选择分析时间
starttime = 0;%秒为单位
endtime = 0;%秒为单位，0为全部视频
if(endtime == 0)
    startframe = 2;
else
    startframe = floor(Rate*starttime);
end
if(endtime == 0)
    endframe = numFrames;
else
    endframe = floor(Rate*endtime);
end
%% 计算打标时间序列
close all
timelist = ((0:numFrames-1)/Rate)';
%% 第一帧当背景
firstframe = double(rgb2gray(read(obj,1)));%这里read的1的作用,读取第一帧
%% 旷场提取，位置判断
imshow(firstframe,[]);
title('请框选旷场');
of=drawrectangle;
OFmask = of.createMask;%创建遮罩
[sizeOFmaskx,sizeOFmasky] = find(OFmask==1);%布尔变量，抠图

a=min(sizeOFmaskx);
b = min(min(sizeOFmaskx));
OFmaskx = min(min(sizeOFmaskx)):max(max(sizeOFmaskx));%这里其实一维就行
OFmasky = min(min(sizeOFmasky)):max(max(sizeOFmasky));
maskfirstframe = firstframe(OFmaskx,OFmasky);
close all
%% 补偿位置提取
imshow(maskfirstframe,[]);
title('请框选背景');
h=imrect;
feedbackpos=round(getPosition(h));
pad_color = mean(mean(maskfirstframe(...
    feedbackpos(2):feedbackpos(2)+feedbackpos(4),...
    feedbackpos(1):feedbackpos(1)+feedbackpos(3))));
%% 第一帧老鼠提取
close all
imshow(maskfirstframe,[]);
title('请框选老鼠');
h=imrect;
firstpos=getPosition(h);%最小x,y和长宽
x=round((firstpos(1)+firstpos(3)/2));  %根据pos计算行下标
y=round((firstpos(2)+firstpos(4)/2));    %根据pos计算列下标
maskfirstframe(firstpos(2):firstpos(2)+firstpos(4),...
    firstpos(1):firstpos(1)+firstpos(3)) = pad_color;%图像补偿，这里的目的是展示中心点吗
t2 = maskfirstframe/255;
showimage = insertMarker(maskfirstframe/255, [x y],'o','Size',10);%/255的意义
accpos = [x y];
imshow(showimage,[])
% close all
%% 计时
close all
%%% 视频分析参数
resfirstframe = imresize(maskfirstframe,[512 512]);
%%% 定义变量
background = zeros(size(resfirstframe));
position = zeros(numFrames,2);
% position(startframe+1,:) = [x y];
tic
%% 计算
for k = startframe:endframe
    tempframe = read(obj,k);
    f = imresize(double(rgb2gray(tempframe(OFmaskx,OFmasky,:))),framesize);
    df = mat2gray(uint8(resfirstframe - f));
    bw = imbinarize(df,threshold);%二值化
    %% 开运算去除噪点
    bw = imopen(bw,se);
    imshow(bw,[]);
    %bw = double(~bwmorph(bw,'close'));
    %% 求图像质心
    outstats = regionprops(bw,'Centroid');
    if size(outstats,1)  == 1
        position(k,:) = round(outstats.Centroid);
    elseif size(outstats,1) > 1
        mindistance = sum((outstats(1,1).Centroid - position(k-1,:)).^2);
        savei = 1;
        for i = 2:size(outstats,1)
            distance = sum((outstats(i,1).Centroid - position(k-1,:)).^2);
            if distance < mindistance
                mindistance = distance;
                savei = i;
            end
        end
        position(k,:) = round(outstats(savei,1).Centroid);
    else
        position(k,:) = position(k-1,:);
        %disp('read defeat');
    end
    if(position(k,:)==[0 0])
        position(k,:) = [x y];
    end
        %% 在背景上画路径
        background(position(k,2),position(k,1)) = ...
        background(position(k,2),position(k,1)) + 1;
%     accpos = (position(k,:)+accpos)/(k - startframe + 1);
    %% 显示图像
    if(showflag == 1)
        if (rem(k,remframe) == 0)
        %% 插入标记
        showimage = insertMarker(f/255, position(k,:) ,'o','Size',20);
        subplot(221)
        imshow(showimage,[])
        subplot(222)
        imshow(background,[])
        subplot(223)
        imshow(bw,[]);
        subplot(224)
        imshow(df,[]);
        pause(0.001)
        end
%         disp(k)
%         disp(position(k,:))
    end
if(rem(k,100)==0)
    disp(k)
    toc
end
end
toc
close all
%% 显示路径
subplot(111)
imshow(~background)
%% 画热图
recsize = 21;
filter = conv2(ones(recsize,recsize),ones(recsize,recsize));
newbackground = mat2gray(conv2(background,filter));
imagesc(newbackground);
colormap('jet');
figure(gcf);colorbar;
%% 计算保存结果
%% 保存结果
all_result = [timelist position];
part_result = all_result(startframe:endframe,:);
save([me_name '.mat'],'part_result');
%%%水平是close arm,竖直是open arm
xlswrite([me_name '.xlsx'],{'Time','x','y'},1); 
xlswrite([me_name '.xlsx'],part_result,1,'2'); 
disp('save successfully！');