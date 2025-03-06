import sys
import dbm
import struct
from typing import List
from rdkit import Chem
from rdkit.Chem import BRICS

def get_fragment(smiles_lst: List[str]) -> None:
    """
    BRICS分解分子并统计片段频率
    
    参数:
        smiles_lst (List[str]): 输入SMILES列表
        
    返回:
        None: 结果保存到output.dbm，日志写入output.log
    """
    database_path = 'output.dbm'
    log_path = 'output.log'
    
    # 使用上下文管理器确保资源释放
    with dbm.open(database_path, flag='n') as database, \
         open(log_path, "w", encoding='utf-8') as log_file:
        
        processed_count = 0
        for idx, smi in enumerate(smiles_lst, 1):
            try:
                # 分子解析与过滤
                mol = Chem.MolFromSmiles(smi)
                if mol is None or mol.GetNumHeavyAtoms() > 200:
                    continue
                
                # BRICS分解
                fragments = BRICS.BRICSDecompose(mol)
                
                # 片段计数更新
                for fragment in fragments:
                    # 统一使用字符串作为key (兼容所有dbm后端)
                    byte_count = database.get(fragment, b'\x00\x00\x00\x00')
                    current_count = struct.unpack('I', byte_count)[0] + 1
                    database[fragment] = struct.pack('I', current_count)
                
                # 日志记录
                processed_count += 1
                if processed_count % 1000 == 0:
                    log_entry = f"Processed {processed_count} molecules (total {idx})\n"
                    log_file.write(log_entry)
                    
            except Exception as e:
                error_msg = f"Error processing molecule #{idx} ({smi}): {str(e)}\n"
                log_file.write(error_msg)

def sdf_to_smiles(sdf_path):
    """
    将 SDF 文件转换为 SMILES 列表
    参数:
        sdf_path (str): SDF 文件路径
    返回:
        list: 包含所有有效分子 SMILES 的列表
    """
    smiles_list = []
    
    # 读取 SDF 文件
    suppl = Chem.SDMolSupplier(sdf_path)
    
    # 遍历每个分子
    for mol in suppl:
        try:
            # 跳过无效分子
            if mol is None:
                continue
                
            # 生成规范化 SMILES
            smiles = Chem.MolToSmiles(mol, canonical=True)
            smiles_list.append(smiles)
            
        except Exception as e:
            print(f"Error processing molecule: {e}")
            continue
            
    return smiles_list

def main():

    sdf_path = sys.argv[1]
    smiles_lst = sdf_to_smiles(sdf_path)
    get_fragment(smiles_lst)

if __name__=="__main__":
    main() 
