ns = [p2]
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
	elif i == 3:
		col = "blue"
		name = "run 4"
        hs = ns[i].hist_beta(col,name)
        handles.append(hs)
ax.set_xlabel("duration (s)")
ax.set_ylabel("count")
all_handles, all_labels = ax.get_legend_handles_labels()
ax.legend(all_handles,all_labels)
fig.show()

