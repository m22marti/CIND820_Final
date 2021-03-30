
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
/* Use of data without outliers
/* Creation of Training and Testing Datasets
*/
TITLE  'Training & Testing Data';
data Have;             /* the data to partition  */
   set COVID.COVID_NBH_Summaryo;  /* for example, use Heart data */
run;
 

/* If propTrain + propValid = 1, then no observation is assigned to testing */
%let propTrain = 0.7;         /* proportion of trainging data */
%let propTest = %sysevalf(1 - &propTrain); /* remaining are used for testing */
 
/* Randomly assign each observation to a role; _ROLE_ is indicator variable */
data RandOut;
   array p[1] _temporary_ (&propTrain);
   array labels[2] $ _temporary_ ("Train", "Test");
   set Have;
   call streaminit(12);         /* set random number seed */
   /* RAND("table") returns 1, 2, or 3 with specified probabilities */
   _k = rand("Table", of p[*]); 
   _ROLE_ = labels[_k];          /* use _ROLE_ = _k if you prefer numerical categories */
   drop _k;
run;
 
proc freq data=RandOut order=freq;
   tables _ROLE_ / nocum;
run;

/*---------------------------------------------------------------------------------------------------------------------
/* create a separate data set for each role
/*
*/

data Train Test;
array p[1] _temporary_ (&propTrain);
set Have;
call streaminit(12);         /* set random number seed */
/* RAND("table") returns 1, 2, or 3 with specified probabilities */
_k = rand("Table", of p[*]);
if      _k = 1 then output Train;
else                output Test;
drop _k;
run;


/*---------------------------------------------------------------------------------------------------------------------
/* Run model on training
/*
*/

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\STEP9_train.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "STEPWISE"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE PLOT");
ods graphics on;

TITLE  'PROC REG on training data ';
proc reg data=train outest=model1;
	model 
		INFECTioN_RATE=
	
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
			P_OCC_Ess_Yes
			P_VM_Yes

	/ slstay=0.15 slentry=0.15
  	ss2 sse aic;
 /*	output out=out3 p=p r=r; */
	OUTPUT OUT=ROBOUT R=RESID p=pred;
;

run;



/*---------------------------------------------------------------------------------------------------------------------
/* Run model on training
/*
*/

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\STEP9_train_model.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "STEPWISE"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE PLOT");
ods graphics on;

TITLE  'PROC REG on training data ';
proc reg data=train outest=model1;
	model 
		INFECTioN_RATE=
	
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
			P_OCC_Ess_Yes
			P_VM_Yes;


 /*	output out=out3 p=p r=r; */
	OUTPUT OUT=ROBOUT R=RESID p=pred;
;

run;


/* plot density of residuals */
proc kde data=robout out=den;
var resid;
run;

proc sort data=den;
by resid;
run;

goptions reset=all;
symbol1 c=blue i=join v=none height=1;
proc gplot data=den;
	plot density*resid=1;
run;
quit;

/* produce a normal quantile graph*/

goptions reset=all;
proc univariate data=robout normal;
	var resid;
	qqplot resid / normal(mu=est sigma=est);
run;


/* Test for heteroscedasticity */

proc reg data=train;
	model 	
		INFECTioN_RATE=
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
			P_IMM_Yes
			P_OCC_Ess_Yes
			P_VM_Yes;
	plot r.*p.;
	run;
	quit;

/* white test: test null hypothesis that the variance of the residuals is homogenous.  if the p-value is very small, we would have to reject the hupothesis
	and accept the alternative hupothesis that the vairanc eis not homogenouse 
*/


proc reg data=train;
	model 	
		INFECTioN_RATE=
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
			P_IMM_Yes
			P_OCC_Ess_Yes
			P_VM_Yes 
			/spec;
	run;
quit;


/*---------------------------------------------------------------------------------------------------------------------
/* score a model
/*
*/

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\STEP9_score.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "STEPWISE"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE PLOT");
ods graphics on;

TITLE  'score a model ';
proc score data=test score=model1
out=scored type=parms;
	var 	P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
			P_IMM_Yes
			P_OCC_Ess_Yes
			P_VM_Yes; 

run;








/*
ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\STEP9_train2.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "testing"
embedded_titles='yes' sheet_interval = 'none');

TITLE  'Linear Regression: Testing1 without outliers Model Fit';

ods excel options(sheet_interval = 'proc' sheet_name = "Testing");
ods graphics on;

PROC REG DATA=train ;
 	MODEL infection_rate = 
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
			P_IMM_Yes
			P_OCC_Ess_Yes
			P_VM_Yes

	/ DW SPEC 
      VIF tol collinoint
	  INFLUENCE R
		;
 OUTPUT OUT=RESIDS R=RESID p= predict;
		plot r.*p.;
 RUN;

/*---------------------------------------------------------------------------------------------------------------------
/* Run model on testing
/*
*/

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\STEP9_test.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "STEPWISE"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE PLOT");
ods graphics on;

TITLE  'PROC REG on testing data ';
proc reg data=test;
	model 
		INFECTioN_RATE=
	
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
			P_IMM_Yes
			P_OCC_Ess_Yes
			P_VM_Yes

;

run;

/*---------------------------------------------------------------------------------------------------------------------
/* MOdel FIt
/*
*/

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\testing1.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "testing"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "Testing");
ods graphics on;

PROC REG DATA=train;
 	MODEL infection_rate = 
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
		/*	P_IMM_Yes*/
			P_OCC_Ess_Yes
			P_VM_Yes

	/ DW SPEC 
      VIF tol collinoint
	  INFLUENCE R
		;
 OUTPUT OUT=RESIDS R=RESID p= predict;
		plot r.*p.;
 RUN;


/*---------------------------------------------------------------------------------------------------------------------
/* Cross validation on train/test
/*
*/

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\STEP10_1.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "STEPWISE"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE PLOT");
ods graphics on;

TITLE  'GLMSELECT Cross validation ';
proc glmselect data=COVID.COVID_NBH_Summary;
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