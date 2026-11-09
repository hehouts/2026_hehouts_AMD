#!/bin/bash
#SBATCH --job-name=AMD_manysearch
#SBATCH --output=logs/manysearch_%j.out
#SBATCH --error=logs/manysearch_%j.err
#SBATCH --account=ctbrowngrp
#SBATCH --partition=bmh
#SBATCH --time=00-14:00:00
#SBATCH --cpus-per-task=48
#SBATCH --mem=100G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=hehouts@ucdavis.edu





set -e

module load conda
eval "$(conda shell.bash hook)" # idk what this ACTUALLY does, but avoids using my .bashrc
conda activate snakemake 


cd /group/ctbrowngrp6/2026_hehouts_AMD

snakemake \
    --use-conda \
    --keep-going \
    --rerun-incomplete \
    --printshellcmds \
    -j 3
