library(R.utils)
library(purrr)
library(utils)
library(tools)
library(vroom)
library(arrow)
library(vroom)
library(tibble)
library(data.table)
# create dir structure
data_dir <- "data"
cache_dir <- "cache"

mkdir = function (dir) {
  if (!dir.exists(dir)) {
    dir.create(dir,recursive=TRUE)
  } 
}
map(c(data_dir,cache_dir),mkdir)

# download files to cache
download_file <- function(dest_dir='',url='') {
  f <- file.path(dest_dir,basename(url))
  
  if (!file.exists(f)) {
      download.file(file.path(url),dest=f)
      print(paste0("File downloaded to: ", f))
  } else {
    print(paste0("File exists: ",f))
  }
}

base_name <- function(filename) {
  file_path_sans_ext(basename(filename))
}


print("Downloading Files")
# download base files
pharmgkb_data_url = "https://api.pharmgkb.org/v1/download/file/data"
pharmgkb_data_files = c("clinicalAnnotations.zip",
                        "clinicalAnnotations_LOE1-2.zip",
                        "variantAnnotations.zip",
                        "guidelineAnnotations.json.zip",
                        "pathways-biopax.zip",
                        "pathways-tsv.zip",
                        "occurrences.zip",
                        "relationships.zip",
                        "drugLabels.zip",
                        "clinicalVariants.zip",
                        "automated_annotations.zip",
                        "genes.zip",
                        "variants.zip",
                        "drugs.zip",
                        "chemicals.zip",
                        "phenotypes.zip")
base_data_files_urls <- map(pharmgkb_data_files,
                            partial(file.path,pharmgkb_data_url))

map(base_data_files_urls,partial(download_file,dest=cache_dir))

print("Extracting data")
unzip_to_dir <- function(filename) {
  extract_dir = file.path(cache_dir,base_name(filename))
  unzip(filename,exdir=extract_dir)
}

c("clinicalAnnotations.zip",
  "clinicalAnnotations_LOE1-2.zip",
  "variantAnnotations.zip",
  "pathways-tsv.zip",
  "occurrences.zip",
  "relationships.zip",
  "drugLabels.zip",
  "clinicalVariants.zip",
  "automated_annotations.zip",
  "genes.zip",
  "variants.zip",
  "drugs.zip",
  "chemicals.zip",
  "phenotypes.zip",
  "pathway-tsv.zip") |>
  map(partial(file.path,cache_dir)) |>
  map(unzip_to_dir)
  
  
# tsv data
process_simple_zips <- function(filename) {
  data_dir_name <- file.path(data_dir,base_name(filename))
  mkdir(data_dir_name)
  cache_dir_name <- file.path(cache_dir,base_name(filename))
  
  # get all TSV files
  list.files(path=cache_dir_name,pattern=".tsv") |>
    map(function(filename) {
      df <- vroom::vroom(file.path(cache_dir_name,filename))
      arrow::write_parquet(df,file.path(data_dir_name,paste0(base_name(filename),".parquet")))
    })
  file.copy(file.path(cache_dir_name,"README.pdf"),file.path(data_dir_name,"README.pdf"))
}

print("Converting tsv to parquet files")
# simple conversions
c("clinicalAnnotations.zip",
  "clinicalAnnotations_LOE1-2.zip",
  "variantAnnotations.zip",
  "occurrences.zip",
  "relationships.zip",
  "drugLabels.zip",
  "clinicalVariants.zip",
  "automated_annotations.zip",
  "genes.zip",
  "variants.zip",
  "drugs.zip",
  "chemicals.zip",
  "phenotypes.zip") |>
  map(process_simple_zips)
  

print("Combining pathway tsv files into a single parquet file")
# combine into one tsv
pathways_dir <- "pathways-tsv"
mkdir(file.path(data_dir,pathways_dir))
list.files(path=file.path(cache_dir,pathways_dir),pattern=".tsv") |>
  map(partial(file.path,cache_dir,pathways_dir)) |>
  map(function(tsv_file) {
    df <- vroom::vroom(tsv_file)
    df["filename"] = basename(tsv_file)
    df
  }) |>
  # combine all dataframes
  reduce(function(agg,df)
  {
    rbindlist(list(agg,df),fill=TRUE)
  },.init = tibble()) |>
  arrow::write_parquet(file.path(data_dir,pathways_dir,"All_Pathways.parquet"))

file.copy(file.path(cache_dir,pathways_dir,"README.pdf"),
          file.path(data_dir,pathways_dir,"README.pdf"))

print("copying over unprocessed files")
# below are files that will be unprocessed
c("guidelineAnnotations.json.zip",
  "pathways-biopax.zip") |>
  map(function(filename) {
    file.copy(file.path(cache_dir,filename),
              file.path(data_dir,filename))})



  