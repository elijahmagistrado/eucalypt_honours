# eucalypt_honours

Within- and across-genus scaling of vessel diameter reveals consistent hydraulic responses to rainfall.

## Overview

This repository contains the data, scripts, and analysis pipeline for a study examining how xylem hydraulic traits scale with precipitation across Australian native woody plant species. The project analyses **hydraulically weighted vessel diameter (Dh)** and **vessel lumen fraction (VLF)** across 480 native Australian species spanning 129 genera and 32 families, using historical wood collections curated by the Forestry Corporation of New South Wales.

The key innovation is the use of a **within-subject centering** (genus-level centered) linear mixed-effects model to separate within- and across-genus trait-climate relationships, helping resolve inconsistencies in vessel size–rainfall scaling found across studies of varying phylogenetic scope.

## Research Questions

- Does Dh scale positively with mean annual precipitation (MAP) at both within- and across-genus levels?
- Does separating within- and across-genus effects explain more variance than conventional linear models?
- How does VLF relate to rainfall compared to Dh, and is it predominantly driven by phylogenetic grouping?

## Key Findings

- **Dh scales positively with MAP** at both within-genus (β = 0.33) and across-genus (β = 0.37) levels, with highly consistent slopes but divergent intercepts across lineages.
- The within-genus centering model explained **78.6% of the variance** in Dh, compared to only **2.8%** for a conventional linear regression.
- **VLF showed no significant relationship** with rainfall; its variation was primarily driven by phylogenetic grouping (45.6% conditional R²).
- Differences in baseline intercepts across genera likely reflect divergent hydraulic strategies that have evolved along different evolutionary lineages.

## Repository Structure

```
eucalypt_honours.Rproj       # RStudio project file
preprocessing.Rmd            # Data preprocessing pipeline
climate analyses.Rmd         # Climate data and statistical analysis
QuPath scripts/              # Groovy scripts for QuPath image analysis
  Automate vessel ID.groovy     # Automated vessel lumen identification
  Remove all objects.groovy     # Clear annotations from images
  Set Pixel Size.groovy         # Configure pixel scale for measurements
data/                        # Raw and processed data files
  vessel_measurements.csv       # Raw vessel measurements from image analysis
  climate_preferences.csv       # Species-level MAP estimates from GBIF + WorldClim
  gbif_filtered.csv             # Filtered GBIF occurrence records
  gbif_raw_occs.csv             # Raw GBIF downloads (pre-1900, Australia, tracheophytes)
  apc_names.csv                 # Taxonomic names aligned to Australian Plant Census
  gbif_namematched.csv          # GBIF records with APC-matched names
  native_sample_export.csv      # Native Australian species list
  zanne_data.csv                # Reference data from Zanne et al. (2010) for validation
  tracheophyte_climate_preferences.csv  # Full climate preference table for all Australian tracheophytes
  genus_facet_labels.csv        # Labels for grouping genera in plots
```

## Data Description

### Vessel Measurements (`vessel_measurements.csv`)
Raw measurements of vessel lumen areas extracted from digitised historical wood slides using QuPath. Images were taken at 4× magnification (~0.99 mm/pixel). On average, three images per species with ~80 vessels measured per image. Hydraulically weighted diameter (Dh) was calculated following Sperry & Saliendra (1994).

### Climate Data
- **GBIF occurrence data**: Filtered to records after 1900, within Australia, tracheophytes only, with coordinate accuracy ≤ 1000 m and marked as human observations.
- **WorldClim 2.1**: Historical MAP data (1970–2000) at ~1 km resolution. Species-level MAP was derived by averaging raster values across all occurrence points for each species with ≥ 10 records.

### Taxonomic Alignment
Species names were aligned to the Australian Plant Census (APC) using the [`APCalign`](https://github.com/ElizabethHWenk/APCalign) R package (Wenk et al. 2024).

## QuPath Image Analysis Pipeline

Vessel lumen areas were measured using semi-automated scripts in **QuPath v0.6.0** (Bankhead et al. 2017). The process involves:

1. **Image preprocessing**: Brightness, contrast, and white balance corrections applied to highlight vessel lumens (which appear distinctly brighter).
2. **Pixel size calibration**: Run `Set Pixel Size.groovy` to ensure consistent scale across images.
3. **Object cleanup**: Run `Remove all objects.groovy` to clear prior annotations before analysis.
4. **Automated vessel ID**: Run `Automate vessel ID.groovy` to segment and measure vessel lumen areas based on pixel thresholding.
5. **Manual verification**: Scripts highlight likely vessels; manual checks were conducted per image to ensure accuracy.

## Statistical Analysis

All analyses were conducted in **R v4.5.3** using the following packages:

- [`easystats`](https://easystats.github.io/easystats/) — Model assessment and reporting
- [`glmmTMB`](https://CRAN.R-project.org/package=glmmTMB) — Linear mixed-effects models
- [`tidyverse`](https://www.tidyverse.org/) — Data manipulation and visualisation
- [`APCalign`](https://doi.org/10.1071/BT24014) — Taxonomic name alignment

### Model: Genus-Level Centering

The primary statistical model partitions trait–climate relationships into within- and across-genus effects:

```
y_ijk = β₀ + β_across · x̄_j + β_within · (x_ijk − x̄_j) + u₀ₖ + u₀ⱼ + u₁ⱼ · (x_ijk − x̄_j) + ε_ijk
```

Where:
- `y_ijk` = trait value (Dh or VLF) for species *i* in genus *j*, family *k*
- `x_ijk` = MAP for species *i*
- `x̄_j` = genus-level mean MAP
- `u₀ₖ`, `u₀ⱼ` = random intercepts for family and genus
- `u₁ⱼ` = random slope for within-genus response

This approach explicitly separates the **across-genus effect** (variation in mean trait values across genera) from the **within-genus effect** (variation among species within a single genus), avoiding ecological fallacies inherent in pooled analyses.

## Software Dependencies

| Tool/Package | Version / Purpose |
|---|---|
| R | ≥ 4.5.0 |
| RStudio | Project workspace |
| QuPath | ≥ 0.6.0 — Image analysis and vessel segmentation |
| easystats | Model diagnostics and reporting |
| glmmTMB | Mixed-effects modelling |
| tidyverse | Data wrangling and plotting |
| APCalign | Taxonomic name alignment to APC/APNI |

## Key References

- **Bourne et al. (2017)** — Species climate range influences hydraulic traits in *Eucalyptus*.
- **Choat et al. (2012)** — Global convergence in forest vulnerability to drought. *Nature*.
- **Isasa et al. (2023)** — Addressing controversies in the P50–Dh relationship. *New Phytologist*.
- **Pfautsch et al. (2016)** — Climate determines vascular traits in *Eucalyptus*. *Ecology Letters*.
- **Sperry & Saliendra (1994)** — Intra- and inter-plant variation in xylem cavitation.
- **van de Pol & Wright (2009)** — Within- versus between-subject effects using mixed models. *Animal Behaviour*.
- **Wenk et al. (2024)** — APCalign: aligning Australian plant names. *Australian Journal of Botany*.
- **Zanne et al. (2010)** — Angiosperm wood structure and hydraulic conductivity. *American Journal of Botany*.

## Data Availability

All data and analysis scripts are published on GitHub:  
https://github.com/elijahmagistrado/eucalypt_honours

Historical wood slides were accessed through the **Australian Botanic Gardens Mount Annan** and are curated by the Forestry Corporation of New South Wales.

---

*Prepared for: Honours research project — Plant hydraulics and macroecology.*  
*For questions or collaboration, please open an issue on this repository.*
