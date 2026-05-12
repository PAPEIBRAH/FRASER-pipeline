# FRASER Pipeline

Pipeline pour détecter des anomalies d’épissage (RNA-seq BAM).

---

# 1. Installation

```bash
git clone https://github.com/PAPEIBRAH/FRASER-pipeline.git
cd FRASER-pipeline

conda env create -f environment.yml
conda activate fraser_env
```

---
# Installation automatique

```bash
Rscript setup.R

---

# 3. Vérification

Dans R :

```r
library(data.table)
library(FRASER)
library(BiocParallel)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(org.Hs.eg.db)

packageVersion("FRASER")
```

---

# 4. RUN (exécution du pipeline)

Pour lancer l’analyse FRASER :

```bash
Rscript run_fraser.R /path/to/BAM /path/to/results
```

---

# 5. Résultats

Les résultats seront générés ici :

```text
/path/to/results/ALL_results.tsv
```
