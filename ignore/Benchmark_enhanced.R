# Enhanced Benchmark Script for {ripserq}
# This script benchmarks several variations of {ripserq} to record censored
# death times as `NA_real_` rather than `Inf` or `NaN` or to use doubles rather
# than floats to store distance measurements. They work as follows:

# `ripserq`, e472dfb7bc5e6da96987987c0cdd989717355b0f:
# no correction; reported as `Inf`
# `ripserq-double`, 2936f3b9455ff9f778b61b0216d7b902177fbfd3:
# type distances as double rather than float
# `ripserq-missing`, bfdfdfbd2569338dc511240b8106e9367736ff3d:
# stored in `std::vector` as `NaN`, then converted to `NA_real_`
# `ripserq-missing-alt`, 41689894007c5d91710f6ad1a7debd0b9d835386:
# stored in `Rcpp::NumericMatrix` as `NA_REAL` (corresponding to `NA_real_`)

# Benchmark tests on small-to-moderate data sets found
# * negligible differences between float versus double
# * significant efficiencies with using `NaN` then converting
# * significant deficiencies to using `NumericMatrix` and not converting

# ENHANCED VERSION: Includes intermediate-sized datasets
# This version focuses on datasets that run in finite time while still
# providing meaningful performance comparisons across branches.

# prepare point clouds
rp2_n <- here::here("src/examples/rp2_600.lower_distance_matrix.csv") |> 
  readLines() |> 
  strsplit(split = ",") |> 
  sapply(length) |> 
  max() + 1L
here::here("src/examples/rp2_600.lower_distance_matrix.csv") |> 
  read.csv(col.names = paste0("X", seq(rp2_n)), header = FALSE) |> 
  as.matrix() |> 
  (\(m) rbind(NA_character_, m))() |>
  as.dist() ->
  rp2_600

# Note: o3_1024 and larger datasets are commented out as they may cause
# system hangs or crashes on some machines. Uncomment if your system
# can handle the computational load.
# here::here("src/examples/o3_1024.txt") |> 
#   readr::read_tsv(col_names = FALSE, col_types = "d") |> 
#   dist() ->
#   o3_1024

set.seed(265879)
klein <- dist(tdaunif::sample_klein_flat(n = 1280, sd = .01))

library(gert)

# branches to benchmark
bench_branches <- c(
  "ripserq",
  "ripserq-double",
  "ripserq-missing", "ripserq-missing-alt"
)
if (! all(bench_branches %in% git_branch_list()$name)) {
  stop("Some branches were not found.")
}

# loop over branches
nrep <- 3L
for (i in seq(nrep)) for (branch in bench_branches) {
  
  # checkout branch and compile source code
  git_branch_checkout(branch)
  devtools::load_all()
  
  # perform benchmark tests
  # Enhanced version focuses on datasets that complete in reasonable time
  res <- bench::mark(
    usa = ripser_dist(UScitiesD, max_dim = 1, thresh = 600),
    euro = ripser_dist(eurodist, max_dim = 1, thresh = 500),
    rp2_600 = ripser_dist(rp2_600, max_dim = 1, thresh = 30),  # Intermediate dataset
    klein = ripser_dist(klein, max_dim = 2, thresh = .5),
    # Uncomment the following line if your system can handle o3_1024:
    # o3_1024 = ripser_dist(o3_1024, max_dim = 2, thresh = 3.5),
    check = FALSE
  )
  
  # save results
  saveRDS(res, file = paste0("ignore/benchmark-", branch, "-", i, ".rds"))
}

# return to "subtrunk" branch
git_branch_checkout("ripserq")

library(tidyverse)

# collate benchmark results
list.files(path = "ignore", pattern = "benchmark\\-.*\\-[0-9]+\\.rds") |> 
  enframe(name = NULL, value = "path") |> 
  mutate(branch = gsub(
    "benchmark\\-([a-z\\-]+)\\-[0-9]+\\.rds", "\\1",
    path
  )) |> 
  transmute(
    subbranch = ifelse(
      branch == "ripserq", " ", gsub("^ripserq\\-", "", branch)
    ),
    rep = gsub("benchmark\\-[a-z\\-]+\\-([0-9]+)\\.rds", "\\1", path),
    results = map(file.path("ignore", path), readRDS)
  ) |> 
  unnest(results) |> 
  select(expression, subbranch, median, mem_alloc) |> 
  arrange(expression, subbranch) |> 
  print() -> bench_results

# plot benchmark results
test_n <- length(unique(bench_results$expression))
bench_results |> 
  mutate(expression = fct_inorder(as.character(expression))) |> 
  mutate(across(c(median, mem_alloc), as.numeric)) |> 
  pivot_longer(
    cols = c(median, mem_alloc),
    names_to = "measure", values_to = "value"
  ) |> 
  ggplot(aes(x = subbranch, y = value)) +
  facet_wrap(
    facets = vars(measure, expression),
    ncol = test_n, scales = "free_y"
  ) +
  geom_boxplot(aes(color = subbranch)) +
  scale_y_log10() +
  theme(axis.text.x = element_text(angle = -30, hjust = 0)) +
  labs(
    title = "Enhanced RipserQ Benchmark Results",
    subtitle = "Including intermediate-sized datasets for reliable performance testing",
    x = "Branch Variation",
    y = "Value (log scale)"
  ) ->
  bench_plot
print(bench_plot)
ggsave(
  here::here("ignore/benchmark-plot-enhanced.pdf"), bench_plot,
  width = 10, height = 8
)
