def process(lst):
    time = []
    rms = []
    for i in lst:
        if i.startswith("#") or i.startswith("@"):
            pass
        else:
            line = i.strip().split()
            time.append(float(line[0])/1000)
            rms.append(float(line[1]))
    return time, rms

with open("rms0_whole.xvg") as f:
    f1 = f.readlines()

time, rms0_whole = process(f1)

with open("rms0_lig.xvg") as f:
    f1 = f.readlines()

_, rms0_lig = process(f1)

with open("rms1_whole.xvg") as f:
    f1 = f.readlines()

_, rms1_whole = process(f1)

with open("rms1_lig.xvg") as f:
    f1 = f.readlines()

_, rms1_lig = process(f1)

with open("rms2_whole.xvg") as f:
    f1 = f.readlines()

_, rms2_whole = process(f1)

with open("rms2_lig.xvg") as f:
    f1 = f.readlines()

_, rms2_lig = process(f1)

rt = open("input.csv", "w")
rt.write("time,rms0_whole,rms0_lig,rms1_whole,rms1_lig,rms2_whole,rms2_lig\n")
for i in range(len(time)):
    rt.write(str(time[i])+","+str(rms0_whole[i])+","+str(rms0_lig[i])+","+str(rms1_whole[i])+","+str(rms1_lig[i])+","+str(rms2_whole[i])+","+str(rms2_lig[i])+"\n")
rt.close()