/**********************************************************************************************************************
/* NAME:		STEP9_LinReg_Model
/* DESCRIPTION:	
/* DATE:		March 1, 2021
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
/* Fields to use for Model
/*
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
			P_IMM_Yes
			P_OCC_Ess_Yes
			P_VM_Yes

*/

proc means data=COVID.COVID_NBH_Summary;
vars P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
			P_IMM_Yes
			P_OCC_Ess_Yes
			P_VM_Yes;
run;

/*---------------------------------------------------------------------------------------------------------------------
/* OUtlier Detection
/*
*/

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\OUTLIER2.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "STEPWISE"
embedded_titles='yes' sheet_interval = 'none');

TITLE  'Outlier Detection';

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE PLOT");
ods graphics on;
PROC ROBUSTREG DATA=COVID.COVID_NBH_Summary plots=(rdplot ddplot histogram qqplot);

	MODEL INFECTION_RATE = 
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
		/*	P_IMM_Yes*/
			P_OCC_Ess_Yes
			P_VM_Yes 
			/ DAGNOSTICS LEVERAGE;
			OUTPUT OUT=ROBOUT R=RESID SR=STDRES;
	RUN;


/*---------------------------------------------------------------------------------------------------------------------
/* Run model without outliers
/*
*/

/* 	test outliers */
PROC SQL;
 	CREATE TABLE COVID.COVID_NBH_SummaryO as  
		SELECT *
			from Covid.COVID_NBH_Summary
			where neighbourhood_id not in (73,113,125)
			ORDER BY NEIGHBOURHOOD_ID;
QUIT;



ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\OUTLIERO2.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "STEPWISE"
embedded_titles='yes' sheet_interval = 'none');

TITLE  'Outlier Detection: outliers removed';

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE PLOT");
ods graphics on;
PROC ROBUSTREG DATA=COVID.COVID_NBH_SummaryO plots=(rdplot ddplot histogram qqplot);

	MODEL INFECTION_RATE = 
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
		/*	P_IMM_Yes*//
			P_OCC_Ess_Yes
			P_VM_Yes 
			/ DAGNOSTICS LEVERAGE;
			OUTPUT OUT=ROBOUT R=RESID SR=STDRES;
	RUN;


ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\testinO1.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "testing"
embedded_titles='yes' sheet_interval = 'none');

TITLE  'Linear Regression: Testing1 without outliers Model Fit';

ods excel options(sheet_interval = 'proc' sheet_name = "Testing");
ods graphics on;

PROC REG DATA=COVID.COVID_NBH_SummaryO ;
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
/* pLOT
/*
*/
ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Charts4.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "STEPWISE"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE PLOT");
ods graphics on;

TITLE  'Linear Regression Model using PROC REG';
ods graphics on;
proc reg data=COVID.COVID_NBH_Summary;
	model 
		INFECTioN_RATE=
	
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
			P_IMM_Yes
			P_OCC_Ess_Yes
			P_VM_Yes

	/ partial;
run;
quit;
ods graphics off;

/*---------------------------------------------------------------------------------------------------------------------
/* Linear Regression Model with Plots
/*
*/
ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\TESTING4.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "STEPWISE"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE PLOT");
ods graphics on;

TITLE  'Linear Regression Model using PROC REG';

PROC REG data= COVID.COVID_NBH_Summary outest=mod1_reg;
	model INFECTioN_RATE=
	
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
			P_IMM_Yes
			P_OCC_Ess_Yes
			P_VM_Yes
			/stb clb;
			output out=stdres p= predict r = resid;
			plot r.*p.;

;
run; 


proc glmselect data= COVID.COVID_NBH_Summary;
	model INFECTioN_RATE=
	
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
		/*	P_IMM_Yes*/
			P_OCC_Ess_Yes
			P_VM_Yes;
			store out=model1;

run;


/*---------------------------------------------------------------------------------------------------------------------
/* Using GLM Model
/*
*/

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\PROC_GLM.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "STEPWISE"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE PLOT");
ods graphics on;

TITLE  'Linear Regression Model using PROC GLM';
PROC GLM DATA=COVID.COVID_NBH_Summary outest=mod1_glm;
 MODEL infection_rate = 
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
			P_IMM_Yes
			P_OCC_Ess_Yes
			P_VM_Yes
;


RUN;

/*---------------------------------------------------------------------------------------------------------------------
/* NOTES:
/* 	Test of Assumptions: We will validate the "iid" assumption of linear regression by examining the residuals of our final
/*   	model. Specifically, we will use diagnostic statistics from REG as well as create an output dataset of
/*		residual values for PROC UNIVARIATE to test.
/*
/* 	Testing for Multicollinearity vif
/*	Multicollinearity is when your independent,X, variables are correlated. A statistic called the
/*	Variance Inflation Factor, VIF, can be used to test for multicollinearity. A cut off of 10 can be used to
/*	test if a regression function is unstable. If VIF>10 then you should search for causes of multicollinearity
/*
/* Testing for Outliers: INFLUENCE R
/*		A Cook's D greater than the absolute value of 2 should be investigated.
/*		RSTUDENT is the studentized deleted residual.The studentized deleted residual checks if the model is significantly different 
/*			if an observation is removed. An RSTUDENT whose absolute value is larger than 2 should be investigated. 
/*		DFFITS:	Observations whose DFFITS values are extreme in relation to the others should be investigated. An abbreviated
/*			version of the printout is listed.
/*		Dfbetas statistics can be used to find outliers that influence an particular parameter's coefficient. 
/*			For small to medium sized  datasets, a Dfbetas over 1.0 should be investigated.
/*
/*		Testing the Fit of the Model: 
/*			The overall fit of the model can be checked by looking at the F-Value and its corresponding p-value (Prob >F) 
/*			for the total model under the Analysis of Variance portion of the REG or GLM print out.
/*			Generally, you want a Prob>F value less than 0.05

*/

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\testing1.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "testing"
embedded_titles='yes' sheet_interval = 'none');

TITLE  'Linear Regression: Testing1 Model Fit';

ods excel options(sheet_interval = 'proc' sheet_name = "Testing");
ods graphics on;

PROC REG DATA=COVID.COVID_NBH_Summaryo;
 	MODEL infection_rate = 
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
	/*		P_IMM_Yes*/
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
/* Testing Residuals
*/

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\testing residuals.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "testing"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "Testing");

TITLE  'Linear Regression: Testing2 Testing Residuals';
 ODS GRAPHICS ON;
 PROC UNIVARIATE DATA=RESIDS
 NORMAL PLOT;
 VAR RESid;
 RUN;


/*---------------------------------------------------------------------------------------------------------------------
/* pLOT Residuals BY PREDICTED VALUES
*/



/*---------------------------------------------------------------------------------------------------------------------
/* Testing fit of model
/*
	 If the p-value for the Lack of Fit test is greater than
0.05 then your model is a good fit and no additional
terms are needed.
*/
ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\model_fit.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "testing"
embedded_titles='yes' sheet_interval = 'none');

TITLE  'Linear Regression: Testing3 Model Fit';

ods excel options(sheet_interval = 'proc' sheet_name = "Testing");

PROC RSREG DATA=train;
	model infection_rate = 
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
		/*	P_IMM_Yes*/
			P_OCC_Ess_Yes
			P_VM_Yes
	/ LACKFIT;
 RUN;


/*---------------------------------------------------------------------------------------------------------------------
/* NOTES: glm
/* 	Testing for Multicollinearity
/*	Multicollinearity is when your independent,X, variables are correlated. A statistic called the
/*	Variance Inflation Factor, VIF, can be used to test for multicollinearity. A cut off of 10 can be used to
/*	test if a regression function is unstable. If VIF>10 then you should search for causes of multicollinearity
*/
PROC GLM DATA=COVID.COVID_NBH_Summary;
	MODEL infection_rate = 
			P_AGE_00_to_19
			P_AGE_20_to_39
			P_AGE_40_to_64
			P_AGE_65_up	
			P_EDU_College_Trades
			P_EDU_HS_Lower
			P_HH_5_Persons
			P_IMM_Yes
			P_INC_25000_50000
			P_INC_50000_99999
			P_OCC_Ess_Yes
			P_VM_Yes
			P_VM_Yes

	/SOLUTION;
 RUN; 

/*---------------------------------------------------------------------------------------------------------------------
/* NOTES:
/*

R-square and Adj-Rsq: You want these numbers to be as high as possible. If your model has a lot of variables,
	use Adj-Rsq because a model with more variables will have a higher R-square than a similar model with fewer variables. Adj-Rsq
	takes the number of variables in your model into account. An R-square or 0.7 or higher is generally accepted as good.

Root MSE: You want this number to be small compared to other models. The value of Root MSE will be dependent on the values of the Y variable you
	are modeling. Thus, you can only compare Root MSE against other models that are modeling the same dependent variable.

Type III SS Pr>F: As a guideline, you want the value for each of the variables in your model to have a Type III SS p-value of 0.05 or less. 
	This is a judgement call. If you have a p-value greater than .05 and are willing to accept a lesser confidence level, then you can use the model. 
 	Do not substitute Type I or Type II SS for Type III SS. They are different statistics and could lead to incorrect conclusions in some cases

Other approaches to finding good models are having a small PRESS statistic (found in REG as Predicted Resid SS (Press)) or having a CP statistic
of p-1 where p is the number of parameters in your model. CP can also be found using PROC REG. 

When building a model only eliminate one term,variable or interaction, at a time. From examining the GLM printout, we will drop the interaction term
of BEDROOMS*SQFEET as the Type III SS indicates it is not significant to the model. If an interaction term is significant to a model, its
individual components are generally left in the model as well. It is also generally accepted to leave an intercept in your model unless you have a good
reason for eliminating it. We will use BEDROOMS,S1, S2 and S3 in our final model.


Some of the approaches for choosing the best model listed above are available in SELECTION= options of REG and SELECTION= options of GLM.
 For example:
 	PROC REG;
 	MODEL PRICE = BEDROOMS SQFEET
 	S1 S2 S3 / SELECTION = ADJRSQ;

	will iteratively run models until the model with the highest adjusted R-square is found. Consult the SAS/STAT User's Guide for details.