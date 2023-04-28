function slippage_measure_norm = compute_slippage(msgStructs, ...
    lim_start, lim_end)
% COMPUTE SLIPPAGE
% Compute the slippage metric from Adaptive Feet for Quadrupedal Walkers
%
% msgStructs - contains result of 
%       extract_topic_from_bag(file_path,'/state_estimator/anymal_state');

% Position of each feet
for i = 1:4
    x_feet(:,i) = cellfun(@(m) double(m.Contacts(i).Position.X),msgStructs);
    y_feet(:,i) = cellfun(@(m) double(m.Contacts(i).Position.Y),msgStructs);
    z_feet(:,i) = cellfun(@(m) double(m.Contacts(i).Position.Z),msgStructs);
    contact(:,i) = cellfun(@(m) double(m.Contacts(i).State),msgStructs);
end

% Position of body
x_body = cellfun(@(m) double(m.Pose.Pose.Position.X),msgStructs);
y_body = cellfun(@(m) double(m.Pose.Pose.Position.Y),msgStructs);
z_body = cellfun(@(m) double(m.Pose.Pose.Position.Z),msgStructs);
pos_body = [x_body,y_body,z_body];

% Distances
t = 1:length(cellfun(@(m) double(m.Contacts(1).Header.Stamp.Sec),msgStructs));
dx = diff(x_feet);
x_slip = (([dx;[0,0,0,0]] + [[0,0,0,0];dx])/2).*contact;
dy = diff(y_feet);
y_slip = (([dy;[0,0,0,0]] + [[0,0,0,0];dy])/2).*contact;
dz = diff(z_feet);
z_slip = (([dz;[0,0,0,0]] + [[0,0,0,0];dz])/2).*contact;

% Split
if ~exist('lim_end','var')
else
    t = t(1:lim_end);
    x_slip = x_slip(1:lim_end,:);
    y_slip = y_slip(1:lim_end,:);
    z_slip = z_slip(1:lim_end,:);
    contact = contact(1:lim_end,:);
    pos_body = pos_body(1:lim_end,:);
end

if ~exist('lim_start','var')
else
    t = t(lim_start:end);
    x_slip = x_slip(lim_start:end,:);
    y_slip = y_slip(lim_start:end,:);
    z_slip = z_slip(lim_start:end,:);
    contact = contact(lim_start:end,:);
    pos_body = pos_body(lim_start:end,:);
end

% Distance travelled by the body
length_path = sum(sqrt(sum(diff(pos_body).^2')));

% Slippage
% slippage_measure_squared = sum(sum(x_slip.^2 + y_slip.^2 + z_slip.^2))/length_path^2;
slippage_measure_norm = sum(sum(sqrt(x_slip.^2 + y_slip.^2 + z_slip.^2)))/length_path;
% numerator = sum(sqrt(x_slip.^2 + y_slip.^2 + z_slip.^2));
% denominator = sqrt(sum(diff(pos_body).^2'));

end
