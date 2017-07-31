import numpy as np
import matplotlib.pyplot as plt
from sys import argv

class particles:
	
	def __init__(self,path):
		with open (path, 'r') as file:
			head = np.fromfile(file, dtype = np.int32, count = 2)
        		count = 2*head[0].nbytes
        		file.seek(count)
        		self.positions = np.fromfile(file, dtype = np.float32, count = head[0])
        		count += head[0]*self.positions[0].nbytes
        		file.seek(count)
        		self.energies = np.fromfile(file, dtype = np.float32, count = head[0])
        		count += head[0]*self.energies[0].nbytes
        		file.seek(count)
        		self.theta = np.fromfile(file, dtype = np.float32, count = head[0])	
        		count += head[0]*self.theta[0].nbytes
        		file.seek(count)
        		self.t_final = np.fromfile(file, dtype = np.float32)	
	
	def hist_energy(self,line_colour,name):
		hist,hbins = np.histogram(self.energies/1e3,bins = 100)
		a1 = ax.plot(hbins[:-1],hist,color = line_colour,label = name,drawstyle = 'steps')
		return a1
		#plt.show()

	def hist_position(self,line_colour,name):
		hist,hbins = np.histogram(self.positions/1e6)
		a1 = ax.plot(hbins[:-1],hist,color = line_colour,label = name,drawstyle = 'steps')
		return a1

	def hist_theta(self,line_colour,name):
		hist,hbins = np.histogram(self.theta,bins = 100)
		a1 = ax.plot(hbins[:-1],hist,color = line_colour,label = name,drawstyle = 'steps')
		return a1
	
	def hist_tf(self,line_colour,name):
		hist,hbins = np.histogram(self.t_final,bins = 100)
		a1 = ax.plot(hbins[:-1],hist,color = line_colour,label = name,drawstyle = 'steps')
		return a1


class trajectories:

	def __init__(self,path):
		with open (path, 'r') as file:
			head = np.fromfile(file, dtype = np.int32, count = 3)
        		count = 3*head[0].nbytes
        		file.seek(count)
			data = np.fromfile(file, dtype = np.float32)
			mat = data.reshape(len(data)/(head[0]*head[1]*head[2]),head[0],head[1],head[2])
			self.traj = mat[:,:,0]
			self.theta = mat[:,:,1]
			self.energies = mat[:,:,2]
			self.t_final = mat[:,:,3]

	def plot_energy(self,pn,line_colour):
		plt.plot(self.energies[:,pn]/1e3,color = line_colour)
		plt.xlabel("Time (arbitrary units)")
		plt.ylabel("Energy (keV)")

	def plot_trajectory(self,pn,line_colour):
		plt.plot(self.traj[:,pn]/1e6,color = line_colour)
		plt.xlabel("Time (arbitrary units)")
		plt.ylabel("Displacement (Mm)")

	def plot_theta(self,pn,line_colour):
		plt.plot(self.theta[:,pn]/1e3,color = line_colour)
		plt.xlabel("Time (arbitrary units)")
		plt.ylabel("Pitch Angle")


#p1 = particles("data.dat")
#p1.plot_energy()
#plt.show()
