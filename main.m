close all;
analysis = true;
samp_hz =100;
video_id = 'TEMP3_1';
% run_yolo = 'LightNet tri test  model/yolo.data  model/yolo.cfg  model/yolo.weights';
% system(run_yolo);
input_path = sprintf('./%s/yolo_Temp3_1.txt',video_id );%'D:\Develop\Scholar\Data\TRI\118\synced_118_07182017_Roadway_01.txt';
true_path = sprintf('./%s/synced_ID001_TEMP3_Roadway_20171221-211645_1_label_result.xls',video_id );
out_path = './TEMP3_1/1.txt';
fid = fopen(input_path, 'r');
raw=[];
%load data
stop_raw = [];
light_raw = [];
while ~feof(fid)
    tline = fgetl(fid);
    item = split(tline, ' ');
    frame_index = str2double(item{1});
    object = item{2};
    x = str2double(item{3});
    y = str2double(item{3});
    w = str2double(item{3});
    h = str2double(item{3});
    s = str2double(item{3});
    line_data = [frame_index, x,y,w,h,s]; 
    if strcmp(object,'traffic_light') 
        light_raw = [light_raw; line_data];
    elseif strcmp(object,'step_sign')  
        stop_raw = [stop_raw; line_data];    
    end
end
fclose(fid);





%frame information
frame_begin = raw(1,1);
frame_end = raw(length(raw),1);
time_begin = raw(1,2);
%search 
fps = 29.97;
time_interval = 1;
frame_interval = time_interval * fps;
min_interval = 5*fps;
traffic_event = after_process(raw(:,3), frame_begin, frame_interval, min_interval );
stop_event = after_process(raw(:,4), frame_begin, frame_interval, min_interval );
write_event(out_path, stop_event,traffic_event,fps,samp_hz );
%load the true event
true_event = xlsread(true_path, 1);
%true_event = true_event(:, [1,2,5,6,7]);
eventTime = num2cell(true_event(:,[1 2]));
true_event(: ,[1 2]) = cell2mat(cellfun(@(x) getFrameNumfromVideo(datestr(x,'MM:SS.FFF'),fps), ...
    eventTime,'UniformOutput',0));
max_show_frame = max(true_event(length(true_event), 2), frame_end);
show_data =zeros(max_show_frame, 6);
%stop sign 5
for i = 1:length(true_event)
    if true_event(i,5)==1
    show_data(true_event(i,1):true_event(i,2),1) = 3;
    end
    if true_event(i,7)==1
    show_data(true_event(i,1):true_event(i,2),2) = 3;
    end
end
stop_total =  sum(show_data(:,1)>0);
light_total =  sum(show_data(:,2)>0);
for i = 1:size(stop_event,1)
    show_data(stop_event(i,1):stop_event(i,2),3) = 2;
end
for i = 1:size(traffic_event,1)
    show_data(traffic_event(i,1):traffic_event(i,2),4) = 2;
end

for i = 1:length(raw)
     if raw(i,4)==1
    show_data(raw(i,1),5) = 1;
    end
    if raw(i,3)==1
    show_data(raw(i,1),6) = 1;
    end
end
stop_final_proposal =  sum(show_data(:,3)>0);

stop_propal =  sum(show_data(:,5)>0);
stop_final_proposal =  sum(show_data(:,3)>0);
light_propal =  sum(show_data(:,6)>0);
light_final_proposal =  sum(show_data(:,4)>0);

stop_correct =  sum(show_data(:,5)&show_data(:,1));
stop_final_correct =  sum(show_data(:,3)&show_data(:,1));
light_correct =  sum(show_data(:,6)&show_data(:,2));
light_final_correct =  sum(show_data(:,4)&show_data(:,2));

if analysis
stop_sign_raw_data = figure('Name',' stop comparison');
axis([0 max_show_frame 0 4]);
hold on
plot( [1:max_show_frame ],show_data(:,1),'o-r','LineWidth',1); %true
plot([1:max_show_frame],show_data(:,3),'o-g','LineWidth',1); %processed
plot([1:max_show_frame],show_data(:,5),'o-b','LineWidth',1); %ori

stop_sign_raw_data = figure('Name',' traffic comparison');
axis([0 max_show_frame 0 4]);
hold on
plot( [1:max_show_frame ],show_data(:,2),'o-r','LineWidth',1); %true
plot([1:max_show_frame],show_data(:,4),'o-g','LineWidth',1); %processed
plot([1:max_show_frame],show_data(:,6),'o-b','LineWidth',1);
end

stop_recall = 100 * stop_correct / stop_total

stop_precision = 100 * stop_correct / stop_propal

light_recall = 100 * light_correct / light_total

light_precision = 100 * light_correct / light_propal

stop_F1 = 2*(stop_recall* stop_precision)/(stop_recall+ stop_precision)

light_F1 = 2*(light_recall* light_precision)/(light_recall+ light_precision)

stop_final_recall = 100 * stop_final_correct / stop_total

light_final_recall = 100 * light_final_correct / light_total

stop_final_precision = 100 * stop_final_correct / stop_propal

light_final_precision = 100 * light_final_correct / light_propal

 function write_event(out_path, stop_event,traffic_event,fps, samp_hz)
fid = fopen(out_path,'w+');
if ~fid
   printf('can not open outputfile'); 
end
for i = 1:size(stop_event,1)
    [b_m, b_s, b_ms] = get_time_from_frame(stop_event(i,1), fps, samp_hz);
    [e_m, e_s, e_ms]  = get_time_from_frame(stop_event(i,2), fps, samp_hz);
    fprintf(fid,'%d:%d.%d,%d:%d.%d,%d,0 \n',b_m, b_s, b_ms,e_m, e_s, e_ms,1 );
end
for i = 1:size(traffic_event,1)
    [b_m, b_s, b_ms] = get_time_from_frame(traffic_event(i,1), fps, samp_hz);
    [e_m, e_s, e_ms]  = get_time_from_frame(traffic_event(i,2), fps, samp_hz);
    fprintf(fid,'%d:%d.%d,%d:%d.%d,0,%d \n',b_m, b_s, b_ms,e_m, e_s, e_ms,1 );
end
fclose(fid)
end

 function [t_m, t_s,t_ms] = get_time_from_frame(frame,fps,hz)
    t_b = hz * frame / fps;
    t_m = floor(t_b / (60*hz));
    t_s = floor((t_b - t_m * 60*hz)/hz);
    t_ms = floor(t_b - t_m * 60*hz - t_s * hz);
 end




function frameNum = getFrameNumfromVideo(time,frameRate)
% frameNum = getFrameNumfromVideo(frameRate,time)
% time is a string: ex. 02:05.73
% frame rate typical fps = 29.97~30;
%%
if size(time,1)>1
    error('input dimension not support');
end

if nargin == 1
    frameRate = 29.97;
end
thisMin = str2double(time(1:2));
thisSec = str2double(time(4:5));
try
    this10ms =  str2double(time(7:8));
    totalSec =  thisMin*60+ thisSec + 0.01*this10ms;
catch
    this100ms =  str2double(time(:,7));
    totalSec =  thisMin*60+ thisSec + 0.1*this100ms;
end

frameNum = round(totalSec.*frameRate);
end
