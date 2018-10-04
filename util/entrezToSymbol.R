library('biomaRt')

entrezToSymbol <- function(ensembl){
  mart <- useDataset("hsapiens_gene_ensembl", useMart("ensembl"))
  genes <- ensembl.ids
  G_list <- getBM(filters= "ensembl_gene_id", attributes= c("ensembl_gene_id",
                                                            "hgnc_symbol"),values=genes,mart= mart)
  return(G_list)
}