
/**********************************************************************************************************************
/* NAME:		STEP8_LinReg_Variable_Selection
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
/*	A good linear model will have a low RMSE and a high R2 close to 1. 
/*
/*
/**********************************************************************************************************************/



proc means data=COVID.COVID_NBH_Summary;
vars 
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
		P_VM_Yes;
		output out=aoutmeans;
run;


/*---------------------------------------------------------------------------------------------------------------------
/* pLOT
/*
*/
ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Charts4.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "STEPWISE"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE PLOT");
ods graphics on;

PROC PLOT DATA=COVID.COVID_NBH_Summary;
   PLOT infection_rate*(
		NIA_IND
		P_AGE_00_to_19
		P_AGE_20_to_39
		P_AGE_40_to_64
		P_AGE_65_up
		P_DWEL_Apart
		P_DWEL_Attached
		P_DWEL_Movable
		P_DWEL_SD_House
		P_EDU_College_Trades
		P_EDU_HS_Lower
		P_EDU_University
		P_HH_Avg_Size
		P_IMM_Yes
		P_INC_Over_100000
		P_OCC_Ess_Yes
		P_VM_Yes
			
);
RUN;

PROC PLOT DATA=COVID.COVID_NBH_Summary;
 PLOT P_OCC_Ess_Yes*P_OCC_Ess_No;
 RUN;


/*---------------------------------------------------------------------------------------------------------------------
/* Variable Selection #0
/*   CAlculate AIC for all possible subsets
*/

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Var_Sel_0.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "var_sel_0"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE SELECTION");
ods graphics on;


 proc reg data=COVID.COVID_NBH_Summary outest=est;
 	model infection_rate=
		
/* calculates AIC for all possible subsets of main effects using an
intercept term.*/
	/ selection=adjrsq sse aic ;
	 output out=out p=p r=r; 
/*calculates AIC for all possible subsets of main effects without an
intercept term by specifying the noint option. 
	/ noint selection=adjrsq sse aic ;
 	output out=out0 p=p r=r;*/

run; 
quit;


 /* combine both out and out0 */

data estout;
 	set est est0; 
run;

proc sort data=estout; by _aic_;

proc print data=estout(obs=8); run;


/*---------------------------------------------------------------------------------------------------------------------
/* Variable Selection #1 - Forward
/*
*/
ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Var_Sel_1.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "var_sel_1"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE SELECTION");
ods graphics on;

proc reg data=COVID.COVID_NBH_Summary outest=est1;
 	model infection_rate=
		/* Insignificant
			P_NBH_SH_UNITS
			POP_density
			NIA_IND
			/*POP_land_area
			POP_population */
			
			/* insignificant  
			P_AGE1_0_to_14
			P_AGE1_15_to_24
			P_AGE1_25_to_54
			P_AGE1_55_to_64
			P_AGE1_65_to_84
			P_AGE1_85_UP*/
		
			P_AGE_00_to_19
			P_AGE_20_to_39
			P_AGE_40_to_64
			P_AGE_65_up	

			/* Insignificant 
			P_COMM_Bicycle
			P_COMM_Other
			P_COMM_Public_Transit
			P_COMM_Vehicle_Driver
			P_COMM_Vehicle_Pass
			P_COMM_Walk*/

			/* Insignificant 
			P_DWEL_Apart
			P_DWEL_Attached
			P_DWEL_Movable
			P_DWEL_SD_House*/

			P_EDU_College_Trades
			P_EDU_HS_Lower
			/*
			P_EDU_University*/
		
			/*
			P_HH_1_Person
			P_HH_2_Persons
			P_HH_3_Persons
			P_HH_4_Persons*/
			P_HH_5_Persons
			/*P_HH_Avg_Size*/
			
			/*P_IMM_1981_2000
			P_IMM_1Non_Perm_Res
			P_IMM_2001_2016
			P_IMM_Before_1981
			P_IMM_Non_Imm*/
			P_IMM_Yes
			/*P_IMM_No*/
		
			/*P_INCIND_pop_low_inc
			P_INCIND_Total_Avg
			/*P_INC_Under_25000*/
			P_INC_25000_50000
			P_INC_50000_99999
		/*	P_INC_25000_99999
			P_INC_Over_100000*/
		/*
			P_IND_Ess_Yes
			P_IND_Ess_No

			/* Use of Y/N Category 
			P_OCC_NA
			P_OCC_0
			P_OCC_1
			P_OCC_2
			P_OCC_3
			P_OCC_4
			P_OCC_5
			P_OCC_6
			P_OCC_7
			P_OCC_8
			P_OCC_9*/
		
		/*	P_OCC_Ess_No*/
			P_OCC_Ess_Yes
			/*
			P_VM_Black
			P_VM_East_Asian
			P_VM_Latin_American
			P_VM_Mult_Oth
			P_VM_Not_Vismin
			P_VM_South_Asian
			P_VM_Southeast_Asian
			P_VM_West_Asian*/

		/*	P_VM_No*/
			P_VM_Yes

	/ slstay=0.15 slentry=0.15
 	selection=forward ss2 sse aic;
 	output out=out1 p=p r=r; 
run; 
quit;



/*---------------------------------------------------------------------------------------------------------------------
/* Variable Selection #2 - Backward
/*
*/
ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Var_Sel_2.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "var_sel_2"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE SELECTION");
ods graphics on;


proc reg data=COVID.COVID_NBH_Summary outest=est2;
 	model infection_rate=
					/* Insignificant
			P_NBH_SH_UNITS
			POP_density
			NIA_IND
			/*POP_land_area
			POP_population */
			
			/* insignificant  
			P_AGE1_0_to_14
			P_AGE1_15_to_24
			P_AGE1_25_to_54
			P_AGE1_55_to_64
			P_AGE1_65_to_84
			P_AGE1_85_UP*/
		
			P_AGE_00_to_19
			P_AGE_20_to_39
			P_AGE_40_to_64
			P_AGE_65_up	

			/* Insignificant 
			P_COMM_Bicycle
			P_COMM_Other
			P_COMM_Public_Transit
			P_COMM_Vehicle_Driver
			P_COMM_Vehicle_Pass
			P_COMM_Walk*/

			/* Insignificant 
			P_DWEL_Apart
			P_DWEL_Attached
			P_DWEL_Movable
			P_DWEL_SD_House*/

			P_EDU_College_Trades
			P_EDU_HS_Lower
			/*
			P_EDU_University*/
		
			/*
			P_HH_1_Person
			P_HH_2_Persons
			P_HH_3_Persons
			P_HH_4_Persons*/
			P_HH_5_Persons
			/*P_HH_Avg_Size*/
			
			/*P_IMM_1981_2000
			P_IMM_1Non_Perm_Res
			P_IMM_2001_2016
			P_IMM_Before_1981
			P_IMM_Non_Imm*/
			P_IMM_Yes
			/*P_IMM_No*/
		
				/*P_INCIND_pop_low_inc
			P_INCIND_Total_Avg
			/*P_INC_Under_25000*/
			P_INC_25000_50000
			P_INC_50000_99999
		/*	P_INC_25000_99999
			P_INC_Over_100000*/
		/*
			P_IND_Ess_Yes
			P_IND_Ess_No

			/* Use of Y/N Category 
			P_OCC_NA
			P_OCC_0
			P_OCC_1
			P_OCC_2
			P_OCC_3
			P_OCC_4
			P_OCC_5
			P_OCC_6
			P_OCC_7
			P_OCC_8
			P_OCC_9*/
		
		/*	P_OCC_Ess_No*/
			P_OCC_Ess_Yes
			/*
			P_VM_Black
			P_VM_East_Asian
			P_VM_Latin_American
			P_VM_Mult_Oth
			P_VM_Not_Vismin
			P_VM_South_Asian
			P_VM_Southeast_Asian
			P_VM_West_Asian*/

		/*	P_VM_No*/
			P_VM_Yes

	/ slstay=0.15 slentry=0.15
 	selection=backward ss2 sse aic;
 	output out=out2 p=p r=r; 
run; 
quit; 






/*---------------------------------------------------------------------------------------------------------------------
/* Variable Selection #3 - Stepwise
/*
*/


ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Var_Sel_3.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "var_sel_3"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE SELECTION");
ods graphics on;



proc reg data=COVID.COVID_NBH_Summary outest=est3;
 	model infection_rate=
				/* Insignificant
			P_NBH_SH_UNITS
			POP_density
			NIA_IND
			/*POP_land_area
			POP_population */
			
			/* insignificant  
			P_AGE1_0_to_14
			P_AGE1_15_to_24
			P_AGE1_25_to_54
			P_AGE1_55_to_64
			P_AGE1_65_to_84
			P_AGE1_85_UP*/
		
			P_AGE_00_to_19
			P_AGE_20_to_39
			P_AGE_40_to_64
			P_AGE_65_up	

			/* Insignificant 
			P_COMM_Bicycle
			P_COMM_Other
			P_COMM_Public_Transit
			P_COMM_Vehicle_Driver
			P_COMM_Vehicle_Pass
			P_COMM_Walk*/

			/* Insignificant 
			P_DWEL_Apart
			P_DWEL_Attached
			P_DWEL_Movable
			P_DWEL_SD_House*/

			P_EDU_College_Trades
			P_EDU_HS_Lower
			/*
			P_EDU_University*/
		
			/*
			P_HH_1_Person
			P_HH_2_Persons
			P_HH_3_Persons
			P_HH_4_Persons*/
			P_HH_5_Persons
			/*P_HH_Avg_Size*/
			
			/*P_IMM_1981_2000
			P_IMM_1Non_Perm_Res
			P_IMM_2001_2016
			P_IMM_Before_1981
			P_IMM_Non_Imm*/
			P_IMM_Yes
			/*P_IMM_No*/
		
			/*P_INCIND_pop_low_inc
			P_INCIND_Total_Avg
			/*P_INC_Under_25000*/
			P_INC_25000_50000
			P_INC_50000_99999
		/*	P_INC_25000_99999
			P_INC_Over_100000*/
			/*
			P_IND_Ess_Yes
			P_IND_Ess_No*/

			/* Use of Y/N Category 
			P_OCC_NA
			P_OCC_0
			P_OCC_1
			P_OCC_2
			P_OCC_3
			P_OCC_4
			P_OCC_5
			P_OCC_6
			P_OCC_7
			P_OCC_8
			P_OCC_9*/
		
		/*	P_OCC_Ess_No*/
			P_OCC_Ess_Yes
			/*
			P_VM_Black
			P_VM_East_Asian
			P_VM_Latin_American
			P_VM_Mult_Oth
			P_VM_Not_Vismin
			P_VM_South_Asian
			P_VM_Southeast_Asian
			P_VM_West_Asian*/

		/*	P_VM_No*/
			P_VM_Yes


	/ slstay=0.15 slentry=0.15
 	selection=stepwise ss2 sse aic;
 	output out=out3 p=p r=r; 
run; 
quit;



/*---------------------------------------------------------------------------------------------------------------------
/* Variable Selection #4 - Calculate RMSE
/*
*/

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Var_Sel_4.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "var_sel_4"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE SELECTION");
ods graphics on;

 proc reg data=COVID.COVID_NBH_Summary outest=est4;

 	model infection_rate=
				/* Insignificant
			P_NBH_SH_UNITS
			POP_density
			NIA_IND
			/*POP_land_area
			POP_population */
			
			/* insignificant  
			P_AGE1_0_to_14
			P_AGE1_15_to_24
			P_AGE1_25_to_54
			P_AGE1_55_to_64
			P_AGE1_65_to_84
			P_AGE1_85_UP*/
		
			P_AGE_00_to_19
			P_AGE_20_to_39
			P_AGE_40_to_64
			P_AGE_65_up	

			/* Insignificant 
			P_COMM_Bicycle
			P_COMM_Other
			P_COMM_Public_Transit
			P_COMM_Vehicle_Driver
			P_COMM_Vehicle_Pass
			P_COMM_Walk*/

			/* Insignificant 
			P_DWEL_Apart
			P_DWEL_Attached
			P_DWEL_Movable
			P_DWEL_SD_House*/

			P_EDU_College_Trades
			P_EDU_HS_Lower
			/*
			P_EDU_University*/
		
			/*
			P_HH_1_Person
			P_HH_2_Persons
			P_HH_3_Persons
			P_HH_4_Persons*/
			P_HH_5_Persons
			/*P_HH_Avg_Size*/
			
			/*P_IMM_1981_2000
			P_IMM_1Non_Perm_Res
			P_IMM_2001_2016
			P_IMM_Before_1981
			P_IMM_Non_Imm*/
			P_IMM_Yes
			/*P_IMM_No*/
		
			/*P_INCIND_pop_low_inc
			P_INCIND_Total_Avg
			/*P_INC_Under_25000*/
			P_INC_25000_50000
			P_INC_50000_99999
		/*	P_INC_25000_99999
			P_INC_Over_100000*/
		/*
			P_IND_Ess_Yes
			P_IND_Ess_No

			/* Use of Y/N Category 
			P_OCC_NA
			P_OCC_0
			P_OCC_1
			P_OCC_2
			P_OCC_3
			P_OCC_4
			P_OCC_5
			P_OCC_6
			P_OCC_7
			P_OCC_8
			P_OCC_9*/
		
		/*	P_OCC_Ess_No*/
			P_OCC_Ess_Yes
			/*
			P_VM_Black
			P_VM_East_Asian
			P_VM_Latin_American
			P_VM_Mult_Oth
			P_VM_Not_Vismin
			P_VM_South_Asian
			P_VM_Southeast_Asian
			P_VM_West_Asian*/

		/*	P_VM_No*/
			P_VM_Yes
	
	/
 	selection=adjrsq sse aic adjrsq;
 	output out=out p=p r=r; 
run; 
quit; 



/*---------------------------------------------------------------------------------------------------------------------
/* Variable Selection #5 - Calculate RMSE 2
/*
*/

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Var_Sel_5.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "var_sel_5"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "VARIABLE SELECTION");
ods graphics on;

proc reg data=COVID.COVID_NBH_Summary outest=est5;

model infection_rate=
				/* Insignificant
			P_NBH_SH_UNITS
			POP_density
			NIA_IND
			/*POP_land_area
			POP_population */
			
			/* insignificant  
			P_AGE1_0_to_14
			P_AGE1_15_to_24
			P_AGE1_25_to_54
			P_AGE1_55_to_64
			P_AGE1_65_to_84
			P_AGE1_85_UP*/
		
			P_AGE_00_to_19
			P_AGE_20_to_39
			P_AGE_40_to_64
			P_AGE_65_up	

			/* Insignificant 
			P_COMM_Bicycle
			P_COMM_Other
			P_COMM_Public_Transit
			P_COMM_Vehicle_Driver
			P_COMM_Vehicle_Pass
			P_COMM_Walk*/

			/* Insignificant 
			P_DWEL_Apart
			P_DWEL_Attached
			P_DWEL_Movable
			P_DWEL_SD_House*/

			P_EDU_College_Trades
			P_EDU_HS_Lower
			/*
			P_EDU_University*/
		
			/*
			P_HH_1_Person
			P_HH_2_Persons
			P_HH_3_Persons
			P_HH_4_Persons*/
			P_HH_5_Persons
			/*P_HH_Avg_Size*/
			
			/*P_IMM_1981_2000
			P_IMM_1Non_Perm_Res
			P_IMM_2001_2016
			P_IMM_Before_1981
			P_IMM_Non_Imm*/
			P_IMM_Yes
			/*P_IMM_No*/
		
				/*P_INCIND_pop_low_inc
			P_INCIND_Total_Avg
			/*P_INC_Under_25000*/
			P_INC_25000_50000
			P_INC_50000_99999
		/*	P_INC_25000_99999
			P_INC_Over_100000*/
		/*
			P_IND_Ess_Yes
			P_IND_Ess_No

			/* Use of Y/N Category 
			P_OCC_NA
			P_OCC_0
			P_OCC_1
			P_OCC_2
			P_OCC_3
			P_OCC_4
			P_OCC_5
			P_OCC_6
			P_OCC_7
			P_OCC_8
			P_OCC_9*/
		
		/*	P_OCC_Ess_No*/
			P_OCC_Ess_Yes
			/*
			P_VM_Black
			P_VM_East_Asian
			P_VM_Latin_American
			P_VM_Mult_Oth
			P_VM_Not_Vismin
			P_VM_South_Asian
			P_VM_Southeast_Asian
			P_VM_West_Asian*/

		/*	P_VM_No*/
			P_VM_Yes

	/
 	noint selection=adjrsq sse aic adjrsq;
 	output out=out p=p r=r; 
run; 
quit; 


data both; 
	set est4 est5; 
run;

proc sort data=both; 
by _rmse_; 
run;

 data top_10; 
	set both (obs=10); 
run;

proc print data=both(obs=10); run;










/*** other version**/
TITLE 'Linear Regression';
proc reg data=COVID.COVID_NBH_Summary  outest=betas covout; 
	model infection_rate = 

			NIA_IND
		P_AGE_00_to_19
	/*	P_EDU_College_Trades
		P_EDU_HS_Lower*/
		P_EDU_University
		P_HH_5_Persons

		P_IMM_Yes
		/*P_INC_Over_100000*/
		P_INC_25000_99999
		P_OCC_Ess_Yes
		P_VM_Yes
				
	/selection= stepwise maxstep=15 sle=0.3 sls=0.3 details lackfit;
	/*output out=pred p=phat lower=lcl upper=ucl;	*/
	;
run;

/* selection = forward */






/*---------------------------------------------------------------------------------------------------------------------
/* GLM Model
/*
*/

PROC GLM DATA=COVID.COVID_NBH_Summary;
 MODEL infection_rate = 
		NIA_IND
		P_AGE_00_to_19
		P_AGE_20_to_39
		P_AGE_40_to_64
		P_AGE_65_up
		P_DWEL_Apart
		P_DWEL_Attached
		P_DWEL_Movable
		P_DWEL_SD_House
		P_EDU_College_Trades
		P_EDU_HS_Lower
		P_EDU_University
		P_HH_Avg_Size
		P_IMM_Yes
		P_INC_Over_100000
		P_OCC_Ess_Yes
		P_VM_Yes;

RUN;

