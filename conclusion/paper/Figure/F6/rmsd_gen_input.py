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

with open("rms_lig_sars2.xvg") as f:
    f1 = f.readlines()

time, rms_sars2 = process(f1)

with open("rms_lig_sars.xvg") as f:
    f1 = f.readlines()

_, rms_sars = process(f1)

with open("rms_lig_mers.xvg") as f:
    f1 = f.readlines()

_, rms_mers = process(f1)

# with open("rms1_lig.xvg") as f:
#     f1 = f.readlines()

# _, rms1_lig = process(f1)

# with open("rms2_whole.xvg") as f:
#     f1 = f.readlines()

# _, rms2_whole = process(f1)

# with open("rms2_lig.xvg") as f:
#     f1 = f.readlines()

# _, rms2_lig = process(f1)

rt = open("input.csv", "w")
rt.write("time,rms_sars2,rms_sars,rms_mers\n")
for i in range(len(time)):
    rt.write(str(time[i])+","+str(rms_sars2[i])+","+str(rms_sars[i])+","+str(rms_mers[i])+"\n")
rt.close()