def plot_rmsd_namd(file):
    from matplotlib import cm,colors
    from matplotlib import pyplot as plt
    from matplotlib.pyplot import figure, show, rc
    import numpy as np
    import pandas as pd
    df = pd.read_csv(file)
    fig = plt.figure(figsize=(30,12))
    plt.subplots_adjust(left=0.1, right=0.9, top=0.9, bottom=0.4)
    ax = plt.gca()
    # df['Time'] = df['Time']/1000
    b3, = plt.plot(df['frames']/2,df['side']/10,linewidth=2, color="#DB8965", label="Side-chain atoms of ligand")
    b1, = plt.plot(df['frames']/2,df['all']/10,linewidth=2, color="#DEDEDF", label="All atoms of ligand")
    b2, = plt.plot(df['frames']/2,df['main']/10,linewidth=2, color="#7886C1", label="Core atoms of ligand")
    # b4, = plt.plot(df['frames']/2,df['pro']/10,linewidth=2, label="protein")
    # b1, = plt.plot(df['frames']/2,df['lig']/10,linewidth=2, label="lig")
    # b2, = plt.plot(df['frames']/2,df['pkt']/10,linewidth=2, label="pkt")    
    
    plt.xlabel('Time/(ns)', fontproperties="Arial",fontsize=24,weight="bold")
    plt.ylabel('RMSD/(nm)', fontproperties="Arial",fontsize=24,weight="bold")
    # plt.ylabel('Frequency',fontproperties="Arial",fontsize=28,weight="bold")   # 设置y轴标签
    plt.xticks(font="Arial",rotation=0,size=18,weight="bold")      # size must be after the font.
    plt.yticks(font="Arial",size=18,weight="bold")
    # plt.title('Frequency_vdw', fontproperties='Arial', fontsize=33)   # 设置图片标题
    plt.legend(handles=[b1,b2,b3,],loc=(0.00,0.7),ncol=1,frameon=False,prop="Arial")    #显示图例，loc图例显示位置(可以用坐标方法显示），ncol图例显示几列，默认为1列,frameon设置图形边框
    # plt.legend(handles=[b1,b2,b4],loc=(0.46,0.84),ncol=2,frameon=False,prop="Arial")
    plt.ylim(0, 0.6)
    # plt.ylim(0, 10)
    leg = plt.gca().get_legend()
    ltext = leg.get_texts()
    plt.setp(ltext, fontsize=12, weight="bold")
    plt.show()
    fig.savefig('huitu.pdf')

plot_rmsd_namd("huitu_input_pktalign.csv")