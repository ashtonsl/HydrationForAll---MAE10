function [labels, scores] = qualityRating(measured, guidelines)
% qualityRating - Classifies contaminant levels relative to EPA/CA guidelines
% 2 Inputs:  measured   - vector of measured contaminant values
%            guidelines - vector of regulatory limits
% 2 Outputs: labels     - cell array: 'OK', 'Borderline', or 'High Concern'
%            scores     - numeric risk score: 0 = OK, 1 = Borderline, 2 = High Concern

n = length(measured);
labels = cell(1, n);
scores = zeros(1, n);

for i = 1:n
    ratio = measured(i) / guidelines(i);
    if ratio <= 0.50   % if ratio less or equal to o.5
        labels{i} = 'OK'; % OK would output
        scores(i) = 0;  % 0 would output as the score
    elseif ratio <= 1.0 % if ratio less than or equal to 1
        labels{i} = 'Borderline'; % Borderline would output
        scores(i) = 1;  % 1 would output as the score
    else                % anything else
        labels{i} = 'High Concern'; % High Concern would output
        scores(i) = 2;  % 2 would output as the score
    end                 % if statement
end                     % for loop
end                     % function
