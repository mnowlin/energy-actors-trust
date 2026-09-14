#!/usr/bin/env Rscript

# Standalone model-enumeration script for the trust LCA (not sourced by the
# manuscript on every render, since it is slow: k = 2-9, nrep = 10 each).
# Run manually to regenerate data/lca_model_comparison.csv, which the
# manuscript's "Latent Class Analysis" methods section reads in.

library(poLCA)

energy_actors_data <- read.csv("data/energyActorsDataWeighted.csv")
trust_vars <- grep("^trust\\.", names(energy_actors_data), value = TRUE)

recode_trust_3cat <- function(x) {
  as.integer(cut(x, breaks = c(-1, 3, 6, 10), labels = c(1, 2, 3)))
}
lca_data <- as.data.frame(lapply(energy_actors_data[trust_vars], recode_trust_3cat))

lca_formula <- as.formula(
  paste0("cbind(", paste(trust_vars, collapse = ", "), ") ~ 1")
)

entropy <- function(fit) {
  p <- fit$posterior
  p <- pmax(p, 1e-12)
  raw <- -sum(p * log(p))
  1 - raw / (nrow(p) * log(ncol(p)))
}

set.seed(20260101)
comparison <- lapply(2:9, function(k) {
  fit <- poLCA(lca_formula, data = lca_data, nclass = k, maxiter = 3000,
               nrep = 10, verbose = FALSE, na.rm = TRUE)
  cs <- sort(prop.table(table(fit$predclass)) * 100, decreasing = TRUE)
  data.frame(
    nclass = k,
    bic = fit$bic,
    aic = fit$aic,
    loglik = fit$llik,
    entropy = entropy(fit),
    min_class_pct = min(cs)
  )
})
comparison <- do.call(rbind, comparison)

write.csv(comparison, "data/lca_model_comparison.csv", row.names = FALSE)
cat("Saved data/lca_model_comparison.csv\n")
print(comparison)
