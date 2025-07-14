#!/bin/bash

do_align(){
    rm tcl

    # SEL_TEXT="segname PRO and ((resid 25 to 28) or (resid 38 to 52) or (resid 54) or (resid 85 to 86) or (resid 114) or (resid 116 to 118) or (resid 126) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 184 to 192))" # crystal dup1 I3C-3
    SEL_TEXT="segname PRO and ((resid 25 to 28) or (resid 39 to 42) or (resid 44 to 46) or (resid 49 to 50) or (resid 54) or (resid 85) or (resid 114) or (resid 116 to 118) or (resid 136 to 147) or (resid 161 to 175) or (resid 181) or (resid 184 to 193))"  # edit I3C-3
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

    /home/yqyang/software/vmd-1.9.4a57-installed/vmd -dispdev text -e tcl
    rm tcl
}

input=$*
do_align ${input}