library(purrr)
library(fs)
library(tools)
library(vroom)
library(arrow)
library(tibble)
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
purrr::discard(~ grepl("guidelineAnnotations.json.zip",.x) ||
grepl("pathways-biopax.zip",.x)) |>
  walk(~ unzip(.x, exdir = file.path(download_dir, base_name(.x))))

print("Converting tsv to parquet files")
fs::dir_ls(
  path = download_dir,
  recurse = TRUE,
  regexp = "*\\.tsv$") |>
  purrr::discard(~grepl("pathways-tsv",.x)) |>
  walk(~ {
    subdir <- strsplit(.x, "/") |>
      pluck(1) |>
      pluck(2)
    fulldir <- file.path(data_dir, subdir)
    dir_create(fulldir)
    parquet_name <- file.path(fulldir, paste0(base_name(.x), ".parquet"))
    arrow::write_parquet(vroom::vroom(.x,delim="\t"), parquet_name) |> quiet()
  })


print("Combining pathways-tsv files into a single parquet file")
# combine into one tsv
pathways_dir <- "pathways-tsv"
output_dir <- file.path(data_dir,pathways_dir)
dir_create(output_dir)
df <- fs::dir_ls(file.path(download_dir,pathways_dir),
regexp = "*\\.tsv$") |>
  map(function(filename) {
    df <- vroom::vroom(filename,col_types="cccccccccc") |> quiet()
    df
  }) |>
  dplyr::bind_rows() |>
    arrow::write_parquet(sink = file.path(output_dir, "pathways.parquet"))

# copy readme files
print("Transfering README.pdfs")
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

print("Transfering unprocessed files")
# below are files that will be unprocessed
c("guidelineAnnotations.json.zip",
  "pathways-biopax.zip") |>
  walk(function(filename) {
    file.copy(file.path(download_dir,filename),
              file.path(data_dir,filename))})