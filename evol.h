#ifndef EVOL_H
#define EVOL_H

__device__ real calc_vel(real, real);
__global__ void move_particles(real *, float *,real *, real *, int *);

#endif
