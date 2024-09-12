# Load the libraries
library(dplyr)
library(ggplot2)

# Read in the file
file <- read.table(gzfile("Homo_sapiens.gene_info.gz"), sep = "\t", header = FALSE, fill = TRUE)

# Subset for columns 3 and 7
subset_data <- file[, c(3, 7)]
colnames(subset_data) <- c("Symbol", "Chromosome")

# Remove rows associated with ambiguous values in "Chromosome" column
usable_data <- subset_data[!grepl("\\|", subset_data$Chromosome), ]
usable_data <- as.data.frame(usable_data)

# Create grouped data such that we have gene count for every chromosome
chromosomes <- c(as.character(1:22), "X", "Y", "MT", "Un")
grouped_data <- usable_data %>%
  group_by(Chromosome) %>%
  summarise(num_genes = n()) %>%
  filter(Chromosome %in% chromosomes) %>%
  mutate(Chromosome = factor(Chromosome, levels = chromosomes))

# Plotting gene count per chromosome
p <- ggplot(grouped_data, aes(x = Chromosome, y = num_genes)) +
  geom_bar(stat = "identity", fill = "grey30") +  
  theme_minimal() +  
  labs(title = "Number of genes in each chromosome", 
       x = "Chromosomes", 
       y = "Gene count") +
  theme(
    plot.title = element_text(hjust = 0.5),  
    text = element_text(size = 14),  
    axis.line = element_line(color = "black"),  
    axis.ticks = element_line(color = "black"),  
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank()
  )

# Saving the plot
ggsave("genes_per_chromosome.pdf", plot = p, width = 8, height = 6)