# Hydration for All — MATLAB Lead Service Line (LSL) Baseline Tool

## Project Summary
This MATLAB project helps users explore drinking-water infrastructure risk by analyzing **Lead Service Line (LSL)** data. The tool imports a CSV dataset, cleans it, calculates basic metrics (like **Percent LSL**), ranks states, and prepares outputs and visuals that make the data easier to understand.

## What This Program Does
- Loads a CSV dataset of lead service line estimates
- Cleans and standardizes state/location labels
- Computes:
  - **Percent_LSL = (LSL_Estimated / Total_Service_Lines) × 100**
  - Rankings by **LSL count** and by **Percent LSL**
- Saves a processed dataset file for reuse (`processed_lead_service_lines.csv`)
- (Next step) Adds user input + top-10 plots

## Files Included
- `main.m`  
  The starting script. Runs the import, cleaning, and baseline calculations.

- `lead_service_lines_by_state.csv`  
  Your input dataset (must be in the same folder as `main.m`).

- Output file created by the program:
  - `processed_lead_service_lines.csv`

## Required CSV Format (Column Headers)
Your CSV must include these columns (exact spelling/capitalization matters unless you update the code):
- `State`
- `LSL_Estimated`
- `Total_Service_Lines`

Example (first row of CSV):
