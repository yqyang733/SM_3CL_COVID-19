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

import os
import sys
import pickle
import numpy as np
from pymol import cmd
from rdkit import Chem
from molvs import standardize_smiles

def get_neiid_bysymbol(mol,marker):

    """根据阈值处理数据，返回处理后的结果和统计信息
    
    参数:
        data (pd.DataFrame): 输入数据框
        threshold (float): 过滤阈值，默认为0.5
        
    返回:
        tuple: 包含两个元素
            - processed_data (pd.DataFrame): 处理后的数据
            - stats (dict): 处理统计信息
            
    异常:
        ValueError: 当阈值不在0-1范围内时抛出
            
    示例:
        >>> data = pd.DataFrame({'value': [0.1, 0.6, 0.4]})
        >>> df, stats = process_data(data, threshold=0.5)
    """

    try:
        for atom in mol.GetAtoms():
            if atom.GetSymbol()==marker:
                neighbors=atom.GetNeighbors()
                if len(neighbors)>1:
                    print ('Cannot process more than one neighbor, will only return one of them')
                atom_nb=neighbors[0]
                return atom_nb.GetIdx()
    except Exception as e:
        print (e)
        return None

def get_id_bysymbol(mol,marker):

    """根据阈值处理数据，返回处理后的结果和统计信息
    
    参数:
        data (pd.DataFrame): 输入数据框
        threshold (float): 过滤阈值，默认为0.5
        
    返回:
        tuple: 包含两个元素
            - processed_data (pd.DataFrame): 处理后的数据
            - stats (dict): 处理统计信息
            
    异常:
        ValueError: 当阈值不在0-1范围内时抛出
            
    示例:
        >>> data = pd.DataFrame({'value': [0.1, 0.6, 0.4]})
        >>> df, stats = process_data(data, threshold=0.5)
    """

    for atom in mol.GetAtoms():
        if atom.GetSymbol()==marker:
            return atom.GetIdx()

def combine2frags(mol_a, mol_b, maker_b='*', maker_a='*'):

    """根据阈值处理数据，返回处理后的结果和统计信息
    
    参数:
        data (pd.DataFrame): 输入数据框
        threshold (float): 过滤阈值，默认为0.5
        
    返回:
        tuple: 包含两个元素
            - processed_data (pd.DataFrame): 处理后的数据
            - stats (dict): 处理统计信息
            
    异常:
        ValueError: 当阈值不在0-1范围内时抛出
            
    示例:
        >>> data = pd.DataFrame({'value': [0.1, 0.6, 0.4]})
        >>> df, stats = process_data(data, threshold=0.5)
    """

    #将两个待连接分子置于同一个对象中
    bind_pos_a=get_neiid_bysymbol(mol_a,maker_a)
    print(bind_pos_a)
    bind_pos_b=get_neiid_bysymbol(mol_b,maker_b)
    print(bind_pos_b)
    #转换成可编辑分子，在两个待连接位点之间加入单键连接，特殊情形需要其他键类型的情况较少，需要时再修改
    merged_mol = Chem.CombineMols(mol_a,mol_b)
    ed_merged_mol= Chem.EditableMol(merged_mol)
    ed_merged_mol.AddBond(bind_pos_a,bind_pos_b+21,order=Chem.rdchem.BondType.SINGLE)
    #将图中多余的marker原子逐个移除，先移除marker a
    marker_a_idx=get_id_bysymbol(merged_mol,maker_a)
    ed_merged_mol.RemoveAtom(marker_a_idx)
    #marker a移除后原子序号变化了，所以又转换为普通分子后再次编辑，移除marker b
    temp_mol = ed_merged_mol.GetMol()
    marker_b_idx=get_id_bysymbol(temp_mol,maker_b)
    ed_merged_mol=Chem.EditableMol(temp_mol)
    ed_merged_mol.RemoveAtom(marker_b_idx)
    final_mol = ed_merged_mol.GetMol()
    
    return final_mol

def pickfragments(fragmentslib, heavyatmnumrange):

    """根据阈值处理数据，返回处理后的结果和统计信息
    
    参数:
        data (pd.DataFrame): 输入数据框
        threshold (float): 过滤阈值，默认为0.5
        
    返回:
        tuple: 包含两个元素
            - processed_data (pd.DataFrame): 处理后的数据
            - stats (dict): 处理统计信息
            
    异常:
        ValueError: 当阈值不在0-1范围内时抛出
            
    示例:
        >>> data = pd.DataFrame({'value': [0.1, 0.6, 0.4]})
        >>> df, stats = process_data(data, threshold=0.5)
    """

    fragmentslib = pickle.load(open(fragmentslib,'rb+'))

    if heavyatmnumrange == "0":
        minatmnum = 1
        maxatmnum = 10
    else:
        minatmnum = int(heavyatmnumrange.split("-")[0])
        maxatmnum = int(heavyatmnumrange.split("-")[1])

    numlst = [i for i in range(minatmnum, maxatmnum+1) if min(fragmentslib.keys()) <= i <= max(fragmentslib.keys())]

    fragmentspicked = []
    for i in numlst:
        for a in fragmentslib[i]:
            fragmentspicked.append(a)
    
    return fragmentspicked


def generate_star_variants(input_str):
    """
    生成保留每个星号(*)而去掉其他星号的字符串变体
    
    参数:
        input_str (str): 包含星号的输入字符串(如"CCCCCOO*OOOOCCC*CCCCC*OOOOO")
        
    返回:
        list: 生成的字符串列表，每个字符串保留原始字符串中的一个星号
        
    示例:
        >>> generate_star_variants("A*B*C*D")
        ['A*BCD', 'AB*CD', 'ABC*D']
    """
    if '*' not in input_str:
        return [input_str]
    
    star_indices = [i for i, char in enumerate(input_str) if char == '*']
    variants = []
    
    for i in star_indices:
        # 保留当前星号，去掉其他所有星号
        variant = []
        for j, char in enumerate(input_str):
            if char == '*' and j != i:
                continue  # 跳过其他星号
            variant.append(char)
        variants.append(''.join(variant))
    
    return variants

def iterallnodes(fragment):
    
    """
    生成保留每个星号(*)而去掉其他星号的字符串变体
    
    参数:
        input_str (str): 包含星号的输入字符串(如"CCCCCOO*OOOOCCC*CCCCC*OOOOO")
        
    返回:
        list: 生成的字符串列表，每个字符串保留原始字符串中的一个星号
        
    示例:
        >>> generate_star_variants("A*B*C*D")
        ['A*BCD', 'AB*CD', 'ABC*D']

    根据阈值处理数据，返回处理后的结果和统计信息
    
    参数:
        data (pd.DataFrame): 输入数据框
        threshold (float): 过滤阈值，默认为0.5
        
    返回:
        tuple: 包含两个元素
            - processed_data (pd.DataFrame): 处理后的数据
            - stats (dict): 处理统计信息
            
    异常:
        ValueError: 当阈值不在0-1范围内时抛出
            
    示例:
        >>> data = pd.DataFrame({'value': [0.1, 0.6, 0.4]})
        >>> df, stats = process_data(data, threshold=0.5)
    """

    fragment = standardize_smiles(fragment)

    if '*' not in fragment:
        return [fragment]
    
    mark_indices = [i for i, char in enumerate(fragment) if char == '*']
    onemarkfrags = []
    
    for i in mark_indices:
        # 保留当前星号，去掉其他所有星号
        variant = []
        for j, char in enumerate(fragment):
            if char == '*' and j != i:
                continue  # 跳过其他星号
            variant.append(char)
        onemarkfrags.append(''.join(variant).replace("()", ""))
    
    return onemarkfrags

def getfixedatms(leadmol):
    
    """根据阈值处理数据，返回处理后的结果和统计信息
    
    参数:
        data (pd.DataFrame): 输入数据框
        threshold (float): 过滤阈值，默认为0.5
        
    返回:
        tuple: 包含两个元素
            - processed_data (pd.DataFrame): 处理后的数据
            - stats (dict): 处理统计信息
            
    异常:
        ValueError: 当阈值不在0-1范围内时抛出
            
    示例:
        >>> data = pd.DataFrame({'value': [0.1, 0.6, 0.4]})
        >>> df, stats = process_data(data, threshold=0.5)
    """

    fixedatms = []

    for atom in leadmol.GetAtoms():
        if atom.GetSymbol() == "*":
            leadmark = leadmol.GetConformer().GetAtomPosition(atom.GetIdx())
            leadmarkpos = np.array([leadmark.x, leadmark.y, leadmark.z])
        else:
            fixedatms.append(atom.GetIdx())

    return fixedatms, leadmarkpos

def optimizeconf(mergemoladdh, fixedatms):

    """根据阈值处理数据，返回处理后的结果和统计信息
    
    参数:
        data (pd.DataFrame): 输入数据框
        threshold (float): 过滤阈值，默认为0.5
        
    返回:
        tuple: 包含两个元素
            - processed_data (pd.DataFrame): 处理后的数据
            - stats (dict): 处理统计信息
            
    异常:
        ValueError: 当阈值不在0-1范围内时抛出
            
    示例:
        >>> data = pd.DataFrame({'value': [0.1, 0.6, 0.4]})
        >>> df, stats = process_data(data, threshold=0.5)
    """

    ff = Chem.rdForceFieldHelpers.UFFGetMoleculeForceField(mergemoladdh)

    for atom_idx in fixedatms:
        pos = mergemoladdh.GetConformer().GetAtomPosition(atom_idx)  
        ff.AddFixedPoint(atom_idx)  

    ff.Minimize(maxIts = 10000)

    return mergemoladdh  

def createfolder(folder_path):
    """
    如果文件夹不存在，则创建它。
    
    参数:
        folder_path (str): 要创建的文件夹路径。
    """
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
        print(f"文件夹已创建: {folder_path}")
    else:
        print(f"文件夹已存在: {folder_path}")

def movefrag2lead(mol, frag_pos, lead_pos):
    """
    将分子中某个原子移动到目标坐标，并平移整个分子
    
    参数:
        mol: RDKit 分子对象
        atom_idx: 要移动的原子索引（从0开始）
        target_pos: 目标坐标 [x, y, z]（单位：Å）
    
    返回:
        平移后的新分子对象
    """
    
    # 计算平移向量
    translation = np.array(lead_pos) - np.array(frag_pos)
    
    # 创建分子副本（避免修改原分子）
    new_mol = Chem.Mol(mol)
    conf = new_mol.GetConformer()
    
    # 对所有原子应用平移
    for i in range(mol.GetNumAtoms()):
        pos = conf.GetAtomPosition(i)
        new_pos = [pos.x + translation[0], pos.y + translation[1], pos.z + translation[2]]
        conf.SetAtomPosition(i, new_pos)
    
    return new_mol

def genlibrary(leadmol2, fragmentslib, heavyatmnumrange):

    """根据阈值处理数据，返回处理后的结果和统计信息
    
    参数:
        data (pd.DataFrame): 输入数据框
        threshold (float): 过滤阈值，默认为0.5
        
    返回:
        tuple: 包含两个元素
            - processed_data (pd.DataFrame): 处理后的数据
            - stats (dict): 处理统计信息
            
    异常:
        ValueError: 当阈值不在0-1范围内时抛出
            
    示例:
        >>> data = pd.DataFrame({'value': [0.1, 0.6, 0.4]})
        >>> df, stats = process_data(data, threshold=0.5)
    """

    libfolder = "Mol3DLib"
    createfolder(libfolder)

    fragmentspicked = pickfragments(fragmentslib, heavyatmnumrange)

    leadmol = Chem.MolFromMol2File(leadmol2)
    fixedatms, leadmarkpos = getfixedatms(leadmol)

    gensmiles = []
    newsmis = open("smiboost.csv", "w")
    numidx = 0

    for frag in fragmentspicked:
        leadmolcopy = Chem.Mol(leadmol)
        
        onemarkfrags = iterallnodes(frag)
        for i in onemarkfrags:
            i = standardize_smiles(i)
            fragmol = Chem.MolFromSmiles(i)
            fragmol = Chem.AddHs(fragmol)
            Chem.AllChem.EmbedMolecule(fragmol)
            Chem.AllChem.MMFFOptimizeMolecule(fragmol)
            _, fragmarkpos = getfixedatms(fragmol)
            fragmol = Chem.RemoveHs(fragmol)
            fragmol = movefrag2lead(fragmol, fragmarkpos, leadmarkpos)
            mergemol = combine2frags(leadmolcopy, fragmol)
            smi = Chem.MolToSmiles(mergemol)
            smi_norm = standardize_smiles(smi)
            if smi_norm not in gensmiles:
                numidx += 1
                molname = f"mol{numidx}"
                gensmiles.append(smi_norm)
                newsmis.write(f"{molname},{smi_norm}\n")
                Chem.MolToMolFile(mergemol, 'merge.mol')
                cmd.load("merge.mol", "LIG")
                cmd.h_add("LIG")
                cmd.save("merge.mol2", "LIG")
                cmd.delete("all")
                fixed = [i-1 for i in fixedatms]
                mergemoladdh = Chem.MolFromMol2File('merge.mol2')
                moloptimized = optimizeconf(mergemoladdh, fixed)
                Chem.MolToMolFile(moloptimized, f"{molname}.mol")
                cmd.load(f"{molname}.mol", "LIG")
                cmd.h_add("LIG")
                cmd.alter("all","resn='LIG'")
                cmd.save(os.path.join(libfolder, f"{molname}.mol2"), "LIG")
                cmd.delete("all")

def main():

    leadmol2 = sys.argv[1]
    fragmentslib = sys.argv[2]
    heavyatmnumrange = sys.argv[3]   # 例如 3-5 会使用重原子数为3，4，5的片段进行替换生成；0 则会使用默认即 1-10
    genlibrary(leadmol2, fragmentslib, heavyatmnumrange)

if __name__=="__main__":
    main() 