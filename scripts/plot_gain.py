import sys, pandas as pd, matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
g = pd.read_csv(sys.argv[1]); out = sys.argv[2]
order = ["original","corr_0.6","corr_0.8","budget_10","budget_20","redun_0.8","no_log","p_0.01","p_0.10"]
labels = ["original","corr 0.6","corr 0.8","budget 10","budget 20","redun 0.8","no log","p 0.01","p 0.10"]
style = {"Hadoop":("#2a78d6","o"),"Hibernate":("#eb6834","s"),"Umbraco":("#1baf7a","^")}
plt.rcParams.update({"font.family":"serif","font.size":7.5,"axes.edgecolor":"#888","axes.linewidth":0.6})
fig, axes = plt.subplots(1, 2, figsize=(7.0, 2.35), sharey=True)
for ax, col, title in zip(axes, ["gain_BSAP","gain_BSFC"], ["BSAP (anti-patterns) gain over BASE","BSFC (exception flow) gain over BASE"]):
    ax.axvspan(-0.01, 0.01, color="#e9e8e4", lw=0, zorder=0)
    ax.axvline(0, color="#666", lw=0.7, zorder=1)
    for i, cfg in enumerate(order):
        ax.axhline(i, color="#eeeeec", lw=0.5, zorder=0)
    for k, (proj, (c, m)) in enumerate(style.items()):
        sub = g[g.project == proj].set_index("config").reindex(order)
        ys = [i + (k - 1) * 0.22 for i in range(len(order))]
        ax.scatter(sub[col], ys, color=c, marker=m, s=22, edgecolor="white", linewidth=0.6, zorder=3, label=proj)
    ax.set_title(title, fontsize=8)
    ax.set_xlabel("Gain in optimism-reduced $R^2$")
    ax.set_xlim(-0.03, 0.24)
    ax.tick_params(length=2, width=0.5)
    for s in ["top","right"]: ax.spines[s].set_visible(False)
axes[0].set_yticks(range(len(order))); axes[0].set_yticklabels(labels); axes[0].invert_yaxis()
axes[1].legend(loc="lower right", frameon=False, fontsize=7, handletextpad=0.2)
fig.tight_layout(w_pad=1.0)
fig.savefig(out, dpi=300)
