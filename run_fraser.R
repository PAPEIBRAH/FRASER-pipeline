
# LOAD LIBRARIES


library(data.table)
library(FRASER)
library(BiocParallel)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(org.Hs.eg.db)

# GLOBAL VARIABLES


txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene
orgDb <- org.Hs.eg.db

workingDir <- "results/"
bamFolder <- "example_data/"


# GET BAM FILES

bamFiles <- list.files(
  bamFolder,
  pattern = "*.bam$",
  full.names = TRUE
)

if (length(bamFiles) == 0) {
  stop("No BAM files found in example_data/")
}

sampleTable <- data.table(
  sampleID = substr(basename(bamFiles), 1, 17),
  bamFile = bamFiles
)


# PARALLELIZATION


register(MulticoreParam(workers = 10))


# CREATE FRASER DATASET


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

data.table::fwrite(
  res_df,
  file.path(workingDir, "ALL_results.tsv"),
  sep = "\t"
)

cat("FRASER analysis completed successfully\n")
