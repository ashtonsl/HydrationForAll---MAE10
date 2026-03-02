% =========================================================
% waterDashboard.m
% MAE 10 Team Project - Local Drinking Water Quality Dashboard
% Grand Challenge: Providing Access to Clean Water
% =========================================================

clc; clear; close all;

%% ---- 1. IMPORT DATA ----------------------------------------
data = readtable('water_quality_CA.csv');

% EPA / CA regulatory limits
LIM_NITRATE  = 10;    % mg/L as N  (EPA MCL)
LIM_ARSENIC  = 10;    % ppb        (EPA MCL)
LIM_LEAD     = 15;    % ppb        (EPA Action Level, 90th percentile)

cities    = data.city;
utilities = data.utility;
nitrate   = data.nitrate_mgL_as_N;
arsenic   = data.arsenic_ppb;
lead      = data.lead_ppb_90th_percentile;
hardness  = data.hardness_mgL_as_CaCO3;
pH_vals   = data.pH;
n         = height(data);

%% ---- 2. USER INPUT -----------------------------------------
fprintf('\n===== California Drinking Water Quality Dashboard =====\n')
fprintf('Available cities:\n')
for i = 1:n
    fprintf('  [%d] %s\n', i, cities{i});
end

idx = input('\nEnter the number of your city: ');
while idx < 1 || idx > n || floor(idx) ~= idx
    idx = input('Invalid. Enter a number from the list: ');
end

selCity    = cities{idx};
selUtility = utilities{idx};
selNitrate = nitrate(idx);
selArsenic = arsenic(idx);
selLead    = lead(idx);
selHard    = hardness(idx);
selPH      = pH_vals(idx);

%% ---- 3. CALL USER-DEFINED FUNCTION -------------------------
contaminantVals  = [selNitrate, selArsenic, selLead];
guidelineVals    = [LIM_NITRATE, LIM_ARSENIC, LIM_LEAD];
contaminantNames = {'Nitrate (mg/L)', 'Arsenic (ppb)', 'Lead (ppb)'};

[ratingLabels, ratingScores] = qualityRating(contaminantVals, guidelineVals);

%% ---- 4. PRINT RESULTS TABLE --------------------------------
fprintf('\n--- Water Quality Report: %s ---\n', selCity);
fprintf('Utility: %s\n\n', selUtility);
fprintf('%-22s %-12s %-12s %-15s\n', ...
        'Contaminant', 'Measured', 'Guideline', 'Rating');
fprintf('%s\n', repmat('-', 1, 63));
for i = 1:3
    fprintf('%-22s %-12.2f %-12.2f %-15s\n', ...
        contaminantNames{i}, contaminantVals(i), ...
        guidelineVals(i), ratingLabels{i});
end
fprintf('\nHardness: %.0f mg/L as CaCO3\n', selHard);
fprintf('pH: %.1f\n', selPH);

%% ---- 5. COMPUTE COMPOSITE RISK SCORES (all cities) ---------
compScores = zeros(n, 1);
for i = 1:n
    compScores(i) = compositeRisk(nitrate(i), arsenic(i), lead(i), ...
                                   LIM_NITRATE, LIM_ARSENIC, LIM_LEAD);
end

%% ---- FIGURE 1: Measured vs. Guideline (selected city) ------
figure(1);
contVals_plot = [selNitrate/LIM_NITRATE, ...
                 selArsenic/LIM_ARSENIC, ...
                 selLead/LIM_LEAD] * 100;
bar(contVals_plot, 'FaceColor', [0.2 0.5 0.8]);
hold on;
yline(100, 'r--', 'LineWidth', 2, 'Label', 'EPA Guideline (100%)');
set(gca, 'XTickLabel', {'Nitrate','Arsenic','Lead'}, 'XTick', 1:3);
ylabel('% of EPA/CA Regulatory Limit');
title(['Contaminant Levels as % of Limit: ', selCity]);
ylim([0 130]);
grid on;

%% ---- FIGURE 2: Color-coded Risk Rating (selected city) -----
figure(2);
colorMap = [0.2 0.75 0.3;   % green  = OK
            1.0 0.75 0.0;   % yellow = Borderline
            0.9 0.2  0.2];  % red    = High Concern
colors = colorMap(ratingScores + 1, :);
b = bar(ratingScores, 'FaceColor', 'flat');
b.CData = colors;
set(gca, 'XTickLabel', {'Nitrate','Arsenic','Lead'}, 'XTick', 1:3);
yticks([0 1 2]);
yticklabels({'OK','Borderline','High Concern'});
ylabel('Risk Rating');
title(['Risk Rating by Contaminant: ', selCity]);
ylim([-0.5 2.5]);
grid on;

%% ---- FIGURE 3: Nitrate Levels Across All Cities ------------
figure(3);
[sorted_N, sortIdx_N] = sort(nitrate);
barh(sorted_N, 'FaceColor', [0.3 0.6 0.9]);
hold on;
xline(LIM_NITRATE, 'r--', 'LineWidth', 2, 'Label', 'EPA MCL = 10 mg/L');
set(gca, 'YTickLabel', cities(sortIdx_N), 'YTick', 1:n);
xlabel('Nitrate (mg/L as N)');
title('Nitrate Levels Across Southern California Cities');
grid on;

%% ---- FIGURE 4: Arsenic Levels Across All Cities ------------
figure(4);
[sorted_A, sortIdx_A] = sort(arsenic);
barh(sorted_A, 'FaceColor', [0.85 0.55 0.2]);
hold on;
xline(LIM_ARSENIC, 'r--', 'LineWidth', 2, 'Label', 'EPA MCL = 10 ppb');
set(gca, 'YTickLabel', cities(sortIdx_A), 'YTick', 1:n);
xlabel('Arsenic (ppb)');
title('Arsenic Levels Across Southern California Cities');
grid on;

%% ---- FIGURE 5: Composite Risk Score (all cities) -----------
figure(5);
[sorted_C, sortIdx_C] = sort(compScores, 'descend');
riskColors = [0.9 0.2 0.2;   % score 2+ = red
              1.0 0.75 0.0;  % score 1   = yellow
              0.2 0.75 0.3]; % score 0   = green
barColors = zeros(n, 3);
for i = 1:n
    if sorted_C(i) >= 2
        barColors(i,:) = riskColors(1,:);
    elseif sorted_C(i) == 1
        barColors(i,:) = riskColors(2,:);
    else
        barColors(i,:) = riskColors(3,:);
    end
end
b5 = bar(sorted_C, 'FaceColor', 'flat');
b5.CData = barColors;
set(gca, 'XTickLabel', cities(sortIdx_C), 'XTick', 1:n, ...
    'XTickLabelRotation', 30);
ylabel('Composite Risk Score (0 = Best, 6 = Worst)');
title('Overall Water Quality Risk Score by City');
yticks(0:6);
grid on;
