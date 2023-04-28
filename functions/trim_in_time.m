function [i_start, i_end, i_mid] = trim_in_time(struct_in, res_max, t_start, ...
    t_end, t_mid)
% TRIM IN TIME 
%   Trims the structure from start to end

i_start = 1;
i_end = length(struct_in);
i_mid = floor((i_end - i_start)/2);
res_start = +Inf;
res_mid = +Inf;
res_end = +Inf;

% Find start time index
for i = 1 : length(struct_in)
    s_now = struct_in{i};
    t_now = double(s_now.Header.Stamp.Sec) + double(s_now.Header.Stamp.Nsec)*1e-9;
    if norm(t_now - t_start) < res_max
        if norm(t_now - t_start) < res_start
            i_start = i;
            res_start = norm(t_now - t_start);
        end
    end
end
% Find end time index
for i = 1 : length(struct_in)
    s_now = struct_in{i};
    t_now = double(s_now.Header.Stamp.Sec) + double(s_now.Header.Stamp.Nsec)*1e-9;
    if norm(t_now - t_end) < res_max
        if norm(t_now - t_end) < res_end
            i_end = i;
            res_end = norm(t_now - t_end);
        end
    end
end
% Find mid time index if needed
if ~exist('t_mid','var')
    i_mid = -1;
else
    for i = 1 : length(struct_in)
        s_now = struct_in{i};
        t_now = double(s_now.Header.Stamp.Sec) + double(s_now.Header.Stamp.Nsec)*1e-9;
        if norm(t_now - t_mid) < res_max
            if norm(t_now - t_mid) < res_mid
                i_mid = i;
                res_mid = norm(t_now - t_mid);
            end
        end
    end
end

end

