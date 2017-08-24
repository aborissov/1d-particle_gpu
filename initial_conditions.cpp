#include <iostream>
#include <random>
#include <chrono>
#include "constants.h"

using namespace std;

void initialise(real *particles, real *initial_energy_kev){
		real eV_temp = 20.0, gamma_0;
        //gamma_0 = 1.11741707190969; 		// 60keV electron
        //gamma_0 = 1.07827804793979398; 				// 40keV electron
        //gamma_0 = 1.03913902396989; 			// 20keV electron
        //gamma_0 = 1.0001678676; 			// 86eV electron
        //gamma_0 = 1.5; 

		real beta_0 = 0.1;

		unsigned seed = std::chrono::system_clock::now().time_since_epoch().count();
		default_random_engine generator(seed);
		default_random_engine generator2(2*seed);
		gamma_distribution<real> distribution(1.5,eV_temp);
		uniform_real_distribution<real> distribution2(-1.0,1.0);

        for(int j = 0; j < nparticles*nfields; j++){
				if (random_energy) gamma_0 = distribution(generator)/m_keV + 1.0;
				if (random_beta) beta_0 = distribution2(generator2);
				if (beta_0 == 0.0) beta_0 = -1.0+(j%2)*2.0;
                if (j%nfields == 0) particles[j] = 0;
                else if (j%nfields == 1) particles[j] = beta_0;
                else if (j%nfields == 2) {
					particles[j] = gamma_0;
					initial_energy_kev[(j-2)/nfields] = (gamma_0 - 1.0)*m_keV;
				}
                else if (j%nfields == 3) particles[j] = 0.0;
		else particles[j] = 0;
        }
}
