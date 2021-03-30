/**********************************************************************************************************************
/* NAME:		STEP4_DATA_Files
/* DESCRIPTION:	Create required files for analysis
/* DATE:		Feb 7, 2021
/* AUTHOR:		Marlene Martins
/* NOTES:		DATA Preparation Neighbourhood demographics DATA 
/*				Creation of Clean Neighbourhood demographics DATA 
/* 				
/* INPUT:		COVID.COVID_DATA			
/*				COVID.DEMOGRAPHICS
/*
/* OUTPUT:		COVID.COVID_SUMMARY_Date	
/*				COVID.COVID_NBH_Summary
/*				COVID.COVID_NBH_HIGH
/*				COVID.COVID_NBH_LOW	
/*  
/**********************************************************************************************************************
/* Modifications
/*
/*
/*
/**********************************************************************************************************************/



/*---------------------------------------------------------------------------------------------------------------------
/* Summarize COVID data by Episode_Date: Seven Day rolling average & Cumulative case counts
/*---------------------------------------------------------------------------------------------------------------------


/* 	Summarize COVID data by Episode Date*/

PROC SQL;
	CREATE TABLE DATA1 AS	
		SELECT 
			EPISODE_Date,
			sum(TOT_hospitalized)  	as TOT_HOSPITALIZED,
			sum(TOT_in_icu)			AS TOT_IN_ICU,
			sum(TOT_intubated)		AS TOT_INTUBATED,
			SUM(CASE_ACTIVE) 		AS ACTIVE_CASES,
			SUM(CASE_FATAL) 		AS FATAL_CASES,
			SUM(CASE_RESOLVED) 		AS RESOLVED_CASES,
			SUM(case_count)			AS TOTAL_CASES,
			SUM(INFECT_CLOSE_CONT)	AS INFECT_CLOSE_CONT,
			SUM(INFECT_OB_CONGR)	AS INFECT_OB_CONGR,
			SUM(INFECT_OB_HEALTH)	AS INFECT_OB_HEALTH,
			SUM(INFECT_OB_OTHER)	AS INFECT_OB_OTHER,
			SUM(INFECT_NO_INFO)		AS INFECT_NO_INFO,
			SUM(INFECT_COMMUNITY)	AS INFECT_COMMUNITY,
			SUM(INFECT_TRAVEL)		AS INFECT_TRAVEL,
			SUM(INFECT_PENDING)		AS INFECT_PENDING

		FROM COVID.COVID_DATA
		GROUP BY 1
		ORDER BY 1
		;
QUIT;


/* create CUMULATIVE TOTAL moving average  */

DATA DATA2;
	SET DATA1;
   	RETAIN cumulative_cases;
 	IF _n_ = 1 THEN cumulative_cases = total_cases;
	ELSE cumulative_cases = cumulative_cases + total_cases;
RUN;

/* create SEVEN DAY  moving average  */

PROC EXPAND DATA=DATA2 OUT=COVID.COVID_SUMMARY_DATE method=none;
   ID episode_date;
   CONVERT total_cases = AVG_7_DAY_ROL  / transout=(movave 7);
	 /*  convert total_cases = WMA  / transout=(movave(1 2 3 4 5 6 7)); */
	 /*  convert total_cases = EWMA / transout=(ewma 0.3);*/
RUN;


/* PLOT SEVEN DAY  moving average curves */

TITLE 'Total Cases 7 day rolling avg';
proc sgplot data=COVID.COVID_SUMMARY_Date cycleattrs;
   series x=episode_date y=AVG_7_DAY_ROL / name='MA'   legendlabel="MA(7)";
  /* series x=episode_date y=WMA  / name='WMA'  legendlabel="WMA(1,2,3,4,5,6,7)";*/
  /* series x=episode_date y=EWMA / name='EWMA' legendlabel="EWMA(0.3)";*/
   scatter x=episode_date y=total_cases;
   keylegend 'MA' 'WMA' 'EWMA';
   xaxis display=(nolabel) grid;
   yaxis label="total cases" grid;
run;


/*---------------------------------------------------------------------------------------------------------------------
/* Neighbourhood Summary File
/*
/* COVID.COVID_NBH_Summary
/*---------------------------------------------------------------------------------------------------------------------

/*---------------------------------------------------------------------------------------------------------------------
/* Join Covid Data to Neighbourhood Demographics Data 
/*  	Calculate Infection rate  
/* 		remove cases with missing neighbourhood id
*/

PROC SQL;
	CREATE TABLE COVID_Summary1 AS	
		SELECT 
			NEIGHBOURHOOD_ID,
			NEIGHBOURHOOD_NAME,
			sum(TOT_hospitalized)  	as TOT_HOSPITALIZED,
			sum(TOT_in_icu)			AS TOT_IN_ICU,
			sum(TOT_intubated)		AS TOT_INTUBATED,
			SUM(CASE_ACTIVE) 		AS ACTIVE_CASES,
			SUM(CASE_FATAL) 		AS FATAL_CASES,
			SUM(CASE_RESOLVED) 		AS RESOLVED_CASES,
			SUM(case_count)			AS TOTAL_CASES,
			SUM(INFECT_CLOSE_CONT)	AS INFECT_CLOSE_CONT,
			SUM(INFECT_OB_CONGR)	AS INFECT_OB_CONGR,
			SUM(INFECT_OB_HEALTH)	AS INFECT_OB_HEALTH,
			SUM(INFECT_OB_OTHER)	AS INFECT_OB_OTHER,
			SUM(INFECT_NO_INFO)		AS INFECT_NO_INFO,
			SUM(INFECT_COMMUNITY)	AS INFECT_COMMUNITY,
			SUM(INFECT_TRAVEL)		AS INFECT_TRAVEL,
			SUM(INFECT_PENDING)		AS INFECT_PENDING
		FROM COVID.COVID_DATA
		where neighbourhood_id NE  999
		GROUP BY 1,2
		;
QUIT;

/* 	add percentage of total cases */
proc sql;
	create table COVID.COVID_Summary2 AS	
		SELECT 
			*,
			FATAL_CASES/TOTAL_CASES			AS P_FATALITY_RATE,
			TOT_hospitalized/TOTAL_CASES	AS P_Hospital_RATE,
			TOT_in_icu/TOTAL_CASES			AS P_ICU_RATE,
			INFECT_CLOSE_CONT/TOTAL_CASES 	AS P_INFECT_CLOSE_CONT,
			INFECT_OB_CONGR /TOTAL_CASES 	AS P_INFECT_OB_CONGR,
			INFECT_OB_HEALTH/TOTAL_CASES 	AS P_INFECT_OB_HEALTH,
			INFECT_OB_OTHER/TOTAL_CASES 	AS P_INFECT_OB_OTHER,
			INFECT_NO_INFO/TOTAL_CASES 		AS P_INFECT_NO_INFO,
		 	INFECT_COMMUNITY/TOTAL_CASES 	AS P_INFECT_COMMUNITY,
		 	INFECT_TRAVEL/TOTAL_CASES 		AS P_INFECT_TRAVEL,
			INFECT_PENDING/TOTAL_CASES 		AS P_INFECT_PENDING
		FROM COVID_Summary1

		;
QUIT;


/* 	Create final file  with infection rate */
PROC SQL;
 	CREATE TABLE COVID.COVID_NBH_Summary AS 
		SELECT 
			A.*,
			B.*,
			TOTAL_CASES/POP_POPULATION AS INFECTION_RATE format comma5.3
		FROM COVID.COVID_Summary2 AS A LEFT JOIN
		     COVID.DEMOGRAPHICS AS B ON A.NEIGHBOURHOOD_ID = B.NEIGHBOURHOOD_ID
			ORDER BY A.NEIGHBOURHOOD_ID;
QUIT;

 


/* 	Create final file  with infection rate - outliers */
PROC SQL;
 	CREATE TABLE COVID.COVID_NBH_SummaryO AS 
		SELECT 
			A.*,
			B.*,
			TOTAL_CASES/POP_POPULATION AS INFECTION_RATE format comma5.3
		FROM COVID.COVID_Summary2 AS A LEFT JOIN
		     COVID.DEMOGRAPHICS AS B ON A.NEIGHBOURHOOD_ID = B.NEIGHBOURHOOD_ID
		where a.neighbourhood_id not in (73,113,125)
			ORDER BY A.NEIGHBOURHOOD_ID;
QUIT;

/*---------------------------------------------------------------------------------------------------------------------
/* Determine deciles based on infection_rate
/*  	
/*

/*
proc univariate data =COVID.COVID_NBH_Summary;
var infection_rate;
output out=anyname pctlpts = 10 to 100 by 10 pctlpre = inc;
run;
*/

/*---------------------------------------------------------------------------------------------------------------------
/* Split Neighbourhood Summary file into deciles
*/

PROC RANK DATA=Covid.COVID_NBH_Summary groups=10 descending out=ranked;
VAR infection_rate;
RANKS decile;
run;

/* Create file with highest decile of infection_rates	*/
proc sql;
	create table COVID.COVID_NBH_HIGH as 
		select neighbourhood_id
		from ranked 
		where decile = 0;
quit;

/* Create file with lowest decile of infection_rates	*/
proc sql;
	create table COVID.COVID_NBH_LOW as 
		select neighbourhood_id
		from ranked 
		where decile = 9;
quit;




/*---------------------------------------------------------------------------------------------------------------------
/* OTHER: NOT NEEDED ?
/*---------------------------------------------------------------------------------------------------------------------
/* Summarize data by neighbourhood by WEND date 
/* 	remove casese with missing neighbourhood id's
/* 	not needed ?
*/

proc sql;
	create table COVID.COVID_SUMMARY  AS	
		SELECT 
			EPISODE_WEND,
			NEIGHBOURHOOD_ID,
			NEIGHBOURHOOD_NAME,
			AGE_GROUP,
			sum(TOT_hospitalized)  	as TOT_HOSPITALIZED,
			sum(TOT_in_icu)			AS TOT_IN_ICU,
			sum(TOT_intubated)		AS TOT_INTUBATED,
			SUM(CASE_ACTIVE) 		AS ACTIVE_CASES,
			SUM(CASE_FATAL) 		AS FATAL_CASES,
			SUM(CASE_RESOLVED) 		AS RESOLVED_CASES,
			SUM(case_count)			AS TOTAL_CASES,
			SUM(INFECT_CLOSE_CONT)	AS INFECT_CLOSE_CONT,
			SUM(INFECT_OB_CONGR)	AS INFECT_OB_CONGR,
			SUM(INFECT_OB_HEALTH)	AS INFECT_OB_HEALTH,
			SUM(INFECT_OB_OTHER)	AS INFECT_OB_OTHER,
			SUM(INFECT_NO_INFO)		AS INFECT_NO_INFO,
			SUM(INFECT_COMMUNITY)	AS INFECT_COMMUNITY,
			SUM(INFECT_TRAVEL)		AS INFECT_TRAVEL,
			SUM(INFECT_PENDING)		AS INFECT_PENDING
		FROM COVID.COVID_DATA 
		where neighbourhood_id NE  999
		GROUP BY 1,2,3,4
		;
QUIT;


/*---------------------------------------------------------------------------------------------------------------------
/* Summarize data by neighbourhood by WEND episode date, neighbourhood ID
/*  join to Neighbourhood Data
*/

proc sql;
	create table COVID.COVID_SUMMARY2 AS	
		SELECT 
			EPISODE_WEND,
			A.NEIGHBOURHOOD_ID,
			A.NEIGHBOURHOOD_NAME,
			POP_POPULATION,
			sum(TOT_hospitalized)  	as TOT_HOSPITALIZED,
			sum(TOT_in_icu)			AS TOT_IN_ICU,
			sum(TOT_intubated)		AS TOT_INTUBATED,
			SUM(CASE_ACTIVE) 		AS ACTIVE_CASES,
			SUM(CASE_FATAL) 		AS FATAL_CASES,
			SUM(CASE_RESOLVED) 		AS RESOLVED_CASES,
			SUM(case_count)			AS TOTAL_CASES,
			SUM(INFECT_CLOSE_CONT)	AS INFECT_CLOSE_CONT,
			SUM(INFECT_OB_CONGR)	AS INFECT_OB_CONGR,
			SUM(INFECT_OB_HEALTH)	AS INFECT_OB_HEALTH,
			SUM(INFECT_OB_OTHER)	AS INFECT_OB_OTHER,
			SUM(INFECT_NO_INFO)		AS INFECT_NO_INFO,
			SUM(INFECT_COMMUNITY)	AS INFECT_COMMUNITY,
			SUM(INFECT_TRAVEL)		AS INFECT_TRAVEL,
			SUM(INFECT_PENDING)		AS INFECT_PENDING
			
		FROM COVID.COVID_DATA as a left join 
		     COVID.DEMOGRAPHICS AS B ON A.NEIGHBOURHOOD_ID = B.NEIGHBOURHOOD_ID
		where A.neighbourhood_id NE  999
		GROUP BY 1,2,3,4

		;
QUIT;

/*---------------------------------------------------------------------------------------------------------------------
/* Determine Deciles
/*---------------------------------------------------------------------------------------------------------------------
/* Summarize data by neighbourhood by WEND date 
/*  - determine infection_rate
*/
proc sql;
	create table COVID.COVID_SUMMARY3 AS	
		SELECT 
			EPISODE_WEND,
			NEIGHBOURHOOD_ID,
			NEIGHBOURHOOD_NAME,
			POP_POPULATION,
			TOTAL_CASES,
			TOTAL_CASES/POP_POPULATION AS INFECTION_RATE format comma10.8		
		FROM COVID.COVID_SUMMARY2
	
		;
QUIT;


/* Split Neighbourhood Summary file into deciles */
/* Retrieve decile with highest infection rates	*/

proc sql;
	create table COVID.COVID_NBH_WEND_HIGH as 
		select *
		from COVID.COVID_SUMMARY3 
		WHERE NEIGHBOURHOOD_ID IN (SELECT NEIGHBOURHOOD_ID FROM COVID.COVID_NBH_HIGH) 
;
quit;


proc sql;
	create table COVID.COVID_NBH_WEND_LOW as 
		select *
		from COVID.COVID_SUMMARY3 
		WHERE NEIGHBOURHOOD_ID IN (SELECT NEIGHBOURHOOD_ID FROM COVID.COVID_NBH_low) 
;
quit;


/*---------------------------------------------------------------------------------------------------------------------
/* Summarize data by neighbourhood by WEND date 
/* 	remove casese with missing neighbourhood id's
/* 	not needed ?
*/

proc sql;
	create table COVID.COVID_SUMMARY_NBH_Date  AS	
		SELECT 
			EPISODE_date,
			episode_wend,
			NEIGHBOURHOOD_ID,
			NEIGHBOURHOOD_NAME,
			sum(TOT_hospitalized)  	as TOT_HOSPITALIZED,
			sum(TOT_in_icu)			AS TOT_IN_ICU,
			sum(TOT_intubated)		AS TOT_INTUBATED,
			SUM(CASE_ACTIVE) 		AS ACTIVE_CASES,
			SUM(CASE_FATAL) 		AS FATAL_CASES,
			SUM(CASE_RESOLVED) 		AS RESOLVED_CASES,
			SUM(case_count)			AS TOTAL_CASES,
			SUM(INFECT_CLOSE_CONT)	AS INFECT_CLOSE_CONT,
			SUM(INFECT_OB_CONGR)	AS INFECT_OB_CONGR,
			SUM(INFECT_OB_HEALTH)	AS INFECT_OB_HEALTH,
			SUM(INFECT_OB_OTHER)	AS INFECT_OB_OTHER,
			SUM(INFECT_NO_INFO)		AS INFECT_NO_INFO,
			SUM(INFECT_COMMUNITY)	AS INFECT_COMMUNITY,
			SUM(INFECT_TRAVEL)		AS INFECT_TRAVEL,
			SUM(INFECT_PENDING)		AS INFECT_PENDING
		FROM COVID.COVID_DATA 
		where neighbourhood_id NE  999
		GROUP BY 1,2,3,4
		;
QUIT;

/* 	test outliers */
PROC SQL;
 	CREATE TABLE testit as  
		SELECT 
			neighbourhood_id,
			neighbourhood_name,
			P_AGE_40_to_64,
			P_EDU_HS_Lower,
			P_HH_5_Persons,
			P_IMM_Yes,
			P_OCC_Ess_Yes,
			P_VM_Yes,
			infection_rate,
			total_cases,
			pop_population,
			pop_density,
			pop_land_area
			from Covid.COVID_NBH_Summary
		/*where a.neighbourhood_id not in (73,113,125)*/
			ORDER BY NEIGHBOURHOOD_ID;
QUIT;