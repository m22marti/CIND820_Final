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
	HOw to check model stability:
		- coefficient stability check
		- go to out of time, accross time validation
		- only keep variables that are part of final development model as wellas response variable (infection_rate)
		- apply all treatments 
		- ensure all indicator variables are generated in model
		- run logistic regression again on validatoin dataset
		- 

	Generate Probability/Score the dataset:


/* create test and trainig dataset */

/* keep model coefficients ina data set */

TITLE  'Logistic Regression Model';

proc reg data= train outest=model2;;
	model INFECTioN_RATE=
	
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
			P_IMM_Yes
			P_OCC_Ess_Yes
			P_VM_Yes;
			output out=stdres p= predict r = resid;
run;
quit;


/* generate score in test data 
produces output in predicted dataset
this will 

*/
proc score data=test score=model2
out=scored type=parms;
	var 	P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
			P_IMM_Yes
			P_OCC_Ess_Yes
			P_VM_Yes; 

run;


/*---------------------------------------------------------------------------------------------------------------------
/* Model for Cross Validation
/Use this model to calculate the prediction error for the reserved part
of the data.
Do this for all k parts, and combine the k estimates of the prediction
error.
/* 
*/
%LET k = 10;
%PUT &k;
%LET i = 1;
%PUT &i;

/* Create training/test  dataset */

	proc surveyselect data=COVID.COVID_NBH_Summaryo group=&k out=have;
	run;
		data training;
	 		set have(where=(groupid ne &i)) ;
		run;

		/*create test dataset */
		data test;
	 		set have(where=(groupid eq &i));
		run;


		ods output 
		Association=native(keep=label2 nvalue2 rename=(nvalue2=native) where=(label2='c'))
		ScoreFitStat=true(keep=dataset freq auc rename=(auc=true));

		/* use training data */
/*l;
		proc reg data= training outest=model2;;
			model INFECTioN_RATE=
			
					P_AGE_40_to_64
					P_EDU_HS_Lower
					P_HH_5_Persons
				/*	P_IMM_Yes*
					P_OCC_Ess_Yes
					P_VM_Yes;
					output out=stdres p= predict r = resid;
		run;*/

		proc score data=test score=model2
			out=scored type=parms;
		var 	P_AGE_40_to_64
				P_EDU_HS_Lower
				P_HH_5_Persons
				P_IMM_Yes
				P_OCC_Ess_Yes
				P_VM_Yes; 

		run;
		quit;

/*
			proc reg data=training outest=RegOut noprint;
			   YHat: model 
					INFECTioN_RATE=
				
						P_AGE_40_to_64
						P_EDU_HS_Lower
						P_HH_5_Persons
					/*	P_IMM_Yes
						P_OCC_Ess_Yes
						P_VM_Yes;
			run;*/

 		/* Scoring the model */
			proc score data=test score=RegOut type=parms predict out=Pred;
			   			var P_AGE_40_to_64
						P_EDU_HS_Lower
						P_HH_5_Persons
					/*	P_IMM_Yes*/
						P_OCC_Ess_Yes
						P_VM_Yes;
			run;
	

		data score&i;
	 		merge true native est;
	 		retain id &i ;
	 		optimism=native-true;
		run;



/* Log score */
proc logistic data=training
	 		outest=est(keep=_status_ _name_) ;
			model total_cases/POP_POPULATION=
				P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
	
			P_OCC_Ess_Yes
			P_VM_Yes;

	 		score data=test fitstat; 
		run;

		data score&i;
	 		merge true native est;
	 		retain id &i ;
	 		optimism=native-true;
		run;



	

	/* use training data */
		proc reg data=training
	 		outest=est(keep=_status_ _name_) ;
			model infection_rate=
				P_OCC_Ess_Yes
				P_EDU_HS_Lower
				p_VM_Black
				P_HH_5_Persons
				P_VM_Southeast_Asian
				P_VM_Latin_American
				P_VM_NO
				P_VM_YES;
		
	 		score data=test fitstat; 
		run;

proc reg data=training outest=RegOut noprint;
   YHat: model y = x;    /* name of model is used by PROC SCORE */
quit;
 
proc score data=ScoreX score=RegOut type=parms predict out=Pred;
   var x;
run;



/* generate KS Statistics */
/* check model strength */
/* the more the KS the better */
/* need to sort in descending order for P_event */
/* create bins in deciles */
/* if model is working fine, the first bins should have higher response rate than next bin */
/* if the response rat eis monotonically decreasing then model is rank ordering
*/

proc sort data=predicted;
by p_event descending;
run;

proc rank data=predicted out=practice groups=10 ties=low;
var P_O_D;
ranks p_final;
run;

/* getting figures to calculate KS and GNI indefelopment dataset */
proc sql;
	select 
		p_final, 
		min(P_O_D) as min_score,
		max(P_O_D) as max_score,
		sum(1*infection_rate) as responder,
		count(infection_rate) as population
	from practice
	group by p_final
	order by p_final
	;
quit;



/*---------------------------------------------------------------------------------------------------------------------*/
/* 10 fold cross validation
/*---------------------------------------------------------------------------------------------------------------------*/
/* 



%LET k = 10;
%PUT &k;
%LET r = 1;
%PUT &r;

/*---------------------------------------------------------------------------------------------------------------------*/
/* STEP1 K-Fold CV 
*/

%LET k = 10;
%PUT &k;
%LET i = 1;
%PUT &i;

/*%macro k_fold_cv(k=10);*/
	ods select none;

	/* assign random */
	proc surveyselect data=COVID.COVID_NBH_Summary group=&k out=have;
	run;
	
	%do i=1 %to &k ;

		/* Create training dataset */
		data training;
	 		set have(where=(groupid ne &i)) ;
		run;

		/*create test dataset */
		data test;
	 		set have(where=(groupid eq &i));
		run;

		ods output 
		Association=native(keep=label2 nvalue2 rename=(nvalue2=native) where=(label2='c'))
		ScoreFitStat=true(keep=dataset freq auc rename=(auc=true));

		/* use training data */
		proc reg data=training
	 		outest=est(keep=_status_ _name_) ;
			model INFECTioN_RATE=
	
			P_AGE_40_to_64
			P_EDU_HS_Lower
			P_HH_5_Persons
	
			P_OCC_Ess_Yes
			P_VM_Yes;
	 		score data=test fitstat; 
		run;

		data score&i;
	 		merge true native est;
	 		retain id &i ;
	 		optimism=native-true;
		run;
	%end;

	data k_fold_cv;
	 	set score1-score&k;
	run;

	ods select all;

%mend;

/* Run Macro */
%k_fold_cv(k=10) 


/*---------------------------------------------------------------------------------------------------------------------*/
/* STEP2  
*/
%LET k = 10;
%PUT &k;
%LET r = 1;
%PUT &r;

%macro k_fold_cv_rep(r=1,k=10);

	ods select none;

	%do r=1 %to &r;
		proc surveyselect data=COVID.COVID_NBH_Summary group=&k out=have;
		run;

		%do i=1 %to &k ;
			data training;
	 			set have(where=(groupid ne &i)) ;
			run;
			data test;
	 		set have(where=(groupid eq &i));
		run;

		ods output 
		Association=native(keep=label2 nvalue2 rename=(nvalue2=native) where=(label2='c'))
		ScoreFitStat=true(keep=dataset freq auc rename=(auc=true));

		proc logistic data=training
	 		outest=est(keep=_status_ _name_) ;
	 		model total_cases/POP_POPULATION=
				P_OCC_Ess_Yes
				P_EDU_HS_Lower
				p_VM_Black
				P_HH_5_Persons
				P_VM_Southeast_Asian
				P_VM_Latin_American
				P_VM_NO
				P_VM_YES;
	 		score data=test fitstat; 
		run;

		data score_r&r._&i;
	 		merge true native est;
	 		retain rep &r id &i;
	 		optimism=native-true;
		run;
		%end;
	%end;

	data k_fold_cv_rep;
	 set score_r:;
	run;

	ods select all;

%mend;

/* Run Macro */
/*%k_fold_cv_rep(r=20,k=10);*/
%k_fold_cv_rep(r=1,k=10);

/*---------------------------------------------------------------------------------------------------------------------*/
/* STEP3 
*/


data all;
 set k_fold_cv k_fold_cv_rep indsname=indsn;
 length indsname $ 32;
 indsname=indsn;
run;

proc summary data=all nway;
 class indsname;
 var optimism;
 output out=want mean=mean lclm=lclm uclm=uclm;
run;



