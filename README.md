# How Robust Are Exception Handling Defect Models?

Group 9 replication of de Pádua and Shang, "Studying the Relationship between Exception Handling Practices and Post-release Defects" (MSR 2018).

Members: Emmanuel Adegboye, Benjamin Emeshili, Marco Spensieri

## What this project does

1. **Reproduce** the original study from the authors' published data and R scripts.
2. **Vary** five modeling settings the authors fixed, one at a time, keeping the data the same.
3. **Classify** each originally significant exception handling metric as robust, moderately robust or fragile.

## Credit

The data, notebooks and helper scripts come from the authors' replication package:
https://guipadua.github.io/eh-model-defects2018

The untouched originals are in `original-package/`. Every change we make to the code is marked with a `# FIX` or `# CHANGED` comment and recorded in `logs/reproducibility-log.md`.

## Folder layout

| Path | Contents |
| --- | --- |
| `0-DataSourcesAnalysis.Rmd` | Notebook 1: merges the five input files into one dataset |
| `1-Model_Construction.Rmd` | Notebook 2: builds and analyses the BASE, BSAP and BSFC models |
| `construction_functions.R`, `analysis_functions.R` | Helper functions used by the notebooks |
| `input/` | The authors' five file-level metric CSVs |
| `config/` | Settings files for the sensitivity runs (in progress) |
| `scripts/` | Our helper scripts for summarising results |
| `output/authors_saved/` | The authors' own saved results, for comparison |
| `output/original_run/` | Our first run of the original package (2026-10-02) |
| `logs/` | Reproducibility log and R session info per machine |
| `original-package/` | The authors' zips and HTML results, exactly as downloaded |
| `docs/` | Our proposal and milestone submissions |

## How to run

Requirements: R 4.3 or later, RStudio, and these packages:

```r
install.packages(c("rms", "Hmisc", "caret", "e1071", "plotly",
                   "BiodiversityR", "logistf", "rmarkdown"))
```

Then, in the RStudio console:

```r
setwd("path/to/eh-replication")
writeLines(capture.output(sessionInfo()), "logs/sessionInfo_<your-name>.txt")
rmarkdown::render("0-DataSourcesAnalysis.Rmd")
rmarkdown::render("1-Model_Construction.Rmd")
```

Notebook 2 takes about 25 minutes. Results are written to `output/base_test_1.csv` and `output/base_test_2.csv`. Move them into a named folder under `output/` after each run so they are not overwritten.

## Known issues (see the log for details)

- **Fixed:** `analysis_functions.R` line 270 failed on R 4.3 and later. Replaced `!is.na(refit)` with `!isTRUE(is.na(refit))`.
- **Open:** `construction_functions.R` line 223 (`data_list = all_list_omitted_m2`) makes the BSFC model reuse the BSAP data, so BSFC results are copies of BSAP. Fix assigned to Benjamin.
- Bootstrap values vary slightly between runs because no random seed is set. A fixed seed will be added with the config file.

## Status

- [x] Original package reproduced (BASE and BSAP match the paper)
- [ ] BSFC fix and rerun
- [ ] Settings moved to config files
- [ ] Sensitivity runs: Hadoop, Hibernate, Umbraco
- [ ] Robustness classification
- [ ] Independent rerun from this README

## Sensitivity runs (Milestone 3)

`code/` holds our configurable copy of the authors' helper functions: the five settings are read from a config file, the BSFC bug is fixed (`# FIX`), and every other change is marked `# CHANGED`. The original files at the top level are left as published.

Run everything from the repository root (Linux, macOS or Git Bash on Windows):

```bash
bash scripts/run_all.sh                 # all 14 configurations, about 2 min each
bash scripts/run_all.sh original no_log # or just some of them
```

- `config/` one file per configuration (see `config/README.md`)
- `output/sensitivity/<config>/output/base_test_2.csv` raw results per configuration
- `output/summary/` R2 per model (`r2.csv`), gain over BASE (`gain.csv`), stability of each significant metric (`stability.csv`) and Fig. 1 (`fig_gain.png`)

**Locale:** the input CSVs start with a UTF-8 byte-order mark. In a non-UTF-8 locale R misreads the first column name and the data preparation merge fails with `'by' must specify a uniquely valid column`. `run_all.sh` sets `LANG=C.UTF-8` for this reason.

Tested on Ubuntu 24.04 with R 4.3.3 (`logs/sessionInfo_linux.txt`); a fresh copy reproduced the stored outputs exactly.
