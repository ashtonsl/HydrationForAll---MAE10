function score = compositeRisk(nitrate, arsenic, lead, chlorine, fluoride, pfas, ...
                                nitrate_lim, arsenic_lim, lead_lim, ...
                                chlorine_lim, fluoride_lim, pfas_lim)
% compositeRisk - Returns a 0-10 risk score for one city
% Each of 5 contaminants contributes 0 (OK), 1 (Borderline), or 2 (High Concern)

[~, s1] = qualityRating(nitrate,   nitrate_lim);
[~, s2] = qualityRating(arsenic,   arsenic_lim);
[~, s3] = qualityRating(lead,      lead_lim);
[~, s4] = qualityRating(chlorine,  chlorine_lim);
[~, s5] = qualityRating(fluoride,  fluoride_lim);
[~, s6] = qualityRating(pfas,      pfas_lim);
score = s1 + s2 + s3 + s4 + s5 + s6;
end

