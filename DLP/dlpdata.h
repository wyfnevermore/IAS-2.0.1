#ifndef _dlp_data
#define _dlp_data  
#include "dlpspec_scan.h" 
#include "useCSI.h"

	int Add(int a,int b);

	bool getDLPData(char *pData,double *wavelength,double *intensity, int if_x_shift);

	bool getScanCofig(char *buf,uScanConfig *pCfg);

	void getWanted();

bool getScanConfigBuf(uScanConfig  scanList,WorkFlowExt work_flow_list,char *pBuffer,char *Ext_pBuffer);

#endif
