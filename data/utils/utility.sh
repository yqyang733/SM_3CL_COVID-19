#!/bin/bash 

#####################################################################################
# This bash file is only worked for SARS2_3CL_DL_generator_FEP project.             #
# Author: Yanqing Yang                                                              #
# Email: yanqyang@zju.edu.cn; 1821074995@qq.com                                     #
#####################################################################################

#####################################################################################
# Preparing the system.psf and system.pdb using topology file producted by CGenFF.  #
# usage: bulid_CGenFF ${file}                                                       #
#####################################################################################
bulid_CGenFF(){
    ffpath="/home/yqyang/software/toppar"
    namd_conf="/home/yqyang/software/namd-conf"
    namd_pre="/home/yqyang/software/namd_pre"
    end_sep=`grep -n "END" LIG.str|head -1|awk -F ":" '{print $1}'`
    cp LIG.str LIG.rtf
    sed -i "${end_sep},$ d" LIG.rtf
    cp LIG.str lig.prm
    sed -i "1,${end_sep} d" lig.prm
    sed -i '$d' lig.prm
    sed -i 's/UNK/LIG/g' ${1}
    obabel -imol2 ${1} -opdb -O ligand.pdb
    sed -i '/CONECT/d' ligand.pdb
    sed -i '/MASTER/d' ligand.pdb
    mkdir build
    cd build
    rm pipline.tcl
    cp ../com21-receptor.pdb .
    cp ${namd_pre}/top_all36_cgenff.rtf .
    cp ${namd_pre}/top_all36_prot.rtf .
    cp ../ligand.pdb .
    cp ../LIG.rtf .
    echo "package require psfgen" >> pipline.tcl
    echo "psfcontext reset" >> pipline.tcl
    echo "topology top_all36_cgenff.rtf" >> pipline.tcl
    echo "topology top_all36_prot.rtf" >> pipline.tcl
    echo "pdbalias residue HIS HSE" >> pipline.tcl
    echo "alias atom ILE CD1 CD" >> pipline.tcl        
    echo "alias atom SER HG HG1" >> pipline.tcl         
    echo "alias atom CYS HG HG1" >> pipline.tcl   
    echo "segment PRO {pdb com21-receptor.pdb}" >> pipline.tcl
    echo "coordpdb com21-receptor.pdb PRO" >> pipline.tcl
    echo "topology LIG.rtf" >> pipline.tcl
    echo "segment LIG {" >> pipline.tcl
    echo "    first none" >> pipline.tcl
    echo "    last none" >> pipline.tcl
    echo "    pdb ligand.pdb" >> pipline.tcl
    echo "    }" >> pipline.tcl
    echo "coordpdb ligand.pdb LIG" >> pipline.tcl
    echo "guesscoord" >> pipline.tcl
    echo "writepdb merged.pdb" >> pipline.tcl
    echo "writepsf merged.psf" >> pipline.tcl
    echo "psfcontext reset" >> pipline.tcl
    echo "mol load psf merged.psf pdb merged.pdb" >> pipline.tcl
    echo "package require solvate" >> pipline.tcl
    echo "solvate merged.psf merged.pdb -t 11.5 -o solvated" >> pipline.tcl
    echo "mol delete all" >> pipline.tcl
    echo "package require autoionize" >> pipline.tcl
    echo "autoionize -psf solvated.psf -pdb solvated.pdb -sc 0.15 -o system" >> pipline.tcl
    echo "exit" >> pipline.tcl
    /home/yqyang/software/vmd-1.9.4a57-installed/vmd -dispdev text -e pipline.tcl
    cd ..
    mkdir md
    cd md
    cp ../build/system.pdb .
    cp ../build/system.psf .
    cp ${namd_conf}/namdmd.sh .
    cp -r ${ffpath} .
    mkdir prod
    cp ${namd_conf}/pro-lig* ./prod/
    cp ../lig.prm ./toppar/
}

#####################################################################################
# Preparing the system.psf and system.pdb using topology file producted by CharmmGUI#
# usage: bulid_charmmgui ${file}                                                    #
# Preparing the system.psf and system.pdb without lone pair.                        #
# usage: bulid_charmmgui_deLP ${file}                                               #
# Preparing the system.psf and system.pdb without lone pair for only ligand.        #
# usage: build_charmmgui_deLP_lig ${file}                                           # 
#####################################################################################
bulid_charmmgui(){
    ffpath="/home/yqyang/software/toppar"
    namd_pre="/home/yqyang/software/namd_pre"
    mkdir ${1}
    tar -zxvf charmm-gui.tgz -C ${1}
    mkdir build
    cd build
    rm pipline.tcl
    cp ../com21-receptor.pdb .
    cp ${namd_pre}/top_all36_cgenff.rtf .
    cp ${namd_pre}/top_all36_prot.rtf .
    cp ${namd_pre}/toppar_water_ions.str .
    cp ../${1}/charmm*/ligandrm.pdb .
    cp ../${1}/charmm*/lig/lig.rtf .
    echo "package require psfgen" >> pipline.tcl
    echo "psfcontext reset" >> pipline.tcl
    echo "topology top_all36_cgenff.rtf" >> pipline.tcl
    echo "topology top_all36_prot.rtf" >> pipline.tcl
    echo "topology toppar_water_ions.str" >> pipline.tcl
    echo "pdbalias residue HIS HSE" >> pipline.tcl
    echo "alias atom ILE CD1 CD" >> pipline.tcl        
    echo "alias atom SER HG HG1" >> pipline.tcl         
    echo "alias atom CYS HG HG1" >> pipline.tcl   
    echo "segment PRO {pdb com21-receptor.pdb}" >> pipline.tcl
    echo "coordpdb com21-receptor.pdb PRO" >> pipline.tcl
    echo "topology lig.rtf" >> pipline.tcl
    echo "segment LIG {" >> pipline.tcl
    echo "    first none" >> pipline.tcl
    echo "    last none" >> pipline.tcl
    echo "    pdb ligandrm.pdb" >> pipline.tcl
    echo "    }" >> pipline.tcl
    echo "coordpdb ligandrm.pdb LIG" >> pipline.tcl
    echo "guesscoord" >> pipline.tcl
    echo "writepdb merged.pdb" >> pipline.tcl
    echo "writepsf merged.psf" >> pipline.tcl
    echo "psfcontext reset" >> pipline.tcl
    echo "mol load psf merged.psf pdb merged.pdb" >> pipline.tcl
    echo "package require solvate" >> pipline.tcl
    echo "solvate merged.psf merged.pdb -t 11.5 -o solvated" >> pipline.tcl
    echo "mol delete all" >> pipline.tcl
    echo "package require autoionize" >> pipline.tcl
    echo "autoionize -psf solvated.psf -pdb solvated.pdb -sc 0.15 -o system" >> pipline.tcl
    echo "exit" >> pipline.tcl
    /home/yqyang/software/vmd-1.9.4a57-installed/vmd -dispdev text -e pipline.tcl
    cd ..
    mkdir md
    cd md
    cp ../build/system.pdb .
    cp ../build/system.psf .
    cp -r ${ffpath} .
    mkdir prod
    cp ../${1}/charmm*/lig/lig.prm ./toppar/
}

bulid_charmmgui_deLP(){
    ffpath="/home/yqyang/software/toppar"
    namd_pre="/home/yqyang/software/namd_pre"
    mkdir ${1}
    tar -zxvf charmm-gui.tgz -C ${1}
    mkdir build
    cd build
    rm pipline.tcl
    cp ../com21-receptor.pdb .
    cp ${namd_pre}/top_all36_cgenff.rtf .
    cp ${namd_pre}/top_all36_prot.rtf .
    cp ${namd_pre}/toppar_water_ions.str .
    cp ../${1}/charmm*/ligandrm.pdb .
    sed -i '/LP/d' ligandrm.pdb
    cp ../${1}/charmm*/lig/lig.rtf .
    sed -i '/LP/d' lig.rtf
    echo "package require psfgen" >> pipline.tcl
    echo "psfcontext reset" >> pipline.tcl
    echo "topology top_all36_cgenff.rtf" >> pipline.tcl
    echo "topology top_all36_prot.rtf" >> pipline.tcl
    echo "topology toppar_water_ions.str" >> pipline.tcl
    echo "pdbalias residue HIS HSE" >> pipline.tcl
    echo "alias atom ILE CD1 CD" >> pipline.tcl        
    echo "alias atom SER HG HG1" >> pipline.tcl         
    echo "alias atom CYS HG HG1" >> pipline.tcl   
    echo "segment PRO {pdb com21-receptor.pdb}" >> pipline.tcl
    echo "coordpdb com21-receptor.pdb PRO" >> pipline.tcl
    echo "topology lig.rtf" >> pipline.tcl
    echo "segment LIG {" >> pipline.tcl
    echo "    first none" >> pipline.tcl
    echo "    last none" >> pipline.tcl
    echo "    pdb ligandrm.pdb" >> pipline.tcl
    echo "    }" >> pipline.tcl
    echo "coordpdb ligandrm.pdb LIG" >> pipline.tcl
    echo "guesscoord" >> pipline.tcl
    echo "writepdb merged.pdb" >> pipline.tcl
    echo "writepsf merged.psf" >> pipline.tcl
    echo "psfcontext reset" >> pipline.tcl
    echo "mol load psf merged.psf pdb merged.pdb" >> pipline.tcl
    echo "package require solvate" >> pipline.tcl
    echo "solvate merged.psf merged.pdb -t 11.5 -o solvated" >> pipline.tcl
    echo "mol delete all" >> pipline.tcl
    echo "package require autoionize" >> pipline.tcl
    echo "autoionize -psf solvated.psf -pdb solvated.pdb -sc 0.15 -o system" >> pipline.tcl
    echo "exit" >> pipline.tcl
    /home/yqyang/software/vmd-1.9.4a57-installed/vmd -dispdev text -e pipline.tcl
    cd ..
    mkdir md
    cd md
    cp ../build/system.pdb .
    cp ../build/system.psf .
    cp -r ${ffpath} .
    mkdir prod
    cp ../${1}/charmm*/lig/lig.prm ./toppar/
}

build_charmmgui_deLP_lig(){
    ffpath="/home/yqyang/software/toppar"
    namd_pre="/home/yqyang/software/namd_pre"
    mkdir ${1}
    tar -zxvf charmm-gui.tgz -C ${1}
    mkdir build
    cd build
    rm pipline.tcl
    cp ${namd_pre}/top_all36_cgenff.rtf .
    cp ${namd_pre}/top_all36_prot.rtf .
    cp ${namd_pre}/toppar_water_ions.str .
    cp ../${1}/charmm*/ligandrm.pdb .
    sed -i '/LP/d' ligandrm.pdb
    cp ../${1}/charmm*/lig/lig.rtf .
    sed -i '/LP/d' lig.rtf
    echo "package require psfgen" >> pipline.tcl
    echo "psfcontext reset" >> pipline.tcl
    echo "topology top_all36_cgenff.rtf" >> pipline.tcl
    echo "topology top_all36_prot.rtf" >> pipline.tcl
    echo "topology toppar_water_ions.str" >> pipline.tcl 
    echo "topology lig.rtf" >> pipline.tcl
    echo "segment LIG {" >> pipline.tcl
    echo "    first none" >> pipline.tcl
    echo "    last none" >> pipline.tcl
    echo "    pdb ligandrm.pdb" >> pipline.tcl
    echo "    }" >> pipline.tcl
    echo "coordpdb ligandrm.pdb LIG" >> pipline.tcl
    echo "guesscoord" >> pipline.tcl
    echo "writepdb merged.pdb" >> pipline.tcl
    echo "writepsf merged.psf" >> pipline.tcl
    echo "exit" >> pipline.tcl
    /home/yqyang/software/vmd-1.9.4a57-installed/vmd -dispdev text -e pipline.tcl
    rm pipline.tcl

    rm do.py
    cat > do.py << EOF
def set_watbox(file_in):
    with open(file_in) as f:
        f1 = f.readlines()
    x = []
    y = []
    z = []
    for i in f1:
        if i.startswith("ATOM"):
            x.append(float(i[30:38]))
            y.append(float(i[38:46]))
            z.append(float(i[46:54]))
    center = ((max(x)+min(x))/2, (max(y)+min(y))/2, (max(z)+min(z))/2)
    # x_com = max(x) - min(x)
    # y_com = max(y) - min(y)
    # z_com = max(z) - min(z)
    # radius = max(x_com, y_com, z_com)/2 + 12
    # x_min = int(center[0] - radius)
    # x_max = int(center[0] + radius)
    # y_min = int(center[1] - radius)
    # y_max = int(center[1] + radius)
    # z_min = int(center[2] - radius)
    # z_max = int(center[2] + radius)
    x_min = int(center[0] - 61.332000732421875/2)
    x_max = int(center[0] + 61.332000732421875/2)
    y_min = int(center[1] - 90.60100173950195/2)
    y_max = int(center[1] + 90.60100173950195/2)
    z_min = int(center[2] - 85.95899963378906/2)
    z_max = int(center[2] + 85.95899963378906/2)
    print("{{{{{0} {1} {2}}} {{{3} {4} {5}}}}}".format(x_min, y_min, z_min, x_max, y_max, z_max))
    # print(x_min, x_max, y_min, y_max, z_min, z_max)
    return x_min, x_max, y_min, y_max, z_min, z_max

def main():
    import sys

    set_watbox(sys.argv[1])

if __name__=="__main__":
    main() 
EOF
    box_size=`python do.py merged.pdb`
    rm do.py
    echo "package require pbctools" >> pipline.tcl
    echo "psfcontext reset" >> pipline.tcl
    echo "mol load psf merged.psf pdb merged.pdb" >> pipline.tcl
    echo "package require solvate" >> pipline.tcl
    echo "solvate merged.psf merged.pdb -minmax ${box_size} -o solvated" >> pipline.tcl
    echo "mol delete all" >> pipline.tcl
    echo "package require autoionize" >> pipline.tcl
    echo "autoionize -psf solvated.psf -pdb solvated.pdb -sc 0.15 -o system" >> pipline.tcl
    echo "pbc box -center centerofmass" >> pipline.tcl
    echo "exit" >> pipline.tcl
    /home/yqyang/software/vmd-1.9.4a57-installed/vmd -dispdev text -e pipline.tcl
    # rm pipline.tcl
    cd ..
    mkdir md
    cd md
    cp ../build/system.pdb .
    cp ../build/system.psf .
    cp -r ${ffpath} .
    mkdir prod
    cp ../${1}/charmm*/lig/lig.prm ./toppar/
}

#####################################################################################
# Position restraints in NAMD.                                                      #
# usage: position_restraints                                                        #
#####################################################################################
position_restraints(){
    # protein="((segname PRO) and noh)"
    protein_backbone="((segname PRO) and backbone)"
    ligand="((segname LIG) and noh)"

    cat > tcl <<EOF
# mol new system.pdb type pdb waitfor all
mol new complex-fep.pdb type pdb waitfor all
set all [atomselect top "all"]

# \$all set beta 0
# set sel [atomselect top "(${protein} or ${ligand})"]
# set sel [atomselect top "${ligand}"]
# \$sel set beta 1
# \$all writepdb constraints_all.pdb

\$all set beta 0
set sel [atomselect top "(${protein_backbone} or ${ligand})"]
\$sel set beta 1
# \$all writepdb constraints_backbone.pdb
\$all writepdb constraints.pdb

quit
EOF

    /home/yqyang/software/vmd-1.9.4a57-installed/vmd -dispdev text -e tcl
    rm tcl
}

#####################################################################################
# Generate config files for NAMD.                                                   #
# Generate em config file.                                                          #
# usage: generate_em_config                                                         #
# Generate nvt config file.                                                         #
# usage: generate_nvt_config                                                        #
# Generate nptstep1 config file. Heavy atoms of protein and ligand are constrainted.#
# usage: generate_nptstep1_config                                                   #    
# Generate nptstep2 config file. Backbone of protein and ligand are constrainted.   #
# usage: generate_nptstep2_config                                                   #
# Generate prodstep1 config file. Backbone of protein and ligand are constrainted.  #
# usage: generate_prodstep1_config                                                  #
# Generate prodstep2 config file. No any constraint.                                #
# usage: generate_prodstep2_config                                                  #
# Generate run namd file.                                                           #
# usage: generate_namd                                                              #
#####################################################################################
generate_em_config(){
    cat > pro-lig-em << EOF
#############################################################
## JOB DESCRIPTION                                         ##
#############################################################

# Minimization
# namd3 +p11 pro-lig-em > pro-lig-em.log

#############################################################
## ADJUSTABLE PARAMETERS                                   ##
#############################################################

structure          ../system.psf
coordinates        ../system.pdb
set outputbase     com

firsttimestep      0

# open names all, later will control
set ITEMP 310
set FTEMP 310
# if you do not want to open this option, assign 0
set INPUTNAME   0                      ;# use the former outputName, for restarting a simulation
set PSWITCH     1                      ;# whether to use langevinPiston pressure control
set FIXPDB      0
set CONSPDB     0
set CONSSCALE   1                      ;# default; initial value if you want to change

#############################################################
## SIMULATION PARAMETERS                                   ##
#############################################################

# Input
paraTypeCharmm      on
parameters          ../toppar/lig.prm
parameters          ../toppar/par_all36m_prot.prm
parameters          ../toppar/par_all36_na.prm
parameters          ../toppar/par_all36_cgenff.prm
mergeCrossterms yes
parameters          ../toppar/par_all35_ethers.prm
parameters          ../toppar/par_all36_carb.prm
parameters          ../toppar/par_all36_lipid_ljpme.prm
parameters          ../toppar/toppar_water_ions_namd.str
parameters          ../toppar/par_interface.prm
parameters          ../toppar/toppar_all36_moreions.str
parameters          ../toppar/toppar_all36_synthetic_polymer.str
parameters          ../toppar/toppar_all36_synthetic_polymer_patch.str
parameters          ../toppar/toppar_all36_polymer_solvent.str
parameters          ../toppar/toppar_dum_noble_gases.str
parameters          ../toppar/toppar_ions_won.str
parameters          ../toppar/toppar_all36_prot_arg0.str
parameters          ../toppar/toppar_all36_prot_c36m_d_aminoacids.str
parameters          ../toppar/toppar_all36_prot_fluoro_alkanes.str
parameters          ../toppar/toppar_all36_prot_heme.str
parameters          ../toppar/toppar_all36_prot_na_combined.str
parameters          ../toppar/toppar_all36_prot_retinol.str
parameters          ../toppar/toppar_all36_prot_model.str
parameters          ../toppar/toppar_all36_prot_modify_res.str
parameters          ../toppar/toppar_all36_na_nad_ppi.str
parameters          ../toppar/toppar_all36_na_rna_modified.str
# parameters          ../toppar/toppar_all36_lipid_sphingo.str
parameters          ../toppar/toppar_all36_lipid_archaeal.str
parameters          ../toppar/toppar_all36_lipid_bacterial.str
parameters          ../toppar/toppar_all36_lipid_cardiolipin.str
parameters          ../toppar/toppar_all36_lipid_cholesterol.str
parameters          ../toppar/toppar_all36_lipid_dag.str
parameters          ../toppar/toppar_all36_lipid_inositol.str
parameters          ../toppar/toppar_all36_lipid_lnp.str
parameters          ../toppar/toppar_all36_lipid_lps.str
parameters          ../toppar/toppar_all36_lipid_mycobacterial.str
parameters          ../toppar/toppar_all36_lipid_miscellaneous.str
parameters          ../toppar/toppar_all36_lipid_model.str
parameters          ../toppar/toppar_all36_lipid_prot.str
parameters          ../toppar/toppar_all36_lipid_tag.str
parameters          ../toppar/toppar_all36_lipid_yeast.str
parameters          ../toppar/toppar_all36_lipid_hmmm.str
parameters          ../toppar/toppar_all36_lipid_detergent.str
parameters          ../toppar/toppar_all36_lipid_ether.str
parameters          ../toppar/toppar_all36_carb_glycolipid.str
parameters          ../toppar/toppar_all36_carb_glycopeptide.str
parameters          ../toppar/toppar_all36_carb_imlab.str
# parameters          ../toppar/toppar_all36_label_spin.str       ;# charmm code
parameters          ../toppar/toppar_all36_label_fluorophore.str

# restart or PBC
if { \$INPUTNAME != 0 } {
    # restart
    BinVelocities \$INPUTNAME.restart.vel.old
    BinCoordinates \$INPUTNAME.restart.coor.old
    ExtendedSystem \$INPUTNAME.restart.xsc.old
} else {
    # Periodic Boundary Conditionsc
    temperature \$ITEMP
    cellBasisVector1 61.46500015258789 0 0
    cellBasisVector2 0 90.86600112915039 0
    cellBasisVector3 0 0 86.00200271606445
    cellOrigin 12.017499923706055 0.5860004425048828 6.76099967956543
}

## Force-Field Parameters
exclude             scaled1-4;         # non-bonded exclusion policy to use "none,1-2,1-3,1-4,or scaled1-4"
                                    # 1-2: all atoms pairs that are bonded are going to be ignored
                                    # 1-3: 3 consecutively bonded are excluded
                                    # scaled1-4: include all the 1-3, and modified 1-4 interactions
                                    # electrostatic scaled by 1-4scaling factor 1.0
                                    # vdW special 1-4 parameters in charmm parameter file.
1-4scaling          1.0

# CUT-OFFS
switching                on
switchdist              10.0
cutoff                  12.0
pairlistdist            13.5

PME                     yes
PMEGridSpacing          1.0
PMETolerance            10e-6
PMEInterpOrder          4

wrapWater               on;                # wrap water to central cell
wrapAll                 on;                # wrap other molecules too
wrapNearest             off;               # use for non-rectangular cells (wrap to the nearest image)

# SPACE PARTITIONING
splitpatch              hydrogen
hgroupcutoff            2.8
stepspercycle           20
margin                  2
longSplitting           C2

# RESPA PROPAGATOR
# timestep                1.0
timestep                2.0
useSettle               on
fullElectFrequency      2
nonbondedFreq           1

# SHAKE
rigidbonds              all
rigidtolerance          0.000001
rigiditerations         400

# COM
ComMotion               no

# vdw
vdwForceSwitching       on

# Constant Temperature Control
if { \$ITEMP == \$FTEMP } {
    langevin                   on;         # do langevin dynamics
    langevinDamping             1;         # damping coefficient (gamma) of 1/ps
                                        # 5/ps by Junfan
    langevinTemp           \$FTEMP;
    langevinHydrogen          off;         # don't couple langevin bath to hydrogens
} else {
    reassignFreq 1000;                     # use this to reassign velocity every 1000 steps
    if { \$FTEMP > \$ITEMP } {
        reassignIncr 10
    } else {
        reassignIncr -10
    }
    reassignTemp \$ITEMP
    reassignHold \$FTEMP
}

# Constant Pressure Control (variable volume)
if { \$PSWITCH != 0 } {
    # if running G-actin remove/comment out these 3 lines
    # by Junfan
    # CONSTANT-P, not in tutorial
    useGroupPressure        yes;           # use a hydrogen-group based pseudo-molecular viral to calcualte pressure and
                                        # has less fluctuation, is needed for rigid bonds (rigidBonds/SHAKE)
    useFlexibleCell         no;            # yes for anisotropic system like membrane
    useConstantRatio        no;            # keeps the ratio of the unit cell in the x-y plane constant A=B
    #    useConstatntArea     yes;
    langevinPiston          on
    langevinPistonTarget    1.01325
    langevinPistonPeriod    100;         # 100? 2000?
    langevinPistonDecay     50;         # 50?
    langevinPistonTemp      \$FTEMP
    StrainRate              0.0 0.0 0.0
}

# Output
outputname \$outputbase-em;

#@ equilibration work flow. have to put in the end!
# run one step to get into scripting mode
minimize                0

# turn off until later
langevinPiston          off

# min all atoms
minimize                10000
EOF
}

generate_nvt_config(){
    cat > pro-lig-nvt << EOF
#############################################################
## JOB DESCRIPTION                                         ##
#############################################################

# NVT
# namd3 +p10 +devices 0 pro-lig-nvt 2 >pro-lig-nvt.log  

#############################################################
## ADJUSTABLE PARAMETERS                                   ##
#############################################################

structure          ../system.psf
coordinates        ../system.pdb
set outputbase     com

firsttimestep      0

set                 ITEMP 310
set                 FTEMP 310
set                 INPUTNAME   0                      ;# use the former outputName, for restarting a simulation
set                 PSWITCH     0                      ;# whether to use langevinPiston pressure control
set                 CONSSCALE   1                      ;# default; initial value if you want to change
set                 CONSPDB     ../constraints_all

#############################################################
## SIMULATION PARAMETERS                                   ##
#############################################################

# Input
paraTypeCharmm      on
parameters          ../toppar/lig.prm
parameters          ../toppar/par_all36m_prot.prm
parameters          ../toppar/par_all36_na.prm
parameters          ../toppar/par_all36_cgenff.prm
mergeCrossterms yes
parameters          ../toppar/par_all35_ethers.prm
parameters          ../toppar/par_all36_carb.prm
parameters          ../toppar/par_all36_lipid_ljpme.prm
parameters          ../toppar/toppar_water_ions_namd.str
parameters          ../toppar/par_interface.prm
parameters          ../toppar/toppar_all36_moreions.str
parameters          ../toppar/toppar_all36_synthetic_polymer.str
parameters          ../toppar/toppar_all36_synthetic_polymer_patch.str
parameters          ../toppar/toppar_all36_polymer_solvent.str
parameters          ../toppar/toppar_dum_noble_gases.str
parameters          ../toppar/toppar_ions_won.str
parameters          ../toppar/toppar_all36_prot_arg0.str
parameters          ../toppar/toppar_all36_prot_c36m_d_aminoacids.str
parameters          ../toppar/toppar_all36_prot_fluoro_alkanes.str
parameters          ../toppar/toppar_all36_prot_heme.str
parameters          ../toppar/toppar_all36_prot_na_combined.str
parameters          ../toppar/toppar_all36_prot_retinol.str
parameters          ../toppar/toppar_all36_prot_model.str
parameters          ../toppar/toppar_all36_prot_modify_res.str
parameters          ../toppar/toppar_all36_na_nad_ppi.str
parameters          ../toppar/toppar_all36_na_rna_modified.str
# parameters          ../toppar/toppar_all36_lipid_sphingo.str
parameters          ../toppar/toppar_all36_lipid_archaeal.str
parameters          ../toppar/toppar_all36_lipid_bacterial.str
parameters          ../toppar/toppar_all36_lipid_cardiolipin.str
parameters          ../toppar/toppar_all36_lipid_cholesterol.str
parameters          ../toppar/toppar_all36_lipid_dag.str
parameters          ../toppar/toppar_all36_lipid_inositol.str
parameters          ../toppar/toppar_all36_lipid_lnp.str
parameters          ../toppar/toppar_all36_lipid_lps.str
parameters          ../toppar/toppar_all36_lipid_mycobacterial.str
parameters          ../toppar/toppar_all36_lipid_miscellaneous.str
parameters          ../toppar/toppar_all36_lipid_model.str
parameters          ../toppar/toppar_all36_lipid_prot.str
parameters          ../toppar/toppar_all36_lipid_tag.str
parameters          ../toppar/toppar_all36_lipid_yeast.str
parameters          ../toppar/toppar_all36_lipid_hmmm.str
parameters          ../toppar/toppar_all36_lipid_detergent.str
parameters          ../toppar/toppar_all36_lipid_ether.str
parameters          ../toppar/toppar_all36_carb_glycolipid.str
parameters          ../toppar/toppar_all36_carb_glycopeptide.str
parameters          ../toppar/toppar_all36_carb_imlab.str
# parameters          ../toppar/toppar_all36_label_spin.str       ;# charmm code
parameters          ../toppar/toppar_all36_label_fluorophore.str

# restart or PBC
if { \$INPUTNAME != 0 } {
    # restart
    BinVelocities \$INPUTNAME.restart.vel.old
    BinCoordinates \$INPUTNAME.restart.coor.old
    ExtendedSystem \$INPUTNAME.restart.xsc.old
} else {
    bincoordinates      \${outputbase}-em.coor
    binvelocities       \${outputbase}-em.vel
    extendedSystem      \${outputbase}-em.xsc
}

## Force-Field Parameters
exclude             scaled1-4;         # non-bonded exclusion policy to use "none,1-2,1-3,1-4,or scaled1-4"
                                    # 1-2: all atoms pairs that are bonded are going to be ignored
                                    # 1-3: 3 consecutively bonded are excluded
                                    # scaled1-4: include all the 1-3, and modified 1-4 interactions
                                    # electrostatic scaled by 1-4scaling factor 1.0
                                    # vdW special 1-4 parameters in charmm parameter file.
1-4scaling              1.0

# CUT-OFFS
switching                on
switchdist              10.0
cutoff                  12.0
pairlistdist            13.5

PME                     yes
PMEGridSpacing          1.0
PMETolerance            10e-6
PMEInterpOrder          4

wrapWater               on;                # wrap water to central cell
wrapAll                 on;                # wrap other molecules too
wrapNearest             off;               # use for non-rectangular cells (wrap to the nearest image)

# SPACE PARTITIONING
splitpatch              hydrogen
hgroupcutoff            2.8
stepspercycle           20
margin                  2
longSplitting           C2

# RESPA PROPAGATOR
# timestep                1.0
timestep                2.0
useSettle               on
fullElectFrequency      2
nonbondedFreq           1

# SHAKE
rigidbonds              all
rigidtolerance          0.000001
rigiditerations         400

# vdw
vdwForceSwitching       on

# Constant Temperature Control
if { \$ITEMP == \$FTEMP } {
    langevin                   on;         # do langevin dynamics
    langevinDamping             1;         # damping coefficient (gamma) of 1/ps
                                        # 5/ps by Junfan
    langevinTemp           \$FTEMP;
    langevinHydrogen          off;         # don't couple langevin bath to hydrogens
} else {
    reassignFreq 1000;                     # use this to reassign velocity every 1000 steps
    if { \$FTEMP > \$ITEMP } {
        reassignIncr 10
    } else {
        reassignIncr -10
    }
    reassignTemp \$ITEMP
    reassignHold \$FTEMP
}

# according to P. Blood use "no" for first NPT run
# then use "yes" for all NPT runs afterward
COMmotion no

#############################################################
## EXECUTION SCRIPT                                        ##
#############################################################

# Output
outputname \$outputbase-nvt;

# 500steps = every 1ps
restartfreq         50000
dcdfreq             50000
xstFreq             50000
outputEnergies      50000
outputPressure      50000
outputTiming        50000

# CUDASOAintegrate        on

# Positional restraints
# Write out a separate pdb file in which the B values for
# the backbone, the non-hydrogen nucleotide atoms, the ion,
# and the water oxygens within 2.5 A of magnesium are set to 2
if { \$CONSPDB != 0 } {
        Constraints          yes
    ConsRef              \$CONSPDB.pdb
    ConsKFile            \$CONSPDB.pdb
    ConskCol             B
    constraintScaling    \$CONSSCALE
}

# NVT
langevinPiston          off
run                     20000
EOF
}

generate_nptstep1_config(){
    cat > pro-lig-nptstep1 << EOF
#############################################################
## JOB DESCRIPTION                                         ##
#############################################################

# nptstep1, Heavy atoms of protein and ligand are constrainted
# namd3 +p10 +devices 0 pro-lig-nptstep1 > pro-lig-nptstep1.log

#############################################################
## ADJUSTABLE PARAMETERS                                   ##
#############################################################

structure          ../system.psf
coordinates        ../system.pdb
set outputbase     com

firsttimestep      0

set                 ITEMP 310
set                 FTEMP 310
set                 INPUTNAME   0                      ;# use the former outputName, for restarting a simulation
set                 PSWITCH     0                      ;# whether to use langevinPiston pressure control
set                 CONSSCALE   1                      ;# default; initial value if you want to change
set                 CONSPDB     ../constraints_all

#############################################################
## SIMULATION PARAMETERS                                   ##
#############################################################

# Input
paraTypeCharmm      on
parameters          ../toppar/lig.prm
parameters          ../toppar/par_all36m_prot.prm
parameters          ../toppar/par_all36_na.prm
parameters          ../toppar/par_all36_cgenff.prm
mergeCrossterms yes
parameters          ../toppar/par_all35_ethers.prm
parameters          ../toppar/par_all36_carb.prm
parameters          ../toppar/par_all36_lipid_ljpme.prm
parameters          ../toppar/toppar_water_ions_namd.str
parameters          ../toppar/par_interface.prm
parameters          ../toppar/toppar_all36_moreions.str
parameters          ../toppar/toppar_all36_synthetic_polymer.str
parameters          ../toppar/toppar_all36_synthetic_polymer_patch.str
parameters          ../toppar/toppar_all36_polymer_solvent.str
parameters          ../toppar/toppar_dum_noble_gases.str
parameters          ../toppar/toppar_ions_won.str
parameters          ../toppar/toppar_all36_prot_arg0.str
parameters          ../toppar/toppar_all36_prot_c36m_d_aminoacids.str
parameters          ../toppar/toppar_all36_prot_fluoro_alkanes.str
parameters          ../toppar/toppar_all36_prot_heme.str
parameters          ../toppar/toppar_all36_prot_na_combined.str
parameters          ../toppar/toppar_all36_prot_retinol.str
parameters          ../toppar/toppar_all36_prot_model.str
parameters          ../toppar/toppar_all36_prot_modify_res.str
parameters          ../toppar/toppar_all36_na_nad_ppi.str
parameters          ../toppar/toppar_all36_na_rna_modified.str
# parameters          ../toppar/toppar_all36_lipid_sphingo.str
parameters          ../toppar/toppar_all36_lipid_archaeal.str
parameters          ../toppar/toppar_all36_lipid_bacterial.str
parameters          ../toppar/toppar_all36_lipid_cardiolipin.str
parameters          ../toppar/toppar_all36_lipid_cholesterol.str
parameters          ../toppar/toppar_all36_lipid_dag.str
parameters          ../toppar/toppar_all36_lipid_inositol.str
parameters          ../toppar/toppar_all36_lipid_lnp.str
parameters          ../toppar/toppar_all36_lipid_lps.str
parameters          ../toppar/toppar_all36_lipid_mycobacterial.str
parameters          ../toppar/toppar_all36_lipid_miscellaneous.str
parameters          ../toppar/toppar_all36_lipid_model.str
parameters          ../toppar/toppar_all36_lipid_prot.str
parameters          ../toppar/toppar_all36_lipid_tag.str
parameters          ../toppar/toppar_all36_lipid_yeast.str
parameters          ../toppar/toppar_all36_lipid_hmmm.str
parameters          ../toppar/toppar_all36_lipid_detergent.str
parameters          ../toppar/toppar_all36_lipid_ether.str
parameters          ../toppar/toppar_all36_carb_glycolipid.str
parameters          ../toppar/toppar_all36_carb_glycopeptide.str
parameters          ../toppar/toppar_all36_carb_imlab.str
# parameters          ../toppar/toppar_all36_label_spin.str       ;# charmm code
parameters          ../toppar/toppar_all36_label_fluorophore.str

# restart or PBC
if { \$INPUTNAME != 0 } {
    # restart
    BinVelocities \$INPUTNAME.restart.vel.old
    BinCoordinates \$INPUTNAME.restart.coor.old
    ExtendedSystem \$INPUTNAME.restart.xsc.old
} else {
    bincoordinates      \${outputbase}-nvt.coor
    binvelocities       \${outputbase}-nvt.vel
    extendedSystem      \${outputbase}-nvt.xsc
}

## Force-Field Parameters
exclude             scaled1-4;         # non-bonded exclusion policy to use "none,1-2,1-3,1-4,or scaled1-4"
                                    # 1-2: all atoms pairs that are bonded are going to be ignored
                                    # 1-3: 3 consecutively bonded are excluded
                                    # scaled1-4: include all the 1-3, and modified 1-4 interactions
                                    # electrostatic scaled by 1-4scaling factor 1.0
                                    # vdW special 1-4 parameters in charmm parameter file.
1-4scaling              1.0

# CUT-OFFS
switching                on
switchdist              10.0
cutoff                  12.0
pairlistdist            13.5

PME                     yes
PMEGridSpacing          1.0
PMETolerance            10e-6
PMEInterpOrder          4

wrapWater               on;                # wrap water to central cell
wrapAll                 on;                # wrap other molecules too
wrapNearest             off;               # use for non-rectangular cells (wrap to the nearest image)

# SPACE PARTITIONING
splitpatch              hydrogen
hgroupcutoff            2.8
stepspercycle           20
margin                  2
longSplitting           C2

# RESPA PROPAGATOR
# timestep                1.0
timestep                2.0
useSettle               on
fullElectFrequency      2
nonbondedFreq           1

# SHAKE
rigidbonds              all
rigidtolerance          0.000001
rigiditerations         400

# vdw
vdwForceSwitching       on

# Constant Temperature Control
if { \$ITEMP == \$FTEMP } {
    langevin                   on;         # do langevin dynamics
    langevinDamping             1;         # damping coefficient (gamma) of 1/ps
                                        # 5/ps by Junfan
    langevinTemp           \$FTEMP;
    langevinHydrogen          off;         # don't couple langevin bath to hydrogens
} else {
    reassignFreq 1000;                     # use this to reassign velocity every 1000 steps
    if { \$FTEMP > \$ITEMP } {
        reassignIncr 10
    } else {
        reassignIncr -10
    }
    reassignTemp \$ITEMP
    reassignHold \$FTEMP
}

# according to P. Blood use "no" for first NPT run
# then use "yes" for all NPT runs afterward
COMmotion no

#############################################################
## EXECUTION SCRIPT                                        ##
#############################################################

# Output
outputname \$outputbase-nptstep1;

# 500steps = every 1ps
restartfreq         50000
dcdfreq             50000
xstFreq             50000
outputEnergies      50000
outputPressure      50000
outputTiming        50000

# CUDASOAintegrate        on

# Positional restraints
# Write out a separate pdb file in which the B values for
# the backbone, the non-hydrogen nucleotide atoms, the ion,
# and the water oxygens within 2.5 A of magnesium are set to 2
if { \$CONSPDB != 0 } {
        Constraints          yes
        ConsRef              \$CONSPDB.pdb
        ConsKFile            \$CONSPDB.pdb
        ConskCol             B
        constraintScaling    \$CONSSCALE
}

set PSWITCH 1
# Constant Pressure Control (variable volume)
if { \$PSWITCH != 0 } {
    # if running G-actin remove/comment out these 3 lines
    # by Junfan
    # CONSTANT-P, not in tutorial
    useGroupPressure        yes;           # use a hydrogen-group based pseudo-molecular viral to calcualte pressure and
                                        # has less fluctuation, is needed for rigid bonds (rigidBonds/SHAKE)
    useFlexibleCell         no;            # yes for anisotropic system like membrane
    useConstantRatio        no;            # keeps the ratio of the unit cell in the x-y plane constant A=B
    #    useConstatntArea     yes;
    langevinPiston          on
    langevinPistonTarget    1.01325
    langevinPistonPeriod    100;         # 100? 2000?
    langevinPistonDecay     100;         # 50?
    langevinPistonTemp      \$FTEMP
    #StrainRate              0.0 0.0 0.0
}

run                     5000000  ;# 10ns
EOF
}

generate_nptstep2_config(){
    cat > pro-lig-nptstep2 << EOF
#############################################################
## JOB DESCRIPTION                                         ##
#############################################################

# nptstep2, backbone of protein and ligand are constrainted.
# namd3 +p10 +devices 0 pro-lig-nptstep2 > pro-lig-nptstep2.log

#############################################################
## ADJUSTABLE PARAMETERS                                   ##
#############################################################

structure          ../system.psf
coordinates        ../system.pdb
set outputbase     com

firsttimestep      0

set                 ITEMP 310
set                 FTEMP 310
set                 INPUTNAME   0                      ;# use the former outputName, for restarting a simulation
set                 PSWITCH     0                      ;# whether to use langevinPiston pressure control
set                 CONSSCALE   1                      ;# default; initial value if you want to change
set                 CONSPDB     ../constraints_backbone

#############################################################
## SIMULATION PARAMETERS                                   ##
#############################################################

# Input
paraTypeCharmm      on
parameters          ../toppar/lig.prm
parameters          ../toppar/par_all36m_prot.prm
parameters          ../toppar/par_all36_na.prm
parameters          ../toppar/par_all36_cgenff.prm
mergeCrossterms yes
parameters          ../toppar/par_all35_ethers.prm
parameters          ../toppar/par_all36_carb.prm
parameters          ../toppar/par_all36_lipid_ljpme.prm
parameters          ../toppar/toppar_water_ions_namd.str
parameters          ../toppar/par_interface.prm
parameters          ../toppar/toppar_all36_moreions.str
parameters          ../toppar/toppar_all36_synthetic_polymer.str
parameters          ../toppar/toppar_all36_synthetic_polymer_patch.str
parameters          ../toppar/toppar_all36_polymer_solvent.str
parameters          ../toppar/toppar_dum_noble_gases.str
parameters          ../toppar/toppar_ions_won.str
parameters          ../toppar/toppar_all36_prot_arg0.str
parameters          ../toppar/toppar_all36_prot_c36m_d_aminoacids.str
parameters          ../toppar/toppar_all36_prot_fluoro_alkanes.str
parameters          ../toppar/toppar_all36_prot_heme.str
parameters          ../toppar/toppar_all36_prot_na_combined.str
parameters          ../toppar/toppar_all36_prot_retinol.str
parameters          ../toppar/toppar_all36_prot_model.str
parameters          ../toppar/toppar_all36_prot_modify_res.str
parameters          ../toppar/toppar_all36_na_nad_ppi.str
parameters          ../toppar/toppar_all36_na_rna_modified.str
# parameters          ../toppar/toppar_all36_lipid_sphingo.str
parameters          ../toppar/toppar_all36_lipid_archaeal.str
parameters          ../toppar/toppar_all36_lipid_bacterial.str
parameters          ../toppar/toppar_all36_lipid_cardiolipin.str
parameters          ../toppar/toppar_all36_lipid_cholesterol.str
parameters          ../toppar/toppar_all36_lipid_dag.str
parameters          ../toppar/toppar_all36_lipid_inositol.str
parameters          ../toppar/toppar_all36_lipid_lnp.str
parameters          ../toppar/toppar_all36_lipid_lps.str
parameters          ../toppar/toppar_all36_lipid_mycobacterial.str
parameters          ../toppar/toppar_all36_lipid_miscellaneous.str
parameters          ../toppar/toppar_all36_lipid_model.str
parameters          ../toppar/toppar_all36_lipid_prot.str
parameters          ../toppar/toppar_all36_lipid_tag.str
parameters          ../toppar/toppar_all36_lipid_yeast.str
parameters          ../toppar/toppar_all36_lipid_hmmm.str
parameters          ../toppar/toppar_all36_lipid_detergent.str
parameters          ../toppar/toppar_all36_lipid_ether.str
parameters          ../toppar/toppar_all36_carb_glycolipid.str
parameters          ../toppar/toppar_all36_carb_glycopeptide.str
parameters          ../toppar/toppar_all36_carb_imlab.str
# parameters          ../toppar/toppar_all36_label_spin.str       ;# charmm code
parameters          ../toppar/toppar_all36_label_fluorophore.str

# restart or PBC
if { \$INPUTNAME != 0 } {
    # restart
    BinVelocities \$INPUTNAME.restart.vel.old
    BinCoordinates \$INPUTNAME.restart.coor.old
    ExtendedSystem \$INPUTNAME.restart.xsc.old
} else {
    bincoordinates      \${outputbase}-nptstep1.coor
    binvelocities       \${outputbase}-nptstep1.vel
    extendedSystem      \${outputbase}-nptstep1.xsc
}


## Force-Field Parameters
exclude             scaled1-4;         # non-bonded exclusion policy to use "none,1-2,1-3,1-4,or scaled1-4"
                                    # 1-2: all atoms pairs that are bonded are going to be ignored
                                    # 1-3: 3 consecutively bonded are excluded
                                    # scaled1-4: include all the 1-3, and modified 1-4 interactions
                                    # electrostatic scaled by 1-4scaling factor 1.0
                                    # vdW special 1-4 parameters in charmm parameter file.
1-4scaling              1.0

# CUT-OFFS
switching                on
switchdist              10.0
cutoff                  12.0
pairlistdist            13.5

PME                     yes
PMEGridSpacing          1.0
PMETolerance            10e-6
PMEInterpOrder          4

wrapWater               on;                # wrap water to central cell
wrapAll                 on;                # wrap other molecules too
wrapNearest             off;               # use for non-rectangular cells (wrap to the nearest image)

# SPACE PARTITIONING
splitpatch              hydrogen
hgroupcutoff            2.8
stepspercycle           20
margin                  2
longSplitting           C2

# RESPA PROPAGATOR
# timestep                1.0
timestep                2.0
useSettle               on
fullElectFrequency      2
nonbondedFreq           1

# SHAKE
rigidbonds              all
rigidtolerance          0.000001
rigiditerations         400

# vdw
vdwForceSwitching       on

# Constant Temperature Control
if { \$ITEMP == \$FTEMP } {
    langevin                   on;         # do langevin dynamics
    langevinDamping             1;         # damping coefficient (gamma) of 1/ps
                                        # 5/ps by Junfan
    langevinTemp           \$FTEMP;
    langevinHydrogen          off;         # don't couple langevin bath to hydrogens
} else {
    reassignFreq 1000;                     # use this to reassign velocity every 1000 steps
    if { \$FTEMP > \$ITEMP } {
        reassignIncr 10
    } else {
        reassignIncr -10
    }
    reassignTemp \$ITEMP
    reassignHold \$FTEMP
}

# according to P. Blood use "no" for first NPT run
# then use "yes" for all NPT runs afterward
COMmotion no

#############################################################
## EXECUTION SCRIPT                                        ##
#############################################################

# Output
outputname \$outputbase-nptstep2;

# 500steps = every 1ps
restartfreq         50000
dcdfreq             50000
xstFreq             50000
outputEnergies      50000
outputPressure      50000
outputTiming        50000

# CUDASOAintegrate        on

# Positional restraints
# Write out a separate pdb file in which the B values for
# the backbone, the non-hydrogen nucleotide atoms, the ion,
# and the water oxygens within 2.5 A of magnesium are set to 2
if { \$CONSPDB != 0 } {
        Constraints          yes
        ConsRef              \$CONSPDB.pdb
        ConsKFile            \$CONSPDB.pdb
        ConskCol             B
        constraintScaling    \$CONSSCALE
}

set PSWITCH 1
# Constant Pressure Control (variable volume)
if { \$PSWITCH != 0 } {
    # if running G-actin remove/comment out these 3 lines
    # by Junfan
    # CONSTANT-P, not in tutorial
    useGroupPressure        yes;           # use a hydrogen-group based pseudo-molecular viral to calcualte pressure and
                                        # has less fluctuation, is needed for rigid bonds (rigidBonds/SHAKE)
    useFlexibleCell         no;            # yes for anisotropic system like membrane
    useConstantRatio        no;            # keeps the ratio of the unit cell in the x-y plane constant A=B
    #    useConstatntArea     yes;
    langevinPiston          on
    langevinPistonTarget    1.01325
    langevinPistonPeriod    100;         # 100? 2000?
    langevinPistonDecay     100;         # 50?
    langevinPistonTemp      \$FTEMP
    #StrainRate              0.0 0.0 0.0
}

run                     10000000  ;# 20ns
EOF
}

generate_prodstep1_config(){
    cat > pro-lig-prodstep1 << EOF
#############################################################
## JOB DESCRIPTION                                         ##
#############################################################

# prodstep1, backbone of protein and ligand are constrainted.
# namd3 +p10 +devices 0 pro-lig-prodstep1 > pro-lig-prodstep1.log

#############################################################
## ADJUSTABLE PARAMETERS                                   ##
#############################################################

structure          ../system.psf
coordinates        ../system.pdb     ;# or reports error
set outputbase     com               ;# consistent with equil
firsttimestep      0

#############################################################

set ITEMP 310
set FTEMP 310
# if you do not want to open this option, assign 0
set INPUTNAME       0                   ;# restart
set PSWITCH         1                   ;# whether to use langevinPiston pressure control
set FIXPDB          0
set CONSPDB         ../constraints_backbone
set CONSSCALE       1                   ;# default:1

#############################################################
## SIMULATION PARAMETERS                                   ##
#############################################################

# Input
paraTypeCharmm      on
parameters          ../toppar/lig.prm
parameters          ../toppar/par_all36m_prot.prm
parameters          ../toppar/par_all36_na.prm
parameters          ../toppar/par_all36_cgenff.prm
mergeCrossterms yes
parameters          ../toppar/par_all35_ethers.prm
parameters          ../toppar/par_all36_carb.prm
parameters          ../toppar/par_all36_lipid_ljpme.prm
parameters          ../toppar/toppar_water_ions_namd.str
parameters          ../toppar/par_interface.prm
parameters          ../toppar/toppar_all36_moreions.str
parameters          ../toppar/toppar_all36_synthetic_polymer.str
parameters          ../toppar/toppar_all36_synthetic_polymer_patch.str
parameters          ../toppar/toppar_all36_polymer_solvent.str
parameters          ../toppar/toppar_dum_noble_gases.str
parameters          ../toppar/toppar_ions_won.str
parameters          ../toppar/toppar_all36_prot_arg0.str
parameters          ../toppar/toppar_all36_prot_c36m_d_aminoacids.str
parameters          ../toppar/toppar_all36_prot_fluoro_alkanes.str
parameters          ../toppar/toppar_all36_prot_heme.str
parameters          ../toppar/toppar_all36_prot_na_combined.str
parameters          ../toppar/toppar_all36_prot_retinol.str
parameters          ../toppar/toppar_all36_prot_model.str
parameters          ../toppar/toppar_all36_prot_modify_res.str
parameters          ../toppar/toppar_all36_na_nad_ppi.str
parameters          ../toppar/toppar_all36_na_rna_modified.str
# parameters          ../toppar/toppar_all36_lipid_sphingo.str
parameters          ../toppar/toppar_all36_lipid_archaeal.str
parameters          ../toppar/toppar_all36_lipid_bacterial.str
parameters          ../toppar/toppar_all36_lipid_cardiolipin.str
parameters          ../toppar/toppar_all36_lipid_cholesterol.str
parameters          ../toppar/toppar_all36_lipid_dag.str
parameters          ../toppar/toppar_all36_lipid_inositol.str
parameters          ../toppar/toppar_all36_lipid_lnp.str
parameters          ../toppar/toppar_all36_lipid_lps.str
parameters          ../toppar/toppar_all36_lipid_mycobacterial.str
parameters          ../toppar/toppar_all36_lipid_miscellaneous.str
parameters          ../toppar/toppar_all36_lipid_model.str
parameters          ../toppar/toppar_all36_lipid_prot.str
parameters          ../toppar/toppar_all36_lipid_tag.str
parameters          ../toppar/toppar_all36_lipid_yeast.str
parameters          ../toppar/toppar_all36_lipid_hmmm.str
parameters          ../toppar/toppar_all36_lipid_detergent.str
parameters          ../toppar/toppar_all36_lipid_ether.str
parameters          ../toppar/toppar_all36_carb_glycolipid.str
parameters          ../toppar/toppar_all36_carb_glycopeptide.str
parameters          ../toppar/toppar_all36_carb_imlab.str
# parameters          ../toppar/toppar_all36_label_spin.str       ;# charmm code
parameters          ../toppar/toppar_all36_label_fluorophore.str

if { \$INPUTNAME != 0 } {
# restart
BinVelocities \$INPUTNAME.restart.vel.old
BinCoordinates \$INPUTNAME.restart.coor.old
ExtendedSystem \$INPUTNAME.restart.xsc.old
} else {
    # from equil. use the former outputName
    bincoordinates          \$outputbase-nptstep2.coor
    binvelocities           \$outputbase-nptstep2.vel
    extendedSystem      \$outputbase-nptstep2.xsc
}

## Force-Field Parameters
exclude             scaled1-4;         # non-bonded exclusion policy to use "none,1-2,1-3,1-4,or scaled1-4"
                                    # 1-2: all atoms pairs that are bonded are going to be ignored
                                    # 1-3: 3 consecutively bonded are excluded
                                    # scaled1-4: include all the 1-3, and modified 1-4 interactions
                                    # electrostatic scaled by 1-4scaling factor 1.0
                                    # vdW special 1-4 parameters in charmm parameter file.
1-4scaling          1.0

# CUT-OFFS
switching                on
switchdist              10.0
cutoff                  12.0
pairlistdist            13.5

PME                     yes
PMEGridSpacing          1.0
PMETolerance            10e-6
PMEInterpOrder          4

wrapWater               on;                # wrap water to central cell
wrapAll                 on;                # wrap other molecules too
wrapNearest             off;               # use for non-rectangular cells (wrap to the nearest image)

# SPACE PARTITIONING
splitpatch              hydrogen
hgroupcutoff            2.8
stepspercycle           20
margin                  2
longSplitting           C2

# RESPA PROPAGATOR
# timestep                1.0
timestep                2.0
useSettle               on
fullElectFrequency      2
nonbondedFreq           1

# SHAKE
rigidbonds              all
rigidtolerance          0.000001
rigiditerations         400

# vdw
vdwForceSwitching       on

# Constant Temperature Control
if { \$ITEMP == \$FTEMP } {
    langevin                   on;         # do langevin dynamics
    langevinDamping             1;         # damping coefficient (gamma) of 1/ps
                                        # 5/ps by Junfan
    langevinTemp           \$FTEMP;
    langevinHydrogen          off;         # don't couple langevin bath to hydrogens
} else {
    reassignFreq 1000;                     # use this to reassign velocity every 1000 steps
    if { \$FTEMP > \$ITEMP } {
        reassignIncr 10
    } else {
        reassignIncr -10
    }
    reassignTemp \$ITEMP
    reassignHold \$FTEMP
}

# Constant Pressure Control (variable volume)
if { \$PSWITCH != 0 } {
    # if running G-actin remove/comment out these 3 lines
    # by Junfan
    # CONSTANT-P, not in tutorial
    useGroupPressure        yes;           # use a hydrogen-group based pseudo-molecular viral to calcualte pressure and
                                        # has less fluctuation, is needed for rigid bonds (rigidBonds/SHAKE)
    useFlexibleCell         no;            # yes for anisotropic system like membrane
    useConstantRatio        no;            # keeps the ratio of the unit cell in the x-y plane constant A=B
    #    useConstatntArea     yes;
    langevinPiston          on
    langevinPistonTarget    1.01325
    langevinPistonPeriod    100;         # 100? 2000?
    langevinPistonDecay     50;         # 50?
    langevinPistonTemp      \$FTEMP
    StrainRate              0.0 0.0 0.0
}

# according to P. Blood use "no" for first NPT run
# then use "yes" for all NPT runs afterward
COMmotion yes

# Fixed atoms
# port first, h2o 2nd, 1 means not move
if { \$FIXPDB != 0 } {
    fixedAtoms      yes
    fixedAtomsForces yes
    fixedAtomsFile  \$FIXPDB.pdb
    fixedAtomsCol   B                   ;# beta
}

# Positional restraints
# Write out a separate pdb file in which the B values for
# the backbone, the non-hydrogen nucleotide atoms, the ion,
# and the water oxygens within 2.5 A of magnesium are set to 2
if { \$CONSPDB != 0 } {
    Constraints          yes
    ConsRef              \$CONSPDB.pdb
    ConsKFile            \$CONSPDB.pdb
    ConskCol             B
    constraintScaling    \$CONSSCALE
}

# CUDASOAintegrate         on

# Output
outputName          \$outputbase-prodstep1

restartfreq         50000     ;# 500steps = every 1ps. name=default
dcdfreq             250000
xstFreq             50000
outputEnergies      50000
outputPressure      50000
outputTiming        50000

run 10000000           ;# 20ns
EOF
}

generate_prodstep2_config(){
    cat > pro-lig-prodstep2 << EOF
#############################################################
## JOB DESCRIPTION                                         ##
#############################################################

# prodstep2, No constraint.
# namd3 +p10 +devices 0 pro-lig-prodstep2 > pro-lig-prodstep2.log

#############################################################
## ADJUSTABLE PARAMETERS                                   ##
#############################################################

structure          ../system.psf
coordinates        ../system.pdb     ;# or reports error
set outputbase     com               ;# consistent with equil
firsttimestep      0

#############################################################

set ITEMP 310
set FTEMP 310
set INPUTNAME       0                   ;# restart
set PSWITCH         1                   ;# whether to use langevinPiston pressure control
set FIXPDB          0
set CONSPDB         0
set CONSSCALE       0                   ;# default:1

#############################################################
## SIMULATION PARAMETERS                                   ##
#############################################################

# Input
paraTypeCharmm      on
parameters          ../toppar/lig.prm
parameters          ../toppar/par_all36m_prot.prm
parameters          ../toppar/par_all36_na.prm
parameters          ../toppar/par_all36_cgenff.prm
mergeCrossterms yes
parameters          ../toppar/par_all35_ethers.prm
parameters          ../toppar/par_all36_carb.prm
parameters          ../toppar/par_all36_lipid_ljpme.prm
parameters          ../toppar/toppar_water_ions_namd.str
parameters          ../toppar/par_interface.prm
parameters          ../toppar/toppar_all36_moreions.str
parameters          ../toppar/toppar_all36_synthetic_polymer.str
parameters          ../toppar/toppar_all36_synthetic_polymer_patch.str
parameters          ../toppar/toppar_all36_polymer_solvent.str
parameters          ../toppar/toppar_dum_noble_gases.str
parameters          ../toppar/toppar_ions_won.str
parameters          ../toppar/toppar_all36_prot_arg0.str
parameters          ../toppar/toppar_all36_prot_c36m_d_aminoacids.str
parameters          ../toppar/toppar_all36_prot_fluoro_alkanes.str
parameters          ../toppar/toppar_all36_prot_heme.str
parameters          ../toppar/toppar_all36_prot_na_combined.str
parameters          ../toppar/toppar_all36_prot_retinol.str
parameters          ../toppar/toppar_all36_prot_model.str
parameters          ../toppar/toppar_all36_prot_modify_res.str
parameters          ../toppar/toppar_all36_na_nad_ppi.str
parameters          ../toppar/toppar_all36_na_rna_modified.str
# parameters          ../toppar/toppar_all36_lipid_sphingo.str
parameters          ../toppar/toppar_all36_lipid_archaeal.str
parameters          ../toppar/toppar_all36_lipid_bacterial.str
parameters          ../toppar/toppar_all36_lipid_cardiolipin.str
parameters          ../toppar/toppar_all36_lipid_cholesterol.str
parameters          ../toppar/toppar_all36_lipid_dag.str
parameters          ../toppar/toppar_all36_lipid_inositol.str
parameters          ../toppar/toppar_all36_lipid_lnp.str
parameters          ../toppar/toppar_all36_lipid_lps.str
parameters          ../toppar/toppar_all36_lipid_mycobacterial.str
parameters          ../toppar/toppar_all36_lipid_miscellaneous.str
parameters          ../toppar/toppar_all36_lipid_model.str
parameters          ../toppar/toppar_all36_lipid_prot.str
parameters          ../toppar/toppar_all36_lipid_tag.str
parameters          ../toppar/toppar_all36_lipid_yeast.str
parameters          ../toppar/toppar_all36_lipid_hmmm.str
parameters          ../toppar/toppar_all36_lipid_detergent.str
parameters          ../toppar/toppar_all36_lipid_ether.str
parameters          ../toppar/toppar_all36_carb_glycolipid.str
parameters          ../toppar/toppar_all36_carb_glycopeptide.str
parameters          ../toppar/toppar_all36_carb_imlab.str
# parameters          ../toppar/toppar_all36_label_spin.str       ;# charmm code
parameters          ../toppar/toppar_all36_label_fluorophore.str

if { \$INPUTNAME != 0 } {
    # restart
    BinVelocities \$INPUTNAME.restart.vel.old
    BinCoordinates \$INPUTNAME.restart.coor.old
    ExtendedSystem \$INPUTNAME.restart.xsc.old
} else {
    # from equil. use the former outputName
    bincoordinates          \$outputbase-prodstep1.coor
    binvelocities           \$outputbase-prodstep1.vel
    extendedSystem      \$outputbase-prodstep1.xsc
}

## Force-Field Parameters
exclude             scaled1-4;         # non-bonded exclusion policy to use "none,1-2,1-3,1-4,or scaled1-4"
                                    # 1-2: all atoms pairs that are bonded are going to be ignored
                                    # 1-3: 3 consecutively bonded are excluded
                                    # scaled1-4: include all the 1-3, and modified 1-4 interactions
                                    # electrostatic scaled by 1-4scaling factor 1.0
                                    # vdW special 1-4 parameters in charmm parameter file.
1-4scaling          1.0

# CUT-OFFS
switching                on
switchdist              10.0
cutoff                  12.0
pairlistdist            13.5

PME                     yes
PMEGridSpacing          1.0
PMETolerance            10e-6
PMEInterpOrder          4

wrapWater               on;                # wrap water to central cell
wrapAll                 on;                # wrap other molecules too
wrapNearest             off;               # use for non-rectangular cells (wrap to the nearest image)

# SPACE PARTITIONING
splitpatch              hydrogen
hgroupcutoff            2.8
stepspercycle           20
margin                  2
longSplitting           C2

# RESPA PROPAGATOR
# timestep                1.0
timestep                2.0
useSettle               on
fullElectFrequency      2
nonbondedFreq           1

# SHAKE
rigidbonds              all
rigidtolerance          0.000001
rigiditerations         400

# vdw
vdwForceSwitching       on

# Constant Temperature Control
if { \$ITEMP == \$FTEMP } {
    langevin                   on;         # do langevin dynamics
    langevinDamping             1;         # damping coefficient (gamma) of 1/ps
                                        # 5/ps by Junfan
    langevinTemp           \$FTEMP;
    langevinHydrogen          off;         # don't couple langevin bath to hydrogens
} else {
    reassignFreq 1000;                     # use this to reassign velocity every 1000 steps
    if { \$FTEMP > \$ITEMP } {
        reassignIncr 10
    } else {
        reassignIncr -10
    }
    reassignTemp \$ITEMP
    reassignHold \$FTEMP
}

# Constant Pressure Control (variable volume)
if { \$PSWITCH != 0 } {
    # if running G-actin remove/comment out these 3 lines
    # by Junfan
    # CONSTANT-P, not in tutorial
    useGroupPressure        yes;           # use a hydrogen-group based pseudo-molecular viral to calcualte pressure and
                                        # has less fluctuation, is needed for rigid bonds (rigidBonds/SHAKE)
    useFlexibleCell         no;            # yes for anisotropic system like membrane
    useConstantRatio        no;            # keeps the ratio of the unit cell in the x-y plane constant A=B
    #    useConstatntArea     yes;
    langevinPiston          on
    langevinPistonTarget    1.01325
    langevinPistonPeriod    100;         # 100? 2000?
    langevinPistonDecay     50;         # 50?
    langevinPistonTemp      \$FTEMP
    StrainRate              0.0 0.0 0.0
}

# according to P. Blood use "no" for first NPT run
# then use "yes" for all NPT runs afterward
COMmotion yes

# Fixed atoms
# port first, h2o 2nd, 1 means not move
if { \$FIXPDB != 0 } {
    fixedAtoms      yes
    fixedAtomsForces yes
    fixedAtomsFile  \$FIXPDB.pdb
    fixedAtomsCol   B                   ;# beta
}

# Positional restraints
# Write out a separate pdb file in which the B values for
# the backbone, the non-hydrogen nucleotide atoms, the ion,
# and the water oxygens within 2.5 A of magnesium are set to 2
if { \$CONSPDB != 0 } {
    Constraints          yes
    ConsRef              \$CONSPDB.pdb
    ConsKFile            \$CONSPDB.pdb
    ConskCol             B
    constraintScaling    \$CONSSCALE
}

# CUDASOAintegrate         on

# Output
outputName          \$outputbase-prodstep2

restartfreq         50000     ;# 500steps = every 1ps. name=default
dcdfreq             250000
xstFreq             50000
outputEnergies      50000
outputPressure      50000
outputTiming        50000

run 90000000           ;# 180ns
EOF
}

generate_namd(){
    cat > namd.sh << EOF
#PBS -N namd
#PBS -q md
#PBS -l nodes=1:ppn=11:gpus=1
#PBS -S /bin/bash
#PBS -j oe
#PBS -l walltime=999:00:00

date
echo "CUDA_VISIBLE_DEVICES: \$CUDA_VISIBLE_DEVICES"
export LD_LIBRARY_PATH=/public/software/lib/:\$LD_LIBRARY_PATH
source /public/software/compiler/intel/intel-compiler-2017.5.239/bin/compilervars.sh intel64
cd \$PBS_O_WORKDIR
echo \$PBS_O_WORKDIR

NAMD="/public/software/apps/NAMD_3.0alpha9/namd3 +p10 +devices 0"

## min
cd prod
base_em=pro-lig-em
\$NAMD \$base_em > \$base_em.log

## nvt
base_nvt=pro-lig-nvt
\$NAMD \$base_nvt > \$base_nvt.log

## npt
base_nptstep1=pro-lig-nptstep1
\$NAMD \$base_nptstep1 > \$base_nptstep1.log
base_nptstep2=pro-lig-nptstep2
\$NAMD \$base_nptstep2 > \$base_nptstep2.log

## prod
base_prodstep1=pro-lig-prodstep1
\$NAMD \$base_prodstep1 > \$base_prodstep1.log
base_prodstep2=pro-lig-prodstep2
\$NAMD \$base_prodstep2 > \$base_prodstep2.log
EOF
}

#####################################################################################
# Get the map of clusters-frames according to the clustering results.               #
# usage: get_map_of_clusters_frames                                                 #
#####################################################################################
get_map_of_clusters_frames(){
    rm huitu_in.csv
    rm *.clu_frame
    file_in=${1}
    clusters=${2}
    grep drawframes ${file_in} |tail -${clusters} > temp.dat
    head=","
    while read line
    do
        cluster_num=`echo ${line}|awk '{print $4}'`
        clu_frames=`echo ${line}|awk -F "{" '{print $2}'|awk -F "}" '{print $1}'`
        head=${head}cluster${cluster_num},frame${cluster_num},
        a=0
        for i in `echo ${clu_frames}`
        do
            a=`echo "${a}+1"|bc`
            echo "${cluster_num},${i}" >> ${cluster_num}.clu_frame
        done
        # max_len=`wc -l 0.clu_frame|awk '{print $1}'`
        max_len=1000
        b=`echo "${max_len}-${a}"|bc`
        for i in `seq 0 ${b}`
        do
            echo "," >> ${cluster_num}.clu_frame
        done
    done < temp.dat
    touch temp.csv
    for i in `seq 1 ${clusters}`
    do
        c=`echo "${i}-1"|bc`
        paste -d "," temp.csv ${c}.clu_frame >> huitu_in.csv
        mv huitu_in.csv temp.csv
    done
    mv temp.csv huitu_in.csv 
    # paste -d "," *.clu_frame >> huitu_in.csv
    sed -i "1i ${head}" huitu_in.csv
    rm *.clu_frame
    rm temp.dat
}

get_map_of_clusters_frames_v2(){
    rm huitu_in_pktalign.csv
    rm tcl
    SEL_TEXT="resname LIG and noh"

    PDB="$1"; shift
    cat > tcl << EOF
mol new $PDB waitfor all
EOF

    for ii in $@; do
        prefix=${ii%.*}
        echo "mol addfile $ii waitfor all" >> tcl
    done

cat >> tcl << EOF
set outfile [open "huitu_in_pktalign.csv" "w"]
# set outfile [open "huitu_in.csv" "w"]
puts \$outfile "cluster1,cluster2,cluster3,cluster4,cluster5,cluster6,"
set sel_lig [atomselect top "$SEL_TEXT"]
foreach {cluster1 cluster2 cluster3 cluster4 cluster5 cluster6} [measure cluster \$sel_lig num 5 cutoff 1.2 first 0 last -1 step 1 distfunc rmsd weight none] break
for {set ii 0} {\$ii < 1000} {incr ii} {puts \$outfile "[lindex \$cluster1 \$ii],[lindex \$cluster2 \$ii],[lindex \$cluster3 \$ii],[lindex \$cluster4 \$ii],[lindex \$cluster5 \$ii],[lindex \$cluster6 \$ii],"}
quit
EOF

    /public/software/apps/vmd/1.9.4/vmd -dispdev text -e tcl
    rm tcl
}

#####################################################################################
# Periodic processing。                                                             #
# usage: do_pbc                                                                     #
#####################################################################################
do_pbc(){
    SEL_TEXT="segname PRO"
    # SEL_TEXT="segname LIG"

    PDB="$1"; shift
    [ $# -eq 0 ] && { echo "mkvmd> Usage: $0 [PSF/PDB] [TRJ]"; \
                    echo "mkvmd> [TRJ] could be multiple files."; \
                    echo "mkvmd> Note that XST files must exist in the same directory as the DCD files"; \
                    echo "mkvmd> By default, the selection is '$SEL_TEXT'"; exit 1; }

    if [ ! -f $PDB ]; then
        echo -e "$PDB \nStructure not found!"
        exit 0
    fi

    cat > tcl << EOF
    package require pbctools
    mol new $PDB waitfor all
EOF

    for ii in $@; do
        prefix=${ii%.*}
        echo "mol addfile $ii waitfor all" >> tcl
        echo "pbc readxst ${prefix}.xst" >> tcl
    done

    cat >> tcl << EOF
pbc wrap -all -compound segid -center com -centersel "${SEL_TEXT}"
# pbc wrap -all -compound residue -center com -centersel "${SEL_TEXT}"  ;# all in watbox
set sel_all [atomselect top all]
set sel_ref0 [atomselect top "${SEL_TEXT}" frame 0]
set sel_ref [atomselect top "${SEL_TEXT}"]
set num_frames [molinfo top get numframes]
for {set ii 0} {\$ii<\$num_frames} {incr ii} {
    \$sel_all frame \$ii
    \$sel_ref frame \$ii
    \$sel_all move [measure fit \$sel_ref \$sel_ref0]
}
animate write dcd wrapped.dcd
quit
EOF

    /public/software/apps/vmd/1.9.4/vmd -dispdev text -e tcl
    rm tcl
}

#####################################################################################
# Align.                                                                            #
# usage: do_align                                                                   #
#####################################################################################
do_align(){
    rm tcl

    # SEL_TEXT="segname PRO and ((resid 25 to 28) or (resid 38 to 52) or (resid 54) or (resid 85 to 86) or (resid 114) or (resid 116 to 118) or (resid 126) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 184 to 192))" # crystal dup1 I3C-3
    # SEL_TEXT="segname PRO and ((resid 25 to 28) or (resid 39 to 42) or (resid 44 to 46) or (resid 49 to 50) or (resid 54) or (resid 85) or (resid 114) or (resid 116 to 118) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 184 to 193))"  # edit I3C-3
    # SEL_TEXT="segname PRO and ((resid 25 to 28) or (resid 38 to 44) or (resid 46) or (resid 49) or (resid 52) or (resid 54) or (resid 85 to 86) or (resid 114) or (resid 116 to 119) or (resid 126) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 185 to 192))" # crystal dup2 I3C-3
    # SEL_TEXT="segname PRO and ((resid 24 to 28) or (resid 38 to 46) or (resid 49) or (resid 52) or (resid 54) or (resid 85 to 87) or (resid 114) or (resid 116 to 119) or (resid 126) or (resid 136 to 148) or (resid 161 to 175) or (resid 181) or (resid 185 to 191))" # crystal dup3 I3C-3
    # SEL_TEXT="segname PRO and ((resid 24 to 28) or (resid 38 to 42) or (resid 44 to 51) or (resid 54) or (resid 85 to 86) or (resid 116 to 119) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 185 to 190) or (resid 192))" # crystal dup4 I3C-3
    # SEL_TEXT="segname PRO and ((resid 25 to 28) or (resid 39 to 42) or (resid 44 to 49) or (resid 52) or (resid 54) or (resid 85 to 86) or (resid 116 to 119) or (resid 126) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 185 to 190) or (resid 192))" # crystal dup5 I3C-3
    # SEL_TEXT="segname PRO and ((resid 20) or (resid 24 to 28) or (resid 38 to 46) or (resid 49) or (resid 54) or (resid 85 to 86) or (resid 114) or (resid 116 to 119) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 185 to 190))" # dup1 com21
    # SEL_TEXT="segname PRO and ((resid 20 to 28) or (resid 38 to 52) or (resid 54) or (resid 57) or (resid 61) or (resid 85 to 87) or (resid 119) or (resid 140 to 147) or (resid 161 to 168) or (resid 171 to 175) or (resid 179) or (resid 181 to 182) or (resid 185 to 190))" # dup2 com21
    # SEL_TEXT="segname PRO and ((resid 20) or (resid 25 to 28) or (resid 38 to 51) or (resid 54) or (resid 85 to 87) or (resid 116 to 119) or (resid 126) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 185 to 191))" # dup3 com21
    # SEL_TEXT="segname PRO and ((resid 22) or (resid 24 to 28) or (resid 38 to 51) or (resid 54) or (resid 57) or (resid 84 to 87) or (resid 142 to 147) or (resid 161 to 175) or (resid 179 to 182) or (resid 185 to 192))" # dup1 I3C-2
    # SEL_TEXT="segname PRO and ((resid 25 to 28) or (resid 38 to 46) or (resid 48 to 51) or (resid 54) or (resid 85 to 87) or (resid 116 to 119) or (resid 126) or (resid 136 to 147) or (resid 161 to 175) or (resid 181 to 182) or (resid 185 to 190) or (resid 192))" # dup2 I3C-2
    # SEL_TEXT="segname PRO and ((resid 25 to 28) or (resid 39 to 42) or (resid 45 to 46) or (resid 49 to 50) or (resid 52) or (resid 54) or (resid 85 to 86) or (resid 114) or (resid 116 to 119) or (resid 126) or (resid 136 to 147) or (resid 161 to 175) or (resid 181 to 182) or (resid 185 to 192))" # dup3 I3C-2
    # SEL_TEXT="segname PRO and ((resid 24 to 28) or (resid 38 to 47) or (resid 49 to 50) or (resid 52) or (resid 54) or (resid 85 to 87) or (resid 114) or (resid 116 to 119) or (resid 126) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 185 to 190))" # dup4 I3C-2
    # SEL_TEXT="segname PRO and ((resid 24 to 28) or (resid 38 to 46) or (resid 49) or (resid 54) or (resid 85 to 87) or (resid 114) or (resid 116 to 119) or (resid 126) or (resid 136) or (resid 138 to 147) or (resid 161 to 175) or (resid 181) or (resid 185 to 190) or (resid 192))" # dup5 I3C-2
    # SEL_TEXT="segname PRO and ((resid 20 to 22) or (resid 24 to 28) or (resid 38 to 55) or (resid 57) or (resid 85 to 87) or (resid 117 to 119) or (resid 139 to 147) or (resid 161 to 175) or (resid 181) or (resid 185 to 190) or (resid 192))" # dup1 I3C-1
    # SEL_TEXT="segname PRO and ((resid 19 to 29) or (resid 38 to 50) or (resid 54) or (resid 85) or (resid 114) or (resid 116 to 120) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 186 to 190))" # dup2 I3C-1
    # SEL_TEXT="segname PRO and ((resid 24 to 25) or (resid 27 to 28) or (resid 38 to 54) or (resid 57) or (resid 85 to 87) or (resid 105) or (resid 130) or (resid 133 to 136) or (resid 142 to 147) or (resid 161 to 169) or (resid 171 to 176) or (resid 180 to 194))" # dup3 I3C-1
    # SEL_TEXT="segname PRO and ((resid 20 to 22) or (resid 24 to 28) or (resid 38 to 52) or (resid 54) or (resid 85 to 87) or (resid 114) or (resid 116 to 120) or (resid 126) or (resid 136 to 147) or (resid 161 to 168) or (resid 170 to 175) or (resid 181) or (resid 185 to 190))" # dup4 I3C-1
    # SEL_TEXT="segname PRO and ((resid 25 to 28) or (resid 38 to 57) or (resid 82) or (resid 84 to 87) or (resid 118 to 119) or (resid 140 to 147) or (resid 161 to 168) or (resid 172 to 175) or (resid 181) or (resid 184 to 193))" # dup5 I3C-1
    SEL_TEXT="segname PRO and ((resid 24 to 28) or (resid 38 to 45) or (resid 54) or (resid 85 to 86) or (resid 114) or (resid 116 to 119) or (resid 126) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 185 to 190))" # dup6 I3C-3
    # SEL_TEXT="resid 25 to 28"

    PDB="$1"; shift
    cat > tcl << EOF
mol new $PDB waitfor all
EOF

    for ii in $@; do
        prefix=${ii%.*}
        echo "mol addfile $ii waitfor all" >> tcl
    done

    cat >> tcl << EOF
set sel_all [atomselect top all]
set sel_ref0 [atomselect top "${SEL_TEXT}" frame 0]
set sel_ref [atomselect top "${SEL_TEXT}"]
set num_frames [molinfo top get numframes]
for {set ii 0} {\$ii<\$num_frames} {incr ii} {
    \$sel_all frame \$ii
    \$sel_ref frame \$ii
    \$sel_all move [measure fit \$sel_ref \$sel_ref0]
}
animate write dcd wrapped_align.dcd
quit
EOF

    /public/software/apps/vmd/1.9.4/vmd -dispdev text -e tcl
    rm tcl
}

#####################################################################################
# RMSD calculation.                                                                 #
# usage: do_rmsd                                                                    #
#####################################################################################
do_rmsd(){
    PDB=${1}
    SELRMSD="(segname PRO) && (backbone)"

    cat > tcl << EOF
package require pbctools
mol new "$PDB" waitfor all
EOF

    for ii in $@; do
        prefix=${ii%.*}
        echo "mol addfile $ii waitfor all" >> tcl
        echo "pbc readxst ${prefix}.xst" >> tcl
    done

    cat >> tcl << EOF
set sel_rmsd0 [atomselect top "${SELRMSD}" frame 0]
set sel_rmsd [atomselect top "${SELRMSD}"]
set num_frames [molinfo top get numframes]
set outfile [open "rmsd_pro.dat" "w"]
for {set ii 0} {\$ii<\$num_frames} {incr ii} {
    \$sel_rmsd frame \$ii
    set rmsd [measure rmsd \$sel_rmsd \$sel_rmsd0]
    puts \$outfile "\$ii \t \$rmsd"
}
quit
EOF

    /home/yqyang/software/vmd-1.9.4a57-installed/vmd -dispdev text -e tcl
    rm tcl

    PDB=${1}
    SELRMSD="(segname LIG) && noh"

    cat > tcl << EOF
package require pbctools
mol new "$PDB" waitfor all
EOF

    for ii in $@; do
        prefix=${ii%.*}
        echo "mol addfile $ii waitfor all" >> tcl
        echo "pbc readxst ${prefix}.xst" >> tcl
    done

    cat >> tcl << EOF
set sel_rmsd0 [atomselect top "${SELRMSD}" frame 0]
set sel_rmsd [atomselect top "${SELRMSD}"]
set num_frames [molinfo top get numframes]
set outfile [open "rmsd_all.dat" "w"]
for {set ii 0} {\$ii<\$num_frames} {incr ii} {
    \$sel_rmsd frame \$ii
    set rmsd [measure rmsd \$sel_rmsd \$sel_rmsd0]
    puts \$outfile "\$ii \t \$rmsd"
}
quit
EOF

    /home/yqyang/software/vmd-1.9.4a57-installed/vmd -dispdev text -e tcl
    rm tcl

    PDB=${1}
    SELRMSD="(segname LIG) && (name C8 || name N4 || name C9 || name C10 || name C14 || name C13 || name C12 || name C11 || name C7 || name C15 || name N3 || name C6 || name O2 || name C5 || name C16 || name C17 || name C18 || name CL || name C19 || name C20 || name C21)"

    cat > tcl << EOF
package require pbctools
mol new "$PDB" waitfor all
EOF

    for ii in $@; do
        prefix=${ii%.*}
        echo "mol addfile $ii waitfor all" >> tcl
        echo "pbc readxst ${prefix}.xst" >> tcl
    done

    cat >> tcl << EOF
set sel_rmsd0 [atomselect top "${SELRMSD}" frame 0]
set sel_rmsd [atomselect top "${SELRMSD}"]
set num_frames [molinfo top get numframes]
set outfile [open "rmsd_main.dat" "w"]
for {set ii 0} {\$ii<\$num_frames} {incr ii} {
    \$sel_rmsd frame \$ii
    set rmsd [measure rmsd \$sel_rmsd \$sel_rmsd0]
    puts \$outfile "\$ii \t \$rmsd"
}
quit
EOF

    /home/yqyang/software/vmd-1.9.4a57-installed/vmd -dispdev text -e tcl
    rm tcl

    PDB=${1}
    SELRMSD="(segname LIG) && (name C22 || name O3 || name N2 || name C4 || name C3 || name C2 || name O1 || name N1 || name C1)"

    cat > tcl << EOF
package require pbctools
mol new "$PDB" waitfor all
EOF

    for ii in $@; do
        prefix=${ii%.*}
        echo "mol addfile $ii waitfor all" >> tcl
        echo "pbc readxst ${prefix}.xst" >> tcl
    done

    cat >> tcl << EOF
set sel_rmsd0 [atomselect top "${SELRMSD}" frame 0]
set sel_rmsd [atomselect top "${SELRMSD}"]
set num_frames [molinfo top get numframes]
set outfile [open "rmsd_side.dat" "w"]
for {set ii 0} {\$ii<\$num_frames} {incr ii} {
    \$sel_rmsd frame \$ii
    set rmsd [measure rmsd \$sel_rmsd \$sel_rmsd0]
    puts \$outfile "\$ii \t \$rmsd"
}
quit
EOF

    /home/yqyang/software/vmd-1.9.4a57-installed/vmd -dispdev text -e tcl
    rm tcl

    awk '{print $1}' rmsd_pro.dat > frames.rms
    awk '{print $2}' rmsd_pro.dat > pro.rms
    awk '{print $2}' rmsd_all.dat > all.rms
    awk '{print $2}' rmsd_main.dat > main.rms
    awk '{print $2}' rmsd_side.dat > side.rms
    paste -d "," frames.rms pro.rms all.rms main.rms side.rms > huitu_input.csv
    sed -i "1i frames,pro,all,main,side" huitu_input.csv

    rm *.rms
}

do_rmsd_v2(){
    PDB=${1}
    # crystal dup1 I3C-3
    # SELRMSD_PRO="segname PRO and ((resid 25 to 28) or (resid 38 to 52) or (resid 54) or (resid 85 to 86) or (resid 114) or (resid 116 to 118) or (resid 126) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 184 to 192))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C8 || name N4 || name C9 || name C10 || name C14 || name C13 || name C12 || name C11 || name C7 || name C15 || name N3 || name C6 || name O2 || name C5 || name C16 || name C17 || name C18 || name CL || name C19 || name C20 || name C21)"
    # SELRMSD_side="(segname LIG) && (name C22 || name O3 || name N2 || name C4 || name C3 || name C2 || name O1 || name N1 || name C1)"

    # crystal dup2 I3C-3
    # SELRMSD_PRO="segname PRO and ((resid 25 to 28) or (resid 38 to 44) or (resid 46) or (resid 49) or (resid 52) or (resid 54) or (resid 85 to 86) or (resid 114) or (resid 116 to 119) or (resid 126) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 185 to 192))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C8 || name N4 || name C9 || name C10 || name C14 || name C13 || name C12 || name C11 || name C7 || name C15 || name N3 || name C6 || name O2 || name C5 || name C16 || name C17 || name C18 || name CL || name C19 || name C20 || name C21)"
    # SELRMSD_side="(segname LIG) && (name C22 || name O3 || name N2 || name C4 || name C3 || name C2 || name O1 || name N1 || name C1)"

    # crystal dup3 I3C-3
    # SELRMSD_PRO="segname PRO and ((resid 24 to 28) or (resid 38 to 46) or (resid 49) or (resid 52) or (resid 54) or (resid 85 to 87) or (resid 114) or (resid 116 to 119) or (resid 126) or (resid 136 to 148) or (resid 161 to 175) or (resid 181) or (resid 185 to 191))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C8 || name N4 || name C9 || name C10 || name C14 || name C13 || name C12 || name C11 || name C7 || name C15 || name N3 || name C6 || name O2 || name C5 || name C16 || name C17 || name C18 || name CL || name C19 || name C20 || name C21)"
    # SELRMSD_side="(segname LIG) && (name C22 || name O3 || name N2 || name C4 || name C3 || name C2 || name O1 || name N1 || name C1)"

    # crystal dup4 I3C-3
    # SELRMSD_PRO="segname PRO and backbone"
    # SELRMSD_PRO="segname PRO and ((resid 24 to 28) or (resid 38 to 42) or (resid 44 to 51) or (resid 54) or (resid 85 to 86) or (resid 116 to 119) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 185 to 190) or (resid 192))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C8 || name N4 || name C9 || name C10 || name C14 || name C13 || name C12 || name C11 || name C7 || name C15 || name N3 || name C6 || name O2 || name C5 || name C16 || name C17 || name C18 || name CL || name C19 || name C20 || name C21)"
    # SELRMSD_side="(segname LIG) && (name C22 || name O3 || name N2 || name C4 || name C3 || name C2 || name O1 || name N1 || name C1)"

    # crystal dup5 I3C-3
    # SELRMSD_PRO="segname PRO and backbone"
    # SELRMSD_PRO="segname PRO and ((resid 25 to 28) or (resid 39 to 42) or (resid 44 to 49) or (resid 52) or (resid 54) or (resid 85 to 86) or (resid 116 to 119) or (resid 126) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 185 to 190) or (resid 192))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C8 || name N4 || name C9 || name C10 || name C14 || name C13 || name C12 || name C11 || name C7 || name C15 || name N3 || name C6 || name O2 || name C5 || name C16 || name C17 || name C18 || name CL || name C19 || name C20 || name C21)"
    # SELRMSD_side="(segname LIG) && (name C22 || name O3 || name N2 || name C4 || name C3 || name C2 || name O1 || name N1 || name C1)"

    # crystal dup6 I3C-3
    # SELRMSD_PRO="segname PRO and backbone"
    SELRMSD_PRO="segname PRO and ((resid 24 to 28) or (resid 38 to 45) or (resid 54) or (resid 85 to 86) or (resid 114) or (resid 116 to 119) or (resid 126) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 185 to 190))"
    SELRMSD_all="(segname LIG) && noh"
    SELRMSD_main="(segname LIG) && (name C8 || name N4 || name C9 || name C10 || name C14 || name C13 || name C12 || name C11 || name C7 || name C15 || name N3 || name C6 || name O2 || name C5 || name C16 || name C17 || name C18 || name CL || name C19 || name C20 || name C21)"
    SELRMSD_side="(segname LIG) && (name C22 || name O3 || name N2 || name C4 || name C3 || name C2 || name O1 || name N1 || name C1)"

    # crystal dup1 com21
    # SELRMSD_PRO="segname PRO and backbone"
    # SELRMSD_PRO="segname PRO and ((resid 20) or (resid 24 to 28) or (resid 38 to 46) or (resid 49) or (resid 54) or (resid 85 to 86) or (resid 114) or (resid 116 to 119) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 185 to 190))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C4 || name N1 || name C3 || name C2 || name C5 || name C6 || name C7 || name C8 || name C17 || name C16 || name N2 || name C12 || name O || name C10 || name C1 || name C3 || name C14 || name CL || name C15 || name C9 || name C11)"
    # SELRMSD_side="(segname LIG) && (name C4 || name N1 || name C3 || name C2 || name C5 || name C6 || name C7 || name C8 || name C17 || name C16 || name N2 || name C12 || name O || name C10 || name C1 || name C3 || name C14 || name CL || name C15 || name C9 || name C11)"

    # crystal dup2 com21
    # SELRMSD_PRO="segname PRO and backbone"
    # SELRMSD_PRO="segname PRO and ((resid 20 to 28) or (resid 38 to 52) or (resid 54) or (resid 57) or (resid 61) or (resid 85 to 87) or (resid 119) or (resid 140 to 147) or (resid 161 to 168) or (resid 171 to 175) or (resid 179) or (resid 181 to 182) or (resid 185 to 190))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C4 || name N1 || name C3 || name C2 || name C5 || name C6 || name C7 || name C8 || name C17 || name C16 || name N2 || name C12 || name O || name C10 || name C1 || name C3 || name C14 || name CL || name C15 || name C9 || name C11)"
    # SELRMSD_side="(segname LIG) && (name C4 || name N1 || name C3 || name C2 || name C5 || name C6 || name C7 || name C8 || name C17 || name C16 || name N2 || name C12 || name O || name C10 || name C1 || name C3 || name C14 || name CL || name C15 || name C9 || name C11)"

    # crystal dup3 com21
    # SELRMSD_PRO="segname PRO and backbone"
    # SELRMSD_PRO="segname PRO and ((resid 20) or (resid 25 to 28) or (resid 38 to 51) or (resid 54) or (resid 85 to 87) or (resid 116 to 119) or (resid 126) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 185 to 191))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C4 || name N1 || name C3 || name C2 || name C5 || name C6 || name C7 || name C8 || name C17 || name C16 || name N2 || name C12 || name O || name C10 || name C1 || name C3 || name C14 || name CL || name C15 || name C9 || name C11)"
    # SELRMSD_side="(segname LIG) && (name C4 || name N1 || name C3 || name C2 || name C5 || name C6 || name C7 || name C8 || name C17 || name C16 || name N2 || name C12 || name O || name C10 || name C1 || name C3 || name C14 || name CL || name C15 || name C9 || name C11)"

    # dup1 I3C-2
    # SELRMSD_PRO="segname PRO and backbone"
    # SELRMSD_PRO="segname PRO and ((resid 22) or (resid 24 to 28) or (resid 38 to 51) or (resid 54) or (resid 57) or (resid 84 to 87) or (resid 142 to 147) or (resid 161 to 175) or (resid 179 to 182) or (resid 185 to 192))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C6 || name N3 || name C7 || name C8 || name C9 || name C10 || name C11 || name C12 || name C13 || name C5 || name N2 || name C4 || name O2 || name C3 || name C14 || name C15 || name C16 || name CL || name C17 || name C18 || name C19)"
    # SELRMSD_side="(segname LIG) && (name C2 || name N1 || name C20 || name C1 || name C22 || name C21 || name N4 || name O1)"

    # dup2 I3C-2
    # SELRMSD_PRO="segname PRO and backbone"
    # SELRMSD_PRO="segname PRO and ((resid 25 to 28) or (resid 38 to 46) or (resid 48 to 51) or (resid 54) or (resid 85 to 87) or (resid 116 to 119) or (resid 126) or (resid 136 to 147) or (resid 161 to 175) or (resid 181 to 182) or (resid 185 to 190) or (resid 192))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C6 || name N3 || name C7 || name C8 || name C9 || name C10 || name C11 || name C12 || name C13 || name C5 || name N2 || name C4 || name O2 || name C3 || name C14 || name C15 || name C16 || name CL || name C17 || name C18 || name C19)"
    # SELRMSD_side="(segname LIG) && (name C2 || name N1 || name C20 || name C1 || name C22 || name C21 || name N4 || name O1)"

    # dup3 I3C-2
    # SELRMSD_PRO="segname PRO and backbone"
    # SELRMSD_PRO="segname PRO and ((resid 25 to 28) or (resid 39 to 42) or (resid 45 to 46) or (resid 49 to 50) or (resid 52) or (resid 54) or (resid 85 to 86) or (resid 114) or (resid 116 to 119) or (resid 126) or (resid 136 to 147) or (resid 161 to 175) or (resid 181 to 182) or (resid 185 to 192))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C6 || name N3 || name C7 || name C8 || name C9 || name C10 || name C11 || name C12 || name C13 || name C5 || name N2 || name C4 || name O2 || name C3 || name C14 || name C15 || name C16 || name CL || name C17 || name C18 || name C19)"
    # SELRMSD_side="(segname LIG) && (name C2 || name N1 || name C20 || name C1 || name C22 || name C21 || name N4 || name O1)"

    # dup4 I3C-2
    # SELRMSD_PRO="segname PRO and backbone"
    # SELRMSD_PRO="segname PRO and ((resid 24 to 28) or (resid 38 to 47) or (resid 49 to 50) or (resid 52) or (resid 54) or (resid 85 to 87) or (resid 114) or (resid 116 to 119) or (resid 126) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 185 to 190))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C6 || name N3 || name C7 || name C8 || name C9 || name C10 || name C11 || name C12 || name C13 || name C5 || name N2 || name C4 || name O2 || name C3 || name C14 || name C15 || name C16 || name CL || name C17 || name C18 || name C19)"
    # SELRMSD_side="(segname LIG) && (name C2 || name N1 || name C20 || name C1 || name C22 || name C21 || name N4 || name O1)"

    # dup5 I3C-2
    # SELRMSD_PRO="segname PRO and backbone"
    # SELRMSD_PRO="segname PRO and ((resid 24 to 28) or (resid 38 to 46) or (resid 49) or (resid 54) or (resid 85 to 87) or (resid 114) or (resid 116 to 119) or (resid 126) or (resid 136) or (resid 138 to 147) or (resid 161 to 175) or (resid 181) or (resid 185 to 190) or (resid 192))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C6 || name N3 || name C7 || name C8 || name C9 || name C10 || name C11 || name C12 || name C13 || name C5 || name N2 || name C4 || name O2 || name C3 || name C14 || name C15 || name C16 || name CL || name C17 || name C18 || name C19)"
    # SELRMSD_side="(segname LIG) && (name C2 || name N1 || name C20 || name C1 || name C22 || name C21 || name N4 || name O1)"

    # dup1 I3C-1
    # SELRMSD_PRO="segname PRO and backbone"
    # SELRMSD_PRO="segname PRO and ((resid 20 to 22) or (resid 24 to 28) or (resid 38 to 55) or (resid 57) or (resid 85 to 87) or (resid 117 to 119) or (resid 139 to 147) or (resid 161 to 175) or (resid 181) or (resid 185 to 190) or (resid 192))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C6 || name N3 || name C7 || name C8 || name C9 || name C10 || name C11 || name C12 || name C13 || name C5 || name N2 || name C4 || name O || name C3 || name C14 || name C15 || name C16 || name CL || name C17 || name C18 || name C19)"
    # SELRMSD_side="(segname LIG) && (name C2 || name N1 || name C20 || name C1)"

    # dup2 I3C-1
    # SELRMSD_PRO="segname PRO and backbone"
    # SELRMSD_PRO="segname PRO and ((resid 19 to 29) or (resid 38 to 50) or (resid 54) or (resid 85) or (resid 114) or (resid 116 to 120) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 186 to 190))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C6 || name N3 || name C7 || name C8 || name C9 || name C10 || name C11 || name C12 || name C13 || name C5 || name N2 || name C4 || name O || name C3 || name C14 || name C15 || name C16 || name CL || name C17 || name C18 || name C19)"
    # SELRMSD_side="(segname LIG) && (name C2 || name N1 || name C20 || name C1)"

    # dup3 I3C-1
    # SELRMSD_PRO="segname PRO and backbone"
    # SELRMSD_PRO="segname PRO and ((resid 24 to 25) or (resid 27 to 28) or (resid 38 to 54) or (resid 57) or (resid 85 to 87) or (resid 105) or (resid 130) or (resid 133 to 136) or (resid 142 to 147) or (resid 161 to 169) or (resid 171 to 176) or (resid 180 to 194))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C6 || name N3 || name C7 || name C8 || name C9 || name C10 || name C11 || name C12 || name C13 || name C5 || name N2 || name C4 || name O || name C3 || name C14 || name C15 || name C16 || name CL || name C17 || name C18 || name C19)"
    # SELRMSD_side="(segname LIG) && (name C2 || name N1 || name C20 || name C1)"

    # dup4 I3C-1
    # SELRMSD_PRO="segname PRO and backbone"
    # SELRMSD_PRO="segname PRO and ((resid 20 to 22) or (resid 24 to 28) or (resid 38 to 52) or (resid 54) or (resid 85 to 87) or (resid 114) or (resid 116 to 120) or (resid 126) or (resid 136 to 147) or (resid 161 to 168) or (resid 170 to 175) or (resid 181) or (resid 185 to 190))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C6 || name N3 || name C7 || name C8 || name C9 || name C10 || name C11 || name C12 || name C13 || name C5 || name N2 || name C4 || name O || name C3 || name C14 || name C15 || name C16 || name CL || name C17 || name C18 || name C19)"
    # SELRMSD_side="(segname LIG) && (name C2 || name N1 || name C20 || name C1)"

    # dup5 I3C-1
    # SELRMSD_PRO="segname PRO and backbone"
    # SELRMSD_PRO="segname PRO and ((resid 25 to 28) or (resid 38 to 57) or (resid 82) or (resid 84 to 87) or (resid 118 to 119) or (resid 140 to 147) or (resid 161 to 168) or (resid 172 to 175) or (resid 181) or (resid 184 to 193))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C6 || name N3 || name C7 || name C8 || name C9 || name C10 || name C11 || name C12 || name C13 || name C5 || name N2 || name C4 || name O || name C3 || name C14 || name C15 || name C16 || name CL || name C17 || name C18 || name C19)"
    # SELRMSD_side="(segname LIG) && (name C2 || name N1 || name C20 || name C1)"

    # edit I3C-3
    # SELRMSD_PRO="segname PRO and ((resid 25 to 28) or (resid 39 to 42) or (resid 44 to 46) or (resid 49 to 50) or (resid 54) or (resid 85) or (resid 114) or (resid 116 to 118) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 184 to 193))"  
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C10 || name N2 || name C9 || name C8 || name C14 || name C13 || name C12 || name C11 || name C7 || name C6 || name N1 || name C2 || name O1 || name C16 || name C1 || name C3 || name C4 || name CL || name C5 || name C15 || name C18)"
    # SELRMSD_side="(segname LIG) && (name C19 || name O3 || name N3 || name C17 || name C20 || name C21 || name O2 || name N4 || name C22)"

    cat > tcl << EOF
mol new "$PDB" waitfor all
EOF

    for ii in $@; do
        prefix=${ii%.*}
        echo "mol addfile $ii waitfor all" >> tcl
    done

    cat >> tcl << EOF
set sel_rmsd_pro0 [atomselect top "${SELRMSD_PRO}" frame 0]
set sel_rmsd_pro [atomselect top "${SELRMSD_PRO}"]
set sel_rmsd_all0 [atomselect top "${SELRMSD_all}" frame 0]
set sel_rmsd_all [atomselect top "${SELRMSD_all}"]
set sel_rmsd_main0 [atomselect top "${SELRMSD_main}" frame 0]
set sel_rmsd_main [atomselect top "${SELRMSD_main}"]
set sel_rmsd_side0 [atomselect top "${SELRMSD_side}" frame 0]
set sel_rmsd_side [atomselect top "${SELRMSD_side}"]
set num_frames [molinfo top get numframes]
set outfile [open "huitu_input_pktalign.csv" "w"]
# set outfile [open "huitu_input.csv" "w"]
puts \$outfile "frames,pro,all,main,side"
for {set ii 0} {\$ii<\$num_frames} {incr ii} {
    \$sel_rmsd_pro frame \$ii
    set rmsd_pro [measure rmsd \$sel_rmsd_pro \$sel_rmsd_pro0]
    \$sel_rmsd_all frame \$ii
    set rmsd_all [measure rmsd \$sel_rmsd_all \$sel_rmsd_all0]
    \$sel_rmsd_main frame \$ii
    set rmsd_main [measure rmsd \$sel_rmsd_main \$sel_rmsd_main0]
    \$sel_rmsd_side frame \$ii
    set rmsd_side [measure rmsd \$sel_rmsd_side \$sel_rmsd_side0]
    puts \$outfile "\$ii,\$rmsd_pro,\$rmsd_all,\$rmsd_main,\$rmsd_side"
}
quit
EOF

    /public/software/apps/vmd/1.9.4/vmd -dispdev text -e tcl
    rm tcl
}

do_rmsd_matrix(){
    rm rmsd_matrix_pktalign.csv
    rm tcl

    PDB=${1}
    SELRMSD_all="(segname LIG) && noh"

    cat > tcl << EOF
mol new "$PDB" waitfor all
EOF

    for ii in $@; do
        prefix=${ii%.*}
        echo "mol addfile $ii waitfor all" >> tcl
    done

    cat >> tcl << EOF
set num_frames [molinfo top get numframes]
# set outfile [open "rmsd_matrix_pktalign.csv" "w"]
set outfile [open "rmsd_matrix.csv" "w"]
for {set aa 0} {\$aa<\$num_frames} {incr aa} {
    set sel_rmsd_allref [atomselect top "${SELRMSD_all}" frame \$aa]
    set sel_rmsd_all [atomselect top "${SELRMSD_all}"]
    set lst {}
    for {set ii 0} {\$ii<\$num_frames} {incr ii} {
        \$sel_rmsd_all frame \$ii
        set rmsd_all [measure rmsd \$sel_rmsd_all \$sel_rmsd_allref]
        lappend lst \$rmsd_all
    }
    for {set bb 0} {\$bb<\$num_frames} {incr bb} {
        puts -nonewline \$outfile "[lindex \$lst \$bb],"
    }
    puts \$outfile ""
}
quit
EOF

    /home/yqyang/software/vmd-1.9.4a57-installed/vmd -dispdev text -e tcl
    rm tcl
}

#####################################################################################
# Save Frames.                                                                      #
# usage: save_frame                                                                 #
#####################################################################################
save_frame(){
    rm tcl
   
    PDB="$1"; shift
    cat > tcl << EOF
mol new $PDB waitfor all
EOF

    for ii in $@; do
        prefix=${ii%.*}
        echo "mol addfile $ii waitfor all" >> tcl
    done

while read line
    do 
    clu=`echo "$line"| awk -F ":" '{print $1}'`
    echo "$clu"
    fra=`echo "$line"| awk -F ":" '{print $2}'`
    echo "$fra"
    cat >> tcl << EOF
animate write pdb {cluster${clu}_centroid.pdb} beg $fra end $fra skip 1 0
EOF
    done < centroid.dat 
    echo "quit" >> tcl  

    /public/software/apps/vmd/1.9.4/vmd -dispdev text -e tcl
    rm tcl 
}

#####################################################################################
# FEP prepare and using FEPbuilder.                                                 #
# usage: fep_file_generate     fep_file_generate_deLP     fepbuilder                #
#####################################################################################
fep_file_generate(){
    state_A=$1
    name_A=`basename ${state_A} .tgz`
    state_B=$2
    name_B=`basename ${state_B} .tgz`
    mkdir temp
    tar -zxvf ${state_A} -C temp
    cp ./temp/charmm-gui*/ligandrm.pdb ${name_A}.pdb
    cp ./temp/charmm-gui*/lig/lig.prm ${name_A}.prm
    cp ./temp/charmm-gui*/lig/lig.rtf ${name_A}.rtf
    rm -r temp
    mkdir temp
    tar -zxvf ${state_B} -C temp
    cp ./temp/charmm-gui*/ligandrm.pdb ${name_B}.pdb
    cp ./temp/charmm-gui*/lig/lig.prm ${name_B}.prm
    cp ./temp/charmm-gui*/lig/lig.rtf ${name_B}.rtf
    rm -r temp ${state_A} ${state_B}
}

fep_file_generate_deLP(){
    state_A=$1
    name_A=`basename ${state_A} .tgz`
    state_B=$2
    name_B=`basename ${state_B} .tgz`
    mkdir temp
    tar -zxvf ${state_A} -C temp
    cp ./temp/charmm-gui*/ligandrm.pdb ${name_A}.pdb
    sed -i '/LP/d' ${name_A}.pdb
    cp ./temp/charmm-gui*/lig/lig.prm ${name_A}.prm
    cp ./temp/charmm-gui*/lig/lig.rtf ${name_A}.rtf
    sed -i '/LP/d' ${name_A}.rtf
    rm -r temp
    mkdir temp
    tar -zxvf ${state_B} -C temp
    cp ./temp/charmm-gui*/ligandrm.pdb ${name_B}.pdb
    sed -i '/LP/d' ${name_B}.pdb
    cp ./temp/charmm-gui*/lig/lig.prm ${name_B}.prm
    cp ./temp/charmm-gui*/lig/lig.rtf ${name_B}.rtf
    sed -i '/LP/d' ${name_B}.rtf
    rm -r temp ${state_A} ${state_B}
}

fepbuilder(){
    state_A=$1
    state_B=$2
    cp -r /public/home/yqyang/file/FEbuilder .
    cp -r /public/home/yqyang/file/namd_pre toppar
    python ./FEbuilder/FEbuilder.py -ref ${state_A} -mut ${state_B} -rec receptor.pdb --ff-path ./toppar/ --vmd-path /public/software/apps/vmd/1.9.4/vmd
}

#####################################################################################
# FEP NAMD result processing.                                                       #
# usage: namd_fep_result                                                            #
#####################################################################################
namd_fep_result(){
    file_in=$1
    rm ${file_in}.dat
    rm ${file_in}.csv
    rm lambda.dat
    for i in {0,0.00005,0.0001,0.001,0.01,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,0.99,0.999,0.9999,0.99999,1};do echo ${i} >> lambda.dat;done
    head_1="lambda"
    echo "complex,ddg" >> ${file_in}.dat
    cd ./${file_in}/simulation/prod
    for f in `ls -F | grep /`; do
        com=`basename ${f} /`
        head_1=${head_1},${com}
        cd ${com}
        ddg=`grep "#Free energy" complex-prod-forward.fepout| tail -1| awk -F "now is " '{print $2}'`
        echo "${com},${ddg}" >> ../../../../${file_in}.dat
        grep "#Free energy" complex-prod-forward.fepout| awk -F "now is " '{print $2}' > temp.dat
        sed -i "1i 0" temp.dat
        paste -d "," ../../../../lambda.dat temp.dat >> ../../../../huitu.csv
        rm temp.dat
        mv ../../../../huitu.csv ../../../../lambda.dat
        cd ..
    done
    cd ../../../
    mv lambda.dat ${file_in}.csv
    sed -i "1i ${head_1}" ${file_in}.csv
}

#####################################################################################
# run the program                                                                   #
# usage: you can pick some functions to run just like playing Lego !!!              #
#####################################################################################
# file=${1}
# bulid_charmmgui ${file}
# build_charmmgui_deLP_lig ${file}
# position_restraints
# generate_namd
# cd prod
# generate_em_config
# generate_nvt_config
# generate_nptstep1_config
# generate_nptstep2_config
# generate_prodstep1_config
# generate_prodstep2_config
# file_in=${1}
# clusters=${2}
# get_map_of_clusters_frames ${file_in} ${clusters}
input=$*
# do_rmsd ${input}
# do_pbc ${input}
# do_align ${input}
# do_rmsd_v2 ${input}
# do_rmsd_matrix ${input}
# get_map_of_clusters_frames_v2 ${input} 
# save_frame ${input} 
# fep_file_generate_deLP ${input}
fepbuilder ${input}
# namd_fep_result ${input}