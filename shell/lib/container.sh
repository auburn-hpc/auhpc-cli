#!/bin/bash

# -- script generated by AUIVS-HPC Shell Development Library [2023-07-07]

#SBATCH --job-name=run-27982-0707-0949
#SBATCH --partition=vza0013_std
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mail-user=morgaia@auburn.edu
#SBATCH --mail-type=ALL

module load singularity

singularity run /my/container/name
