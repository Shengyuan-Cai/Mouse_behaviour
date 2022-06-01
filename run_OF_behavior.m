%{
    ������Ƶ��������
%}
%% �������
clear all
close all
%%%����resize
framesize = [512 512];
%% ���ò���
lightfb = 120;%�������߷�������
threshold = 0.5;%��ֵ
showflag = 0;%�Ƿ���ʾͼ��
remframe = 4;%��֡��
se = strel('disk',7);%ȥ��
%% �������봦��,���Խ��
path_work = 'Z:\caishengyuan\double_op\';
skeleton_folder = [path_work,'10\freemoving-10-1day/'];
behaviour_namelist = dir([skeleton_folder,'*.avi']);
data_name =natsort({behaviour.name});
data_name =data_name';
%% ��ȡ��Ƶ
fileName = 'freemoving_10_1day_1.avi';%��Ƶ��
path_name = 'Z:\caishengyuan\double_op\10\freemoving-10-1day/';%�ļ�·��
x=[path_name,fileName];
obj = VideoReader(x);
numFrames = obj.NumFrames;% ֡������
height = obj.Height;
width = obj.Width;
Rate = obj.FrameRate;
%% ���ô洢mat�ļ���excel�ļ�����
% 
newdir = '.\data';
mkdir(newdir);
me_name = [newdir '\result_' fileName(1:end - 4)];%Ϊɶend��4,�Ȼ���Ҫ�ĸ�ʽ
%% �ֶ�ѡ�����ʱ��
starttime = 0;%��Ϊ��λ
endtime = 0;%��Ϊ��λ��0Ϊȫ����Ƶ
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
%% ������ʱ������
close all
timelist = ((0:numFrames-1)/Rate)';
%% ��һ֡������
firstframe = double(rgb2gray(read(obj,1)));%����read��1������,��ȡ��һ֡
%% ������ȡ��λ���ж�
imshow(firstframe,[]);
title('���ѡ����');
of=drawrectangle;
OFmask = of.createMask;%��������
[sizeOFmaskx,sizeOFmasky] = find(OFmask==1);%������������ͼ

a=min(sizeOFmaskx);
b = min(min(sizeOFmaskx));
OFmaskx = min(min(sizeOFmaskx)):max(max(sizeOFmaskx));%������ʵһά����
OFmasky = min(min(sizeOFmasky)):max(max(sizeOFmasky));
maskfirstframe = firstframe(OFmaskx,OFmasky);
close all
%% ����λ����ȡ
imshow(maskfirstframe,[]);
title('���ѡ����');
h=imrect;
feedbackpos=round(getPosition(h));
pad_color = mean(mean(maskfirstframe(...
    feedbackpos(2):feedbackpos(2)+feedbackpos(4),...
    feedbackpos(1):feedbackpos(1)+feedbackpos(3))));
%% ��һ֡������ȡ
close all
imshow(maskfirstframe,[]);
title('���ѡ����');
h=imrect;
firstpos=getPosition(h);%��Сx,y�ͳ���
x=round((firstpos(1)+firstpos(3)/2));  %����pos�������±�
y=round((firstpos(2)+firstpos(4)/2));    %����pos�������±�
maskfirstframe(firstpos(2):firstpos(2)+firstpos(4),...
    firstpos(1):firstpos(1)+firstpos(3)) = pad_color;%ͼ�񲹳��������Ŀ����չʾ���ĵ���
t2 = maskfirstframe/255;
showimage = insertMarker(maskfirstframe/255, [x y],'o','Size',10);%/255������
accpos = [x y];
imshow(showimage,[])
% close all
%% ��ʱ
close all
%%% ��Ƶ��������
resfirstframe = imresize(maskfirstframe,[512 512]);
%%% �������
background = zeros(size(resfirstframe));
position = zeros(numFrames,2);
% position(startframe+1,:) = [x y];
tic
%% ����
for k = startframe:endframe
    tempframe = read(obj,k);
    f = imresize(double(rgb2gray(tempframe(OFmaskx,OFmasky,:))),framesize);
    df = mat2gray(uint8(resfirstframe - f));
    bw = imbinarize(df,threshold);%��ֵ��
    %% ������ȥ�����
    bw = imopen(bw,se);
    imshow(bw,[]);
    %bw = double(~bwmorph(bw,'close'));
    %% ��ͼ������
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
        %% �ڱ����ϻ�·��
        background(position(k,2),position(k,1)) = ...
        background(position(k,2),position(k,1)) + 1;
%     accpos = (position(k,:)+accpos)/(k - startframe + 1);
    %% ��ʾͼ��
    if(showflag == 1)
        if (rem(k,remframe) == 0)
        %% ������
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
%% ��ʾ·��
subplot(111)
imshow(~background)
%% ����ͼ
recsize = 21;
filter = conv2(ones(recsize,recsize),ones(recsize,recsize));
newbackground = mat2gray(conv2(background,filter));
imagesc(newbackground);
colormap('jet');
figure(gcf);colorbar;
%% ���㱣����
%% ������
all_result = [timelist position];
part_result = all_result(startframe:endframe,:);
save([me_name '.mat'],'part_result');
%%%ˮƽ��close arm,��ֱ��open arm
xlswrite([me_name '.xlsx'],{'Time','x','y'},1); 
xlswrite([me_name '.xlsx'],part_result,1,'2'); 
disp('save successfully��');