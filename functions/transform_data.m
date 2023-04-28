function vec_out = transform_data(vec_in, T_in_out)
% TRANSFORM DATA
%   Transform vectorial signal in new coordinates

% Compute average trasform
% s_T = length(T_in_out);
% T = T_in_out{floor(s_T/2)};

% Check if T and vec have same size
if length(vec_in) ~= length(T_in_out)
    error("Sizes do not match!");
end

% Transform
vec_out = zeros(size(vec_in));
for i = 1 : length(vec_in)
    T = T_in_out{i};
    vec_now = inv(T)*[vec_in(i,:).'; 1];
    vec_out(i,:) = vec_now(1:3).';
end

end

