message("===================================")
message("  FRASER PIPELINE SETUP (ROBUST)   ")
message("===================================")

# BiocManager safe init
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager", repos = "https://cloud.r-project.org")
}

BiocManager::version()

# -------------------------------------------------
# Packages required
# -------------------------------------------------

cran_packages <- c(
  "dplyr",
  "tidyr",
  "data.table"
)

bioc_packages <- c(
  "FRASER",
  "BiocParallel",
  "Rsamtools",
  "GenomicRanges",
  "SummarizedExperiment",
  "Biobase",
  "IRanges",
  "Biostrings",
  "XVector",
  "MatrixGenerics",
  "TxDb.Hsapiens.UCSC.hg38.knownGene",
  "org.Hs.eg.db"
)

# -------------------------------------------------
# Install CRAN packages (only if missing)
# -------------------------------------------------
message("Checking CRAN packages...")

for (pkg in cran_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message("Installing CRAN package: ", pkg)
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

# -------------------------------------------------
# Install Bioconductor packages (safe mode)
# -------------------------------------------------
message("Checking Bioconductor packages...")

for (pkg in bioc_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message("Installing Bioconductor package: ", pkg)
    BiocManager::install(pkg, ask = FALSE, update = FALSE)
  }
}

# -------------------------------------------------
# Avoid breaking system packages (important in conda)
# -------------------------------------------------
message("Setting Bioconductor config...")
options(
  repos = BiocManager::repositories(),
  BioC_mirror = "https://bioconductor.org"
)

# -------------------------------------------------
# Final verification
# -------------------------------------------------
message("===================================")
message("Verifying installation...")

library(FRASER)

message("✔ FRASER loaded successfully")
message("✔ Setup complete")
message("===================================")
