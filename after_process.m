function event_span = after_process(data, frame_begin, tolerable_interval, min_event_last )
soilder = Soilder(tolerable_interval);
for i = 1:length(data)   
    if data(i) ==1 && soilder.die()
        soilder = soilder.reborn(i, i);
    elseif data(i) ==1 && ~soilder.die()
        soilder = soilder.fulfill();
    elseif data(i)==0 && ~soilder.die()
        soilder = soilder.fight(i) ;
    end   
end
soilder = soilder.over(length(data));
if ~isempty(soilder.past_life)
index = soilder.past_life(:,3) > (tolerable_interval + min_event_last);
event_span = soilder.past_life(index, :);
event_span(:,1) = floor(event_span(:,1) + frame_begin);
event_span(:,2) = floor(event_span(:,2) +frame_begin);
else
    event_span =[];
end
end







