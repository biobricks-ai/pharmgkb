---
title: pharmgkb
namespace: pharmgkb
description: The Pharmacogenomics Knowledge Base
dependencies: 
  - name: pharmgkb
    url: https://www.pharmgkb.org/downloads
---
<a href="https://github.com/biobricks-ai/pharmgkb/actions"><img src="https://github.com/biobricks-ai/pharmgkb/actions/workflows/bricktools-check.yaml/badge.svg?branch=master"/></a>

# Description

This directory contains data that was obtained from [PharmGKB](https://www.pharmgkb.org/downloads) - The Pharmacogenomics Knowledge Base

Most of the datasets consist of tsv files that have been converted to parquet
Each subdir contains parquet file(s) with a README.pdf describing each dataset. filenames were preserved, but extensions
were changed from .tsv to .parquet

One exception is the dir contains `pathways-tsv` which is a combination of many tsv files. An additional `filename` column
has been attached describing which file from the original `pathways-tsv.zip` it was obtained from.

There are two more exceptions in this collection: `guidelineAnnotations.json.zip` contains raw json
and `pathways-biopax.zip` contains Web Ontology Language (OWL) XML. These were not converted to parquet files

# Data Retrieval

You will need dvc installed in order to retrieve the data.

To download an individual file, use the command
```
dvc get git@github.com:insilica/oncindex-bricks.git bricks/pharmgkb/data/drugLabels/drugLabels.parquet -o data/drugLabels/drugLabels.parquet
```
to download the drugLabels project files
```
dvc get git@github.com:insilica/oncindex-bricks.git bricks/pharmgkb/data/drugLabels -o data/drugLabels
```

download the collated patient data
```
dvc get git@github.com:insilica/oncindex-bricks.git bricks/pharmgkb/data/combined_clinical_drug.parquet -o data/
```

To view the data description for a dataset, retrieve the corresponding README.pdf
```
dvc get git@github.com:insilica/oncindex-bricks.git bricks/pharmgkb/data/drugLabels/README.pdf -o data/drugLabels/README.pdf
```

### It is advised to import the files into a project so that you will able to track changes in the dataset
```
dvc import git@github.com:insilica/oncindex-bricks.git bricks/pharmgkb/data/drugLabels -o data/drugLabels
```

Then follow the instructions to save the data into your local dvc repo
