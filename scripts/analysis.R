#!/usr/bin/env Rscript

# Sourced by energy-actors-trust.qmd.
# Loads data and builds the tables/figures/objects referenced by the
# manuscript's code chunks and inline R.
#
# Pipeline:
#   1. Latent Class Analysis (LCA) of trust in 15 energy policy actors
#   2. Multinomial logit: demographics/political beliefs -> trust-class membership
#   3. Weighted regression: demographics/political beliefs/trust-class -> concern

library(dplyr)
library(tidyr)
library(ggplot2)
library(poLCA)
library(nnet)
library(estimatr)
library(modelsummary)

energy_actors_data <- read.csv("data/energyActorsDataWeighted.csv")

trust_vars <- grep("^trust\\.", names(energy_actors_data), value = TRUE)
concern_vars <- grep("^concern\\.", names(energy_actors_data), value = TRUE)

# ---------------------------------------------------------------------------
# 1. Latent Class Analysis
# ---------------------------------------------------------------------------

# Collapse the 0-10 trust items to a 3-level ordinal indicator (Low 0-3,
# Moderate 4-6, High 7-10) for LCA tractability; poLCA requires integer
# categories coded from 1.
recode_trust_3cat <- function(x) {
  as.integer(cut(x, breaks = c(-1, 3, 6, 10), labels = c(1, 2, 3)))
}

lca_data <- as.data.frame(lapply(energy_actors_data[trust_vars], recode_trust_3cat))

lca_formula <- as.formula(
  paste0("cbind(", paste(trust_vars, collapse = ", "), ") ~ 1")
)

# Class enumeration (k = 2-9) showed no BIC minimum, but the *rate* of BIC
# improvement drops sharply after k = 4 (elbow), entropy stays high (~0.85),
# and the 4-class solution is the smallest one where each class is
# qualitatively distinct rather than a further split of the same pattern.
# See literature/ for the model-comparison notes.
set.seed(20260101)
lca_fit <- poLCA(
  lca_formula,
  data = lca_data,
  nclass = 4,
  maxiter = 3000,
  nrep = 10,
  verbose = FALSE,
  na.rm = TRUE
)

# --- Label classes programmatically from their item-response profiles ------
# probhigh: rows = class, cols = trust item; cell = P(High trust | class)
probhigh <- sapply(lca_fit$probs, function(m) m[, 3])
colnames(probhigh) <- names(lca_fit$probs)

science_items <- c(
  "trust.nas", "trust.university.scientists",
  "trust.federal.scientists", "trust.state.scientists"
)
officials_items <- c("trust.state.officials", "trust.local.officials", "trust.utilities")

overall_trust <- rowMeans(probhigh)
science_gap <- rowMeans(probhigh[, science_items, drop = FALSE]) -
  rowMeans(probhigh[, officials_items, drop = FALSE])

class_rank <- order(overall_trust)
lowest_class <- class_rank[1]
highest_class <- class_rank[length(class_rank)]
middle_classes <- class_rank[-c(1, length(class_rank))]
science_class <- middle_classes[which.max(science_gap[middle_classes])]
generalized_class <- middle_classes[which.min(science_gap[middle_classes])]

class_labels <- character(nrow(probhigh))
class_labels[lowest_class] <- "Deep Distrust of All Actors"
class_labels[generalized_class] <- "Generalized Low Trust"
class_labels[science_class] <- "Trust in Scientists & Environmental Groups"
class_labels[highest_class] <- "Broad Institutional Trust"

# Order factor levels by class size (largest = reference category below)
class_size <- table(lca_fit$predclass)
level_order <- class_labels[order(-class_size)]

energy_actors_data$trust_class <- factor(
  class_labels[lca_fit$predclass],
  levels = level_order
)

# --- LCA summary objects for the manuscript ---------------------------------

lca_class_size_tbl <- energy_actors_data |>
  count(trust_class) |>
  mutate(pct = round(100 * n / sum(n), 1))

lca_entropy <- {
  p <- lca_fit$posterior
  p <- pmax(p, 1e-12)
  raw <- -sum(p * log(p))
  1 - raw / (nrow(p) * log(ncol(p)))
}

lca_profile_long <- as.data.frame(probhigh) |>
  mutate(class = class_labels) |>
  pivot_longer(-class, names_to = "item", values_to = "p_high") |>
  mutate(
    class = factor(class, levels = level_order),
    item = gsub("^trust\\.", "", item),
    item = gsub("\\.", " ", item)
  )

lca_profile_plot <- ggplot(lca_profile_long, aes(x = class, y = item, fill = p_high)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "white", high = "steelblue4", limits = c(0, 1),
                       name = "P(High\nTrust)") +
  labs(x = NULL, y = NULL) +
  theme_minimal(base_size = 10) +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

# ---------------------------------------------------------------------------
# 2. Demographics/political beliefs -> trust-class membership
# ---------------------------------------------------------------------------

energy_actors_data$trust_class <- relevel(energy_actors_data$trust_class,
                                           ref = level_order[1])

# Display-only factor (class name + class size, e.g. "Broad Institutional
# Trust (26.5%)") used solely for tbl-mnl's column headers, matching the
# Table 2 layout in Wehde & Nowlin (2023). trust_class itself (no % suffix)
# remains the version used everywhere else (e.g. the concern-regression rows).
class_pct <- setNames(round(100 * as.numeric(class_size) / sum(class_size), 1),
                       class_labels)
level_order_pct <- paste0(level_order, " (", class_pct[level_order], "%)")
energy_actors_data$trust_class_pct <- factor(
  paste0(as.character(energy_actors_data$trust_class), " (",
         class_pct[as.character(energy_actors_data$trust_class)], "%)"),
  levels = level_order_pct
)

mnl_fit <- multinom(
  trust_class_pct ~ age + male + white + college + inc +
    democrat + republican + trump.approval,
  data = energy_actors_data,
  weights = weight,
  trace = FALSE
)

# ---------------------------------------------------------------------------
# 3. Validity check: does trust-class membership predict concern about
#    pollution, net of demographics and political beliefs? A single flagship
#    outcome (rather than all five concern items) to keep this a validity
#    check on the LCA typology, not a second full study.
# ---------------------------------------------------------------------------

concern_fit <- lm_robust(
  concern.pollution ~ age + male + white + college + inc +
    democrat + republican + trump.approval + trust_class,
  data = energy_actors_data,
  weights = weight,
  se_type = "HC1"
)
