processing
================
Nicholas Rachmaninoff
10/4/2018

``` r
#==================
suppressPackageStartupMessages({
library(data.table)
library(GEOquery)
library(dplyr)
})
#==================
#config
#==================
#output directory
project.dir <- "."

exprMat.fp <- file.path(project.dir, "raw/GSE99095_normalizedExpression.csv")


#==================
#load data
#==================
exprMat <- fread(exprMat.fp, data.table = FALSE)
rownames(exprMat) <- exprMat$V1
exprMat <- exprMat[, -1]
```

Change the ennsembl ID's to gene symbols
========================================

``` r
source("../CMSC828O-project/util/entrezToSymbol.R")
gene.symbols <- entrezToSymbol(rownames(exprMat))

gene.symbols <- gene.symbols %>% filter(hgnc_symbol != "")
gene.symbols <- gene.symbols %>% filter(ensembl_gene_id %in% rownames(exprMat))

exprMat <- exprMat[match(gene.symbols$ensembl_gene_id, rownames(exprMat)), ]
stopifnot(identical(gene.symbols$ensembl_gene_id, rownames(exprMat)))
rownames(exprMat) <- gene.symbols$ensembl_gene_id
```

Make the metadata (cellInfo)
============================

``` r
#meta <- fread(meta.fp, data.table = FALSE, skip = 12)
gse <- getGEO('GSE99095',GSEMatrix=TRUE)
```

    ## Found 2 file(s)

    ## GSE99095-GPL16791_series_matrix.txt.gz

    ## Parsed with column specification:
    ## cols(
    ##   .default = col_character()
    ## )

    ## See spec(...) for full column specifications.

    ## File stored at:

    ## /tmp/RtmpI6QChQ/GPL16791.soft

    ## GSE99095-GPL21290_series_matrix.txt.gz

    ## Parsed with column specification:
    ## cols(
    ##   .default = col_character()
    ## )

    ## See spec(...) for full column specifications.

    ## File stored at:

    ## /tmp/RtmpI6QChQ/GPL21290.soft

``` r
#for some reason this was divided into two files with additional samples
pdata1 <- gse$`GSE99095-GPL16791_series_matrix.txt.gz`@phenoData@data
pdata2 <- gse$`GSE99095-GPL21290_series_matrix.txt.gz`@phenoData@data
#=================
#subset metadata to samples in expression matrix and reorder
#=================
pdata <- bind_rows(pdata1, pdata2)
```

    ## Warning in bind_rows_(x, .id): Unequal factor levels: coercing to character

    ## Warning in bind_rows_(x, .id): binding character and factor vector,
    ## coercing into character vector

    ## Warning in bind_rows_(x, .id): binding character and factor vector,
    ## coercing into character vector

    ## Warning in bind_rows_(x, .id): Unequal factor levels: coercing to character

    ## Warning in bind_rows_(x, .id): binding character and factor vector,
    ## coercing into character vector

    ## Warning in bind_rows_(x, .id): binding character and factor vector,
    ## coercing into character vector

    ## Warning in bind_rows_(x, .id): Unequal factor levels: coercing to character

    ## Warning in bind_rows_(x, .id): binding character and factor vector,
    ## coercing into character vector

    ## Warning in bind_rows_(x, .id): binding character and factor vector,
    ## coercing into character vector

    ## Warning in bind_rows_(x, .id): Unequal factor levels: coercing to character

    ## Warning in bind_rows_(x, .id): binding character and factor vector,
    ## coercing into character vector

    ## Warning in bind_rows_(x, .id): binding character and factor vector,
    ## coercing into character vector

    ## Warning in bind_rows_(x, .id): Unequal factor levels: coercing to character

    ## Warning in bind_rows_(x, .id): binding character and factor vector,
    ## coercing into character vector

    ## Warning in bind_rows_(x, .id): binding character and factor vector,
    ## coercing into character vector

    ## Warning in bind_rows_(x, .id): Unequal factor levels: coercing to character

    ## Warning in bind_rows_(x, .id): binding character and factor vector,
    ## coercing into character vector

    ## Warning in bind_rows_(x, .id): binding character and factor vector,
    ## coercing into character vector

    ## Warning in bind_rows_(x, .id): Unequal factor levels: coercing to character

    ## Warning in bind_rows_(x, .id): binding character and factor vector,
    ## coercing into character vector

    ## Warning in bind_rows_(x, .id): binding character and factor vector,
    ## coercing into character vector

    ## Warning in bind_rows_(x, .id): Unequal factor levels: coercing to character

    ## Warning in bind_rows_(x, .id): binding character and factor vector,
    ## coercing into character vector

    ## Warning in bind_rows_(x, .id): binding character and factor vector,
    ## coercing into character vector

    ## Warning in bind_rows_(x, .id): Unequal factor levels: coercing to character

    ## Warning in bind_rows_(x, .id): binding character and factor vector,
    ## coercing into character vector

    ## Warning in bind_rows_(x, .id): binding character and factor vector,
    ## coercing into character vector

``` r
pdata <- pdata[match(colnames(exprMat), pdata$title),]
stopifnot(identical(pdata$title, colnames(exprMat)))

cellInfo <- pdata
cellInfo$nGene <- colSums(exprMat>0)

dir.create("processed")
```

    ## Warning in dir.create("processed"): 'processed' already exists

``` r
save(exprMat, cellInfo, file = "processed/processed.rdata")
```

download human transcription factor database
============================================

``` r
setwd(project.dir)
dir.create("cisTarget_databases"); setwd("cisTarget_databases") # if needed
```

    ## Warning in dir.create("cisTarget_databases"): 'cisTarget_databases' already
    ## exists

``` r
dbFiles <- c("https://resources.aertslab.org/cistarget/databases/homo_sapiens/hg19/refseq_r45/mc9nr/gene_based/hg19-500bp-upstream-7species.mc9nr.feather",
             "https://resources.aertslab.org/cistarget/databases/homo_sapiens/hg19/refseq_r45/mc9nr/gene_based/hg19-tss-centered-10kb-7species.mc9nr.feather")

for(featherURL in dbFiles)
{
  download.file(featherURL, destfile=basename(featherURL)) # saved in current dir
  descrURL <- gsub(".feather$", ".descr", featherURL)
  if(file.exists(descrURL)) download.file(descrURL, destfile=basename(descrURL))
}
```
