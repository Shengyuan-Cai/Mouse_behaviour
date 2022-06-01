
path_work = 'Z:/ck/mouse_behavior/giat/20210901/';
data_folder1 = [path_work,'results/3Dskeleton/Calibrated_3DSkeleton/'];
data_folder2 = 'Z:\caishengyuan\mouse_behaviour\label\';
data_folder_namelist1 = dir([data_folder1,'*.mat']);
data_folder_namelist2 = dir([data_folder2,'*.mat']);
data_name =natsort({data_folder_namelist1.name});
label_name = natsort({data_folder_namelist2.name});
data_name =data_name';
label_name = label_name';
fs = 30;
t = 1:27000;
walk = [2 3 17 18 19  37 39];
turnleft =  [8 31 32];
turnright = 28;
data3D_choice = [];
for i = 1:length(data_name)
    data = load([data_folder1,cell2mat(data_name(i))]);
    data3d = data.coords3d;
    datalabel = load([data_folder2,cell2mat(label_name(i))]);
    labelown = datalabel.frameLabels;  
    for  k = 1:length(labelown)
        if ismember(labelown(k),walk)
            data3D_choice = [data3D_choice,data3d(k,:)]; 
        elseif ismember(labelown(k),turnleft)
            data3D_choice = [data3D_choice,data3d(k,:)];                
        elseif ismember(labelown(k),turnright)
            data3D_choice = [data3D_choice,data3d(k,:)];
        end

            
%     speed_x = diff(data3d(:,37));
%     speed_x = abs([speed_x;speed_x(end)]);
%     speed_y = diff(data3d(:,38));
%     speed_y = abs([speed_y;speed_y(end)]);
%     speed = (speed_x.^2 + speed_y.^2).^0.5;
        figure;
        cwt(data3d(:,27),'amor',fs);
        figure;
        plot(speed);
    end
end


     





