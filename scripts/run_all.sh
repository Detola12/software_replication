#!/bin/bash
# Run every sensitivity configuration. Run from the repository root:  bash scripts/run_all.sh
# Needs R with rms, Hmisc, caret, e1071, knitr. Takes about 2 minutes per configuration.
set -e
export LANG=C.UTF-8 LC_ALL=C.UTF-8          # input CSVs have a UTF-8 byte-order mark
ROOT=$(pwd)
export CODE_DIR=$ROOT/code DATA_RDATA=$ROOT/0-all_no_missing.RData
if [ ! -f "$DATA_RDATA" ]; then             # data preparation (notebook 0), once
  Rscript -e 'knitr::purl("0-DataSourcesAnalysis.Rmd", output="nb0.R", quiet=TRUE); pdf(NULL); source("nb0.R")'
fi
for cfg in ${@:-original original_bug corr_0.6 corr_0.8 budget_10 budget_20 redun_0.8 no_log p_0.01 p_0.10 seed_1 seed_2 seed_3 seed_4}; do
  echo "== $cfg"; mkdir -p output/sensitivity
  Rscript scripts/run_config.R config/$cfg.R output/sensitivity/$cfg > output/sensitivity/$cfg.log 2>&1
done
python3 scripts/analyze.py output/sensitivity output/summary/metric_groups.tsv output/summary
python3 scripts/plot_gain.py output/summary/gain.csv output/summary/fig_gain.png
