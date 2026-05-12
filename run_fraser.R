
# LOAD LIBRARIES


library(data.table)
library(FRASER)
library(BiocParallel)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(org.Hs.eg.db)


# ARGUMENTS (LOCAL USE)


args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 2) {
  stop("Usage: Rscript run_fraser.R <bam_folder> <output_folder>")
}

bamFolder <- args[1]
workingDir <- args[2]

# REFERENCES


txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene
orgDb <- org.Hs.eg.db


# GET BAM FILES


bamFiles <- list.files(
  bamFolder,
  pattern = "*.bam$",
  full.names = TRUE
)

if (length(bamFiles) == 0) {
  stop("No BAM files found in the provided folder")
}

# SAMPLE TABLE (GENERIC)



sampleTable <- data.table(
  sampleID = tools::file_path_sans_ext(basename(bamFiles)),
  bamFile = bamFiles
)

# PARALLELIZATION


register(MulticoreParam(workers = 10))

# FRASER DATASET



fds <- FraserDataSet(
  colData = sampleTable,
  workingDir = workingDir
)

strandSpecific(fds) <- "no"
pairedEnd(fds) <- TRUE

# COUNT + PSI


fds <- countRNAData(fds, recount = FALSE)

fds <- calculatePSIValues(fds)


# FILTERING


fds <- filterExpressionAndVariability(
  fds,
  minExpressionInOneSample = 20,
  minDeltaPsi = 0.0,
  filter = TRUE
)

# RUN FRASER


fds <- FRASER(fds)

# ANNOTATION


fds <- annotateRangesWithTxDb(
  fds,
  txdb = txdb,
  orgDb = orgDb
)


# STATISTICS

fds <- calculatePvalues(fds, type = "jaccard")

fds <- calculatePadjValues(
  fds,
  type = "jaccard",
  method = "BY"
)

# EXPORT RESULTS


res <- results(fds)
res_df <- as.data.frame(res)

dir.create(workingDir, showWarnings = FALSE, recursive = TRUE)

fwrite(
  res_df,
  file.path(workingDir, "ALL_results.tsv"),
  sep = "\t"
)

cat("\nFRASER analysis completed successfully\n")
