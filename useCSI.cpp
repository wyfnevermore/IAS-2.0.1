#include "stdafx.h"
//#endif
#include "useCSI.h"
#include "string.h"

bool tridiagonalMatrices(double *wlength, double *abs_std, int count)
{
	// COL_DATA_LEN = 624
	double ci[NUM_DATA];
	double di[NUM_DATA];
	double mi[NUM_DATA];
	double mn[NUM_DATA];
	double cn[NUM_DATA];
	double dn[NUM_DATA];
	double tmp1 = 0.0, tmp2 = 0.0;
	for(int i = 0; i < count-1; i++)
	{
		if(i == 0)
		{
			ci[i] = 0;
			di[i] = 0;
		}else
		{
			tmp1 = 6 * ((abs_std[i+1]-abs_std[i])/(wlength[i+1]-wlength[i]) - (abs_std[i]-abs_std[i-1])/(wlength[i]-wlength[i-1])) - di[i-1]*((wlength[i]-wlength[i-1]));
			tmp2 = 2 * (wlength[i]-wlength[i-1] + wlength[i+1]-wlength[i]) - ci[i-1]*(wlength[i]-wlength[i-1]);
			if(tmp2 != 0)
			{
				ci[i] = (wlength[i+1]-wlength[i])/tmp2;
				di[i] = tmp1/tmp2;
			}else
			{
				ci[i] = 0;
				di[i] = 0;
			}
		}
	}

	/*for(int i = 0; i < count-1; i++)
	{
		cn[i] = ci[count-1-i-1];
		dn[i] = di[count-1-i-1];
	}

	for(int i = 0; i < count-1; i++)
	{
		if(i == count-2 || i == 0)
		{
			mn[i] = 0;
		}else
		{
			mn[i] = di[i] - ci[i]*mn[i-1];
		}
	}

	for(int i = 0; i < count-1; i++)
	{
		mi[i] = mn[count-1-i-1];
	}*/

	for(int i = count-1; i >= 0; i--)
	{
		if(i == count-1 || i == 0)
		{
			mi[i] = 0;
		}else
		{
			mi[i] = di[i] - ci[i]*mi[i+1];
		}
	}

	bool pass = false;
	pass = cubicSplineInterpolation(wlength, abs_std, mi, count);

	return pass;
}

bool DataProcess(double *wlength, double *abs_std, int len)
{
	double startP = wlength[0];
	int s = 0;
	int e = 0;
	double endP = wlength[len-1];
	int cnt = 0;
	double wlss[NUM_DATA];
	double abss[NUM_DATA];

	for(int i = 0; i < len; i++)
	{
		if(wlength[i] >= startP)
		{
			s = i;
			break;
		}
	}
	for(int j = 0; j < len; j++)
	{
		if(wlength[j] >= endP)
		{
			e = j;
			break;
		}
	}
	for(int j = 0; j < len; j++)
	{
		if(s <= j && j <= e)
		{
			wlss[cnt] = wlength[j];
			abss[cnt] = abs_std[j];
			cnt++;
		}
	}

	tridiagonalMatrices(wlss, abss, cnt);

	//wlength = wlss;
	//abs_std = abss;

	for(int i = 0; i < NUM_DATA; i++)
	{
		wlength[i] = wlss[i];
		abs_std[i] = abss[i];
	}

	return true;
}

bool cubicSplineInterpolation(double *wlength, double *abs_std, double* m, int count)
{
	double wavels[NUM_DATA];
	double ai[NUM_DATA];
	double bi[NUM_DATA];
	double ci[NUM_DATA];
	double di[NUM_DATA];
	double abs_S[NUM_DATA] = {0.0};

	for(int i = 0; i < NUM_DATA; i++)
	{
		wavels[i] = 900 + i*1;
	}

	for(int i = 0; i < count-1; i++)
	{
		ai[i] = abs_std[i];
		bi[i] = (abs_std[i+1]-abs_std[i])/(wlength[i+1]-wlength[i]) - (wlength[i+1]-wlength[i])*m[i]/2 - (wlength[i+1]-wlength[i])*(m[i+1]-m[i])/6;
		ci[i] = m[i]/2;
		di[i] = (m[i+1]-m[i])/(6*((wlength[i+1]-wlength[i])));
	}

	for(int i = 0; i < NUM_DATA; i++)
	{
		for(int j = 0; j < count-1; j++)
		{
			if(wavels[i] >= wlength[j] && wavels[i] <= wlength[j+1])
			{
				abs_S[i] = ai[j] + bi[j]*(wavels[i]-wlength[j]) + ci[j]*(wavels[i]-wlength[j])*(wavels[i]-wlength[j]) + di[j]*(wavels[i]-wlength[j])*(wavels[i]-wlength[j])*(wavels[i]-wlength[j]);
				break;
			}else
			{
				abs_S[i] = 0.0;
			}
		}
	}

	for(int i = 0; i < NUM_DATA; i++)
	{
		wlength[i] = wavels[i];
		abs_std[i] = abs_S[i];
	}

	return true;
}
