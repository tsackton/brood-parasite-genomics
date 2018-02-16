Input sequences (alignment_species.xlsx) were downloaded (get_ncbi_genomes.sh) and then trimmed to have a minimum scaffold length of 1 kb (filt_by_len.py).

These sequences were then used as the inputs to progressiveCactus (runProgCact.sh, seq_file, config.xml) to produce a whole genome alignment.
