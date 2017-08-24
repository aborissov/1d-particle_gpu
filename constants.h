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
const real m_keV = 510.9989461;
const real Temp = 1.0e7;

const real Bscl = 0.01;
const real Lscl = 1.0e6;
const real Tscl = 1.0e-6;
const real Vscl = Lscl/Tscl;
const real Escl = Vscl*Bscl;
const real etascl = Vscl*Lscl*mu0_si;

const real Tfinal = 3.0/Tscl;
const real dt = 1.0e-8/Tscl;
const real dt_ne = 1.0e-6/Tscl;
const int timeblocks = 1500;
const int nt = Tfinal/(dt*timeblocks);
const int nfields = 4;
const int nparticles = 5024;
const int nwrite = 500;
const int nwrite_particles = 2;
const int output_fields = nfields;

const bool random_energy = 1;
const bool random_beta = 1;

EXTERN real *d_energy_kev, *d_potential, *d_energy_kev_0;

#endif
