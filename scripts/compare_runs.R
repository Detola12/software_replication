# Usage: Rscript scripts/compare_runs.R <run A csv> <run B csv>
args <- commandArgs(trailingOnly = TRUE)
a <- read.csv(args[1]); b <- read.csv(args[2])
key_a <- paste(a$name, a$project); key_b <- paste(b$name, b$project)
cat("Same models in same order:", identical(key_a, key_b), "\n\n")
for (col in c("budget", "nvar_initial", "cutoff", "signifcant_r", "final_form"))
  cat(sprintf("%-14s identical: %s\n", col, identical(a[[col]], b[[col]])))
signs <- function(s) sapply(regmatches(s, gregexpr("= -?[0-9.]+(e[-+]?[0-9]+)?", s)),
  function(v) paste(ifelse(grepl("= -", v), "-", "+"), collapse = ""))
cat(sprintf("%-14s identical: %s\n\n", "coef signs", identical(signs(a$coef), signs(b$coef))))
d <- data.frame(model = key_a, A = round(a$r2_c_r, 3), B = round(b$r2_c_r, 3),
                diff = round(b$r2_c_r - a$r2_c_r, 3))
print(d, row.names = FALSE)
