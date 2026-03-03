% =========================================================
% waterDashboard.m
% MAE 10 Team Project - Local Drinking Water Quality Dashboard
% Grand Challenge: Providing Access to Clean Water
% =========================================================

clc; clear; close all;

%% ---- 1. IMPORT DATA ----------------------------------------
data = readtable('dataset.csv');

% EPA / CA regulatory limits
LIM_NITRATE  = 10;    % mg/L as N     (EPA MCL)
LIM_ARSENIC  = 10;    % ppb           (EPA MCL)
LIM_LEAD     = 15;    % ppb           (EPA Action Level, 90th percentile)
LIM_CHLORINE = 4;     % ppm           (EPA MRDL)
LIM_FLUORIDE = 4;     % ppm           (EPA MCL; 0.7 ppm is recommended target)
LIM_PFAS     = 4;     % ppt           (EPA MCL, 2024)

cities    = data.city;
utilities = data.utility;
nitrate   = data.nitrate_mgL_as_N;
arsenic   = data.arsenic_ppb;
lead      = data.lead_ppb_90th_percentile;
hardness  = data.hardness_mgL_as_CaCO3;
pH_vals   = data.pH;
chlorine  = data.chlorine_ppm;
fluoride  = data.fluoride_ppm;
pfas      = data.pfas_pfos_ppt;
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
selChlor   = chlorine(idx);
selFluor   = fluoride(idx);
selPFAS    = pfas(idx);

%% ---- 3. CALL USER-DEFINED FUNCTION -------------------------
contaminantVals  = [selNitrate, selArsenic, selLead, selChlor, selFluor, selPFAS];
guidelineVals    = [LIM_NITRATE, LIM_ARSENIC, LIM_LEAD, LIM_CHLORINE, LIM_FLUORIDE, LIM_PFAS];
contaminantNames = {'Nitrate (mg/L)', 'Arsenic (ppb)', 'Lead (ppb)', ...
                    'Chlorine (ppm)', 'Fluoride (ppm)', 'PFAS/PFOS (ppt)'};

[ratingLabels, ratingScores] = qualityRating(contaminantVals, guidelineVals);

%% ---- 4. PRINT RESULTS TABLE --------------------------------
fprintf('\n--- Water Quality Report: %s ---\n', selCity);
fprintf('Utility: %s\n\n', selUtility);
fprintf('%-22s %-12s %-12s %-15s\n', 'Contaminant','Measured','Guideline','Rating');
fprintf('%s\n', repmat('-', 1, 63));
for i = 1:6
    fprintf('%-22s %-12.2f %-12.2f %-15s\n', ...
        contaminantNames{i}, contaminantVals(i), guidelineVals(i), ratingLabels{i});
end
fprintf('\nHardness: %.0f mg/L as CaCO3\n', selHard);
fprintf('pH: %.1f\n', selPH);

%% ---- 5. COMPUTE COMPOSITE RISK SCORES (all cities) ---------
compScores = zeros(n, 1);
for i = 1:n
    compScores(i) = compositeRisk(nitrate(i), arsenic(i), lead(i), ...
                                   chlorine(i), fluoride(i), pfas(i), ...
                                   LIM_NITRATE, LIM_ARSENIC, LIM_LEAD, ...
                                   LIM_CHLORINE, LIM_FLUORIDE, LIM_PFAS);
end

%% ---- FIGURE 1: All Contaminants as % of Limit (selected city) ------
figure(1);
contVals_plot = [selNitrate/LIM_NITRATE, selArsenic/LIM_ARSENIC, ...
                 selLead/LIM_LEAD, selChlor/LIM_CHLORINE, ...
                 selFluor/LIM_FLUORIDE, selPFAS/LIM_PFAS] * 100;
bar(contVals_plot, 'FaceColor', [0.2 0.5 0.8]);
hold on;
yline(100, 'r--', 'LineWidth', 2, 'Label', 'EPA Guideline (100%)');
set(gca, 'XTickLabel', {'Nitrate','Arsenic','Lead','Chlorine','Fluoride','PFAS/PFOS'}, ...
    'XTick', 1:6, 'XTickLabelRotation', 15);
ylabel('% of EPA/CA Regulatory Limit');
title(['Contaminant Levels as % of Limit: ', selCity]);
ylim([0 130]);
grid on;

%% ---- FIGURE 2: Lead Levels Across All Cities ---------------
figure(2);
[sorted_L, sortIdx_L] = sort(lead);
barh(sorted_L, 'FaceColor', [0.6 0.2 0.8]);
hold on;
xline(LIM_LEAD, 'r--', 'LineWidth', 2, 'Label', 'EPA Action Level = 15 ppb');
set(gca, 'YTickLabel', cities(sortIdx_L), 'YTick', 1:n);
xlabel('Lead (ppb, 90th Percentile)');
title('Lead Levels Across Southern California Cities');
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

%% ---- FIGURE 4: PFAS/PFOS Levels Across All Cities ----------
figure(4);
[sorted_P, sortIdx_P] = sort(pfas);
barh(sorted_P, 'FaceColor', [0.85 0.35 0.35]);
hold on;
xline(LIM_PFAS, 'r--', 'LineWidth', 2, 'Label', 'EPA MCL = 4 ppt');
set(gca, 'YTickLabel', cities(sortIdx_P), 'YTick', 1:n);
xlabel('PFAS/PFOS (ppt)');
title('PFAS/PFOS Levels Across Southern California Cities');
grid on;

%% ---- FIGURE 5: Composite Risk Score (all cities) -----------
figure(5);
[sorted_C, sortIdx_C] = sort(compScores, 'descend');
riskColors = [0.9 0.2 0.2;   % score >= 4 = red
              1.0 0.75 0.0;  % score 2-3  = yellow
              0.2 0.75 0.3]; % score 0-1  = green
barColors = zeros(n, 3);
for i = 1:n
    if sorted_C(i) >= 4
        barColors(i,:) = riskColors(1,:);
    elseif sorted_C(i) >= 2
        barColors(i,:) = riskColors(2,:);
    else
        barColors(i,:) = riskColors(3,:);
    end
end
b5 = bar(sorted_C, 'FaceColor', 'flat');
b5.CData = barColors;
set(gca, 'XTickLabel', cities(sortIdx_C), 'XTick', 1:n, ...
    'XTickLabelRotation', 30);
ylabel('Composite Risk Score (0 = Best, 10 = Worst)');
title('Overall Water Quality Risk Score by City');
yticks(0:10);
grid on;
