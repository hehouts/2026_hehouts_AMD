# AMD metagenomes vs GTDB rs226 singleton pangenome
# replaces acquire_metadata_w_branchwater_AMD.ipynb

# Read the accession file: strip newlines/whitespace, skip blank lines -> list of 103 accessions
SAMPLE_LST = [x.strip() for x in open("/group/ctbrowngrp6/2026_hehouts_AMD/sra_accessions_AMD.txt") if x.strip()]

# Folder of precomputed wort signatures, one <accession>.sig per SRA metagenome
SRA_SIGS_DIR = "/group/ctbrowngrp5/wort/wort-sra/sigs"
# GTDB rs226 database: one signature per species (singleton representatives), zipped
GTDB_SIGS = "/home/ctbrown/scratch3/2026-gtdb-dl/gtdb-cds-rs226.species.singleton.sig.zip"


# --------- SLURM settings -----------
SLURM_ACCOUNT   = "ctbrowngrp"
SLURM_PARTITION = "bmh"            # or high2
MANYSEARCH_THREADS = 4
MANYSEARCH_MEM     = "32GB"
MANYSEARCH_RUNTIME = 120            # minutes
# ------------------------------------


# 'all' is the default target: it lists every final file you want.
# expand() fills {sample_i} with each accession -> 103 CSV paths.
# Snakemake works backward from these files to decide which jobs to run.
rule all:
    input:
        expand("/group/ctbrowngrp6/2026_hehouts_AMD/manysearch/{sample_i}.csv", sample_i=SAMPLE_LST)

# One job per metagenome. {sample_i} is a wildcard; Snakemake fills it in
# by matching the output path against the files 'all' asked for.
rule manysearch:
    input:
        query=GTDB_SIGS,                               # Snakemake checks this exists before running
        against=f"{SRA_SIGS_DIR}/{{sample_i}}.sig",    # double braces keep {sample_i} as a wildcard inside the f-string
    output:
        "/group/ctbrowngrp6/2026_hehouts_AMD/manysearch/{sample_i}.csv"
    threads: MANYSEARCH_THREADS
    resources:
        mem=MANYSEARCH_MEM,
        runtime=MANYSEARCH_RUNTIME,
        slurm_account=SLURM_ACCOUNT,
        slurm_partition=SLURM_PARTITION,
    conda:
        "/group/ctbrowngrp6/2026_hehouts_AMD/env.yml"   # env with sourmash + branchwater plugin; built once, reused
    shell:
        # -k 21 --scaled 1000: k-mer size and sketch resolution (must match how the sigs were built)
        # --threshold 0: report every GTDB species with any overlap, no minimum
        # -c {threads}: number of cores manysearch uses
        # first positional arg = queries (GTDB species), second = what to search against (the metagenome)
        """
        sourmash scripts manysearch \
            -k 21 --scaled 1000 --threshold 0 \
            -c {threads} \
            {input.query} \
            {input.against} \
            -o {output}
        """
