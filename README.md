# FRASER-pipeline
# FRASER RNA Splicing Pipeline

Simple pipeline for aberrant splicing detection using FRASER.

---

# Installation

## Clone repository

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git

cd YOUR_REPOSITORY
```

---

## Create conda environment

```bash
conda env create -f environment.yml

conda activate fraser_env
```

---

## Open R

```bash
R
```

---

## Install FRASER packages

```r
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("FRASER")

BiocManager::install("TxDb.Hsapiens.UCSC.hg38.knownGene")

BiocManager::install("org.Hs.eg.db")
```

---

# Usage

## Put BAM files in:

```text
example_data/
```

BAM files must be indexed (`.bai`).

Example:

```text
example_data/
├── sample1.bam
├── sample1.bai
├── sample2.bam
├── sample2.bai
```

---

## Run pipeline

```bash
Rscript run_fraser.R
```

---

# Output

Results will be generated in:

```text
results/ALL_results.tsv
```
