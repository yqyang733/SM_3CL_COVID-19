with open("predict_all_12w.csv") as f:
    f1 = f.readlines()
a = 0
b = 0
c = 0
d = 0
e = 0
f = 0
g = 0
h = 0
for i in f1:
    line = i.strip().split(",")
    if -3 < float(line[2]) <= -2:
        a += 1
    elif -2 < float(line[2]) <= -1:
        b += 1
    elif -1 < float(line[2]) <= 0:
        c += 1
    elif 0 < float(line[2]) <= 1:
        d += 1
    elif 1 < float(line[2]) <= 2:
        e += 1
    elif 2 < float(line[2]) <= 3:
        f += 1
    elif 3 < float(line[2]) <= 4:
        g += 1
    elif 4 < float(line[2]) <= 5:
        h += 1
rt = open("distribution.csv", "w")
rt.write("(-3 -2],"+str(a)+"\n")
rt.write("(-2 -1],"+str(b)+"\n")
rt.write("(-1 0],"+str(c)+"\n")
rt.write("(0 1],"+str(d)+"\n")
rt.write("(1 2],"+str(e)+"\n")
rt.write("(2 3],"+str(f)+"\n")
rt.write("(3 4],"+str(g)+"\n")
rt.write("(4 5],"+str(h)+"\n")