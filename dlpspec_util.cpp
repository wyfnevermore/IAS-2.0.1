/*****************************************************************************
**
**  Copyright (c) 2015 Texas Instruments Incorporated.
**
******************************************************************************
**
**  DLP Spectrum Library
**
*****************************************************************************/

#include "stdafx.h"
#include "stdlib.h"
#include "math.h"
#include "dlpspec_util.h"
#include "dlpspec_types.h"

/**
 * @addtogroup group_util
 *
 * @{
 */

//DLPSPEC_ERR_CODE dlpspec_util_nmToColumn(const double nm, const double *coeffs, double *column)
///**
// * Function to output compute corresponding DMD column number given a wavelength
// *
// * @param[in]   nm      wavelenght in nm
// * @param[in]   coeffs  Coefficient from wavelenght calibration
// * @param[out]  column  DMD column for which wavelength is desired
// *
// * @return      Error code
// *
// */
//{
//	//double factor;
//	DLPSPEC_ERR_CODE ret_val = (DLPSPEC_PASS);
//
//	if ((coeffs == NULL) || (column == NULL))
//		return ERR_DLPSPEC_NULL_POINTER;
//    
//    //First check to see if coeffs are linear (1st order). If so, return linear fit. This guards against divide by zero.
//    ////ssss
//	//if (0 == coeffs[2])
//    //{
//    //    if (0 != coeffs[1])
//    //    {
//    //        *(column) = (nm - coeffs[0]) / coeffs[1];
//    //    }
//    //    else
//    //    {
//    //        ret_val = ERR_DLPSPEC_INVALID_INPUT;
//    //    }
//    //}
//    //else
//    //{
//    //	//Compute first factor and check if the DMD column is within acceptable range, if not compute the next one
//    //	factor = ((-1.0 * coeffs[1]) + sqrt(coeffs[1]*coeffs[1] - 4.0 *coeffs[2]*(coeffs[0]-nm))) / (2.0*coeffs[2]);
//    //	if ((factor >= MIN_DMD_COLUMN) && (factor <= MAX_DMD_COLUMN))
//    //		*(column) = factor;
//    //	else
//    //	{
//    //		factor = ((-1.0 * coeffs[1]) - sqrt(coeffs[1]*coeffs[1] - 4.0 *coeffs[2]*(coeffs[0]-nm))) / (2.0*coeffs[2]);
//    //		if ((factor >= MIN_DMD_COLUMN) && (factor <= MAX_DMD_COLUMN))
//    //			*(column) = factor;
//    //		else
//    //			ret_val = ERR_DLPSPEC_FAIL;
//    //	}
//    //}
//
//	*(column) = get_value(nm, coeffs, 5);
//
//	return ret_val;
//}

 
//	double get_value(double mx, const double *coffs, int coffs_size)
//{ 
//	double min = 0.0;
//	double max = 850.0;
//
//	double f0 = 0.0;
//	double f1 = 0.0;
//	//double f2 = 0;
//	double x0 = 0.0;
//	double x1 = 0.0;
//	double x2 = 0.0;
//
//	x1 = min;
//	x2 = max;
//
//	// solve(double *coffs, double column, int coffs_size);
//	/*f1 = coffs[0]*pow(0.0,4) + coffs[1]*pow(0.0,3)
//           + coffs[2]*pow(0.0,2) + coffs[3]*0.0
//           + coffs[4] - mx;*/
//	f1 = solve(coffs, x0, coffs_size) - mx; 
//	//f2 = max - mx;
//	/*double f2 = coffs[4]*pow(797.6,4) + coffs[3]*pow(797.6,3)
//           + coffs[2]*pow(797.6,2) + coffs[1]*797.6
//           + coffs[0];*/
//	do {
//		x0 = (x1 + x2) / 2.0;
//		/*f0 = coffs[0]*pow(x0,4) + coffs[1]*pow(x0,3)
//           + coffs[2]*pow(x0,2) + coffs[3]*x0
//           + coffs[4] - mx;*/
//		f0 = solve(coffs, x0, coffs_size) - mx;
//		if(fabs(f0) <= 1e-6) {
//			break;
//		}
//
//		if(f0 * f1 < 0) {
//			x2 = x0;
//            //f2 = f0;
//		} else {
//			x1 = x0;
//            f1 = f0;
//		}
//	}while(fabs(f0) >= 1e-6);
//	return x0;
//
//}

double solve(const double *coffs, double column, int coffs_size)
{
	double tmp = 0.0;
	double equa = 0.0;
	for (int i = 0; i < coffs_size; i++)
	{
		tmp = tmp + coffs[i] * pow(column, coffs_size - 1 - i);
	}
	equa = tmp;

	return equa;
}

DLPSPEC_ERR_CODE dlpspec_util_columnToNm(const double column,  const double *coeffs, double *nm)
/**
 * Function to output compute corresponding wavelength given a DMD column number
 *
 * @param[in]   column  DMD column for which wavelength is desired
 * @param[in]   coeffs  Coefficient from wavelength calibration
 * @param[out]  nm      wavelength in nm
 *
 * @return  Error code
 */
{
	if ((coeffs == NULL) || (nm == NULL))
		return ERR_DLPSPEC_NULL_POINTER;

	////*(nm) = coeffs[2] * column * column + coeffs[1] * column + coeffs[0];

	*(nm) = 0.0; 
/*	for (int i = 0; i < sizeof(coeffs); i++)
	{
		*(nm) = *(nm) + coeffs[i] * pow(column, (int)(sizeof(coeffs) - 1 - i));
	}*/

	for (int i = 0; i < 5; i++)
	{
		*(nm) = *(nm) + coeffs[i] * pow(column, (int)(5 - 1 - i));
	}


	return (DLPSPEC_PASS);
}

DLPSPEC_ERR_CODE dlpspec_util_columnToNmDistance(const double column_distance,  const double *coeffs, double *nm)
/**
 * Function to output wavelength distance in nm at the center of the DMD given a DMD 
 * distance in columns
 *
 * @param[in]    column_distance DMD column distance which distance in nm is desired
 * @param[in]    coeffs          Coefficient from wavelength calibration
 * @param[out]   nm              wavelength distance in nm
 *
 * @return   Error code
 *
 */
{
	double start_nm;
	double end_nm;
	double start_px = MAX_DMD_COLUMN / 2;
	double end_px = start_px + column_distance;
    
    DLPSPEC_ERR_CODE ret_val = (DLPSPEC_PASS);

    if ((coeffs == NULL) || (nm == NULL))
		return ERR_DLPSPEC_NULL_POINTER;
    
	ret_val = dlpspec_util_columnToNm(start_px, coeffs, &start_nm);
    if (ret_val < 0)
    {
        return ret_val;
    }
	
	ret_val = dlpspec_util_columnToNm(end_px, coeffs, &end_nm);
    if (ret_val < 0)
    {
        return ret_val;
    }
    
	*nm = (int)fabs(end_nm - start_nm);
	
	return ret_val;
}

/** @} // group group_util
 *
 */
