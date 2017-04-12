#ifndef useCSI_H
#define useCSI_H
 
#include "string.h"
#include "stdio.h"
#include "stdlib.h"


#define NUM_DATA 801


 bool cubicSplineInterpolation(double *wlength,double *intens, double* m, int count);
 bool tridiagonalMatrices(double *wlength, double *intens, int count);
 bool DataProcess(double *wlength, double *abs_std,int Len);


#endif
