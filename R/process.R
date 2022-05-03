library(purrr)
library(fs)
library(tools)
library(vroom)
library(arrow)
library(tibble)
library(data.table)
# create dir structure
download_dir <- "download"
data_dir <- "data"
quiet = pkgcond::suppress_conditions
dir_create(data_dir)

base_name <- function(filename) {
  tools::file_path_sans_ext(basename(filename))
}

print("Extracting data from zip files")
fs::dir_ls(download_dir, regexp = "*.zip") |>
  walk(~ unzip(.x, exdir = file.path(download_dir, base_name(.x))))

print("Converting tsv to parquet files")
fs::dir_ls(
  path = download_dir,
  recurse = TRUE,
  regexp = "*\\.tsv$") |>
  walk(~ {
    subdir <- strsplit(.x, "/") |>
      pluck(1) |>
      pluck(2)
    fulldir <- file.path(data_dir, subdir)
    dir_create(fulldir)
    parquet_name <- file.path(fulldir, paste0(base_name(.x), ".parquet"))
    arrow::write_parquet(vroom::vroom(.x,delim="\t"), parquet_name) |> quiet()
  })


print("Combining pathway tsv files into a single parquet file")
# combine into one tsv
pathways_dir <- "pathways-tsv"

fs::dir_ls(file.path(data_dir,pathways_dir)) |>
  map(function(parquet_file) {
    df <- arrow::read_parquet(parquet_file)
    df
  }) |>
  reduce(function(agg,df) # combine all dataframes
  {
    data.table::rbindlist(list(agg,df),fill=TRUE)
  },.init = tibble()) |>
  arrow::write_parquet(file.path(data_dir, "pathways.parquet"))

# delete parquet files in pathways-tsv
dir_ls(
  path = file.path(data_dir,pathways_dir),
  recurse = TRUE,
  regexp = "*\\.parquet$") |>
walk(~ fs::file_delete(.x))

# copy over parquet file
fs::file_move(file.path(data_dir, "pathways.parquet"),
file.path(data_dir,pathways_dir))

# copy readme files
print("Copying over README.pdf")
dir_ls( path = download_dir,
recurse = TRUE,
regexp = "README.pdf") |>
walk(~ { 
    subdir <- strsplit(.x, "/") |>
      pluck(1) |>
      pluck(2)
    fulldir <- file.path(data_dir, subdir)
    file.copy(.x,
    fulldir)})

print("copying over unprocessed files")
# below are files that will be unprocessed
c("guidelineAnnotations.json.zip",
  "pathways-biopax.zip") |>
  walk(function(filename) {
    file.copy(file.path(download_dir,filename),
              file.path(data_dir,filename))})