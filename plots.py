#p1 = particles("./Data/1.dat")
#p2 = particles("./Data/2.dat")
#p3 = particles("./Data/3.dat")
#p4 = particles("./Data/4.dat")
#
#p11 = particles("./Data/11.dat")
#p12 = particles("./Data/12.dat")
#p13 = particles("./Data/13.dat")
#p14 = particles("./Data/14.dat")
#
#p21 = particles("./Data/21.dat")
#p22 = particles("./Data/22.dat")
#p23 = particles("./Data/23.dat")
#p24 = particles("./Data/24.dat")
#
#p100 = particles("./Data/100.dat")
#p101 = particles("./Data/101.dat")

ns = [p6]
fig = plt.figure()
ax = fig.add_axes([0.1,0.1,0.8,0.8])
rcol = 0
gcol = 0
bcol = 0
handles = []
for i in range(len(ns)):
        if i == 0:
		col = "black"
		name = "run 1"
	elif i == 1:
		col = "red"
		name = "run 2"
	elif i == 2:
		col = "green"
		name = "run 3"
        hs = ns[i].hist_energy(col,name)
        handles.append(hs)
ax.set_xlabel("duration (s)")
ax.set_ylabel("count")
all_handles, all_labels = ax.get_legend_handles_labels()
ax.legend(all_handles,all_labels)
fig.show()

