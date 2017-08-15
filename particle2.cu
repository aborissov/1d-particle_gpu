#define MAINFILE
#include <iostream>
#include <fstream>
#include <math.h>
#include <cuda.h>
#include <curand.h>
#include "helper_cuda.h"

#include "constants.h"
#include "initial_conditions.h"
#include "evol.h"
#include "diagnostics.h"

using namespace std;

int main(int argc, char *argv[]){
	real *h_particles, *d_particles; // array of particles: 1d position, cosine of pitch angle, lorentz factor, exit time
	bool newflag = 1,newflag_trajectories = 1;
	float *dw;
	int threads_per_block = 32;
	int nblocks = nparticles/threads_per_block;  // make sure nparticles is a multiple of 32

	printf("nt %d dt %f Tfinal %f timeblocks %d\n ",nt,dt,Tfinal,timeblocks);
	printf("nblocks %d, threads_per_block %d threads %d, nparticles %d\n",nblocks,threads_per_block,threads_per_block*nblocks,nparticles);


	float milli;
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	h_particles = (real *)malloc(nparticles*nfields*sizeof(real));
	
	checkCudaErrors( cudaMalloc((void **)&d_energy_kev, nparticles*sizeof(real)) );
	checkCudaErrors( cudaMalloc((void **)&d_potential, nparticles*sizeof(real)) );
	checkCudaErrors( cudaMalloc((void **)&d_particles, nparticles*nfields*sizeof(real)) );
	checkCudaErrors( cudaMalloc((void **)&dw, nparticles*nt*sizeof(float)) );
	initialise(h_particles);
	
	printf("size of: dw %d d_particles %d\n", nparticles*nt, nparticles*nfields);

	checkCudaErrors( cudaMemcpy(d_particles,h_particles,nparticles*nfields*sizeof(real),cudaMemcpyHostToDevice) );

	// random number generation
	
	cudaEventRecord(start);
	
	curandGenerator_t gen;
	checkCudaErrors( curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_XORWOW) );
	checkCudaErrors( curandSetPseudoRandomGeneratorSeed(gen, 1234ULL) );
	checkCudaErrors( curandGenerateNormal(gen, dw, nparticles*nt, 0.0f, 1.0f) );
	
	cudaEventRecord(stop);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milli, start, stop);
	
	printf("CURAND normal RNG  execution time (ms): %f,  samples/sec: %e \n",
	        milli, nparticles*nt/(0.001*milli));

	// run particles
	cudaEventRecord(start);
	for (int j = 0; j < timeblocks; j++){
		checkCudaErrors( curandSetGeneratorOffset(gen, (unsigned long long) j*nparticles*nt-1) );
		checkCudaErrors( curandGenerateNormal(gen, dw, nparticles*nt, 0.0f, 1.0f) );
		move_particles<<<nblocks,threads_per_block>>>(d_particles,dw,d_energy_kev,d_potential,&j);
		getLastCudaError("move_particles execution failed\n");
		if (j % 100 == 0) printf("done timeblock %d\n",j);
	}
	cudaEventRecord(stop);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milli, start, stop);
	
	printf("kernel  execution time (ms): %f\n", milli);

	checkCudaErrors( cudaMemcpy(h_particles,d_particles,nparticles*nfields*sizeof(real),cudaMemcpyDeviceToHost) );
	write_particles(h_particles,newflag,argv[1]);
	cout << "size of particles array " << nparticles << endl;
	//for (int j = 0; j < nparticles; j++) printf("particle %d final energy %f position %f\n",j,(particles[nfields*j+2]-1)*511.0,particles[nfields*j]*Lscl);
	
	free(h_particles);
	checkCudaErrors( cudaFree(d_energy_kev) );
	checkCudaErrors( cudaFree(d_potential) );
	checkCudaErrors( cudaFree(dw) );
	checkCudaErrors( cudaFree(d_particles) );

	cudaDeviceReset();

	return 0;
}
