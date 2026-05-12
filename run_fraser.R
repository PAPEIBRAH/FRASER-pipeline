#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(FRASER)
  library(BiocParallel)
  library(TxDb.Hsapiens.UCSC.hg38.knownGene)
  library(org.Hs.eg.db)
  library(DelayedArray)
})

# =========================
# FIX CRITICAL (YOUR ERROR FIX)
# =========================
DelayedArray::setAutoRealizationBackend("SerialParam")

# =========================
# INPUT ARGS
# =========================

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 2) {
  stop("Usage: Rscript run_fraser.R <bam_folder> <output_folder>")
}

bamFolder <- normalizePath(args[1])
workingDir <- normalizePath(args[2], mustWork = FALSE)

dir.create(workingDir, recursive = TRUE, showWarnings = FALSE)

message("======================================")
message(" FRASER PIPELINE START")
message("======================================")

# =========================
# BAM FILES
# =========================

bamFiles <- list.files(bamFolder, pattern="\\.bam$", full.names=TRUE)

if (length(bamFiles) == 0) {
  stop("No BAM files found")
}

sampleTable <- data.table(
  sampleID = tools::file_path_sans_ext(basename(bamFiles)),
  bamFile = bamFiles
)

message("Found BAM files: ", length(bamFiles))

# =========================
# HPC SAFE PARALLEL
# =========================

n_workers <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", unset = 2))

if (.Platform$OS.type == "windows") {
  BPPARAM <- SerialParam()
} else {
  BPPARAM <- MulticoreParam(workers = n_workers)
}

register(BPPARAM)

message("Using workers: ", n_workers)

# =========================
# REFERENCES
# =========================

txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene
orgDb <- org.Hs.eg.db

# =========================
# FRASER PIPELINE
# =========================

fds <- FraserDataSet(
  colData = sampleTable,
  workingDir = workingDir
)

strandSpecific(fds) <- "no"
pairedEnd(fds) <- TRUE

message("Counting RNA...")
fds <- countRNAData(fds)

message("Calculating PSI...")
fds <- calculatePSIValues(fds)

message("Filtering...")
fds <- filterExpressionAndVariability(
  fds,
  minExpressionInOneSample = 20,
  minDeltaPsi = 0.01,
  filter = TRUE
)

message("Running FRASER model...")
fds <- FRASER(fds)

message("Annotating...")
fds <- annotateRangesWithTxDb(fds, txdb = txdb, orgDb = orgDb)

message("Statistics...")
fds <- calculatePvalues(fds, type="jaccard")
fds <- calculatePadjValues(fds, type="jaccard", method="BY")

# =========================
# OUTPUT
# =========================

res <- as.data.frame(results(fds))

fwrite(res, file.path(workingDir, "FRASER_results.tsv"), sep="\t")
saveRDS(fds, file.path(workingDir, "FRASER_object.rds"))

message("======================================")
message(" DONE SUCCESSFULLY ")
message("======================================")
