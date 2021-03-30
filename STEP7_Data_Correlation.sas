/**********************************************************************************************************************
/* NAME:		STEP7_DATA_Correlation
/* DESCRIPTION:	Correlation of demographics data to infection rates
/* DATE:		Feb 7, 2021
/* AUTHOR:		Marlene Martins
/* NOTES:		
/* 				
/* INPUT:		COVID.COVID_NBH_WEND_Summary 	
/*				COVID.COVID_NBH_Summary 
/*  
/**********************************************************************************************************************
/* Modifications
/*
/*
/*
/**********************************************************************************************************************/

/*---------------------------------------------------------------------------------------------------------------------
/* list data info
*/

proc contents
data=COVID.COVID_NBH_SUMMARY OUT=Aoutdata;
run;

/*
ods exclude all;
proc corr data=COVID.COVID_NBH_SUMMARY;
ods output PearsonCorr=P;
	var x y;
	by SomeGroup;
run;
ods exclude none;

proc print data=P; run;


/*---------------------------------------------------------------------------------------------------------------------*/
/* Correlation between independent and dependent variables infection rate and all percentages 
/* COVID.COVID_NBH_Summary
*/

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Charts.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "Test"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "Correlation");
ods graphics on;


PROC CORR DATA=COVID.COVID_NBH_Summary rank outp=CorrOutp PLOTS=SCATTER(NVAR=all);
ods output PearsonCorr=P;
/*	PLOTS(ONLY)=SCATTER(ELLIPSE=NONE); */

	VAR 

			P_INC_25000_99999

			/* Insignificant
			P_NBH_SH_UNITS
			POP_density
			NIA_IND
			POP_land_area
			POP_population */
			
			/* insignificant  */
			P_AGE1_0_to_14
			P_AGE1_15_to_24
			P_AGE1_25_to_54
			P_AGE1_55_to_64
			P_AGE1_65_to_84
			P_AGE1_85_UP
		
			P_AGE_00_to_19
			P_AGE_20_to_39
			P_AGE_40_to_64
			P_AGE_65_up
			

			/* Insignificant */
			P_COMM_Bicycle
			P_COMM_Other
			P_COMM_Public_Transit
			P_COMM_Vehicle_Driver
			P_COMM_Vehicle_Pass
			P_COMM_Walk

			/* Insignificant */
			P_DWEL_Apart
			P_DWEL_Attached
			P_DWEL_Movable
			P_DWEL_SD_House

			P_EDU_College_Trades
			P_EDU_HS_Lower
			P_EDU_University
		
			P_HH_1_Person
			P_HH_2_Persons
			P_HH_3_Persons
			P_HH_4_Persons
			P_HH_5_Persons
			P_HH_Avg_Size
			
			P_IMM_1981_2000
			P_IMM_1Non_Perm_Res
			P_IMM_2001_2016
			P_IMM_Before_1981
			P_IMM_Non_Imm
			P_IMM_Yes
			P_IMM_No
		
			P_INCIND_pop_low_inc
			P_INCIND_Total_Avg
			P_INC_25000_50000
			P_INC_50000_99999
			P_INC_Over_100000
			P_INC_Under_25000

			/* Use of Category */
			P_IND_Cat_11
			P_IND_Cat_21
			P_IND_Cat_22
			P_IND_Cat_23
			P_IND_Cat_31
			P_IND_Cat_41
			P_IND_Cat_44
			P_IND_Cat_48
			P_IND_Cat_51
			P_IND_Cat_52
			P_IND_Cat_53
			P_IND_Cat_54
			P_IND_Cat_55
			P_IND_Cat_56
			P_IND_Cat_61
			P_IND_Cat_62
			P_IND_Cat_71
			P_IND_Cat_72
			P_IND_Cat_81
			P_IND_Cat_91
			P_IND_Ess_No
			P_IND_Ess_Yes

			/* Use of Y/N Category */
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
			P_OCC_9
			
			P_OCC_Ess_No
			P_OCC_Ess_Yes
			
			
			P_VM_Black
			P_VM_East_Asian
			P_VM_Latin_American
			P_VM_Mult_Oth
			P_VM_Not_Vismin
			P_VM_South_Asian
			P_VM_Southeast_Asian
			P_VM_West_Asian

			P_VM_No
			P_VM_Yes
			
	;
	WITH infection_rate;
	TITLE 'Correlation and Scatter Plot with Infection rate';
RUN;



/*---------------------------------------------------------------------------------------------------------------------
/* CORRELATION FOR multicollineary between all independent variables
/*
*/
ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Charts4.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "Correlation"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "Correlation");
ods graphics on;

PROC CORR DATA=COVID.COVID_NBH_Summary outp=CorrOutp;
 	VAR 	
			/* Insignificant*/
			P_NBH_SH_UNITS
			POP_density
			NIA_IND
			POP_land_area
			POP_population 
			
			/* insignificant  */
			P_AGE1_0_to_14
			P_AGE1_15_to_24
			P_AGE1_25_to_54
			P_AGE1_55_to_64
			P_AGE1_65_to_84
			P_AGE1_85_UP
		
			P_AGE_00_to_19
			P_AGE_20_to_39
			P_AGE_40_to_64
			P_AGE_65_up	

			/* Insignificant */
			P_COMM_Bicycle
			P_COMM_Other
			P_COMM_Public_Transit
			P_COMM_Vehicle_Driver
			P_COMM_Vehicle_Pass
			P_COMM_Walk

			/* Insignificant */
			P_DWEL_Apart
			P_DWEL_Attached
			P_DWEL_Movable
			P_DWEL_SD_House

			P_EDU_College_Trades
			P_EDU_HS_Lower
			P_EDU_University
		
			P_HH_1_Person
			P_HH_2_Persons
			P_HH_3_Persons
			P_HH_4_Persons
			P_HH_5_Persons
			P_HH_Avg_Size
			
			P_IMM_1981_2000
			P_IMM_1Non_Perm_Res
			P_IMM_2001_2016
			P_IMM_Before_1981
			P_IMM_Non_Imm
			P_IMM_Yes
			P_IMM_No
		
			P_INCIND_pop_low_inc
			P_INCIND_Total_Avg
			P_INC_Under_25000
			P_INC_25000_50000
			P_INC_50000_99999
			P_INC_25000_99999
			P_INC_Over_100000

			/* Use of Category 
			P_IND_Cat_11
			P_IND_Cat_21
			P_IND_Cat_22
			P_IND_Cat_23
			P_IND_Cat_31
			P_IND_Cat_41
			P_IND_Cat_44
			P_IND_Cat_48
			P_IND_Cat_51
			P_IND_Cat_52
			P_IND_Cat_53
			P_IND_Cat_54
			P_IND_Cat_55
			P_IND_Cat_56
			P_IND_Cat_61
			P_IND_Cat_62
			P_IND_Cat_71
			P_IND_Cat_72
			P_IND_Cat_81
			P_IND_Cat_91
			P_IND_Ess_No
			P_IND_Ess_Yes*/

			/* Use of Y/N Category */
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
			P_OCC_9
		
			P_OCC_Ess_No
			P_OCC_Ess_Yes
				
			P_VM_Black
			P_VM_East_Asian
			P_VM_Latin_American
			P_VM_Mult_Oth
			P_VM_Not_Vismin
			P_VM_South_Asian
			P_VM_Southeast_Asian
			P_VM_West_Asian

			P_VM_No
			P_VM_Yes

;
RUN;


