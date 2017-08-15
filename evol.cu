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

__global__ void move_particles(real *particles, float *dw, real *energy_kev,real *potential,int *timeblock){
        real E,J,eta,eta_spitzer,nu,kappa,lambda_ei = 2.0e8/Lscl,Epar_extent = 1.0e3;
		real beta,v,u,uperp,gamma,dudt,betadot,gammadot,dbeta,dgamma,position,t_final;
		int tid = threadIdx.x + blockIdx.x*blockDim.x;
		int random_index;
		random_index = threadIdx.x + nt*blockIdx.x*blockDim.x;

		position = particles[nfields*tid];
		beta = particles[nfields*tid+1];
		gamma = particles[nfields*tid+2];
		t_final = particles[nfields*tid+3];

        for(int tstep = 0; tstep < nt; tstep++){
        	v = calc_vel(gamma,beta);
        	u = v*gamma*beta;
        	uperp = v*gamma*sqrt(1.0-beta*beta);

			if (abs(position*Lscl) < Epar_extent) {
				//eta_spitzer = 2.4e3/(pow((double) Temp,1.5))/etascl;
				eta_spitzer = 7.6e-8/etascl;	// corresponds to temperature 10^7 K
				J = 1.0e4/Escl;		// NON-DIMENSIONAL!!! Note: ensures electric field of 10 V/m when eta = 10^-3 (non-dimensional)
				eta = 1.0e-3;		// NON-DIMENSIONAL!!!
    			E = eta*J;			// NON-DIMENSIONAL!!!
				kappa = 0.001*eta_spitzer/eta;
				//kappa = 1.0e-8;

				nu = v/(lambda_ei*kappa);
				//nu = 0.0;

        	    dudt = q*E*Escl/m*Tscl/Vscl;
        	    gammadot = u*Vscl/(c*c)*dudt*Vscl/(sqrt(1 + u*u*Vscl*Vscl/(c*c) + uperp*uperp*Vscl*Vscl/(c*c)));     
        	    if (u == 0) betadot = 0;
        	    else betadot = dudt/u*beta*(1.0-beta*beta);

        	    dgamma = gammadot*dt;
        	    dbeta = (betadot - beta*nu)*dt + sqrt((1.0 - beta*beta)*nu)*sqrt(dt)*((real) dw[random_index]);
			    random_index += blockDim.x;

        	    beta += dbeta;
        	    if (beta > 1.0){
					beta = -beta + floor(beta) + 1.0;
				}
        	    else if (beta < -1.0){
					beta = -beta + ceil(beta) - 1.0;
				}
        	    gamma += dgamma;
        	    if (gamma < 1) gamma -= 2.0*dgamma;

        	    v = calc_vel(gamma, beta);
        	    position += beta*v*dt;
				
				energy_kev[tid] = (gamma-1.0)*511.0;
				potential[tid] = -eta*J*Escl*position*Lscl/1.0e3;
				
				if (fabs(energy_kev[tid] - potential[tid] - energy_kev_0) > 1.0){
					position = Epar_extent/Lscl;
					printf("particle %d deviated from energy conservation at time %f", tid, (t_final+dt)*Tscl);
					printf(" kinetic %f, potential %f, initial %f, difference %f\n", energy_kev[tid], potential[tid], energy_kev_0,energy_kev[tid] - potential[tid] - energy_kev_0);
					printf(" eta, J, Escl, position, epar_extent, %f %f %f %f %f\n", eta,J,Escl,position*Lscl,Epar_extent);
				}
				t_final += dt;
			}
        }
		particles[nfields*tid] = position;
		particles[nfields*tid+1] = beta;
		particles[nfields*tid+2] = gamma;
		particles[nfields*tid+3] = t_final;
}

