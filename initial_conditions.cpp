#include <iostream>
#include "constants.h"

using namespace std;

void initialise(real *particles){
        for(int j = 0; j < nparticles*nfields; j++){
                if (j%nfields == 0) particles[j] = 0;
                else if (j%nfields == 1) particles[j] = 0.1;
                else if (j%nfields == 2) particles[j] = 1.0001678676; // corresponds to 86eV electron
                //else if (j%nfields == 2) particles[j] = 1.5; // corresponds to 86eV electron
                else if (j%nfields == 3) particles[j] = 0.0;
		else particles[j] = 0;
        }
}
