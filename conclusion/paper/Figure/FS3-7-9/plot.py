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

    x = np.array(df["x"])
    y = np.array(df["y"])

    fig=plt.figure(figsize=(10,10))     # 创建子图时只需要创建一张画布即可。
    #plt.subplots_adjust(left=0.1, right=0.9, top=0.9, bottom=0.3)           #设置绘图区域大小位置
    # plt.subplot(3,1,1)     # 代表第二行第二列第一个图

    plt.bar(x,y,width=0.5,color='#66889E',label='dock contact',edgecolor='k', linewidth=0, alpha=1)                     #调整y1轴位置，颜色，label为图例名称，与下方legend结合使用
    
    # plt.legend(loc=(0.8,0.78),ncol=1,frameon=False,prop="Times New Roman")    #显示图例，loc图例显示位置(可以用坐标方法显示），ncol图例显示几列，默认为1列,frameon设置图形边框
    # leg = plt.gca().get_legend()
    # ltext = leg.get_texts()
    # plt.setp(ltext, fontsize=18, weight="bold")

    plt.yticks(font="Times New Roman",weight="bold",size=0) 
    plt.xticks(font="Times New Roman",weight="bold",size=0)       
    plt.ylim(0,12)                                   #设置y轴刻度，位置,大小
    #plt.xlabel('PDB', fontproperties="Times New Roman",fontsize=15,weight="bold")
    # plt.ylabel('Frequency',fontproperties="Times New Roman",fontsize=18,weight="bold")
    #plt.grid(axis="y",c=(217/256,217/256,217/256))        #设置网格线
                     #将y轴网格线置于底层
    #plt.xlabel("Quarter",labelpad=10,size=18,)                          #设置x轴标签,labelpad设置标签距离x轴的位置
    #plt.ylabel("Amount",labelpad=10,size=18,)                                   #设置y轴标签,labelpad设置标签距离y轴的位置

    ax = plt.gca()                         #获取整个表格边框
    #ax.spines['top'].set_color('none')  # 设置上‘脊梁’为无色
    #ax.spines['right'].set_color('none')  # 设置右‘脊梁’为无色
    #ax.spines['left'].set_color('none')  # 设置左‘脊梁’为无色
    
    # plt.subplot(3,1,2)

    # plt.bar(x_ace2,y_ace2,width=0.5,color='#C35C6A',label='ace2 contact',edgecolor='k', linewidth=0, alpha=1)                     #调整y1轴位置，颜色，label为图例名称，与下方legend结合使用
    
    # plt.legend(loc=(0.8,0.78),ncol=1,frameon=False,prop="Times New Roman")    #显示图例，loc图例显示位置(可以用坐标方法显示），ncol图例显示几列，默认为1列,frameon设置图形边框
    # leg = plt.gca().get_legend()
    # ltext = leg.get_texts()
    # plt.setp(ltext, fontsize=18, weight="bold")

    # plt.yticks(font="Times New Roman",weight="bold",size=17)                                          #设置y轴刻度，位置,大小
    # plt.xticks(font="Times New Roman",weight="bold",size=15) 
    # #plt.xlabel('PDB', fontproperties="Times New Roman",fontsize=15,weight="bold")
    # plt.ylabel('Frequency',fontproperties="Times New Roman",fontsize=18,weight="bold")
    # #plt.grid(axis="y",c=(217/256,217/256,217/256))        #设置网格线
    #                  #将y轴网格线置于底层
    # #plt.xlabel("Quarter",labelpad=10,size=18,)                          #设置x轴标签,labelpad设置标签距离x轴的位置
    # #plt.ylabel("Amount",labelpad=10,size=18,)                                   #设置y轴标签,labelpad设置标签距离y轴的位置

    # ax = plt.gca()                         #获取整个表格边框
    # #ax.spines['top'].set_color('none')  # 设置上‘脊梁’为无色
    # #ax.spines['right'].set_color('none')  # 设置右‘脊梁’为无色
    # #ax.spines['left'].set_color('none')  # 设置左‘脊梁’为无色

    # plt.subplot(3,1,3)

    # plt.bar(x_antibody,y_antibody,width=0.5,color='#7E527F',label='antibody contact',edgecolor='k', linewidth=0,alpha=1)                     #调整y1轴位置，颜色，label为图例名称，与下方legend结合使用
    
    # plt.legend(loc=(0.8,0.78),ncol=1,frameon=False,prop="Times New Roman")    #显示图例，loc图例显示位置(可以用坐标方法显示），ncol图例显示几列，默认为1列,frameon设置图形边框
    # leg = plt.gca().get_legend()
    # ltext = leg.get_texts()
    # plt.setp(ltext, fontsize=18, weight="bold")

    # plt.yticks(font="Times New Roman",weight="bold",size=17)                                          #设置y轴刻度，位置,大小
    # plt.xticks(font="Times New Roman",weight="bold",size=15) 
    # #plt.xlabel('PDB', fontproperties="Times New Roman",fontsize=15,weight="bold")
    # plt.ylabel('Frequency',fontproperties="Times New Roman",fontsize=18,weight="bold")
    # #plt.grid(axis="y",c=(217/256,217/256,217/256))        #设置网格线
    #                  #将y轴网格线置于底层
    # #plt.xlabel("Quarter",labelpad=10,size=18,)                          #设置x轴标签,labelpad设置标签距离x轴的位置
    # #plt.ylabel("Amount",labelpad=10,size=18,)                                   #设置y轴标签,labelpad设置标签距离y轴的位置

    # ax = plt.gca()                         #获取整个表格边框
    # #ax.spines['top'].set_color('none')  # 设置上‘脊梁’为无色
    # #ax.spines['right'].set_color('none')  # 设置右‘脊梁’为无色
    # #ax.spines['left'].set_color('none')  # 设置左‘脊梁’为无色

    plt.show()
    fig.savefig('contact.pdf')

def main():
    file = str(sys.argv[1])
    col_pic(file)
    
if __name__=="__main__":
    main()