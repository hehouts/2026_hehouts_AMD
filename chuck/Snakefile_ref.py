# AMD metagenomes vs GTDB rs226 singleton pangenome
# replaces acquire_metadata_w_branchwater_AMD.ipynb

SAMPLE_LST = [x.strip() for x in open("/group/ctbrowngrp6/2026_hehouts_AMD/sra_accessions_AMD.txt") if x.strip()]

SRA_SIGS_DIR = "/group/ctbrowngrp5/wort/wort-sra/sigs"
GTDB_SIGS = "/home/ctbrown/scratch3/2026-gtdb-dl/gtdb-cds-rs226.species.singleton.sig.zip"


# target: one manysearch CSV per metagenome
rule all:
    input:
        expand("/group/ctbrowngrp6/2026_hehouts_AMD/manysearch/{sample_i}.csv", sample_i=SAMPLE_LST)

rule manysearch:
    output:
        "/group/ctbrowngrp6/2026_hehouts_AMD/manysearch/{sample_i}.csv"
    threads: 16
    resources:
        mem_mb=32000,
        runtime=240,  # minutes
        slurm_account="ctbrowngrp",
        slurm_partition="bmh",
    conda:
        "/group/ctbrowngrp6/2026_hehouts_AMD/env.yml"
    shell:
        """
        sourmash scripts manysearch \
            -k 21 --scaled 1000 --threshold 0 \
            -c {threads} \
            {GTDB_SIGS} \
            {SRA_SIGS_DIR}/{wildcards.sample_i}.sig \
            -o {output}
        """
