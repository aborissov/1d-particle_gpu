import numpy as np
import matplotlib.pyplot as plt
from sys import argv

path = "data.dat"
with open (path, 'r') as file:
	head = np.fromfile(file, dtype = np.int32, count = 2)
	count = 2*head[0].nbytes
	file.seek(count)
	positions = np.fromfile(file, dtype = np.float32, count = head[0])
	count += head[0]*positions[0].nbytes
	file.seek(count)
	energies = np.fromfile(file, dtype = np.float32, count = head[0])
	count += head[0]*energies[0].nbytes
	file.seek(count)
	theta = np.fromfile(file, dtype = np.float32)

#limsy = [0,2]
#plt.plot(x)
##plt.ylim(limsy)
#plt.show()

#plt.hist(x,bins = 100,range = (-3e2,3e2))
plt.hist(positions/1e6,bins = 100,histtype = 'step',color = 'k')
plt.xlabel("Displacement (Mm)")
plt.ylabel("count")
#plt.show()
print len(positions)

plt.figure()
plt.hist(energies/1e3,bins = 100,histtype = 'step', color = 'k')
plt.xlabel("Energy (keV)")
plt.ylabel("count")
#plt.show()

plt.figure()
plt.hist(theta,bins = 100,histtype = 'step', color = 'k')
plt.xlabel("Pitch Angle")
plt.ylabel("count")
plt.show()

