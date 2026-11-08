# config

One file per configuration. Each sets the five modeling settings, whether the BSFC bug fix is on, the random seed and the number of bootstrap repetitions. `scripts/run_config.R` reads one of these files.

| File | Setting changed | Value (original) |
| --- | --- | --- |
| original_bug.R | none, published code (BSFC bug kept) | |
| original.R | BSFC fix on (kept in every file below) | |
| corr_0.6.R / corr_0.8.R | correlation cutoff | 0.6 / 0.8 (0.7) |
| budget_10.R / budget_20.R | files per predictor | 10 / 20 (15) |
| redun_0.8.R | redundancy cutoff R2 | 0.8 (0.9) |
| no_log.R | transform | none (log10(x + 1)) |
| p_0.01.R / p_0.10.R | significance threshold (fastbw and Wald) | 0.01 / 0.10 (0.05) |
| seed_1.R to seed_4.R | original settings, different random seed | |
