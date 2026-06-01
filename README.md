# Xylem Climate Analyses

Author: Elijah Magistrado

---

## Overview

This repository contains the analysis pipeline for investigating relationships between **xylem vessel traits** and **climate variables** (Mean Annual Temperature, Mean Annual Precipitation) in Australian native tracheophytes. The study computes hydraulic traits from histological images and correlates them with species' climatic niches derived from GBIF occurrence records.

### Key Research Questions
- How does hydraulic diameter (Dh) vary with Mean Annual Precipitation (MAP)?
- How does Vessel Lumen Fraction (VLF) vary with MAP?
- Do these relationships differ across plant families and genera?

---

## Repository Structure

```
eucalypt_honours.Rproj          # RStudio project file
climate analyses.Rmd            # Statistical modelling & plotting (main analysis)
preprocessing.Rmd               # Data import, taxonomic matching, climate extraction
.gitignore                      # Ignored files and directories

data/                           # Input and intermediate data files
├── vessel_areas.csv            # Processed vessel area measurements
├── vessel_measurements.csv     # Raw vessel measurements (2023)
├── 2026_measurements.csv       # Raw vessel measurements (2026)
├── climate_preferences.csv     # Climate data for sample species
├── tracheophyte_climate_preferences.csv  # Full dataset climate preferences
├── zanne_data.csv              # Zanne et al. (2010) comparison data
├── apc_names.csv               # APC taxonomic matching results
├── gbif_namematched.csv        # GBIF name-matched species
└── *.parquet, *.csv            # GBIF occurrence data files

figures/                        # Output figures
├── whittaker_plot.png          # Species distribution in climate space (Fig. 2)
├── Dh_mixed_model_Claude.png   # Hydraulic diameter mixed model plots (Fig. 4)
├── VLF_mixed_model_Claude.png  # Vessel lumen fraction mixed model plots (Fig. 5)
└── Dh_VLF_overall.png          # Combined comparison plot (Fig. 3)

QuPath scripts/                 # QuPath macro scripts for image analysis
├── Automate vessel ID.groovy   # Automated vessel identification
├── Remove all objects.groovy   # Clear selection/annotations
└── Set Pixel Size.groovy       # Calibration script

rasters_30s/                    # WorldClim 30-arc-second rasters
├── wc2.1_30s_bio_1.tif         # Mean Annual Temperature (MAT)
└── wc2.1_30s_bio_12.tif        # Mean Annual Precipitation (MAP)
```

---

## Analysis Pipeline

### 1. Preprocessing (`preprocessing.Rmd`)

Handles data ingestion and preparation:

- **Import vessel measurements** from QuPath image analysis
- **Taxonomic name matching** using APC (Australian Plant Census) via `ausflora`
- **GBIF occurrence data** download and filtering (coordinates, quality thresholds)
- **Climate extraction** from WorldClim rasters for occurrence points
- Generate climate preference summaries per species (mean MAT and MAP)

### 2. Statistical Analysis (`climate analyses.Rmd`)

Core analysis workflow:

- **Trait computation:**
  - Hydraulic diameter (Dh): `Σ(r⁵) / Σ(r⁴)` — weighted mean vessel radius
  - Vessel Lumen Fraction (VLF): proportion of cross-sectional area occupied by vessels
- **Exploratory plotting:** Whittaker-style climate preference distribution (Fig. 2)
- **Mixed-effects models** (`glmmTMB`):
  - `log(Dh) ~ genus_mean_MAP + diff_from_genus_MAP + (1 | family) + (diff_from_genus_MAP | genus)`
  - `log(VLF) ~ genus_mean_MAP + diff_from_genus_MAP + (1 | family) + (diff_from_genus_MAP | genus)`
  - Compared against simpler fixed-effects models via ANOVA and model comparison
- **Visualization:** Faceted plots of family-level and genus-level responses (Fig. 3–5)
- **Supplementary analysis:** Comparison with Zanne et al. (2010) dataset (Fig. S1)

---

## Dependencies

### R Packages
| Package       | Purpose                              |
|---------------|--------------------------------------|
| `tidyverse`   | Data manipulation & visualization    |
| `patchwork`   | Combining multiple plots             |
| `terra`       | Raster processing (climate data)     |
| `APCalign`    | Taxonomic name alignment             |
| `glmmTMB`     | Generalized linear mixed models      |
| `easystats`   | Model diagnostics & comparison       |
| `ggeffects`   | Marginal effects / predictions       |
| `scales`      | Axis formatting utilities            |

### External Resources
- **WorldClim v2.1** (30-arc-second resolution) — BIO1 and BIO12 rasters
- **GBIF** (Global Biodiversity Information Facility) — occurrence records
- **Australian Plant Census (APC)** via `ausflora` — taxonomic reference

---

## Reproduction Steps

1. Open the project in RStudio: `eucalypt_honours.Rproj`
2. Install required packages if not already installed:

```r
install.packages(c("tidyverse", "patchwork", "terra", "glmmTMB",
                   "easystats", "ggeffects", "scales"))
# APCalign may need to be installed from source/github
```

3. Run `preprocessing.Rmd` first to prepare all data files in the `data/` directory
4. Run `climate analyses.Rmd` for statistical models and figure generation
5. Figures will be saved to the `figures/` directory

---

## Key Variables & Metrics

| Variable | Description                                  | Formula / Unit                    |
|----------|----------------------------------------------|-----------------------------------|
| **Dh**   | Hydraulic diameter (weighted mean radius)    | Σ(r⁵)/Σ(r⁴), μm                   |
| **VLF**  | Vessel Lumen Fraction (% of lumen area)      | vessel_area / total_lumen_area × 100, % |
| **MAT**  | Mean Annual Temperature                      | °C                                |
| **MAP**  | Mean Annual Precipitation                    | mm/year                           |

---

## Acknowledgements

Claude Sonnet 4.6 and Qwen 3.6 was used for code review. Qwen 3.6 was used to write the majority of this README.md file.