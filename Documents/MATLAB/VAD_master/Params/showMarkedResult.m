function [] = showMarkedResult(start_f, end_f, total_f)
%start_f: starting point in frames. total_f: len of X_AXIS
%note: end_f:the very frame after the specified area
t_start = [0.966 2.331 6.126 9.644  14.531 17.342 20.768 24.495 28.764 33.874 38.167 45.536 48.659 53.003];
t_end =   [2.003 4.667 8.013 13.071 15.892 19.335 23.226 27.288 32.444 36.729 44.078 48.297 51.558 55.538];
t_total = 56.321;

start_time = start_f / total_f * t_total;
end_time = end_f / total_f * t_total;

for i = t_start
    if i >= start_time & i < end_time
        frame_pos = (i - start_time) / (end_time - start_time) * (end_f - start_f) + start_f;
        plot([frame_pos frame_pos],[-50 50],'g');
    end
end

for i = t_end
    if i >= start_time & i < end_time
        frame_pos = (i - start_time) / (end_time - start_time) * (end_f - start_f) + start_f;
        plot([frame_pos frame_pos],[-50 50],'r');
    end
end