#  FRASER Pipeline

Pipeline pour détecter des anomalies d’épissage (RNA-seq BAM).

Ce pipeline utilise **FRASER (Bioconductor)** pour identifier des événements d’épissage aberrants à partir de données RNA-seq alignées (BAM).

---

# 1. Installation

## Cloner le repository

```bash
git clone https://github.com/PAPEIBRAH/FRASER-pipeline.git
cd FRASER-pipeline
```

## Environnement Conda (recommandé)

```bash
conda env create -f environment.yml
conda activate fraser_env
```

## Installation automatique (optionnel)

```bash
Rscript setup.R
```

---

# 2. RUN (exécution du pipeline)

```bash
Rscript run_fraser.R /path/to/BAM /path/to/results
```

## Exemple

```bash
Rscript run_fraser.R ./data/BAM ./results
```

---

# 3. Résultats

Les résultats seront générés ici :

```
/path/to/results/FRASER_results.tsv
```

Fichiers générés :

- FRASER_results.tsv → résultats des événements d’épissage  
- FRASER_object.rds → objet R complet  

---



## Bonnes pratiques

- Toujours utiliser conda env  
- Ne pas installer les packages R manuellement  
- Vérifier les BAM indexés (.bai)  

---

# 5. Dépendances

## Conda
- r-base  
- bioconductor-fraser  
- r-curl  
- r-httr  
- bioconductor-genomicranges  
- bioconductor-summarizedexperiment  

## R
- FRASER  
- BiocParallel  
- TxDb.Hsapiens.UCSC.hg38.knownGene  
- org.Hs.eg.db  

---

# 6. Contact

Email : <pape-ibrahima.FAYE@univ-amu.fr>

---

# 7. Auteur

Pipeline FRASER pour analyse d’épissage RNA-seq.

GitHub : https://github.com/PAPEIBRAH/FRASER-pipeline
