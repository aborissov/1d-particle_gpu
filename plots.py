#p1 = particles("./Data/1.dat")
#p2 = particles("./Data/2.dat")
#p3 = particles("./Data/3.dat")
#p4 = particles("./Data/4.dat")
#p5 = particles("./Data/5.dat")
#p6 = particles("./Data/6.dat")
#p7 = particles("./Data/7.dat")
#p8 = particles("./Data/8.dat")
#p9 = particles("./Data/9.dat")
#p10 = particles("./Data/10.dat")
#p11 = particles("./Data/11.dat")
#p12 = particles("./Data/12.dat")

ns = [p48,p56,p59]
fig = plt.figure()
ax = fig.add_axes([0.1,0.1,0.8,0.8])
rcol = 0
gcol = 0
bcol = 0
handles = []
for i in range(len(ns)):
        if i == 0:
		col = "black"
		name = "run 24"
	elif i == 1:
		col = "red"
		name = "run 25"
	elif i == 2:
		col = "green"
		name = "run 26"
	elif i == 3:
		col = "blue"
		name = "run 27"
        hs = ns[i].hist_beta(col,name)
        handles.append(hs)
ax.set_xlabel("duration (s)")
#ax.set_xlim([0,1])
#ax.set_xlabel("cosine of pitch angle")
ax.set_ylabel("count")
all_handles, all_labels = ax.get_legend_handles_labels()
ax.legend(all_handles,all_labels)
fig.show()

