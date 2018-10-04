library('biomaRt')

entrezToSymbol <- function(ensembl){
  ### Returns a dataframe with ensembl ids and HGNC symbols
  
  ### ensembl ###
  # input: a vector of ensembl gene ID's
  
  mart <- useDataset("hsapiens_gene_ensembl", useMart("ensembl"))
  genes <- ensembl
  G_list <- getBM(filters= "ensembl_gene_id", attributes= c("ensembl_gene_id",
                                                            "hgnc_symbol"),values=genes,mart= mart)
  return(G_list)
}