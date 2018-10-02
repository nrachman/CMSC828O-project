#==================
library(data.table)
library(GEOquery)
library(dplyr)
#==================
#config
#==================
#output directory
project.dir <- "/hpcdata/sg/sg_data/users/rachmaninoffn2/CMSC828O/bm_GEO"

exprMat.fp <- file.path(project.dir, "data/GSE99095_normalizedExpression.csv")


#==================
#load data
#==================
exprMat <- fread(exprMat.fp, data.table = FALSE)
rownames(exprMat) <- exprMat$V1
exprMat <- exprMat[, -1]

#meta <- fread(meta.fp, data.table = FALSE, skip = 12)
gse <- getGEO('GSE99095',GSEMatrix=TRUE)

#for some reason this was divided into two files with additional samples
pdata1 <- gse$`GSE99095-GPL16791_series_matrix.txt.gz`@phenoData@data
pdata2 <- gse$`GSE99095-GPL21290_series_matrix.txt.gz`@phenoData@data
#=================
#subset metadata to samples in expression matrix and reorder
#=================
pdata <- bind_rows(pdata1, pdata2)
pdata <- pdata[match(colnames(exprMat), pdata$title),]
stopifnot(identical(pdata$title, colnames(exprMat)))

cellInfo <- pdata
cellInfo$nGene <- colSums(exprMat>0)

save(exprMat, cellInfo, file = "../bm_GEO/processed.rdata")


#==============
#download human transcription factor database
#==============

setwd(project.dir)
dir.create("cisTarget_databases"); setwd("cisTarget_databases") # if needed

dbFiles <- c("https://resources.aertslab.org/cistarget/databases/homo_sapiens/hg19/refseq_r45/mc9nr/gene_based/hg19-500bp-upstream-7species.mc9nr.feather",
             "https://resources.aertslab.org/cistarget/databases/homo_sapiens/hg19/refseq_r45/mc9nr/gene_based/hg19-tss-centered-10kb-7species.mc9nr.feather")

for(featherURL in dbFiles)
{
  download.file(featherURL, destfile=basename(featherURL)) # saved in current dir
  descrURL <- gsub(".feather$", ".descr", featherURL)
  if(file.exists(descrURL)) download.file(descrURL, destfile=basename(descrURL))
}
