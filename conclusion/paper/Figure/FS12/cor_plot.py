import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.patches as patches

with open("ddg.dat") as f:
    f.readline()
    f1 = f.readlines()

X = []
Y = []

for i in f1:
    line = i.strip().split(",")
    X.append(float(line[1]))
    Y.append(float(line[2]))

pearson= np.corrcoef(X,Y)[0,1]
rt = open("pearson.dat","w")
rt.write("pearson="+str(pearson))
rt.close()

# r2 = 1 - np.sum((np.array(X) - np.array(Y))**2) / np.sum((np.array(X) - np.mean(np.array(Y)))**2)
# rt = open("r2.dat","w")
# rt.write("r2="+str(r2))
# rt.close()

fig = plt.figure(figsize=(8,8))
plt.subplots_adjust(left=0.2, right=0.8, top=0.9, bottom=0.15)

plt.scatter(X, Y, s=60, alpha=0.7, edgecolors="k")

b, a = np.polyfit(X, Y, deg=1)

xseq = np.linspace(min(X)-0.7, max(X)+0.5, num=100) # x轴
plt.plot(xseq, a + b * xseq, color="k", lw=2.5)

plt.xlabel('', fontproperties="Arial",fontsize=24,weight="bold")
plt.ylabel('', fontproperties="Arial",fontsize=24,weight="bold")
plt.xticks(font="Arial",rotation=0,size=18,weight="bold")      # size must be after the font.
plt.yticks(font="Arial",size=18,weight="bold")

plt.show()
# fig.savefig('huitu.pdf')