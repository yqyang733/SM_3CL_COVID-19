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
plt.rcParams['xtick.direction']='in'
plt.rcParams['ytick.direction']='in'
plt.subplots_adjust(left=0.35, right=0.9, top=0.9, bottom=0.3)

def col_pic(file):
    df=pd.read_csv(file)
    #df=df.sort_values(by='1996', ascending=False)

    x_label=np.array(df["mut"])
    x=np.arange(len(x_label))
    y1=np.array(df["pre"])
    er_1=np.array(df["pre_er"])
    y2=np.array(df["lab"])
    # er_2=np.array(df["lab_er"])
    error_attri_1={"elinewidth":1,"ecolor":"black","capsize":2}
    # error_attri_2={"elinewidth":1,"ecolor":"black","capsize":2}

    fig=plt.figure(figsize=(8,8))
    fig,ax1=plt.subplots()
    # ax1.set_ylim(-abs(max(y1,key=abs))-1,(abs(max(y1,key=abs))+1)/1)
    plt.subplots_adjust(left=0.15, right=0.85, top=0.95, bottom=0.2)           #设置绘图区域大小位置

    # b1 = plt.bar(x,y1,width=0.3,color='#C3CFEB',label='Theory',edgecolor='k', linewidth=0, yerr=er_1, error_kw=error_attri_1, alpha=1)                     #调整y1轴位置，颜色，label为图例名称，与下方legend结合使用
    b1 = plt.bar(x,y1,width=0.3,color='#345FBB',label='Theory',edgecolor='k', linewidth=0, yerr=er_1, error_kw=error_attri_1, alpha=0.7)                     #调整y1轴位置，颜色，label为图例名称，与下方legend结合使用

    plt.xticks(x+0.15,x_label,font="Arial",size=20,rotation=0,weight="bold")                                #设置x轴刻度，位置,大小
    plt.yticks(font="Arial",size=20,weight="bold",color="black")
    plt.ylabel('ΔΔG/(kcal/mol)',fontproperties="Arial",fontsize=24,weight="bold")
    # plt.xlabel('Mutations', fontproperties="Arial",fontsize=24,weight="bold")

    # ax2=ax1.twinx()#产生一个ax1的镜面坐标
    # b2 = plt.bar(x+0.3,y2,width=0.3,color='#F3CCC2',label='Experiment',edgecolor='k', linewidth=0, alpha=1,) #yerr=er_2, error_kw=error_attri_2, )                 #调整y2轴位置，颜色，label为图例名称，与下方legend结合使用
    b2 = plt.bar(x+0.3,y2,width=0.3,color='#D75533',label='Experiment',edgecolor='k', linewidth=0, alpha=0.7,) #yerr=er_2, error_kw=error_attri_2, )                 #调整y2轴位置，颜色，label为图例名称，与下方legend结合使用

    # ax2.set_ylim(-abs(max(y2,key=abs))-0.2,(abs(max(y2,key=abs))+0.2)/1)
                                             #设置y轴刻度，位置,大小
    # plt.yticks(font="Arial",size=20,color="#CE8892",weight="bold")
    #plt.grid(axis="y",c=(217/256,217/256,217/256))        #设置网格线
                     #将y轴网格线置于底层
    #plt.xlabel("Quarter",labelpad=10,size=18,)                          #设置x轴标签,labelpad设置标签距离x轴的位置
    #plt.ylabel("Amount",labelpad=10,size=18,)                                   #设置y轴标签,labelpad设置标签距离y轴的位置

    # ax = plt.gca()                         #获取整个表格边框
    #ax.spines['top'].set_color('none')  # 设置上‘脊梁’为无色
    #ax.spines['right'].set_color('none')  # 设置右‘脊梁’为无色
    #ax.spines['left'].set_color('none')  # 设置左‘脊梁’为无色
    plt.ylim(-2,1)
    plt.legend(handles=[b1,b2],loc=(0.63,0.8),ncol=1,frameon=False,prop="Arial",)    #显示图例，loc图例显示位置(可以用坐标方法显示），ncol图例显示几列，默认为1列,frameon设置图形边框
    leg = plt.gca().get_legend()
    ltext = leg.get_texts()
    plt.setp(ltext, fontsize=15, weight="bold")
    plt.show()
    fig.savefig('pdb_vG.pdf')

def main():
    file = str(sys.argv[1])
    col_pic(file)
    
if __name__=="__main__":
    main() 