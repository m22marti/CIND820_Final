
/**********************************************************************************************************************
/* NAME:		STEP10_Model_Validation2
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
/* not enought data to create sizable training and validation sets.  cross validation is an alternative for estimating prediction error.
/* computes predicted residual sum of squares and repeated fo reach K part.
/* sum of k predicted residual sum of squares to estimate the prediction error that is denoted by CVPRESS. 
/*
/*---------------------------------------------------------------------------------------------------------------------
/* SAMPLE 1
/* Good
*/

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\STEP10_glm_10fold1.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "STEPWISE"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE PLOT");
ods graphics on;

TITLE  'GLMSELECT Cross validation ';
proc glmselect data=COVID.COVID_NBH_Summaryo;
	model 
		INFECTioN_RATE=
	
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
	/*		P_IMM_Yes*/
			P_OCC_Ess_Yes
			P_VM_Yes

		/selection=forward(stop=CV) 
/*	cvMethod=split(10) */
		CVMETHOD=RANDOM(10) CVDETAILS=ALL;

		partition fraction(test=0.3);
run;



/*---------------------------------------------------------------------------------------------------------------------
/* SAMPLE 3: Using code 
/* GOOD
*/

/* https://www.anegron.site/2020/05/15/cross-validation-in-sas/ */
ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\STEP10_3.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "STEPWISE"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE PLOT");
ods graphics on;

TITLE  '10 Fold Cross validation ';

%let K=10;
%let rate=%sysevalf((&K-1)/&K);
%put &rate;
  
/* BElow is the model */
  
proc reg data= COVID.COVID_NBH_Summaryo;
	model INFECTioN_RATE=
	
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
			P_IMM_Yes
			P_OCC_Ess_Yes
			P_VM_Yes;
run;
quit;



/*---------------------------------------------------------------------------------------------------------------------
/* 10 fold cross validation
/*
*/

 /*	Generate the cross validation sample;*/

 proc surveyselect data=COVID.COVID_NBH_Summary out=cv seed=231258
  	samprate=&rate outall reps=10;
 run;


  /* the variable selected is an automatic variable generatic by surveyselect.
  /* If selected is true then then new_y will get the value of y otherwise is missing */
   
 data cv;
 set cv;
   if selected then new_INFECTION_RATE=INFECTION_RATE;
 run;

/* get predicted values for the missing new_y in each replicate */

 ods output ParameterEstimates=ParamEst;
  proc reg data=cv;
    model new_INFECTION_RATE = 
		
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
		/*	P_IMM_Yes*/
			P_OCC_Ess_Yes
			P_VM_Yes;
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
 /*proc corr data=out2 pearson out=corr(where=( type ='CORR'));*/
 proc corr data=out2 pearson out=corr;
  var INFECTION_RATE ;
  with y_hat;
 run;

 data corr;
  set corr;
  Rsqrd=INFECTION_RATE**2;
 run;



/*---------------------------------------------------------------------------------------------------------------------
/* SAMPLE 4 using GLMSELECT
/* GOOD
*/
ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\STEP10_glm_cross_val.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "STEPWISE"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE PLOT");
ods graphics on;

TITLE  'GLMSELECT Cross validation ';
proc glmselect data=COVID.COVID_NBH_Summaryo;
	model 
		INFECTioN_RATE=
	
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
		/*	P_IMM_Yes*/
			P_OCC_Ess_Yes
			P_VM_Yes

		/selection=forward
		CVMETHOD=RANDOM(10) CVDETAILS=ALL;
		partition fraction(test=0.3);
run;



/*---------------------------------------------------------------------------------------------------------------------
/* SAMPLE 2
/*
*/
/* Create training/test  dataset */

%LET k = 10;
%PUT &k;
%LET i = 1;
%PUT &i;

		proc surveyselect data=COVID.COVID_NBH_Summaryo group=&k out=have;
		run;

		data training;
	 		set have(where=(groupid ne &i)) ;
		run;

		/*create test dataset */
		data test;
	 		set have(where=(groupid eq &i));
		run;


/* Running the model */
proc reg data=training outest=RegOut noprint;
   YHat: model 
		INFECTioN_RATE=
	
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
		/*	P_IMM_Yes*/
			P_OCC_Ess_Yes
			P_VM_Yes;

quit;

 /* Scoring the model */
proc score data=test score=RegOut type=parms predict out=Pred;
   var P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
		/*	P_IMM_Yes*/
			P_OCC_Ess_Yes
			P_VM_Yes;
run;

