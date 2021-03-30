/**********************************************************************************************************************
/* NAME:		STEP2_Data_Clean_COVID
/* DESCRIPTION:	Covid Data Cleaning & Preparation
/* DATE:		Feb 7, 2021
/* AUTHOR:		Marlene Martins
/* NOTES:		Data Preparation for COVID19 
/*				Creation of Neighbourhood reference table 
/* 				
/* INPUT:		COVID.NBH_DEMO_RAW
/* 				COVID.COVID_DATA_RAW
/*			
/* OUTPUT:		COVID.COVID_DATA
/*  
/**********************************************************************************************************************
/* Modifications
/*
/*
/*
/**********************************************************************************************************************/

/*---------------------------------------------------------------------------------------------------------------------
/* Create Neighbourhood table
/* 	Transpose neighbourhood name to number
/*
*/

/* Extract first record from Demographics data */
proc sql;
	create table NBH_data2 as 
		select *
		from covid.NBH_DEMO_RAW
		where _id = 1
		;
quit;

/* Transpose into table format */
proc transpose data=NBH_data2
out=NBH_DATA3
name=neighbourhood_name
prefix=neighbourhood_num;
run;

proc sql;
	create table NBH_DATA4 AS 
		SELECT 
			NEIGHBOURHOOD_NAME,
			NEIGHBOURHOOD_NUM1 AS NEIGHBOURHOOD_ID
		FROM NBH_DATA3
;
QUIT;


/*---------------------------------------------------------------------------------------------------------------------
/* Join to covid data
/* Check to make sure all neighbourhood names have a number
/* 
*/

PROC SQL;
	CREATE TABLE NBH_DATA5 AS
		SELECT 
			C.NEIGHBOURHOOD_NAME 				AS C_NAME,
			SUBSTR(C.NEIGHBOURHOOD_NAME, 1,32) 	AS C_NAME_32,
			B.NEIGHBOURHOOD_NAME 				AS B_NAME,
			B.NEIGHBOURHOOD_ID					AS B_ID
		FROM COVID.COVID_DATA_RAW 	AS C LEFT JOIN 
		     NBH_DATA4 				AS B ON SUBSTR(C.NEIGHBOURHOOD_NAME, 1,32) = B.NEIGHBOURHOOD_NAME
			 ;
QUIT;


/* Show names mismatches without a number */

PROC SQL;
	CREATE TABLE NBH_DATA6 AS	
		SELECT 
			C_NAME,
			C_NAME_32,
			B_NAME,
			B_ID,
			COUNT(*) AS CNTIT
		FROM NBH_DATA5
		WHERE B_ID IS NULL
		GROUP BY 1,2,3,4
	;
QUIT;

/* Clean neighbourhood names in neighbourood table to match those in COVID data*/

PROC SQL;
	CREATE TABLE NBH_DATA7 AS 
		SELECT 
			NEIGHBOURHOOD_ID,
			CASE 
				WHEN NEIGHBOURHOOD_ID = 108 THEN 'Briar Hill - Belgravia' 
				WHEN NEIGHBOURHOOD_ID = 59  THEN 'Danforth-East York' 
				WHEN NEIGHBOURHOOD_ID = 91  THEN 'Weston-Pellam Park'
			ELSE NEIGHBOURHOOD_NAME
			END AS NEIGHBOURHOOD_NAME		
		FROM NBH_DATA4
		ORDER BY NEIGHBOURHOOD_ID
;
QUIT;


/* Test Clean neighbourhood names in new neighbourood table to match those in COVID data*/

PROC SQL;
	CREATE TABLE NBH_DATA8 AS
		SELECT 
			C.NEIGHBOURHOOD_NAME 				AS C_NAME,
			SUBSTR(C.NEIGHBOURHOOD_NAME, 1,32) 	AS C_NAME_32,
			B.NEIGHBOURHOOD_NAME 				AS B_NAME,
			B.NEIGHBOURHOOD_ID					AS B_ID
		FROM COVID.COVID_DATA_RAW 	AS C LEFT JOIN 
		     NBH_DATA7 				AS B ON SUBSTR(C.NEIGHBOURHOOD_NAME, 1,32) = B.NEIGHBOURHOOD_NAME
			 ;
QUIT;


/* Show names mismatches without a number */

PROC SQL;
	CREATE TABLE NBH_DATA9 AS	
		SELECT 
			C_NAME,
			C_NAME_32,
			B_NAME,
			B_ID,
			COUNT(*) AS CNTIT
		FROM NBH_DATA8
		WHERE B_ID IS NULL
		GROUP BY 1,2,3,4
	;
QUIT;


/* Remove _id record and add Unknown = 99 */

PROC SQL;
	CREATE TABLE NBH_DATA8 AS 
		SELECT 
			NEIGHBOURHOOD_NAME AS NEIGHBOURHOOD_NAMEO, 				
			NEIGHBOURHOOD_ID   AS NEIGHBOURHOOD_IDO,
			CASE WHEN NEIGHBOURHOOD_NAME IN ('_id')	THEN 'Unknown' ELSE NEIGHBOURHOOD_NAME END as NEIGHBOURHOOD_NAME,
			CASE WHEN NEIGHBOURHOOD_NAME IN ('_id')	THEN 999 ELSE NEIGHBOURHOOD_ID END as NEIGHBOURHOOD_ID

		/*	CASE WHEN NEIGHBOURHOOD_ID = 0 THEN 'Unknown' ELSE NEIGHBOURHOOD_NAME END AS NEIGHBOURHOOD_NAME*/
		FROM NBH_DATA7 	

			 ;
QUIT;


/*---------------------------------------------------------------------------------------------------------------------
/* Join all neighbourhood data into one reference file
/* 
*/

PROC SQL;
	CREATE TABLE COVID.NBH_INFO AS
		SELECT 
			A.NEIGHBOURHOOD_NAME, 				
			A.NEIGHBOURHOOD_ID,
			CASE WHEN B.NEIGHBOURHOOD_ID IS NULL THEN 0 ELSE 1 		END AS NBH_NIA_IND,
			CASE WHEN C.NEIGHBOURHOOD_ID IS NULL THEN 0 ELSE UNITS  END AS NBH_SH_UNITS,
			CASE WHEN C.NEIGHBOURHOOD_ID IS NULL THEN 0 ELSE RGI   	END AS NBH_SH_RGI
	
		FROM NBH_DATA8 		AS A LEFT JOIN
			 COVID.NBH_NIA_RAW 	AS B ON A.NEIGHBOURHOOD_ID = B.NEIGHBOURHOOD_ID LEFT JOIN
			 COVID.NBH_SH_RAW 	AS C ON A.NEIGHBOURHOOD_ID = input(C.NEIGHBOURHOOD_ID, 8.)			
			 ;
QUIT;

/*---------------------------------------------------------------------------------------------------------------------
/* Clean COVID Data
/*
/* *** Need to run when new data downloaded ***
/*
*/

/* identify missing neighbourhoods as unknown  */
PROC SQL;
	CREATE TABLE COV_DATA1 AS 
		SELECT *,
		CASE WHEN NEIGHBOURHOOD_NAME = ' ' THEN 'Unknown' ELSE NEIGHBOURHOOD_NAME END AS NEIGHBOURHOOD_NAME2
		FROM COVID.COVID_DATA_RAW;
QUIT;


proc contents
data=COV_DATA1 OUT=Aoutdata;
run;


/* Add neighbourhood ID to COVID_DATA */
/* Convert Y/N to counts */

PROC SQL;
	CREATE TABLE COV_DATA2 AS
		SELECT 
 			A.*,
			B.NEIGHBOURHOOD_ID,

			(intnx('week.7',EPISODE_DATE,0,'e')) as EPISODE_WEND 	FORMAT DATE9.,
			(intnx('week.7',EPISODE_DATE,0,'e')) as EPISODE_WEND2 	FORMAT MMDDYY10.,
			(intnx('week.7',EPISODE_DATE,0,'e')) as EPISODE_WEND3 	FORMAT YYMMDD10.,
			(intnx('MONTH',EPISODE_DATE ,0,'E')) AS EPISODE_MEND 	FORMAT DATE9.,
		
			CASE WHEN CURRENTLY_HOSPITALIZED = 'Yes' 								then 1 else 0 end as CUR_HOSPITALIZED,
			CASE WHEN CURRENTLY_IN_icu = 'Yes' 		 								then 1 else 0 end as CUR_IN_ICU,
			CASE WHEN CURRENTLY_INTUBATED = 'Yes' 	 								then 1 else 0 end as CUR_INTUBATED,

			CASE WHEN EVER_HOSPITALIZED = 'Yes' 	 								then 1 else 0 end as TOT_HOSPITALIZED,
			CASE WHEN EVER_IN_icu = 'Yes' 		 	 								then 1 else 0 end as TOT_IN_ICU,
			CASE WHEN EVER_INTUBATED = 'Yes' 	 	 								then 1 else 0 end as TOT_INTUBATED,

			CASE WHEN OUTCOME = 'ACTIVE' 			 								THEN 1 ELSE 0 END AS CASE_ACTIVE,
			CASE WHEN OUTCOME = 'FATAL'  			 								THEN 1 ELSE 0 END AS CASE_FATAL,
			CASE WHEN OUTCOME = 'RESOLVED'  		 								THEN 1 ELSE 0 END AS CASE_RESOLVED,
			CASE WHEN OUTBREAK_ASSOCIATED = 'Outbreak Associated' 					THEN 1 ELSE 0 END AS INFECT_OUTBREAK,

			CASE WHEN SOURCE_OF_INFECTION = 'Close Contact' 						THEN 1 ELSE 0 END AS INFECT_CLOSE_CONT,
			CASE WHEN SOURCE_OF_INFECTION = 'Outbreaks, Congregate Settings' 		THEN 1 ELSE 0 END AS INFECT_OB_CONGR,
			CASE WHEN SOURCE_OF_INFECTION = 'Outbreaks, Healthcare Institutions' 	THEN 1 ELSE 0 END AS INFECT_OB_HEALTH,
			CASE WHEN SOURCE_OF_INFECTION = 'Outbreaks, Other Settings' 			THEN 1 ELSE 0 END AS INFECT_OB_OTHER,
			CASE WHEN SOURCE_OF_INFECTION contains 'Community' 						THEN 1 ELSE 0 END AS INFECT_COMMUNITY,
			CASE WHEN SOURCE_OF_INFECTION = 'No Information'						THEN 1 ELSE 0 END AS INFECT_NO_INFO,
			CASE WHEN SOURCE_OF_INFECTION contains 'Travel' 						THEN 1 ELSE 0 END AS INFECT_TRAVEL,
			CASE WHEN SOURCE_OF_INFECTION contains 'Pending' 						THEN 1 ELSE 0 END AS INFECT_PENDING
	
		FROM COV_DATA1   	AS A left join
		     COVID.NBH_INFO AS B ON SUBSTR(A.NEIGHBOURHOOD_NAME2, 1,32) = B.NEIGHBOURHOOD_NAME
	;
QUIT;
	

/* Create final COVID Data file */

PROC SQL;
	CREATE TABLE COVID.COVID_DATA AS 
		SELECT 
			neighbourhood_id,
			neighbourhood_name2 as neighbourhood_name,
			assigned_id,
			age_group,
			case_active + case_fatal + case_resolved as case_count,
			case_active,
			case_fatal,
			case_resolved,
			client_gender,
			cur_hospitalized,
			cur_in_icu,
			cur_intubated,
			TOT_hospitalized,
			TOT_in_icu,
			TOT_intubated,
			episode_date,
			episode_mend,
			episode_wend,
			episode_wend2,
			episode_wend3,
			fsa,
			reported_date,
			INFECT_CLOSE_CONT,
			INFECT_OB_CONGR,
			INFECT_OB_HEALTH,
			INFECT_OB_OTHER,
			INFECT_NO_INFO,
			INFECT_COMMUNITY,
			INFECT_TRAVEL,
			INFECT_PENDING
		FROM COV_DATA2
;
QUIT;

proc contents
data=COVID.COVID_DATA OUT=Aoutdata;
run;


