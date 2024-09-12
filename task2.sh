# Unzip the file to view contents
# gzcat NC_000913.faa.gz

# Get the number of sequences 
num_sequences=$(zgrep -c '^>gi' NC_000913.faa.gz) 
echo "Number of protein sequences: $num_sequences"

# Get the total count of amino acid
amino_acid_count=$(zgrep -v '^>' NC_000913.faa.gz | tr -d '\n' | wc -c)
echo "Total number of amino acid: $amino_acid_count"

avg_length=$(echo "$amino_acid_count / $num_sequences" | bc)
echo "The average length of protein in this strain is $avg_length"