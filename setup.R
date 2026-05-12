message("====================================")
message(" FRASER SETUP (CONDA SAFE MODE) ")
message("====================================")

# BiocManager safe init
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager", repos = "https://cloud.r-project.org")
}

# -----------------------------
# FORCE CONSISTENT BACKEND
# -----------------------------
suppressPackageStartupMessages({
  library(DelayedArray)
})

# FIX IMPORTANT for FRASER bug
DelayedArray::setAutoRealizationBackend("SerialParam")

message("✔ DelayedArray backend set to SerialParam")

# -----------------------------
# CHECK CORE PACKAGE
# -----------------------------
if (!requireNamespace("FRASER", quietly = TRUE)) {
  stop("FRASER not installed - check conda environment")
}

message("✔ FRASER available")

# -----------------------------
# OPTIONAL verification
# -----------------------------
library(FRASER)

message("✔ FRASER loaded successfully")
message("SETUP COMPLETE")
