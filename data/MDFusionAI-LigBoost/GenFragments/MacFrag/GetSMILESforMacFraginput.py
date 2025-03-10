from rdkit import Chem

rt = open("Chembl_SMILES_MacFrag.smi", "w")

with open("Chembl_SMILES") as f:
    f1 = f.readlines()

for i in f1:
    if i.strip("\"\n") == "":
        pass
    else:
        try:
            smi = Chem.MolToSmiles(Chem.MolFromSmiles(i.strip("\"\n")),True)
            rt.write(smi + "\n")
        except:
            print(i.strip("\"\n") + " error !")

rt.close()
