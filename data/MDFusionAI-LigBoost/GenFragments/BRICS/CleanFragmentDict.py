import re
import dbm
import pickle
import struct
from rdkit import Chem
from collections import defaultdict

dbname = "output.dbm"
fragment_counts = defaultdict(int)
with dbm.open(dbname, flag='r') as db:
    for key, val in db.items():
        fragment_counts[key] += struct.unpack('I',val)[0]

expr = re.compile(r'[0-9]+\*')
fragment_counts_clean = defaultdict(int)
nRejected=0
for k,v in fragment_counts.items():
    k = k.decode('UTF-8')
    if k.find('*')<0:
        nRejected +=1
        continue
    k = Chem.MolToSmiles(Chem.MolFromSmiles(expr.sub('*',k)),True)
    fragment_counts_clean[k] += v

fragment_counts_clean_ = sorted([(v,k) for k,v in fragment_counts_clean.items()],reverse=True)

pickle.dump(fragment_counts_clean_, open('fragment_counts_clean.pkl','wb+'))

HeavyNum_Fragments = defaultdict(list)
for i in fragment_counts_clean.keys():
    try:
        m = Chem.MolFromSmiles(i)
        heanum = m.GetNumHeavyAtoms()
        HeavyNum_Fragments[heanum].append(i)
    except:
        pass
pickle.dump(HeavyNum_Fragments, open('HeavyNum_Fragments.pkl','wb+'))