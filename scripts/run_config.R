# Usage: Rscript run_config.R <config.R> <outdir>
args <- commandArgs(trailingOnly = TRUE)
source(args[1])                      # sets the five settings, SEED, B_BOOT, BSFC_FIX
OUT_DIR <- args[2]
CODE_DIR <- Sys.getenv("CODE_DIR")
DATA_RDATA <- Sys.getenv("DATA_RDATA")
dir.create(file.path(OUT_DIR, "output"), recursive = TRUE, showWarnings = FALSE)
setwd(OUT_DIR)
pdf(NULL)
set.seed(SEED)
cat("CONFIG", CONFIG_NAME, "corr", CORR_THRESHOLD, "budget", BUDGET_DIV, "redun", REDUN_R2,
    "log", LOG_TRANSFORM, "p", SIG_P, "B", B_BOOT, "bsfc_fix", BSFC_FIX, "seed", SEED, "\n")
t0 <- Sys.time()
source(file.path(CODE_DIR, "section2.R"), echo = FALSE)
cat("ELAPSED_MIN", round(as.numeric(difftime(Sys.time(), t0, units = "mins")), 1), "\n")
