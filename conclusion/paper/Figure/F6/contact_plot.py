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
    #df=df.sort_values(by='1996', ascending=False)

    x_label=np.array(df["residue"])
    x=np.arange(len(x_label))
    y1=np.array(df["SARS2"])
    y2=np.array(df["SARS"])
    y3=np.array(df["MERS"])

    # fig=plt.figure(figsize=(8,5))
    fig,ax=plt.subplots()
    plt.subplots_adjust(left=0.25, right=0.9, top=0.9, bottom=0.25)           #设置绘图区域大小位置

    # plt.bar(x,y1,width=0.3,color='#00AFBB',label='Initial',edgecolor='#00AFBB', linewidth=0.25)                     #调整y1轴位置，颜色，label为图例名称，与下方legend结合使用
    plt.bar(x,y1,width=0.2,label='SARS2',edgecolor='#66889E', linewidth=0,color="#66889E")
    # plt.bar(x+0.3,y2,width=0.3,color='#FC4E07',label='20ns',edgecolor='#FC4E07', linewidth=0.25)                 #调整y2轴位置，颜色，label为图例名称，与下方legend结合使用
    plt.bar(x+0.2,y2,width=0.2,label='SARS',edgecolor='#C35C6A', linewidth=0,color="#C35C6A")
    plt.bar(x+0.4,y3,width=0.2,label='MERS',edgecolor='#7E527F', linewidth=0,color="#7E527F")
    # plt.bar(x+0.6,y4,width=0.2,label='100ns',edgecolor='#5976BA', linewidth=0,color="#5976BA")
    plt.xticks(x+0.3,x_label,font="Arial",size=12,weight="bold",rotation=45)      # rotation=90                          #设置x轴刻度，位置,大小

    plt.legend(loc=(0.2,0.92),ncol=3,frameon=False,prop="Arial")    #显示图例，loc图例显示位置(可以用坐标方法显示），ncol图例显示几列，默认为1列,frameon设置图形边框
    leg = plt.gca().get_legend()
    ltext = leg.get_texts()
    plt.setp(ltext, fontsize=10, weight="bold")

    plt.yticks(font="Arial",size=12,weight="bold")                                          #设置y轴刻度，位置,大小
    #plt.grid(axis="y",c=(217/256,217/256,217/256))        #设置网格线
                     #将y轴网格线置于底层
    #plt.xlabel("Quarter",labelpad=10,size=18,)                          #设置x轴标签,labelpad设置标签距离x轴的位置
    #plt.ylabel("Amount",labelpad=10,size=18,)                                   #设置y轴标签,labelpad设置标签距离y轴的位置
    plt.xlabel('Residue', fontproperties="Arial",fontsize=15,weight="bold")
    plt.ylabel('Contact Ratio', fontproperties="Arial",fontsize=15,weight="bold")

    plt.ylim(0,1.1)

    # ax = plt.gca()                         #获取整个表格边框
    # ax.spines['top'].set_color('none')  # 设置上‘脊梁’为无色
    # ax.spines['right'].set_color('none')  # 设置右‘脊梁’为无色
    # ax.spines['left'].set_color('none')  # 设置左‘脊梁’为无色
    plt.show()

    fig.savefig('Figure.pdf')

def main():
    file = str(sys.argv[1])
    col_pic(file)
    
if __name__=="__main__":
    main() 