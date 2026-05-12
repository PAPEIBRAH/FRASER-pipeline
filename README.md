# FRASER Pipeline

Pipeline pour détecter des anomalies d’épissage (RNA-seq BAM).

---

# 1. Installation

```bash
git clone https://github.com/PAPEIBRAH/FRASER-pipeline.git
cd FRASER-pipeline

conda env create -f environment.yml
conda activate fraser_env



# Ouvrir R
R

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

# Fraser et ses dependances
BiocManager::install("FRASER")
BiocManager::install("TxDb.Hsapiens.UCSC.hg38.knownGene")
BiocManager::install("org.Hs.eg.db")

# verification
library(data.table)
library(FRASER)
library(BiocParallel)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(org.Hs.eg.db)
packageVersion("FRASER")
