/* Include files */

#include "CoupledTanks_WCPS_v2_DoubleSD_sfun.h"
#include "CoupledTanks_WCPS_v2_DoubleSD_sfun_debug_macros.h"
#include "c1_CoupledTanks_WCPS_v2_DoubleSD.h"
#include "c2_CoupledTanks_WCPS_v2_DoubleSD.h"
#include "c4_CoupledTanks_WCPS_v2_DoubleSD.h"
#include "c5_CoupledTanks_WCPS_v2_DoubleSD.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */
uint32_T _CoupledTanks_WCPS_v2_DoubleSDMachineNumber_;
real_T _sfTime_;

/* Function Declarations */

/* Function Definitions */
void CoupledTanks_WCPS_v2_DoubleSD_initializer(void)
{
}

void CoupledTanks_WCPS_v2_DoubleSD_terminator(void)
{
}

/* SFunction Glue Code */
unsigned int sf_CoupledTanks_WCPS_v2_DoubleSD_method_dispatcher(SimStruct
  *simstructPtr, unsigned int chartFileNumber, const char* specsCksum, int_T
  method, void *data)
{
  if (chartFileNumber==1) {
    c1_CoupledTanks_WCPS_v2_DoubleSD_method_dispatcher(simstructPtr, method,
      data);
    return 1;
  }

  if (chartFileNumber==2) {
    c2_CoupledTanks_WCPS_v2_DoubleSD_method_dispatcher(simstructPtr, method,
      data);
    return 1;
  }

  if (chartFileNumber==4) {
    c4_CoupledTanks_WCPS_v2_DoubleSD_method_dispatcher(simstructPtr, method,
      data);
    return 1;
  }

  if (chartFileNumber==5) {
    c5_CoupledTanks_WCPS_v2_DoubleSD_method_dispatcher(simstructPtr, method,
      data);
    return 1;
  }

  return 0;
}

unsigned int sf_CoupledTanks_WCPS_v2_DoubleSD_process_check_sum_call( int nlhs,
  mxArray * plhs[], int nrhs, const mxArray * prhs[] )
{

#ifdef MATLAB_MEX_FILE

  char commandName[20];
  if (nrhs<1 || !mxIsChar(prhs[0]) )
    return 0;

  /* Possible call to get the checksum */
  mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));
  commandName[(sizeof(commandName)/sizeof(char)-1)] = '\0';
  if (strcmp(commandName,"sf_get_check_sum"))
    return 0;
  plhs[0] = mxCreateDoubleMatrix( 1,4,mxREAL);
  if (nrhs>1 && mxIsChar(prhs[1])) {
    mxGetString(prhs[1], commandName,sizeof(commandName)/sizeof(char));
    commandName[(sizeof(commandName)/sizeof(char)-1)] = '\0';
    if (!strcmp(commandName,"machine")) {
      ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(1086918880U);
      ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(2709242341U);
      ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(1750628013U);
      ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(2559822966U);
    } else if (!strcmp(commandName,"exportedFcn")) {
      ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(0U);
      ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(0U);
      ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(0U);
      ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(0U);
    } else if (!strcmp(commandName,"makefile")) {
      ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(3790832020U);
      ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(2860773776U);
      ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(3211282937U);
      ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(2377869578U);
    } else if (nrhs==3 && !strcmp(commandName,"chart")) {
      unsigned int chartFileNumber;
      chartFileNumber = (unsigned int)mxGetScalar(prhs[2]);
      switch (chartFileNumber) {
       case 1:
        {
          extern void sf_c1_CoupledTanks_WCPS_v2_DoubleSD_get_check_sum(mxArray *
            plhs[]);
          sf_c1_CoupledTanks_WCPS_v2_DoubleSD_get_check_sum(plhs);
          break;
        }

       case 2:
        {
          extern void sf_c2_CoupledTanks_WCPS_v2_DoubleSD_get_check_sum(mxArray *
            plhs[]);
          sf_c2_CoupledTanks_WCPS_v2_DoubleSD_get_check_sum(plhs);
          break;
        }

       case 4:
        {
          extern void sf_c4_CoupledTanks_WCPS_v2_DoubleSD_get_check_sum(mxArray *
            plhs[]);
          sf_c4_CoupledTanks_WCPS_v2_DoubleSD_get_check_sum(plhs);
          break;
        }

       case 5:
        {
          extern void sf_c5_CoupledTanks_WCPS_v2_DoubleSD_get_check_sum(mxArray *
            plhs[]);
          sf_c5_CoupledTanks_WCPS_v2_DoubleSD_get_check_sum(plhs);
          break;
        }

       default:
        ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(0.0);
        ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(0.0);
        ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(0.0);
        ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(0.0);
      }
    } else if (!strcmp(commandName,"target")) {
      ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(1764838350U);
      ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(3410240878U);
      ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(118138738U);
      ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(243351119U);
    } else {
      return 0;
    }
  } else {
    ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(2186883022U);
    ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(3928932449U);
    ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(2650015987U);
    ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(3852052714U);
  }

  return 1;

#else

  return 0;

#endif

}

unsigned int sf_CoupledTanks_WCPS_v2_DoubleSD_autoinheritance_info( int nlhs,
  mxArray * plhs[], int nrhs, const mxArray * prhs[] )
{

#ifdef MATLAB_MEX_FILE

  char commandName[32];
  char aiChksum[64];
  if (nrhs<3 || !mxIsChar(prhs[0]) )
    return 0;

  /* Possible call to get the autoinheritance_info */
  mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));
  commandName[(sizeof(commandName)/sizeof(char)-1)] = '\0';
  if (strcmp(commandName,"get_autoinheritance_info"))
    return 0;
  mxGetString(prhs[2], aiChksum,sizeof(aiChksum)/sizeof(char));
  aiChksum[(sizeof(aiChksum)/sizeof(char)-1)] = '\0';

  {
    unsigned int chartFileNumber;
    chartFileNumber = (unsigned int)mxGetScalar(prhs[1]);
    switch (chartFileNumber) {
     case 1:
      {
        if (strcmp(aiChksum, "f7DXcvNVPjuEWcS74tpwcG") == 0) {
          extern mxArray
            *sf_c1_CoupledTanks_WCPS_v2_DoubleSD_get_autoinheritance_info(void);
          plhs[0] = sf_c1_CoupledTanks_WCPS_v2_DoubleSD_get_autoinheritance_info
            ();
          break;
        }

        plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);
        break;
      }

     case 2:
      {
        if (strcmp(aiChksum, "eD9np7FsqSjytUKHDaowM") == 0) {
          extern mxArray
            *sf_c2_CoupledTanks_WCPS_v2_DoubleSD_get_autoinheritance_info(void);
          plhs[0] = sf_c2_CoupledTanks_WCPS_v2_DoubleSD_get_autoinheritance_info
            ();
          break;
        }

        plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);
        break;
      }

     case 4:
      {
        if (strcmp(aiChksum, "dy38S1lc8OySY6YrfvF2oE") == 0) {
          extern mxArray
            *sf_c4_CoupledTanks_WCPS_v2_DoubleSD_get_autoinheritance_info(void);
          plhs[0] = sf_c4_CoupledTanks_WCPS_v2_DoubleSD_get_autoinheritance_info
            ();
          break;
        }

        plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);
        break;
      }

     case 5:
      {
        if (strcmp(aiChksum, "jmsXEwoEjRN1aZB84lRU4B") == 0) {
          extern mxArray
            *sf_c5_CoupledTanks_WCPS_v2_DoubleSD_get_autoinheritance_info(void);
          plhs[0] = sf_c5_CoupledTanks_WCPS_v2_DoubleSD_get_autoinheritance_info
            ();
          break;
        }

        plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);
        break;
      }

     default:
      plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);
    }
  }

  return 1;

#else

  return 0;

#endif

}

unsigned int sf_CoupledTanks_WCPS_v2_DoubleSD_get_eml_resolved_functions_info
  ( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] )
{

#ifdef MATLAB_MEX_FILE

  char commandName[64];
  if (nrhs<2 || !mxIsChar(prhs[0]))
    return 0;

  /* Possible call to get the get_eml_resolved_functions_info */
  mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));
  commandName[(sizeof(commandName)/sizeof(char)-1)] = '\0';
  if (strcmp(commandName,"get_eml_resolved_functions_info"))
    return 0;

  {
    unsigned int chartFileNumber;
    chartFileNumber = (unsigned int)mxGetScalar(prhs[1]);
    switch (chartFileNumber) {
     case 1:
      {
        extern const mxArray
          *sf_c1_CoupledTanks_WCPS_v2_DoubleSD_get_eml_resolved_functions_info
          (void);
        mxArray *persistentMxArray = (mxArray *)
          sf_c1_CoupledTanks_WCPS_v2_DoubleSD_get_eml_resolved_functions_info();
        plhs[0] = mxDuplicateArray(persistentMxArray);
        mxDestroyArray(persistentMxArray);
        break;
      }

     case 2:
      {
        extern const mxArray
          *sf_c2_CoupledTanks_WCPS_v2_DoubleSD_get_eml_resolved_functions_info
          (void);
        mxArray *persistentMxArray = (mxArray *)
          sf_c2_CoupledTanks_WCPS_v2_DoubleSD_get_eml_resolved_functions_info();
        plhs[0] = mxDuplicateArray(persistentMxArray);
        mxDestroyArray(persistentMxArray);
        break;
      }

     case 4:
      {
        extern const mxArray
          *sf_c4_CoupledTanks_WCPS_v2_DoubleSD_get_eml_resolved_functions_info
          (void);
        mxArray *persistentMxArray = (mxArray *)
          sf_c4_CoupledTanks_WCPS_v2_DoubleSD_get_eml_resolved_functions_info();
        plhs[0] = mxDuplicateArray(persistentMxArray);
        mxDestroyArray(persistentMxArray);
        break;
      }

     case 5:
      {
        extern const mxArray
          *sf_c5_CoupledTanks_WCPS_v2_DoubleSD_get_eml_resolved_functions_info
          (void);
        mxArray *persistentMxArray = (mxArray *)
          sf_c5_CoupledTanks_WCPS_v2_DoubleSD_get_eml_resolved_functions_info();
        plhs[0] = mxDuplicateArray(persistentMxArray);
        mxDestroyArray(persistentMxArray);
        break;
      }

     default:
      plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);
    }
  }

  return 1;

#else

  return 0;

#endif

}

unsigned int sf_CoupledTanks_WCPS_v2_DoubleSD_third_party_uses_info( int nlhs,
  mxArray * plhs[], int nrhs, const mxArray * prhs[] )
{
  char commandName[64];
  char tpChksum[64];
  if (nrhs<3 || !mxIsChar(prhs[0]))
    return 0;

  /* Possible call to get the third_party_uses_info */
  mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));
  commandName[(sizeof(commandName)/sizeof(char)-1)] = '\0';
  mxGetString(prhs[2], tpChksum,sizeof(tpChksum)/sizeof(char));
  tpChksum[(sizeof(tpChksum)/sizeof(char)-1)] = '\0';
  if (strcmp(commandName,"get_third_party_uses_info"))
    return 0;

  {
    unsigned int chartFileNumber;
    chartFileNumber = (unsigned int)mxGetScalar(prhs[1]);
    switch (chartFileNumber) {
     case 1:
      {
        if (strcmp(tpChksum, "vL869rC737XPkuQY5au6P") == 0) {
          extern mxArray
            *sf_c1_CoupledTanks_WCPS_v2_DoubleSD_third_party_uses_info(void);
          plhs[0] = sf_c1_CoupledTanks_WCPS_v2_DoubleSD_third_party_uses_info();
          break;
        }
      }

     case 2:
      {
        if (strcmp(tpChksum, "uWU9m5H6bxtCsuRR5ud96C") == 0) {
          extern mxArray
            *sf_c2_CoupledTanks_WCPS_v2_DoubleSD_third_party_uses_info(void);
          plhs[0] = sf_c2_CoupledTanks_WCPS_v2_DoubleSD_third_party_uses_info();
          break;
        }
      }

     case 4:
      {
        if (strcmp(tpChksum, "VjtQEgfXJQvq8eJal2F8p") == 0) {
          extern mxArray
            *sf_c4_CoupledTanks_WCPS_v2_DoubleSD_third_party_uses_info(void);
          plhs[0] = sf_c4_CoupledTanks_WCPS_v2_DoubleSD_third_party_uses_info();
          break;
        }
      }

     case 5:
      {
        if (strcmp(tpChksum, "KyMeNexqYYWCCGzxSvMBBF") == 0) {
          extern mxArray
            *sf_c5_CoupledTanks_WCPS_v2_DoubleSD_third_party_uses_info(void);
          plhs[0] = sf_c5_CoupledTanks_WCPS_v2_DoubleSD_third_party_uses_info();
          break;
        }
      }

     default:
      plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);
    }
  }

  return 1;
}

void CoupledTanks_WCPS_v2_DoubleSD_debug_initialize(struct SfDebugInstanceStruct*
  debugInstance)
{
  _CoupledTanks_WCPS_v2_DoubleSDMachineNumber_ = sf_debug_initialize_machine
    (debugInstance,"CoupledTanks_WCPS_v2_DoubleSD","sfun",0,4,0,0,0);
  sf_debug_set_machine_event_thresholds(debugInstance,
    _CoupledTanks_WCPS_v2_DoubleSDMachineNumber_,0,0);
  sf_debug_set_machine_data_thresholds(debugInstance,
    _CoupledTanks_WCPS_v2_DoubleSDMachineNumber_,0);
}

void CoupledTanks_WCPS_v2_DoubleSD_register_exported_symbols(SimStruct* S)
{
}

static mxArray* sRtwOptimizationInfoStruct= NULL;
mxArray* load_CoupledTanks_WCPS_v2_DoubleSD_optimization_info(void)
{
  if (sRtwOptimizationInfoStruct==NULL) {
    sRtwOptimizationInfoStruct = sf_load_rtw_optimization_info(
      "CoupledTanks_WCPS_v2_DoubleSD", "CoupledTanks_WCPS_v2_DoubleSD");
    mexMakeArrayPersistent(sRtwOptimizationInfoStruct);
  }

  return(sRtwOptimizationInfoStruct);
}

void unload_CoupledTanks_WCPS_v2_DoubleSD_optimization_info(void)
{
  if (sRtwOptimizationInfoStruct!=NULL) {
    mxDestroyArray(sRtwOptimizationInfoStruct);
    sRtwOptimizationInfoStruct = NULL;
  }
}
