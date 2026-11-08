# Reproducibility Log

Project: Replication of de Padua & Shang (MSR 2018), exception handling and post-release defects
Package source: https://guipadua.github.io/eh-model-defects2018 (downloaded from the authors' GitHub repo, guipadua/guipadua.github.io, because the direct link was blocked)

## Environment

Paste the output of sessionInfo() here (type it in the RStudio console and press Enter):

```
R version 4.6.1 (2026-06-24 ucrt)
Platform: x86_64-w64-mingw32/x64
Running under: Windows 11 x64 (build 22631)

Matrix products: default
  LAPACK version 3.12.1

locale:
[1] LC_COLLATE=English_United States.utf8  LC_CTYPE=English_United States.utf8   
[3] LC_MONETARY=English_United States.utf8 LC_NUMERIC=C                          
[5] LC_TIME=English_United States.utf8    

time zone: Africa/Lagos
tzcode source: internal

attached base packages:
[1] tcltk     splines   stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] BiodiversityR_2.18-1 vegan_2.7-6          permute_0.9-10       rmarkdown_2.32       caret_7.0-1         
 [6] lattice_0.22-9       e1071_1.7-17         plotly_4.12.1        ggplot2_4.0.3        rms_8.1-1           
[11] Hmisc_5.3-0         

loaded via a namespace (and not attached):
  [1] RColorBrewer_1.1-3   rstudioapi_0.19.0    jsonlite_2.0.0       magrittr_2.0.5       TH.data_1.1-5       
  [6] farver_2.1.2         nloptr_2.2.1         vctrs_0.7.3          minqa_1.2.8          base64enc_0.1-6     
 [11] htmltools_0.5.9      forcats_1.0.1        polspline_1.1.25     haven_2.5.5          survey_4.5          
 [16] cellranger_1.1.0     Formula_1.2-6        pROC_1.19.1          parallelly_1.48.0    htmlwidgets_1.6.4   
 [21] plyr_1.8.9           sandwich_3.1-3       zoo_1.9-1            lubridate_1.9.5      lifecycle_1.0.5     
 [26] iterators_1.0.14     pkgconfig_2.0.3      Matrix_1.7-5         R6_2.6.1             fastmap_1.2.0       
 [31] rbibutils_2.4.1      future_1.76.0        digest_0.6.39        colorspace_2.1-3     effects_4.2-5       
 [36] timechange_0.4.0     httr_1.4.9           abind_1.4-8          mgcv_1.9-4           compiler_4.6.1      
 [41] Rcmdr_2.15.0         proxy_0.4-29         withr_3.0.3          htmlTable_2.5.0      S7_0.2.2            
 [46] backports_1.5.1      carData_3.0-6        DBI_1.3.0            relimp_1.0-5         MASS_7.3-65         
 [51] lava_1.9.3           quantreg_6.1         ModelMetrics_1.2.2.2 tools_4.6.1          foreign_0.8-91      
 [56] otel_0.2.0           TeachingDemos_2.13   future.apply_1.20.2  nnet_7.3-20          glue_1.8.1          
 [61] nlme_3.1-169         grid_4.6.1           checkmate_2.3.4      cluster_2.1.8.2      reshape2_1.4.5      
 [66] generics_0.1.4       recipes_1.4.0        gtable_0.3.6         nortest_1.0-4        class_7.3-23        
 [71] tidyr_1.3.2          data.table_1.18.6.1  hms_1.1.4            car_3.1-5            foreach_1.5.2       
 [76] pillar_1.11.1        stringr_1.6.0        mitools_2.7          RcmdrMisc_2.10.2     dplyr_1.2.1         
 [81] survival_3.8-6       SparseM_1.84-2       tidyselect_1.2.1     knitr_1.52           reformulas_0.4.4    
 [86] gridExtra_2.3.1      stats4_4.6.1         xfun_0.61            hardhat_1.4.3        timeDate_4052.112   
 [91] stringi_1.8.9        boot_1.3-32          evaluate_1.0.5       codetools_0.2-20     tibble_3.3.1        
 [96] cli_3.6.6            rpart_4.1.27         Rdpack_2.6.6         Rcpp_1.1.2           readxl_1.5.0.1      
[101] globals_0.19.1       parallel_4.6.1       MatrixModels_0.5-4   gower_1.0.2          tcltk2_1.6.1        
[106] lme4_2.0-6           listenv_1.0.0        viridisLite_0.4.3    mvtnorm_1.4-2        ipred_0.9-16        
[111] scales_1.4.0         prodlim_2026.03.11   insight_1.5.4        purrr_1.2.2          rlang_1.3.0         
[116] multcomp_1.4-32     
```

## Entries

### 2026-10-02: Notebook 0 (0-DataSourcesAnalysis.Rmd)

- Ran by: Emmanuel
- Changes made to code: none
- Errors: none
- Output: all_no_missing.csv and 0-all_no_missing.RData
- Check: compared our all_no_missing.csv with the authors' published version
- Result: REPRODUCED EXACTLY. Same 10,195 files (Hadoop 3,662, Hibernate 3,450, Umbraco 3,083), same 159 columns, every value identical.
- Notes:
    - File size differs slightly (7,861,327 vs 7,851,131 bytes) because of Windows line endings; contents are identical.
    - File counts are below Table 1 of the paper (e.g., Hadoop 3,662 vs 3,698) because files with missing data were removed in this step.

### Observations about the code

- The predictor budget (15 files per predictor) is hard-coded in 4 places across construction_functions.R and analysis_functions.R, not set once.
- The redundancy cutoff (0.9) is never written in the code; it comes from the default of the redun() function.
- The notebook asks for setwd() to a Mac path; opening the folder as an RStudio project avoids this.

### Next: Notebook 1 (1-Model_Construction.Rmd)

- Ran by: Emmanuel
- Changes made to code:
    - 2026-10-02: analysis_functions.R line 270. Changed `!is.na(refit)` to `!isTRUE(is.na(refit))`.
- Errors:
    - 2026-10-02: `Error in class_refit != "try-error" && !is.na(refit): 'length = 31' in coercion to 'logical(1)'`
    - Cause: since R 4.3, `&&` only accepts a single TRUE/FALSE. `is.na()` on a fitted model returns one value per model part (31 here). Older R silently used the first value; new R stops with an error.
    - Fix keeps the original behaviour: skip only when refit is NA (no model), otherwise continue. Results should not change.
    - Reproducibility finding: the package does not run unmodified on current R.
- Run method: rmarkdown::render("1-Model_Construction.Rmd") from the RStudio console, 2026-10-02, about 25 minutes
- Output: output/base_test_1.csv, output/base_test_2.csv, 1-Model_Construction-our-run.html, sessionInfo.txt
- Check: compared with the authors' backup outputs (base_test_1_BKP.csv, base_test_2_BKP.csv) and Table 4 of the paper

#### Result vs authors' output files
- REPRODUCED. Same metrics kept, same model formulas, same coefficients and R2 (differences around 1e-12).
- Only the bootstrap-based values differ (r2_c, slope_c, r2_c_r, slope_c_r), by up to 0.023. Cause: the code sets no random seed, so the 1,000 bootstrap samples differ on every run. Fix for our study: add set.seed() so our runs are repeatable.

#### Result vs Table 4 of the paper (optimism-reduced R2, our run, rounded)

| Project | BASE paper / ours | BSAP paper / ours | BSFC paper / ours |
| --- | --- | --- | --- |
| Hadoop | 0.33 / 0.33 | 0.35 / 0.35 | 0.37 / 0.35 |
| Hibernate | 0.21 / 0.21 | 0.23 / 0.23 | 0.28 / 0.23 |
| Umbraco | 0.09 / 0.09 | 0.18 / 0.18 | 0.09 / 0.18 |

- BASE and BSAP: REPRODUCED. Significant anti-patterns also match the paper: Hadoop (Ignoring Interrupted Exception, Log and Throw), Hibernate (Dummy Handler), Umbraco (Dummy Handler, Generic Catch).
- BSFC: NOT REPRODUCED. In our run AND in the authors' own backup file, every BSFC row is an exact copy of the BSAP row.

#### Major finding: bug in the published package
- construction_functions.R line 223, inside dataApplyReductionByModel(): `data_list = all_list_omitted_m2`
- This leftover line overwrites the function's input with the BSAP data, so the BSFC model (exception flow characteristics) is built from BSAP data.
- The published package therefore cannot produce the paper's BSFC results (RQ1 of the paper). The paper's numbers must have come from a different version of the code.
- Not yet fixed. Next: run a corrected copy (line 223 commented out) and compare BSFC with Table 4.
### 2026-10-25: BSFC fix and seeded rerun

- Ran by: Benjamin
- - Machine: Windows 11 x64, R 4.6.1, run from VS Code terminal with Rscript
- Changes made to code:
    - 1-Model_Construction.Rmd: added `set.seed(2026)` at the end of the setup chunk
    - construction_functions.R line 223: commented out `data_list = all_list_omitted_m2`
- Run time: about 20 minutes
- Output: output/bsfc_fix_run/
- Result vs Table 4 of the paper: ALL MODELS REPRODUCED
    - BSFC now differs from BSAP in all three projects
    - BSFC potential predictors 31 / 27 / 23, cutoffs .70 / .70 / .24, optimism-reduced R2 .37 / .28 / .09: all match the paper
    - BASE and BSAP unchanged by the fix and still match the paper
- Result vs Table 5: significant flow metrics and their signs match the paper (Hadoop: 5 metrics, all positive; Hibernate: Throw Wrap and Type Prevalence negative, Invoked Method positive; Umbraco: none significant). The paper's "Documentation" effect for Hibernate is consistent with RatioCommentToCode (negative).
- Conclusion: the paper's BSFC results came from code without the leftover line at 223. With that line removed, the published package reproduces every model in Table 4.