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

import sys
from pymol import cmd
from rdkit import Chem
from molvs import standardize_smiles

# 假设片段库是一个 SMILES 列表
fragment_library = [
    "*C",        # 甲基
    "*OCCCC",        # 羟基
    "*N",        # 氨基
    "*CCC=O",      # 羰基
    "*C#N",      # 氰基
    # ... 其他片段
]

def get_neiid_bysymbol(mol,marker):
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

#函数二，获取marker原子的index
def get_id_bysymbol(mol,marker):
    for atom in mol.GetAtoms():
        if atom.GetSymbol()==marker:
            return atom.GetIdx()

mol_a = MolFromMol2File('LIG-1.mol2')
# mol_a = Chem.AddHs(mol_a)
Chem.MolToMolFile(mol_a, 'optimized_mol_11.mol')
mol_b = Chem.MolFromSmiles(fragment_library[0])
AllChem.EmbedMolecule(mol_b)
AllChem.MMFFOptimizeMolecule(mol_b)
# mol_b = Chem.AddHs(mol_b)

def combine2frags(mol_a,mol_b,maker_b='*',maker_a='*'):
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

final_mol = combine2frags(mol_a, mol_b)
Chem.MolToMolFile(final_mol, 'merge.mol')

cmd.load("merge.mol", "LIG")
cmd.alter("all","resn='LIG'")
cmd.h_add("LIG")
cmd.save("merged.mol2", "LIG")
cmd.delete("all")

modified_mol = MolFromMol2File('merged.mol2')

fixed_atoms = list(range(15))  # 例如，固定前两个原子（C 和 C）

# 3. 创建 UFF 力场对象
ff = rdForceFieldHelpers.UFFGetMoleculeForceField(modified_mol)

# 4. 添加位置约束：将固定原子的位置约束为初始坐标
for atom_idx in fixed_atoms:
    pos = modified_mol.GetConformer().GetAtomPosition(atom_idx)  # 获取原子的初始坐标
    ff.AddFixedPoint(atom_idx)  # 固定该原子的位置

# 5. 运行优化
ff.Minimize(maxIts=1000)  # 最大迭代次数

# 6. 查看优化后的结构
# print(Chem.MolToXYZBlock(mol))  # 输出优化后的 XYZ 坐标

# 7. 保存优化后的分子（可选）
Chem.MolToMolFile(modified_mol, 'final.mol')  # 保存为 .mol 文件
# Chem.MolToMolFile(final_mol, 'optimized_mol_5.mol')  # 保存为 .mol 文件

cmd.load("final.mol", "LIG")
cmd.h_add("LIG")
cmd.save("final.mol2", "LIG")
cmd.delete("all")

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
        onemarkfrags.append(''.join(variant))
    
    return onemarkfrags

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

    fragmentspicked = pickfragments(fragmentslib, heavyatmnumrange)

    leadmol = Chem.MolFromMol2File(leadmol2)
    # 需要找出leadmol中除了mark的其他的所有原子的idx用来后续最小化时候的固定

    for frag in fragmentspicked:
        leadmolcopy = leadmol.copy()
        
        onemarkfrags = iterallnodes(frag)
        for i in onemarkfrags:
            i = standardize_smiles(i)
            fragmol = Chem.MolFromSmiles(i)
            Chem.AllChem.EmbedMolecule(fragmol)
            Chem.AllChem.MMFFOptimizeMolecule(fragmol)
            



    # 迭代每个片段上的每个可拼接节点对leadmol进行片段替换拼接生成SMILES和对应的3D结构，先设置一个列表，看新生成的分子在不在列表中，不在的话就存在列表中并生成其对应的3D结构，存在的话跳过。这样做是为了生成重复的分子。


def main():

    leadmol2 = sys.argv[1]
    fragmentslib = sys.argv[2]
    heavyatmnumrange = sys.argv[3]   # 例如 3-5 会使用重原子数为3，4，5的片段进行替换生成；0 则会使用默认即 1-10
    genlibrary(leadmol2, fragmentslib, heavyatmnumrange)

if __name__=="__main__":
    main() 