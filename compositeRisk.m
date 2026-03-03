function score = compositeRisk(nitrate, arsenic, lead, ...
                                nitrate_lim, arsenic_lim, lead_lim)
% compositeRisk - Returns a single 0-6 risk score for one city
% Each contaminant contributes 0 (OK), 1 (Borderline), or 2 (High Concern)

[~, s1] = qualityRating(nitrate,  nitrate_lim);
[~, s2] = qualityRating(arsenic,  arsenic_lim);
[~, s3] = qualityRating(lead,     lead_lim);
score = s1 + s2 + s3;
end

