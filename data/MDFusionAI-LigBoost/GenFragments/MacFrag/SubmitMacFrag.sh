#!/bin/bash

#PBS -N aa
#PBS -j oe
#PBS -q sugon_new
#PBS -l nodes=1:ppn=28
#PBS -l walltime=2400:00:00

ulimit -s unlimited
ulimit -l unlimited

cd $PBS_O_WORKDIR
NP=`cat $PBS_NODEFILE | wc -l`
echo "Starting run at" `date`

cd /public/home/yqyang/Project/SM_3CL_COVID-19/data/MDFusionAI-LigBoost/GenFragments/MacFrag/MacFrag.dist
./MacFrag -i /public/home/yqyang/Project/SM_3CL_COVID-19/data/MDFusionAI-LigBoost/GenFragments/ChemblFragment/MacFrag/Chembl_SMILES_MacFrag.smi -o /public/home/yqyang/Project/SM_3CL_COVID-19/data/MDFusionAI-LigBoost/GenFragments/ChemblFragment/MacFrag/ -maxBlocks 10 -maxSR 8 -asMols False -minFragAtoms 1

echo "Finished run at" `date`
