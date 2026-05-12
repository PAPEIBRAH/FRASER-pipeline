library(data.table)
library(FRASER)
library(BiocParallel)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(org.Hs.eg.db)

# =========================
# INPUT ARGUMENTS
# =========================

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 2) {
  stop("Usage: Rscript run_fraser.R <bam_folder> <output_folder>")
}

bamFolder <- args[1]
workingDir <- args[2]

# =========================
# REFERENCES
# =========================

txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene
orgDb <- org.Hs.eg.db

# =========================
# BAM FILES
# =========================

bamFiles <- list.files(bamFolder, pattern="*.bam$", full.names=TRUE)

if (length(bamFiles) == 0) {
  stop("No BAM files found")
}

sampleTable <- data.table(
  sampleID = tools::file_path_sans_ext(basename(bamFiles)),
  bamFile = bamFiles
)

# =========================
# PARALLEL
# =========================

register(MulticoreParam(workers = 10))

# =========================
# FRASER
# =========================

fds <- FraserDataSet(colData = sampleTable, workingDir = workingDir)

strandSpecific(fds) <- "no"
pairedEnd(fds) <- TRUE

fds <- countRNAData(fds)
fds <- calculatePSIValues(fds)

fds <- filterExpressionAndVariability(
  fds,
  minExpressionInOneSample = 20,
  minDeltaPsi = 0.0,
  filter = TRUE
)

fds <- FRASER(fds)

# =========================
# ANNOTATION
# =========================

fds <- annotateRangesWithTxDb(fds, txdb = txdb, orgDb = orgDb)

# =========================
# STATS
# =========================

fds <- calculatePvalues(fds, type="jaccard")

fds <- calculatePadjValues(fds, type="jaccard", method="BY")

# =========================
# OUTPUT
# =========================

res <- as.data.frame(results(fds))

dir.create(workingDir, recursive = TRUE, showWarnings = FALSE)

fwrite(res, file.path(workingDir, "ALL_results.tsv"), sep="\t")

cat("\nDONE: FRASER analysis completed\n")
