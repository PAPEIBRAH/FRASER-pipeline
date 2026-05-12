# =========================
# FRASER SETUP AUTOMATIQUE
# =========================

cat("\n=== INSTALLATION FRASER PIPELINE ===\n")

# =========================
# 1. CRAN PACKAGES
# =========================

cran_packages <- c(
  "data.table",
  "httr",
  "Matrix",
  "codetools"
)

install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

cat("\nInstalling CRAN packages...\n")
invisible(lapply(cran_packages, install_if_missing))

# =========================
# 2. BIOCONDUCTOR
# =========================

if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager", repos = "https://cloud.r-project.org")
}

options(repos = BiocManager::repositories())

bioc_packages <- c(
  "FRASER",
  "BiocParallel",
  "TxDb.Hsapiens.UCSC.hg38.knownGene",
  "org.Hs.eg.db",
  "SummarizedExperiment",
  "GenomicRanges",
  "S4Vectors",
  "IRanges",
  "Biostrings",
  "Rsamtools"
)

cat("\nInstalling Bioconductor packages...\n")

for (pkg in bioc_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    BiocManager::install(pkg, ask = FALSE, update = FALSE)
  }
}

# =========================
# 3. VERIFICATION
# =========================

cat("\n=== VERIFICATION ===\n")

library(data.table)
library(FRASER)
library(BiocParallel)

cat("\nFRASER version:\n")
print(packageVersion("FRASER"))

cat("\n=== INSTALLATION COMPLETE ===\n")
