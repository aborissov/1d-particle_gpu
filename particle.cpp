#include <iostream>
#include <fstream>
#include <math.h>
#include <random>
#include <chrono>


using namespace std;


float calc_vel(float gamma, float beta){
	const float c = 3.0e1;
	const float dt = 1.0e-3;
	float v = sqrt(c*c - c*c/(gamma*gamma));
	//cout << "gamma = " << gamma << endl;
	//cout << "beta = " << beta << endl;
	//cout << "v = " << v << endl;
	return v;
}

void move_particles(float *particles, int nparticles){
	const float c = 3.0e1;
	const float dt = 1.0e-5;
	float q,E,m;
	q = -1.0;
	E = 1.0e0;
	m = 1.0;
	float nu = 1.0e9;

	for(int j = 0; j < nparticles; j++){
		unsigned seed = chrono::system_clock::now().time_since_epoch().count();
		default_random_engine generator (seed);
		normal_distribution<float> distribution(0.0,1.0);
		float dw = distribution(generator)*sqrt(dt);

		float z = particles[3*j];
		float beta = particles[3*j+1];
		float v = calc_vel(particles[3*j + 2], particles[3*j + 1]);
		float u = v*particles[3*j+2]*beta;
		float uperp = v*particles[3*j+2]*sqrt(1-beta*beta);
		float dudt = q*E/m;
		float gammadot = u/(c*c)*dudt/(sqrt(1 + u*u/(c*c) + uperp*uperp));	// work in progress!!!
		float betadot;
		if (u == 0) betadot = 0;
		else betadot = dudt/u*beta*(1.0-beta*beta);

		float dgamma = gammadot*dt;
		float dbeta = (betadot*dt + beta*nu)*dt + sqrt((1.0 - beta*beta)*nu)*dw;

		particles[3*j+1] += dbeta;
		beta = particles[3*j+1];
        	if (beta > 1.0) particles[3*j+1] = -beta + floor(beta) + 1.0;
        	else if (beta < -1.0) particles[3*j+1] = -beta + ceil(beta) - 1.0;
		particles[3*j+2] += dgamma;
		if (particles[3*j+2] < 1) particles[3*j+2] -=2.0*dgamma;

		v = calc_vel(particles[3*j + 2], particles[3*j + 1]);
		particles[3*j] += particles[3*j+1]*v*dt;
		//particles[3*j+2] = sqrt(1.0 + u*u/(c*c) + 2.0*mu*B/(m*c*c));

		//cout << "z = " << z << endl;
		//cout << "beta = " << beta << endl;
		//cout << "v = " << v << endl;
		//cout << "u = " << u << endl;
		//cout << "uperp = " << uperp << endl;
		//cout << "dudt = " << dudt << endl;
		//cout << "gammadot = " << gammadot << endl;
		//cout << "betadot = " << betadot << endl;
	}
}

void initialise(float *particles,int nparticles){
	const float c = 3.0e1;
	const float dt = 1.0e-3;
	for(int j = 0; j < nparticles*3; j++){
		if (j%3 == 0) particles[j] = 0;
		else if (j%3 == 1) particles[j] = 0.1;
		else particles[j] = 1.01;
	}
}

void write_particles(float *particles,int nparticles,bool newflag){
  	ofstream outFile;
	float v;
	v = calc_vel(particles[2], particles[1]);

  	if (newflag) outFile.open("data.dat", ofstream::binary);
	else outFile.open("data.dat", ofstream::binary | ofstream::app);
  	outFile.write((char*) &(particles[0]), sizeof(float));
  	//outFile.write((char*) &v, sizeof(float));
  	outFile.close();
	//cout << particles[0] << endl;
}

int main(){
	const float c = 3.0e1;
	const float dt = 1.0e-3;
	int nparticles = 1;
	float particles[nparticles*3]; // array of particles: 1d position, cosine of pitch angle, lorentz factor
	int nt = 0.1/dt;
	bool newflag = 1;

	initialise(particles,nparticles);
	for (int j = 0; j < nt; j++){
		write_particles(particles,nparticles,newflag);
		newflag = 0;
		move_particles(particles,nparticles);
		//cout << particles[0] << endl;
		if (isnan(particles[0])){
			cout << "position is nan. stopping" << endl;
			return 0;
		}
	}
	return 0;
}
