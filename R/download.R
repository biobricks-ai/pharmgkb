library(purrr)
library(fs)


download_dir <- "download"

dir_create(download_dir)
print("Downloading Files")

# base_name <- function(filename) {
#   file_path_sans_ext(basename(filename))
# }
# download base files
pharmgkb_data_url <- "https://api.pharmgkb.org/v1/download/file/data"
pharmgkb_data_files <- c(
    "clinicalAnnotations.zip",
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
    "phenotypes.zip"
)

pharmgkb_data_files |>
    map(~ file.path(pharmgkb_data_url, .x)) |>
    walk(~ {
        filename <- basename(.x)
        download.file(.x, dest = file.path(download_dir, filename))
    })