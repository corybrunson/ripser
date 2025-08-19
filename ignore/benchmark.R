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
  # (\(m) m[seq(6), seq(6)])()
  as.dist() ->
  rp2_600
here::here("src/examples/o3_1024.txt") |> 
  readr::read_tsv(col_names = FALSE, col_types = "d") |> 
  dist() ->
  o3_1024
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
  # missing_branches <- setdiff(bench_branches, git_branch_list()$name)
  stop("Some branches were not found.")
}

# loop over branches
nrep <- 3L
for (i in seq(nrep)) for (branch in bench_branches) {
  
  # checkout branch and compile source code
  git_branch_checkout(branch)
  devtools::load_all()
  
  # perform benchmark tests
  res <- bench::mark(
    usa = ripser_dist(UScitiesD, max_dim = 1, thresh = 600),
    euro = ripser_dist(eurodist, max_dim = 1, thresh = 500),
    rp2_600 = ripser_dist(rp2_600, max_dim = 1, thresh = 30),
    klein = ripser_dist(klein, max_dim = 2, thresh = .5),
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
bench_results |> 
  mutate(expression = fct_inorder(as.character(expression))) |> 
  mutate(across(c(median, mem_alloc), as.numeric)) |> 
  pivot_longer(
    cols = c(median, mem_alloc),
    names_to = "measure", values_to = "value"
  ) |> 
  ggplot(aes(x = subbranch, y = value)) +
  facet_wrap(facets = vars(measure, expression), scales = "free_y") +
  # geom_col(aes(fill = subbranch)) +
  geom_boxplot(aes(color = subbranch)) +
  scale_y_log10() +
  theme(axis.text.x = element_text(angle = -30, hjust = 0)) ->
  bench_plot
print(bench_plot)
ggsave(
  here::here("ignore/benchmark-plot.pdf"), bench_plot,
  width = 8, height = 6
)
