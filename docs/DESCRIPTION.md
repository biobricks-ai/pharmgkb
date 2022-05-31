# Description

This directory contains data that was obtained from [PharmGKB](https://www.pharmgkb.org/downloads) - The Pharmacogenomics Knowledge Base

Most of the datasets consist of tsv files that have been converted to parquet
Each subdir contains parquet file(s) with a README.pdf describing each dataset. filenames were preserved, but extensions
were changed from .tsv to .parquet

One exception is the dir contains `pathways-tsv` which is a combination of many tsv files. An additional `filename` column
has been attached describing which file from the original `pathways-tsv.zip` it was obtained from.

There are two more exceptions in this collection: `guidelineAnnotations.json.zip` contains raw json
and `pathways-biopax.zip` contains Web Ontology Language (OWL) XML. These were not converted to parquet files