"""Summarise sensitivity runs.

Usage: python3 -I analyze.py <runs_dir> <names.tsv> <out_dir>
Reads <runs_dir>/<config>/output/base_test_2.csv for every config and writes:
  r2.csv          optimism-reduced R2 (refit) per config x project x model
  gain.csv        BSAP-BASE and BSFC-BASE gain per config x project
  stability.csv   per originally significant EH metric: configs significant with same sign
  sig_long.csv    every significant metric per config x project x model, with sign
"""
import os, re, sys
import pandas as pd

runs_dir, names_path, out_dir = sys.argv[1:4]
os.makedirs(out_dir, exist_ok=True)

groups = {}
for line in open(names_path):
    g, n = line.rstrip("\n").split("\t")
    groups.setdefault(g, set()).add(n)
EH = (groups["CATCH"] | groups["TRY"]) - {"File.Path", "Project"}

CONFIGS = ["original", "corr_0.6", "corr_0.8", "budget_10", "budget_20",
           "redun_0.8", "no_log", "p_0.01", "p_0.10"]
EXTRA = ["original_bug"]
MODEL = {"CAT.BASE": "BASE", "CAT.BSAP": "BSAP", "CAT.BSFC": "BSFC"}
PROJ = {"hadoop-2.6": "Hadoop", "hibernate-5.0": "Hibernate", "umbraco-7.6": "Umbraco"}


def parse_coef(s):
    out = {}
    if not isinstance(s, str):
        return out
    for name, val in re.findall(r"([A-Za-z0-9_.]+) = (-?[0-9.eE+-]+)", s):
        try:
            out[name] = float(val)
        except ValueError:
            pass
    return out


def concept(m):
    """Collapse Avg/Sum/total variants of the same metric to one concept."""
    c = re.sub(r"^(Avg\.\.|Sum\.of\.|Avg\.)", "", m)
    c = re.sub(r"^AP\.", "", c)
    c = re.sub(r"\.1$", "", c)
    return c


rows = []
for cfg in CONFIGS + EXTRA:
    p = os.path.join(runs_dir, cfg, "output", "base_test_2.csv")
    if not os.path.exists(p):
        continue
    d = pd.read_csv(p)
    for _, r in d.iterrows():
        coef = parse_coef(r["coef"])
        sig = [x.strip() for x in str(r["signifcant_r"]).split(",") if x.strip() not in ("", "TOTAL", "nan")]
        rows.append(dict(config=cfg, project=PROJ[r["project"]], model=MODEL[r["name"]],
                         n=r["n"], budget=r["budget"], nvar_initial=r["nvar_initial"],
                         cutoff=r["cutoff"], r2_c_r=r["r2_c_r"], over_budget=r["over_budget"],
                         sig=sig, coef=coef))
res = pd.DataFrame(rows)
if res.empty:
    sys.exit("no results yet")

res[["config", "project", "model", "n", "budget", "nvar_initial", "cutoff", "r2_c_r", "over_budget"]] \
    .to_csv(os.path.join(out_dir, "r2.csv"), index=False)

long = []
for _, r in res.iterrows():
    for m in r["sig"]:
        long.append(dict(config=r["config"], project=r["project"], model=r["model"], metric=m,
                         concept=concept(m), eh=m in EH, sign=1 if r["coef"].get(m, 0) > 0 else -1))
long = pd.DataFrame(long)
long.to_csv(os.path.join(out_dir, "sig_long.csv"), index=False)

# Gain over BASE
piv = res[res.config.isin(CONFIGS)].pivot_table(index=["config", "project"], columns="model", values="r2_c_r")
piv["gain_BSAP"] = piv["BSAP"] - piv["BASE"]
piv["gain_BSFC"] = piv["BSFC"] - piv["BASE"]
piv.reset_index().to_csv(os.path.join(out_dir, "gain.csv"), index=False)

# Stability of originally significant EH metrics (reference = original, BSFC fixed)
ref = long[(long.config == "original") & long.eh]
done = [c for c in CONFIGS if c in set(res.config)]
stab = []
for _, r in ref.iterrows():
    exact, concept_hits, per = 0, 0, {}
    for cfg in done:
        sub = long[(long.config == cfg) & (long.project == r.project) & (long.model == r.model)]
        e = ((sub.metric == r.metric) & (sub.sign == r.sign)).any()
        c = ((sub.concept == r.concept) & (sub.sign == r.sign)).any()
        exact += e
        concept_hits += c
        per[cfg] = "Y" if e else ("~" if c else "-")
    stab.append(dict(project=r.project, model=r.model, metric=r.metric, sign="+" if r.sign > 0 else "-",
                     exact=exact, concept=concept_hits, runs=len(done), **per))
stab = pd.DataFrame(stab)
stab.to_csv(os.path.join(out_dir, "stability.csv"), index=False)
print("configs done:", done + [c for c in EXTRA if c in set(res.config)])
print(stab.to_string() if not stab.empty else "no stability rows")
