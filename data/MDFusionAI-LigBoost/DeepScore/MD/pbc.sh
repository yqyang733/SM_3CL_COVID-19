lst=${1}
for i in `cat ${lst}`
do
cd ${i}
mkdir -p analysis/pbc
cd analysis/pbc

cp ../../npt/npt.gro ../../prod/npt.gro
cp ../../index.ndx .

echo 21|gmx trjconv -f ../../prod/npt.gro -s ../../prod/prod.tpr -o new.pdb -n index.ndx

cat << EOL > GetAtm.py
from collections import defaultdict

def main():

    atm_coord = defaultdict(list)

    with open("new.pdb") as f:
        f1 = f.readlines()

    for pdb_line in f1:
        if pdb_line.startswith("ATOM"):
            atom_serial_number = pdb_line[6:11]
            chain_identifier = pdb_line[21:22]
            x_coord = pdb_line[30:38]
            y_coord = pdb_line[38:46]
            z_coord = pdb_line[46:54]
            atm_coord[chain_identifier].append([atom_serial_number, (x_coord,y_coord,z_coord)])

    N = 0
    aimcenter_x = 0
    aimcenter_y = 0
    aimcenter_z = 0
    for k, items in atm_coord.items():
        N += 1
        aimcenter_x += float(items[0][1][0])
        aimcenter_y += float(items[0][1][1])
        aimcenter_z += float(items[0][1][2])
    aimcenter_x = aimcenter_x/N
    aimcenter_y = aimcenter_y/N
    aimcenter_z = aimcenter_z/N

    final_dis = 100000000000000000
    for k, items in atm_coord.items():
        for coord in items:
            dis2 = (float(coord[1][0])-aimcenter_x)*(float(coord[1][0])-aimcenter_x) + (float(coord[1][1])-aimcenter_y)*(float(coord[1][1])-aimcenter_y) + (float(coord[1][2])-aimcenter_z)*(float(coord[1][2])-aimcenter_z)
            if dis2 < final_dis:
                final_dis = dis2
                final_idx = coord[0]

    # print("目标中心点坐标：", aimcenter_x, aimcenter_y, aimcenter_z)
    # print("距离目标中心最近的原子编号：", final_idx)
    # print("距离目标中心最近的距离：", final_dis)

    print(final_idx)

    return final_idx
    
if __name__=="__main__":
    main() 
EOL

centeratm=`python GetAtm.py`

echo "[ atom ]" >> index.ndx
echo ${centeratm} >> index.ndx

echo -e "\nc\nc\nc\nc\n"|gmx trjcat -f ../../prod/prod.xtc ../../prod/prod.part0002.xtc ../../prod/prod.part0003.xtc ../../prod/prod.part0004.xtc -settime -o prod.xtc
echo 22 0|gmx trjconv -f prod.xtc -s ../../prod/prod.tpr -o md_pbcmol_new.xtc -pbc atom -ur compact -center -n index.ndx
echo 0|gmx trjconv -f md_pbcmol_new.xtc -s ../../prod/prod.tpr -o md_pbcwhole_new.xtc -pbc whole -n index.ndx
echo 21 21|gmx trjconv -f md_pbcwhole_new.xtc -s ../../prod/prod.tpr -o md_pbcfit_all_new.xtc -fit rot+trans -n index.ndx
rm prod.xtc md_pbcmol_new.xtc md_pbcwhole_new.xtc

cd ../../..
done