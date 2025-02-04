library(ggplot2)
library(dplyr)
library(patchwork)
library(stringr)
library(tikzDevice)

results = read.csv(file = "results-prepared.csv", sep=",", dec=".")
stats = read.csv(file = "_stats-prepared.csv", sep=",", dec=".")

stats["engine"][stats["engine"] == "fove.LiftedVarElim"] = "Lifted Variable Elimination"
stats["engine"][stats["engine"] == "ve.VarElimEngine"] = "Variable Elimination"
stats = rename(stats, "Algorithm" = "engine")

tikz('lifagu-plot-runtimes.tex', standAlone = FALSE, width = 3.5, height = 1.7)

p1 <- ggplot(stats, aes(x=d, y=mean_time, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(group=Algorithm, shape=Algorithm, color=Algorithm)) +
  geom_ribbon(
    aes(
      y = mean_time,
      ymin = mean_time - std,
      ymax = mean_time + std,
      fill = Algorithm
    ),
    alpha = 0.2,
    colour = NA
  ) +
  xlab("$d$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.title = element_text(size=10),
    axis.text = element_text(size=8),
    legend.position = c(0.29, 0.9),
    legend.title = element_blank(),
    legend.text = element_text(size=8),
    legend.background = element_rect(fill = NA),
    legend.spacing.y = unit(0, 'mm')
  ) +
  scale_fill_manual(
    values = c(
      rgb(50,113,173, maxColorValue=255),
      rgb(70,165,69, maxColorValue=255)
    )
  ) +
  scale_color_manual(
    values = c(
      rgb(50,113,173, maxColorValue=255),
      rgb(70,165,69, maxColorValue=255)
    )
  ) +
  guides(fill = "none")

p1
dev.off()

for (p in c(0.05, 0.1, 0.15, 0.2)) {
  results_filtered = filter(results, d > 2)
  results_filtered = filter(results_filtered, perc_delete == p)

  tikz(paste("lifagu-plot-kldiv-p=", p, ".tex", sep=""), standAlone = FALSE, width = 3.5, height = 1.7)

  p <- ggplot(results_filtered, aes(x=as.factor(d), y=kl_divergence_distributions, color=as.factor(p_cohorts))) +
    geom_boxplot(alpha=0.2) +
    xlab("$d$") +
    ylab("KLD") +
    theme_classic() +
    theme(
      axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
      axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
      axis.title = element_text(size=10),
      axis.text = element_text(size=8),
      legend.position = c(0.37, 0.9),
      legend.direction = "horizontal",
      legend.title = element_blank(),
      legend.text = element_text(size=8),
      legend.background = element_rect(fill = NA),
      legend.spacing.y = unit(0, 'mm')
    ) +
    coord_cartesian(ylim = c(0, 1e-2)) +
    guides(fill = "none", color = guide_legend(nrow=2, byrow=TRUE)) +
    scale_color_manual(
      values = c(
        rgb(247,192,26, maxColorValue=255),
        rgb(37,122,164, maxColorValue=255),
        rgb(78,155,133, maxColorValue=255),
        rgb(86,51,94,   maxColorValue=255),
        rgb(126,41,84,  maxColorValue=255)
      ),
      breaks = c("0.2", "0.3", "0.5", "0.7", "0.9"),
      labels = c("$p=0.2$", "$p=0.3$", "$p=0.5$", "$p=0.7$", "$p=0.9$")
    )

    print(p)
    dev.off()
}