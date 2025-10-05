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
# plt.subplots_adjust(left=0.3, right=0.9, top=0.9, bottom=0.2)

def col_pic(file):
    df=pd.read_csv(file)
    #df=df.sort_values(by='1996', ascending=False)

    x_label = np.array(df["Fold"], dtype=np.str_)
    x=np.arange(len(x_label))
    y1=np.array(df["Value"])
    # er_1=np.array(df["SD"])
    # y2=np.array(df["K_484"])
    # er_2=np.array(df["K_484_er"])
    # error_attri_1={"elinewidth":1.5,"ecolor":"black","capsize":2}
    # error_attri_2={"elinewidth":1,"ecolor":"forestgreen","capsize":2}

    fig=plt.figure(figsize=(6,8))
    plt.subplots_adjust(left=0.18, right=0.9, top=0.9, bottom=0.15)           #设置绘图区域大小位置

    plt.bar(x[0],y1[0],width=0.45,color='#014F9C',label='gbsa',edgecolor='k', linewidth=0, alpha=1) # yerr=er_1, error_kw=error_attri_1, alpha=1)                     #调整y1轴位置，颜色，label为图例名称，与下方legend结合使用
    plt.bar(x[1],y1[1],width=0.45,color='#3C79B4',label='gbsa',edgecolor='k', linewidth=0, alpha=1)
    plt.bar(x[2],y1[2],width=0.45,color='#78A3CC',label='gbsa',edgecolor='k', linewidth=0, alpha=1)
    plt.bar(x[3],y1[3],width=0.45,color='#B3CDE4',label='gbsa',edgecolor='k', linewidth=0, alpha=1)
    plt.bar(x[4],y1[4],width=0.45,color='#EEF7FC',label='gbsa',edgecolor='k', linewidth=0, alpha=1)
    # plt.bar(x+0.3,y2,width=0.3,color='forestgreen',label='K484',edgecolor='k', linewidth=0.25, yerr=er_2, error_kw=error_attri_2, alpha=1)                 #调整y2轴位置，颜色，label为图例名称，与下方legend结合使用
    plt.xticks(x,x_label,font="Arial",size=20,rotation=0,weight="bold")                                #设置x轴刻度，位置,大小

    # plt.legend(loc=(0.83,0.85),ncol=1,frameon=False,prop="Arial",)    #显示图例，loc图例显示位置(可以用坐标方法显示），ncol图例显示几列，默认为1列,frameon设置图形边框

    plt.yticks(font="Arial",size=20,weight="bold")                                          #设置y轴刻度，位置,大小
    # plt.xlabel('Conformations', fontproperties="Arial",fontsize=24,weight="bold")
    plt.ylabel('Mean Squared Error',fontproperties="Arial",fontsize=24,weight="bold")
    #plt.grid(axis="y",c=(217/256,217/256,217/256))        #设置网格线
                     #将y轴网格线置于底层
    #plt.xlabel("Quarter",labelpad=10,size=18,)                          #设置x轴标签,labelpad设置标签距离x轴的位置
    #plt.ylabel("Amount",labelpad=10,size=18,)                                   #设置y轴标签,labelpad设置标签距离y轴的位置
    # plt.ylim(0, 1)

    ax = plt.gca()                         #获取整个表格边框
    #ax.spines['top'].set_color('none')  # 设置上‘脊梁’为无色
    #ax.spines['right'].set_color('none')  # 设置右‘脊梁’为无色
    #ax.spines['left'].set_color('none')  # 设置左‘脊梁’为无色

    plt.show()
    fig.savefig('MSE.pdf')

def main():
    file = str(sys.argv[1])
    col_pic(file)
    
if __name__=="__main__":
    main() 