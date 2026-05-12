#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(FRASER)
  library(BiocParallel)
  library(TxDb.Hsapiens.UCSC.hg38.knownGene)
  library(org.Hs.eg.db)
})

# =========================================================
# 1. INPUT ARGS (robuste + simple GitHub UX)
# =========================================================

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 2) {
  stop("
Usage:
  Rscript run_fraser.R <bam_folder> <output_folder>

Example:
  Rscript run_fraser.R /data/bams /results
")
}

bamFolder  <- normalizePath(args[1], mustWork = TRUE)
workingDir <- normalizePath(args[2], mustWork = FALSE)

dir.create(workingDir, recursive = TRUE, showWarnings = FALSE)

message("======================================")
message(" FRASER PIPELINE START")
message("======================================")
message("BAM folder : ", bamFolder)
message("Output dir : ", workingDir)

# =========================================================
# 2. INPUT VALIDATION
# =========================================================

bamFiles <- list.files(bamFolder, pattern = "\\.bam$", full.names = TRUE)

if (length(bamFiles) == 0) {
  stop(" No BAM files found in: ", bamFolder)
}

message("Found BAM files: ", length(bamFiles))

sampleTable <- data.table(
  sampleID = tools::file_path_sans_ext(basename(bamFiles)),
  bamFile  = bamFiles
)

# =========================================================
# 3. PARALLEL BACKEND (HPC SAFE)
# =========================================================

n_workers <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", unset = 2))

message("Using workers: ", n_workers)

if (.Platform$OS.type == "windows") {
  BPPARAM <- SerialParam()
} else {
  BPPARAM <- MulticoreParam(workers = n_workers)
}

register(BPPARAM)

# =========================================================
# 4. REFERENCES
# =========================================================

txdb  <- TxDb.Hsapiens.UCSC.hg38.knownGene
orgDb <- org.Hs.eg.db

# =========================================================
# 5. CREATE FRASER OBJECT
# =========================================================

message("Creating FraserDataSet...")

fds <- FraserDataSet(
  colData = sampleTable,
  workingDir = workingDir
)

strandSpecific(fds) <- "no"
pairedEnd(fds) <- TRUE

# =========================================================
# 6. COUNT + PSI
# =========================================================

message("Counting RNA data...")
fds <- countRNAData(fds)

message("Calculating PSI...")
fds <- calculatePSIValues(fds)

# =========================================================
# 7. FILTERING (robust defaults)
# =========================================================

message("Filtering...")
fds <- filterExpressionAndVariability(
  fds,
  minExpressionInOneSample = 20,
  minDeltaPsi = 0.01,
  filter = TRUE
)

# =========================================================
# 8. FRASER MODEL
# =========================================================

message("Running FRASER model...")
fds <- FRASER(fds)

# =========================================================
# 9. ANNOTATION
# =========================================================

message("Annotating...")
fds <- annotateRangesWithTxDb(
  fds,
  txdb = txdb,
  orgDb = orgDb
)

# =========================================================
# 10. STATISTICS
# =========================================================

message("Computing p-values...")
fds <- calculatePvalues(fds, type = "jaccard")

message("Adjusting p-values...")
fds <- calculatePadjValues(fds, type = "jaccard", method = "BY")

# =========================================================
# 11. OUTPUT
# =========================================================

message("Saving results...")

res <- as.data.frame(results(fds))

fwrite(
  res,
  file.path(workingDir, "FRASER_results.tsv"),
  sep = "\t"
)

saveRDS(
  fds,
  file = file.path(workingDir, "FRASER_object.rds")
)

# =========================================================
# 12. SUMMARY
# =========================================================

message("======================================")
message(" FRASER DONE SUCCESSFULLY")
message(" Samples: ", nrow(sampleTable))
message(" Results saved in: ", workingDir)
message("======================================")
