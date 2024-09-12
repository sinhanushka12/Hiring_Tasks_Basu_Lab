create_mapping <- function(data) {
    mapping <- list()
    for (i in 1:nrow(data)) {
        gene_id <- data[i, "GeneID"]
        symbol <- data[i, "Symbol"]
        mapping[[symbol]] <- gene_id

        # Handle the synonyms and map them to gene_id
        all_synonyms <- unlist(strsplit(data[i, "Synonyms"], "\\|"))
        for (synonym in all_synonyms) {
            mapping[[synonym]] <- gene_id
        }
    }
    return(mapping)
}

replace_gene_names <- function(unique_mapping, input_gmt, output_gmt){
    out <- file(output_gmt, "w")
    for (line in input_gmt) {
        fields <- unlist(strsplit(line, "\t"))
        pathway_name <- fields[1]
        pathway_description <- fields[2]
        gene_names <- fields[3:length(fields)]
        
        entrez_id <- c()
        for (gene_name in gene_names) {
            entrez_id <- c(entrez_id, unique_mapping[[gene_name]])
        }
        new_line <- c(pathway_name, pathway_description, entrez_id)
        writeLines(paste(new_line, collapse = "\t"), out)
    }
    close(out)
}

# ------------------------------------------------------ DATA And FUNCTION CALLS ---------------------------------------------------------------------------------

# Read the genome info file
genome_info_file <- read.table(gzfile("Homo_sapiens.gene_info.gz"), sep = "\t", header = FALSE, fill = TRUE)

# Subset for columns 2, 3 and 5: GeneID (Entrez Id), Symbol and Synonyms.
subset_data <- genome_info_file[, c(2, 3, 5)]
colnames(subset_data) <- c("GeneID", "Symbol", "Synonyms")

# Create unique mapping
res <- create_mapping(as.data.frame(subset_data))

print("Done creating mapping")

# Read gmt file 
gmt_file <- readLines(gzfile("h.all.v2023.1.Hs.symbols.gmt"))
output_gmt <- "h.all.v2023.1.Hs.entrez.gmt"

# Create a new gmt file with entrez ids
replace_gene_names(res, gmt_file, output_gmt)

print("Done creating a new GMT file")