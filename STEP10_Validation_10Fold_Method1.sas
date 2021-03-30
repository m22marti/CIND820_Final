
/**********************************************************************************************************************
/* NAME:		STEP10_Model_Validation
/* DESCRIPTION:	
/* DATE:		Feb 7, 2021
/* AUTHOR:		Marlene Martins
/* NOTES:		
/* 				
/* INPUT:		COVID.COVID_NBH_Summary 
/*				
/*  
/**********************************************************************************************************************
/* Modifications
/*
/*
/*
/**********************************************************************************************************************/
/*---------------------------------------------------------------------------------------------------------------------
/* NOTES:
/* 
/*
*/


ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\STEP10_10fold_cval.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "STEPWISE"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE PLOT");
ods graphics on;

TITLE  '10 fold Cross validation ';

%let K=10;
  %let rate=%sysevalf((&K-1)/&K);

 %PUT &k;
 %PUT &rate;
  
  *Build model with all data;
  
  proc reg data=COVID.COVID_NBH_Summaryo;
  	MODEL INFECTION_RATE = 
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
			P_OCC_Ess_Yes
			P_VM_Yes ;
  run;

  *Generate the cross validation sample;
  proc surveyselect data=COVID.COVID_NBH_Summaryo out=cv seed=231258
  samprate=&rate outall reps=10;
  run;

  /* the variable selected is an automatic variable generatic by surveyselect.If selected is true then then new_y will get the value of y otherwise is missing */
   
   data cv;
 set cv;
   if selected then new_INFECTION_RATE=INFECTION_RATE;
 run;

/* get predicted values for the missing new_y in each replicate */

 ods output ParameterEstimates=ParamEst;
  proc reg data=cv;
    MODEL INFECTION_RATE = 
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
			P_OCC_Ess_Yes
			P_VM_Yes ;
   by replicate;
   output out=out1(where=(new_INFECTION_RATE=.)) predicted=y_hat;
  run;

 /* summarise the results of the cross-validations */ 
  data out2;
  set out1;
 	d=INFECTION_RATE-y_hat;
   absd=abs(d);
  run;

  proc summary data=out2;
  var d absd;
  output out=out3 std(d)=rmse mean(absd)=mae;
  run;

 /* Calculate the R2 */ 
  proc corr data=out2 pearson out=corr;
  var INFECTION_RATE ;
  with y_hat;
 run;
 /*
 proc corr data=out2 pearson out=corr(where=( type ='CORR'));
  var y ;
  with y hat;
 run;*/

 data corr;
  set corr;
  Rsqrd=INFECTION_RATE**2;
 run;


