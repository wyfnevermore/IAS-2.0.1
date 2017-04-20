#include "dlpdata.h"//;
#include <iomanip>
#include <fstream>
using namespace std;

int Add(int a,int b)
{
	int c=a+b;
	return c;
	//HINSTANCE hDllInst = LoadLibrary(_T("dlp_nir_driver.dll"));  
	//typedef int (*DLLAdd)(int x1,int x2);

	//DLLAdd fn_Add;

	//fn_Add=(DLLAdd)GetProcAddress(hDllInst,"Add");
	//int aa= fn_Add(a,b);  
	//return 4;
}

bool getScanCofig(char *buf,uScanConfig *pCfg){
	if(dlpspec_scan_read_configuration(buf, 155) != DLPSPEC_PASS)
	{
		return false;
	}
	int scSize = sizeof(uScanConfig);
	memcpy(pCfg , buf , scSize);
	return true;
}


bool getScanConfigBuf(uScanConfig  scanList,WorkFlowExt work_flow_list,char *pBuffer,char *Ext_pBuffer)
{
    int bufferSize = sizeof(uScanConfig)*2;
    int Ext_bufferSize = sizeof(WorkFlowExt);
    if(pBuffer == NULL)
    {
        return false;
    }
    if(dlpspec_scan_write_configuration(&scanList,pBuffer,bufferSize) != DLPSPEC_PASS)
    {
        return false;
    }
    memcpy(Ext_pBuffer,(char*)(&work_flow_list),Ext_bufferSize);
    return true;
}

bool getDLPData(char *pData,double *wavelength,double *intensity, int if_x_shift)
{  
	 scanResults Results;
	if(dlpspec_scan_interpret(pData,SCAN_DATA_BLOB_SIZE,&Results, if_x_shift) != DLPSPEC_PASS)
	{
		return false;
	}
	
	int gain = Results.pga;
		if(if_x_shift == 1)
	{ 
		for(int i = 0; i < NUM_DATA; i++)
		{
			wavelength[i] = Results.wavelength[Results.length-i-1];
			intensity[i] = Results.intensity[Results.length-i-1]/(double)gain;
		} 

		return true;
	}else if(if_x_shift == 2)
	{
		for(int i = 0; i < NUM_DATA; i++)
		{
			wavelength[i] = Results.wavelength[Results.length-i-1];
			intensity[i] = Results.intensity[Results.length-i-1]/(double)gain;
		}

		DataProcess(wavelength, intensity,Results.length);  
	}else
	{
		for(int i = 0; i < ADC_DATA_LEN; i++)
		{
			wavelength[i] = Results.wavelength[i];
			intensity[i] = Results.intensity[i]/(double)gain;
	
		}
	}
	return true;
}
