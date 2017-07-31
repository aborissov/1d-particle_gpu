#include <iostream>
#include <stdio.h>
#include <math.h>
#include "constants.h"

using namespace std;

__device__ real calc_vel(real gamma, real beta){
        real v = sqrt(c*c - c*c/(gamma*gamma));
        //cout << "gamma = " << gamma << endl;
        //cout << "beta = " << beta << endl;
        //cout << "v = " << v << endl;
        return v/Vscl;
}

__global__ void move_particles(real *particles, float *dw, real *energy_kev,real *potential){
        real E,J,eta,eta_spitzer,nu,kappa,lambda_ei = 2.0e8/Lscl,Epar_extent = 1.0e3;
		real beta,v,u,uperp,gamma,dudt,betadot,gammadot,dbeta,dgamma,position;
		int tid = threadIdx.x + blockIdx.x*blockDim.x;
		int random_index;
		random_index = tid;
		//random_index = timestep;

        for(int tstep = 0; tstep < nt; tstep++){
			position = particles[nfields*tid];
			beta = particles[nfields*tid+1];
			gamma = particles[nfields*tid+2];
        	v = calc_vel(gamma,beta);
        	u = v*gamma*beta;
        	uperp = v*gamma*sqrt(1.0-beta*beta);

			//printf("particle %d dw %f random_index %d\n",tid,dw[random_index],random_index);

			if (abs(position*Lscl) < Epar_extent){
				//kappa = eta_spitzer/eta;
				kappa = 1.0e-5;
			}
			else {
				J = 0;
				E = 0;
				if (particles[nfields*tid+3] == 0){
					particles[nfields*tid+3] = tstep*dt*Tscl;
					//cout << "particle " << tid << " " << timestep*dt*Tscl << endl;
				}
			}
			if (particles[nfields*tid+3] == 0){
				eta_spitzer = 2.4e3/(pow((double) Temp,1.5))/etascl;
				J = 1.0e4/Escl;		// NON-DIMENSIONAL!!! Note: ensures electric field of 10 V/m when eta = 10^-3 (non-dimensional)
				eta = 1.0e-3;		// NON-DIMENSIONAL!!!
    			E = eta*J;			// NON-DIMENSIONAL!!!

				if (abs(position*Lscl) < Epar_extent) nu = v/(lambda_ei*kappa);
				else nu = 0.0;
				//nu = 0.0;

        	        	dudt = q*E*Escl/m*Tscl/Vscl;
        	        	gammadot = u*Vscl/(c*c)*dudt*Vscl/(sqrt(1 + u*u*Vscl*Vscl/(c*c) + uperp*uperp*Vscl*Vscl/(c*c)));      // work in progress!!!
        	        	if (u == 0) betadot = 0;
        	        	else betadot = dudt/u*beta*(1.0-beta*beta);

        	        	dgamma = gammadot*dt;
        	        	dbeta = (betadot - beta*nu)*dt + sqrt((1.0 - beta*beta)*nu)*((real) dw[random_index]);
						random_index += blockDim.x;

        	        	beta += dbeta;
        	        	if (beta > 1.0){
							//cout << "beta = " << particles[nfields*tid+1] << endl;
							beta = -beta + floor(beta) + 1.0;
						}
        	        	else if (beta < -1.0){
							//cout << "beta = " << particles[nfields*tid+1] << endl;
							beta = -beta + ceil(beta) - 1.0;
						}
        	        	gamma += dgamma;
        	        	if (gamma < 1) gamma -= 2.0*dgamma;

        	        	v = calc_vel(gamma, beta);
        	        	position += beta*v*dt;
				
				energy_kev[tid] = (gamma-1.0)*511.0;
				potential[tid] = -eta*J*Escl*position*Lscl/1.0e3;
				

				particles[nfields*tid] = position;
				particles[nfields*tid+1] = beta;
				particles[nfields*tid+2] = gamma;
				
				//if (fabs(energy_kev[tid] - potential[tid] - energy_kev_0) < 1.0 && tid == 1){
				//	printf("particle %d deviated from energy conservation at time %f", tid, timestep*dt*Tscl);
				//	printf(" kinetic %f, potential %f, initial %f, difference %f\n", energy_kev[tid], potential[tid], energy_kev_0,energy_kev[tid] - potential[tid] - energy_kev_0);
				//	printf(" eta, J, Escl, position, epar_extent, %f %f %f %f %f\n", eta,J,Escl,position*Lscl,Epar_extent);
				//}
				if (fabs(energy_kev[tid] - potential[tid] - energy_kev_0) > 1.0){
					particles[nfields*tid] = Epar_extent/Lscl;
					printf("particle %d deviated from energy conservation at time %f", tid, tstep*dt*Tscl);
					printf(" kinetic %f, potential %f, initial %f, difference %f\n", energy_kev[tid], potential[tid], energy_kev_0,energy_kev[tid] - potential[tid] - energy_kev_0);
					printf(" eta, J, Escl, position, epar_extent, %f %f %f %f %f\n", eta,J,Escl,position*Lscl,Epar_extent);
				}
				//cout << "particle " << tid << " total energy " << energy_kev[tid] - potential[tid] - energy_kev_0  
				//	<< " kinetic, potential, initial " << energy_kev[tid] << " " << potential[tid] << " "  << energy_kev_0 << endl;
			}
        }
}

