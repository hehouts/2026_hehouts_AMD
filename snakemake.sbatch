#!/bin/bash
#SBATCH --job-name=AMD_manysearch
#SBATCH --output=logs/manysearch_%j.out
#SBATCH --error=logs/manysearch_%j.err
#SBATCH --account=ctbrowngrp
#SBATCH --partition=bmh
#SBATCH --time=00-14:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mail-user=hehouts@ucdavis.edu
## off SBATCH --mail-type=BEGIN,END,FAIL


set -e

module load conda
eval "$(conda shell.bash hook)"
conda activate snakemake

cd /group/ctbrowngrp6/2026_hehouts_AMD

snakemake \
    --executor slurm \
    --use-conda \
    --keep-going \
    --rerun-incomplete \
    --printshellcmds \
    --latency-wait 60 \
    -j 100 
