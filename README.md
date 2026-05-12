# FRASER Pipeline

Pipeline simple pour détecter des anomalies d’épissage (RNA-seq BAM).

---

# 1. Installation

```bash
git clone https://github.com/TON_USERNAME/FRASER-pipeline.git
cd FRASER-pipeline

conda env create -f environment.yml
conda activate fraser_env



# Ouvrir R
R

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
#
BiocManager::install("FRASER")
BiocManager::install("TxDb.Hsapiens.UCSC.hg38.knownGene")
BiocManager::install("org.Hs.eg.db")
