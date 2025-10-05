import sys
from matplotlib import cm,colors
from matplotlib import pyplot as plt
from matplotlib.pyplot import figure, show, rc
import numpy as np
import pandas as pd

#%matplotlib inline                   
plt.rcParams["font.sans-serif"]='SimHei'   #解决中文乱码问题
plt.rcParams['axes.unicode_minus']=False   #解决负号无法显示的问题
plt.rc('axes',axisbelow=True)  

def col_pic(file):
    df=pd.read_csv(file)

    x = np.array(df["time"])
    y_rms0_whole = np.array(df["rms0_whole"])
    y_rms0_lig = np.array(df["rms0_lig"])
    y_rms1_whole = np.array(df["rms1_whole"])
    y_rms1_lig = np.array(df["rms1_lig"])
    y_rms2_whole = np.array(df["rms2_whole"])
    y_rms2_lig = np.array(df["rms2_lig"])

    fig=plt.figure(figsize=(8,8))     # 创建子图时只需要创建一张画布即可。
    #plt.subplots_adjust(left=0.1, right=0.9, top=0.9, bottom=0.3)           #设置绘图区域大小位置
    plt.subplot(3,1,1)     # 代表第二行第二列第一个图
    
    b1, = plt.plot(x,y_rms0_whole,linewidth=2, label="The Main Protease",color="#66889E")
    b2, = plt.plot(x,y_rms0_lig,linewidth=2, label="I3C-0",color="#C35C6A")

    plt.legend(handles=[b1,b2,],loc=(0.02,0.80),ncol=2,frameon=False,prop="Arial")    #显示图例，loc图例显示位置(可以用坐标方法显示），ncol图例显示几列，默认为1列,frameon设置图形边框
    leg = plt.gca().get_legend()
    ltext = leg.get_texts()
    plt.setp(ltext, fontsize=10, weight="bold")

    plt.yticks(font="Arial",weight="bold",size=12) 
    plt.xticks(font="Arial",weight="bold",size=0,rotation=30)                                          #设置y轴刻度，位置,大小
    # plt.xlabel('Time (ns)', fontproperties="Arial",fontsize=15,weight="bold")
    plt.ylabel('RMSD (nm)',fontproperties="Arial",fontsize=12,weight="bold")
    #plt.grid(axis="y",c=(217/256,217/256,217/256))        #设置网格线
                     #将y轴网格线置于底层
    #plt.xlabel("Quarter",labelpad=10,size=18,)                          #设置x轴标签,labelpad设置标签距离x轴的位置
    #plt.ylabel("Amount",labelpad=10,size=18,)  
    plt.ylim(0,0.3)                                 #设置y轴标签,labelpad设置标签距离y轴的位置

    ax = plt.gca()                         #获取整个表格边框
    #ax.spines['top'].set_color('none')  # 设置上‘脊梁’为无色
    #ax.spines['right'].set_color('none')  # 设置右‘脊梁’为无色
    #ax.spines['left'].set_color('none')  # 设置左‘脊梁’为无色
    
    plt.subplot(3,1,2)

    b1, = plt.plot(x,y_rms1_whole,linewidth=2, label="The Main Protease",color="#66889E")
    b2, = plt.plot(x,y_rms1_lig,linewidth=2, label="I3C-1",color="#C35C6A")

    plt.legend(handles=[b1,b2,],loc=(0.02,0.70),ncol=2,frameon=False,prop="Arial")    #显示图例，loc图例显示位置(可以用坐标方法显示），ncol图例显示几列，默认为1列,frameon设置图形边框
    leg = plt.gca().get_legend()
    ltext = leg.get_texts()
    plt.setp(ltext, fontsize=10, weight="bold")

    # plt.ylim(0,1)
    plt.yticks(font="Arial",weight="bold",size=12)                                          #设置y轴刻度，位置,大小
    plt.xticks(font="Arial",weight="bold",size=0,rotation=30) 
    # plt.xlabel('Time (ns)', fontproperties="Arial",fontsize=15,weight="bold")
    plt.ylabel('RMSD (nm)',fontproperties="Arial",fontsize=12,weight="bold")
    #plt.grid(axis="y",c=(217/256,217/256,217/256))        #设置网格线
                     #将y轴网格线置于底层
    #plt.xlabel("Quarter",labelpad=10,size=18,)                          #设置x轴标签,labelpad设置标签距离x轴的位置
    #plt.ylabel("Amount",labelpad=10,size=18,)                                   #设置y轴标签,labelpad设置标签距离y轴的位置
    plt.ylim(0,0.3)  
    ax = plt.gca()                         #获取整个表格边框
    
    #ax.spines['top'].set_color('none')  # 设置上‘脊梁’为无色
    #ax.spines['right'].set_color('none')  # 设置右‘脊梁’为无色
    #ax.spines['left'].set_color('none')  # 设置左‘脊梁’为无色

    plt.subplot(3,1,3)

    b1, = plt.plot(x,y_rms2_whole,linewidth=2, label="The Main Protease",color="#66889E")
    b2, = plt.plot(x,y_rms2_lig,linewidth=2, label="I3C-2",color="#C35C6A")
    
    plt.legend(handles=[b1,b2,],loc=(0.02,0.70),ncol=2,frameon=False,prop="Arial")    #显示图例，loc图例显示位置(可以用坐标方法显示），ncol图例显示几列，默认为1列,frameon设置图形边框
    leg = plt.gca().get_legend()
    ltext = leg.get_texts()
    plt.setp(ltext, fontsize=10, weight="bold")

    plt.yticks(font="Arial",weight="bold",size=12)                                          #设置y轴刻度，位置,大小
    plt.xticks(font="Arial",weight="bold",size=12,rotation=0) 
    #plt.xlabel('PDB', fontproperties="Arial",fontsize=15,weight="bold")
    plt.ylabel('RMSD (nm)',fontproperties="Arial",fontsize=12,weight="bold")
    #plt.grid(axis="y",c=(217/256,217/256,217/256))        #设置网格线
                     #将y轴网格线置于底层
    #plt.xlabel("Quarter",labelpad=10,size=18,)                          #设置x轴标签,labelpad设置标签距离x轴的位置
    #plt.ylabel("Amount",labelpad=10,size=18,)                                   #设置y轴标签,labelpad设置标签距离y轴的位置
    plt.ylim(0,0.3)  
    ax = plt.gca()                         #获取整个表格边框
    #ax.spines['top'].set_color('none')  # 设置上‘脊梁’为无色
    #ax.spines['right'].set_color('none')  # 设置右‘脊梁’为无色
    #ax.spines['left'].set_color('none')  # 设置左‘脊梁’为无色

    plt.show()
    fig.savefig('contact_1.pdf')

def main():
    file = str(sys.argv[1])
    col_pic(file)
    
if __name__=="__main__":
    main()