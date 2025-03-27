import os
import shutil

class config:

    def __init__(self):

        self.queue = "quick"
        self.name = "MD"

def submit_sh(queue, name):
    
    submitsh = open(os.path.join(".", "jobXu.sh"), "w")
    submitsh.write(
'''#!/bin/bash
#SBATCH -J {0}
#SBATCH -p {1}
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=11
#SBATCH --gres=gpu:1

echo "Start time: $(date)"
echo "SLURM_JOB_NODELIST: $SLURM_JOB_NODELIST"
echo "hostname: $(hostname)"
echo "CUDA_VISIBLE_DEVICES: $CUDA_VISIBLE_DEVICES"
echo "Job directory: $(pwd)"

# Decide the software version
# source /public/software/profile.d/apps_gromacs_2023.2.sh
export PATH=/public/home/yqyang/software/Miniconda3/envs/gmxMMPBSA/bin:$PATH
source /public/software/profile.d/apps_gromacs_2023.2.sh

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

cd prod
gmx mdrun -s prod.tpr -cpi prod.cpt -deffnm prod -dhdl dhdl -ntmpi 1 -nb gpu -bonded gpu -gpu_id 0 -pme gpu -noappend -nsteps 10000000
cd ..                                                                                                                                        
'''.format(name, queue)
    )

def run():

    settings = config()
    submit_sh(settings.queue, settings.name)    
                                                                                 
def main():

    run()
    
if __name__=="__main__":
    main() 
