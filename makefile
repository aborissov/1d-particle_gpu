OBJS = diagnostics.o initial_conditions.o evol.o particle2.o
CCG = g++
CCN = nvcc
DEBUG = -g
CFLAGS = -O3 -std=gnu++11  -c $(DEBUG)
LFLAGS = -O3 -std=gnu++11  $(DEBUG)
NVCCFLAGS = -lineinfo -arch=sm_35 --ptxas-options=-v --use_fast_math -c
NVCCLFLAGS = -lineinfo -arch=sm_35 --ptxas-options=-v --use_fast_math 
INC = -I$(CUDA_HOME)/include -I.
LIB = -L$(CUDA_HOME)/lib64 -lcudart -lcurand

p1 : $(OBJS)
	$(CCN) $(NVCCLFLAGS) $(LIB) $(OBJS) -o p1
	#$(CCN) $(INC) $(NVCCLFLAGS) $(LIB) $(OBJS) particle2.cu

particle2.o : particle2.cu initial_conditions.h evol.h diagnostics.h constants.h
	$(CCN) $(INC) $(NVCCFLAGS) $(LIB) particle2.cu

diagnostics.o : diagnostics.h diagnostics.cpp constants.h
	$(CCN) $(INC) $(NVCCFLAGS) $(LIB) diagnostics.cpp
	#$(CCG) $(CFLAGS) diagnostics.cpp

initial_conditions.o : initial_conditions.h initial_conditions.cpp constants.h
	$(CCN) $(INC) $(NVCCFLAGS) $(LIB) initial_conditions.cpp
	#$(CCG) $(CFLAGS) initial_conditions.cpp

evol.o : evol.h evol.cu constants.h
	$(CCN) $(NVCCFLAGS) evol.cu

clean:
	\rm *.o p1
