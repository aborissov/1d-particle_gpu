#include <iostream>
#include "constants.h"

using namespace std;

void initialise(real *particles){
        for(int j = 0; j < nparticles*nfields; j++){
                if (j%nfields == 0) particles[j] = 0;
                else if (j%nfields == 1) particles[j] = 0.1;
                else if (j%nfields == 2) particles[j] = 1.5;
		else particles[j] = 0;
        }
}
