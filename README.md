# Within- and across-genus scaling of vessel diameter reveals consistent hydraulic responses to rainfall

Data and analysis code accompanying the manuscript by Elijah Magistrado, Isaac Towers, Jugo Ilic, Zoe Ball, and Daniel Falster, submitted to *Annals of Botany*.

## Study overview

This study tests how xylem anatomy varies with mean annual precipitation (MAP) across 480 Australian native woody plant species from 129 genera and 32 families. It analyses two traits measured from digitised historical wood slides:

- hydraulically weighted vessel diameter (Dh); and
- vessel lumen fraction (VLF), the percentage of the sampled cross-sectional area occupied by vessel lumen.

Genus-level centering in linear mixed-effects models separates within-genus responses to rainfall from differences among genus-level means. The analysis compares these hierarchical models with conventional pooled regressions.

The historical slides are curated by the Forestry Corporation of New South Wales and were accessed through the National Herbarium of New South Wales at the Australian Botanic Gardens Mount Annan.

## Repository contents

| Path | Description |
|------------------------------------|------------------------------------|
| [`climate analyses.Rmd`](climate%20analyses.Rmd) | Primary analysis: trait calculation, model fitting, model comparison, and manuscript figures. |
| [`model_checks.Rmd`](model_checks.Rmd) | Model checks and sensitivity analyses requested by the reviewers (Supporting Information). |
| [`supporting_information.Rmd`](supporting_information.Rmd) | Builds the Supporting Information PDF from the figures and tables. |
| [`preprocessing.Rmd`](preprocessing.Rmd) | Upstream workflow for taxonomic alignment, GBIF filtering, WorldClim extraction, and assembly of vessel measurements. |
| [`liu_comparison.Rmd`](liu_comparison.Rmd) | Supporting reanalysis of the Liu *et al.* (2019) dataset. |
| [`QuPath scripts/`](QuPath%20scripts/) | Groovy scripts used to calibrate images and assist vessel-lumen segmentation in QuPath. |
| [`data/`](data/) | Tracked measurement, climate-summary, taxonomic, and comparison datasets. |
| [`images/`](images/) | Micrograph for Fig. S1, which is not made by the code. |
| [`eucalypt_honours.Rproj`](eucalypt_honours.Rproj) | RStudio project file. |

Generated figures (PNG and vector PDF), tables and the Supporting Information PDF are written to `figures/`, `tables/` and `supporting_information.pdf`, which are not tracked.

## Data files

### Files used directly in the primary analysis

| File | Rows | Role |
|----------------------|----------------------------:|----------------------|
| [`data/vessel_areas.csv`](data/vessel_areas.csv) | 150,303 | Combined, taxonomically aligned vessel and image-area measurements used to calculate Dh and VLF. |
| [`data/climate_preferences.csv`](data/climate_preferences.csv) | 494 | Species-level MAP and mean annual temperature (MAT) summaries derived from occurrence records and WorldClim 2.1 (`n_obs` = retained records). |
| [`data/tracheophyte_climate_preferences.csv`](data/tracheophyte_climate_preferences.csv) | 23,589 | Climate summaries for Australian native tracheophytes, used to show the climatic coverage of the study sample. |

### Measurement and derived files

| File | Description |
|------------------------------------|------------------------------------|
| [`data/vessel_measurements.csv`](data/vessel_measurements.csv) | QuPath measurement export from the earlier image-analysis phase. |
| [`data/2026_measurements.csv`](data/2026_measurements.csv) | Additional QuPath measurements incorporated in the current analysis. |
| [`data/xylem_stats.csv`](data/xylem_stats.csv) | Analysis-ready summary for the 480 study taxa (474 species plus infraspecific taxa), keyed by `scientificName`. Written by `climate analyses.Rmd` and used for all models and figures. |
| [`data/apc_names.csv`](data/apc_names.csv) | Species names supplied to the Australian Plant Census alignment workflow. |
| [`data/gbif_namematched.csv`](data/gbif_namematched.csv) | Output used to connect accepted plant names with GBIF names. |
| [`data/native_sample_export.csv`](data/native_sample_export.csv) | List of sampled Australian native species. |

### External comparison and plotting files

| File | Description |
|------------------------------------|------------------------------------|
| [`data/Liu2019.csv`](data/Liu2019.csv) | Data used for the supporting reanalysis of Liu *et al.* (2019). |
| [`data/zanne_data.csv`](data/zanne_data.csv) | Wood-anatomy data from Zanne *et al.* (2010), used to compare trait measurements. |
| [`data/genus_facet_labels.csv`](data/genus_facet_labels.csv) | Genus labels used in exploratory or supporting figures. |

### Key variables and units

| Variable | Meaning | Unit or scale |
|------------------------|------------------------|------------------------|
| `Area.µm.2` / `Area µm^2` | Detected lumen or image-annotation area | µm² |
| `mean_Dh` | Species mean hydraulically weighted vessel diameter, calculated as `sum(d^5) / sum(d^4)` | µm |
| `mean_VLF` | Mean vessel lumen area divided by sampled image area | \% |
| `MAP` | Mean annual precipitation across retained occurrence records | mm yr⁻¹ |
| `MAT` | Mean annual temperature across retained occurrence records | °C |
| `n_vessels` | Number of complete vessels contributing to Dh | count |
| `n_images` | Number of sampled images for a species | count |

In the primary models, Dh, VLF, and MAP are natural-log transformed. Full vessels contribute to Dh; complete and boundary-intersecting (`part`) vessels contribute to VLF.

## Data provenance and processing

### Wood anatomy

Digitised slides were visually cleaned and cropped before semi-automated segmentation in QuPath 0.6.0. The supplied calibration script sets both image dimensions to **0.9905 µm per pixel**. Candidate lumen objects were detected with a project-specific pixel classifier and checked manually; objects intersecting an image boundary were classified as `part`.

The raw digitised slide images and the QuPath pixel classifier named `Vessel ID` are not included in this repository. The CSV measurement exports and processed measurements needed for the statistical analysis are included.

### Taxonomy

Names were aligned to the Australian Plant Census and Australian Plant Name Index using [`APCalign`](https://doi.org/10.1071/BT24014). Taxonomic resources can change over time, so a fresh preprocessing run may not reproduce historical name matches exactly.

### Species climate summaries

Species-level climate values were derived from [GBIF](https://www.gbif.org/) occurrence data and [WorldClim 2.1](https://www.worldclim.org/data/worldclim21.html) historical bioclimatic rasters for 1970-2000 at 30 arc-second resolution. For the sampled species, records were restricted to Australia, year `>= 1900`, human observations, and coordinate uncertainty `<= 1,000 m`. Species with fewer than 10 retained occurrences were excluded. MAP and MAT were averaged across the retained records for each species.

The multi-gigabyte occurrence downloads, intermediate Parquet files, and WorldClim rasters are not tracked. Their derived species-level summaries are tracked. The study-species occurrences come from GBIF download `0035920-260409193756587` (GBIF.org, 21 April 2026, <https://doi.org/10.15468/dl.88g9fd>), saved as `data/gbif_sample_occs.parquet`. The download used for `tracheophyte_climate_preferences.csv` is not yet recorded.

## Reproducing the results

### Primary analysis from tracked data

The shortest reproducible route starts from the processed CSV files already in `data/`.

1.  Clone this repository and open `eucalypt_honours.Rproj`, or set the repository root as the R working directory.

2.  Use R 4.5.3 where possible. Install the required packages:

    ``` r
    install.packages(c(
      "APCalign", "DHARMa", "easystats", "ggeffects", "glmmTMB", "kableExtra", "ragg",
      "patchwork", "rmarkdown", "scales", "terra", "tidyverse"
    ))
    ```

3.  Create the ignored output directory and render the analysis:

    ``` r
    dir.create("figures", showWarnings = FALSE)
    rmarkdown::render("climate analyses.Rmd")
    rmarkdown::render("model_checks.Rmd")
    rmarkdown::render("supporting_information.Rmd")
    ```

The notebook writes `data/xylem_stats.csv`, fits the Dh and VLF genus-centered mixed models and the pooled comparison models, reports model summaries, performance measures and the Table 2 variance partition, and writes the manuscript figures to `figures/` and the tables requested by the reviewers to `tables/`. `model_checks.Rmd` then reads `data/xylem_stats.csv` and runs the model checks and sensitivity analyses for the Supporting Information.

To run the supporting Liu *et al.* comparison:

``` r
rmarkdown::render("liu_comparison.Rmd")
```

### Recreating processed data

`preprocessing.Rmd` documents the upstream workflow but is **not executable from a clean clone without additional inputs**. It requires:

- GBIF occurrence downloads and intermediate Parquet files;
- WorldClim 2.1 BIO1 and BIO12 rasters in `rasters_30s/`;
- internet access for current APC/APNI taxonomic resources; and
- the additional R packages `arrow` and `data.table` (and `rgbif` if resubmitting the commented GBIF download).

Several download and export statements are intentionally commented, so upstream regeneration requires manual review. The tracked processed datasets are the version used for the reported analysis.

## Software environment

The manuscript reports R 4.5.3, easystats 0.7.5, glmmTMB 1.1.14, and tidyverse 2.0.0. The workflows also load APCalign, DHARMa, ggeffects, kableExtra, patchwork, ragg, scales, and terra. `supporting_information.Rmd` also needs a LaTeX installation (for example `tinytex::install_tinytex()`). This repository does not currently contain an `renv` lockfile, so versions other than those reported in the manuscript are not pinned.

Image measurements were made with QuPath 0.6.0. The Groovy scripts alone do not recreate the full image-analysis environment because the source images, manual corrections, and `Vessel ID` pixel classifier are not included.

## Data and code availability

The data and code needed to inspect and rerun the primary statistical analysis are publicly available in this repository:

<https://github.com/elijahmagistrado/eucalypt_honours>

This is a live GitHub repository. For a stable publication record, cite a tagged release or a DOI-bearing archive once one is available. Until then, record the commit hash used for an analysis. Original wood-slide images and untracked third-party source files are outside this GitHub deposit; see the provenance notes above.

This structure is intended to meet the [Annals of Botany data and materials policy](https://academic.oup.com/aob/pages/General_Instructions), which strongly encourages authors to make all data and software code on which the conclusions of the paper rely available to readers, and requires publicly available datasets to be cited with an identifier such as a DOI.

## Citation

### Manuscript

Magistrado E, Towers I, Ilic J, Ball Z, Falster D. 2026. Within- and across-genus scaling of vessel diameter reveals consistent hydraulic responses to rainfall. Manuscript submitted to *Annals of Botany*.

Replace this provisional citation with the article DOI and final bibliographic details after publication.

### Repository

Magistrado E, Towers I, Ilic J, Ball Z, Falster D. 2026. Data and code for "Within- and across-genus scaling of vessel diameter reveals consistent hydraulic responses to rainfall." GitHub repository: <https://github.com/elijahmagistrado/eucalypt_honours>.

For a reproducible citation, append the release tag, archival DOI, or Git commit hash used.

## Licensing and third-party material

No repository-level licence is currently included. Public accessibility does not by itself grant permission to reuse or redistribute the code or data. Add an explicit code and data licence before the archival publication release, after confirming that the selected terms are compatible with the historical collection and third-party datasets.

GBIF, WorldClim, APC/APNI, Liu *et al.* (2019), and Zanne *et al.* (2010) material remains subject to its original citation and reuse terms.

## Contact

For questions about the data or analysis, contact Elijah Magistrado at [e.magistrado\@student.unsw.edu.au](mailto:e.magistrado@student.unsw.edu.au) or open a GitHub issue.