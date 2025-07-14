#!/bin/bash

do_rmsd(){
    PDB=${1}
    # crystal dup1 I3C-3
    # SELRMSD_PRO="segname PRO and ((resid 25 to 28) or (resid 38 to 52) or (resid 54) or (resid 85 to 86) or (resid 114) or (resid 116 to 118) or (resid 126) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 184 to 192))"
    # SELRMSD_all="(segname LIG) && noh"
    # SELRMSD_main="(segname LIG) && (name C8 || name N4 || name C9 || name C10 || name C14 || name C13 || name C12 || name C11 || name C7 || name C15 || name N3 || name C6 || name O2 || name C5 || name C16 || name C17 || name C18 || name CL || name C19 || name C20 || name C21)"
    # SELRMSD_side="(segname LIG) && (name C22 || name O3 || name N2 || name C4 || name C3 || name C2 || name O1 || name N1 || name C1)"

    # edit I3C-3
    SELRMSD_PRO="segname PRO and ((resid 25 to 28) or (resid 39 to 42) or (resid 44 to 46) or (resid 49 to 50) or (resid 54) or (resid 85) or (resid 114) or (resid 116 to 118) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 184 to 193))"  
    SELRMSD_all="(segname LIG) && noh"
    SELRMSD_main="(segname LIG) && (name C10 || name N2 || name C9 || name C8 || name C14 || name C13 || name C12 || name C11 || name C7 || name C6 || name N1 || name C2 || name O1 || name C16 || name C1 || name C3 || name C4 || name CL || name C5 || name C15 || name C18)"
    SELRMSD_side="(segname LIG) && (name C19 || name O3 || name N3 || name C17 || name C20 || name C21 || name O2 || name N4 || name C22)"

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

    /home/yqyang/software/vmd-1.9.4a57-installed/vmd -dispdev text -e tcl
    rm tcl
}

input=$*
do_rmsd ${input}