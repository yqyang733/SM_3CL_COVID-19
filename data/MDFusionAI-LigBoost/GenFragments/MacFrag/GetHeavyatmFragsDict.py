# -*- coding: utf-8 -*-

"""
文件名/File Name: Gen3DLib.py
功能/Description: 
  小分子先导化合物侧链基团替换生成SMILES分子库和3D分子库
  Generate SMILES library and 3D molecular library through lead compound side chain replacement

作者/Author: yqyang
邮箱/Email: 
  yanqyang@zju.edu.cn
  1821074995@qq.com

创建日期/Created Date: 2025-05-01
修改记录/Modification History:
    2025-05-01 yqyang - 创建Gen3DLib.py / Created Gen3DLib.py

版本/Version: 0.0.0
"""

import re
import sys
import pickle
from rdkit import Chem
from collections import defaultdict

def fragmentcount(fragsmi):

    with open(fragsmi) as f:
        f1 = f.readlines()

    expr = re.compile(r'[0-9]+\*')
    fragment_counts_clean = defaultdict(int)
    nRejected=0
    idx = 0
    for i in f1:
        idx += 1
        print(idx)
        # print("i", i)
        if i.find('*')<0:
            nRejected +=1
            continue
        k = Chem.MolToSmiles(Chem.MolFromSmiles(expr.sub('*',i)),kekuleSmiles=True)
        # print("k", k)
        fragment_counts_clean[k] += 1

    fragment_counts_clean_ = sorted([(v,k) for k,v in fragment_counts_clean.items()],reverse=True)

    return fragment_counts_clean

def genfragdict(fragmentcounts):

    HeavyNum_Fragments = defaultdict(list)

    for i in fragmentcounts.keys():
        try:
            m = Chem.MolFromSmiles(i)
            heanum = m.GetNumHeavyAtoms()
            HeavyNum_Fragments[heanum].append(i)
        except:
            pass

    pickle.dump(HeavyNum_Fragments, open('HeavyNum_Fragments.pkl','wb+'))

def main():

    fragsmi = sys.argv[1]
    fragmentcounts = fragmentcount(fragsmi)
    genfragdict(fragmentcounts)

if __name__=="__main__":
    main() 