function [terrain_inclinations] = compute_terrain_inclination(stateStructs)
%COMPUTE_TERRAIN_INCLINATION Summary of this function goes here
%   Detailed explanation goes here

contacts = cellfun(@(m) m.Contacts, stateStructs, 'UniformOutput', false);

terrain_inclinations = zeros(length(contacts), 2);

for i = 1:length(contacts)
    contact_feet = sum([contacts{i}.State] == [contacts{i}.STATECLOSED]);

    if contact_feet < 4
        terrain_inclinations(i,:) = [nan, nan];
    else
        positions = [contacts{i}.Position];
        A = [[positions.X]', [positions.Y]', ones(4, 1)];
        b = [positions.Z]';

        terrain_coeffs = A \ b;

        roll = atan(terrain_coeffs(2));
        pitch = - atan(terrain_coeffs(1));

        terrain_inclinations(i,:) = [roll, pitch];
    end
end

% Downsample
n = 1000; % Desired number of entries
x = 1:size(terrain_inclinations, 1);

nan_indices = any(isnan(terrain_inclinations), 2);

x_interp = linspace(min(x(~nan_indices)), max(x(~nan_indices)), n);
terrain_inclinations = interp1(x(~nan_indices), terrain_inclinations(~nan_indices, :), x_interp, 'linear');

end

