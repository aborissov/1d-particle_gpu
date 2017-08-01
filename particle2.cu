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

	float milli;
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	energy_kev = (real *)malloc(nparticles*sizeof(real));
	potential = (real *)malloc(nparticles*sizeof(real));
	h_particles = (real *)malloc(nparticles*nfields*sizeof(real));
	
	checkCudaErrors( cudaMalloc((void **)&energy_kev, nparticles*sizeof(real)) );
	checkCudaErrors( cudaMalloc((void **)&potential, nparticles*sizeof(real)) );
	checkCudaErrors( cudaMalloc((void **)&d_particles, nparticles*nfields*sizeof(real)) );
	checkCudaErrors( cudaMalloc((void **)&dw, nparticles*nt*sizeof(float)) );
	initialise(h_particles);

	checkCudaErrors( cudaMemcpy(d_particles,h_particles,nparticles*nfields*sizeof(real),cudaMemcpyHostToDevice) );

	// random number generation
	
	cudaEventRecord(start);
	
	curandGenerator_t gen;
	checkCudaErrors( curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_DEFAULT) );
	checkCudaErrors( curandSetPseudoRandomGeneratorSeed(gen, 1234ULL) );
	checkCudaErrors( curandGenerateNormal(gen, dw, nparticles*nt, 0.0f, 1.0f) );
	
	cudaEventRecord(stop);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milli, start, stop);
	
	printf("CURAND normal RNG  execution time (ms): %f,  samples/sec: %e \n",
	        milli, nparticles*nt/(0.001*milli));

	// run particles
	cudaEventRecord(start);
	move_particles<<<nblocks,threads_per_block>>>(d_particles,dw,energy_kev,potential);
	cudaEventRecord(stop);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milli, start, stop);
	
	printf("kernel  execution time (ms): %f\n", milli);


	//// main time loop
	//for (int j = 0; j < nt; j++){
	//	//if (j%1 == 0) write_particle(particles,newflag_trajectories);
	//	//newflag_trajectories = 0;


	//	//if (isnan((double) particles[0])){
	//	//	cout << "position is nan. stopping" << endl;
	//	//	return 0;
	//	//}
	//	//if (j % (nt/100) == 0) printf("timestep %d of %d\n",j,nt);
	//}

	checkCudaErrors( cudaMemcpy(h_particles,d_particles,nparticles*nfields*sizeof(real),cudaMemcpyDeviceToHost) );
	write_particles(h_particles,newflag,argv[1]);
	cout << "size of particles array " << nparticles << endl;
	//for (int j = 0; j < nparticles; j++) printf("particle %d final energy %f position %f\n",j,(particles[nfields*j+2]-1)*511.0,particles[nfields*j]*Lscl);
	
	free(h_particles);
	checkCudaErrors( cudaFree(energy_kev) );
	checkCudaErrors( cudaFree(potential) );
	checkCudaErrors( cudaFree(dw) );
	checkCudaErrors( cudaFree(d_particles) );

	cudaDeviceReset();

	return 0;
}
