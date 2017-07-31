#ifndef CONSTANTS_H
#define CONSTANTS_H

#ifdef MAINFILE
	#define EXTERN
#else
	#define EXTERN extern
#endif

typedef double real;

const real c = 3.0e8;
const real mu0_si = 8.85e-12;
const real q = -1.6e-19;
const real m = 9.11e-31;
const real Temp = 1.0e7;


const real Bscl = 0.01;
const real Lscl = 1.0e6;
const real Tscl = 1.0e-6;
const real Vscl = Lscl/Tscl;
const real Escl = Vscl*Bscl;
const real etascl = Vscl*Lscl*mu0_si;

const real Tfinal = 0.01/Tscl;
const real dt = 1.0e-8/Tscl;
const int nt = Tfinal/dt;
const int nfields = 4;
const int nparticles = 1000;
const int nwrite = 500;
const int nwrite_particles = 2;
const int output_fields = nfields;

EXTERN real *energy_kev, *potential;
const real energy_kev_0 = 0.5*511.0;

#endif
