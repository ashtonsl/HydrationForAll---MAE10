function [labels, scores] = qualityRating(measured, guidelines)
% qualityRating - Classifies contaminant levels relative to EPA/CA guidelines
% Inputs:  measured   - vector of measured contaminant values
%          guidelines - vector of regulatory limits
% Outputs: labels     - cell array: 'OK', 'Borderline', or 'High Concern'
%          scores     - numeric risk score: 0 = OK, 1 = Borderline, 2 = High Concern

n = length(measured);
labels = cell(1, n);
scores = zeros(1, n);

for i = 1:n
    ratio = measured(i) / guidelines(i);
    if ratio <= 0.50
        labels{i} = 'OK';
        scores(i) = 0;
    elseif ratio <= 1.0
        labels{i} = 'Borderline';
        scores(i) = 1;
    else
        labels{i} = 'High Concern';
        scores(i) = 2;
    end
end
end
