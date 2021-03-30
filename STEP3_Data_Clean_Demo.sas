/**********************************************************************************************************************
/* NAME:		STEP3_DATA_Clean_Demo
/* DESCRIPTION:	Neighbourhood Demographic DATA Cleaning & Preparation
/* DATE:		Feb 7, 2021
/* AUTHOR:		Marlene Martins
/* NOTES:		DATA Preparation Neighbourhood demographics DATA 
/*				Creation of Clean Neighbourhood demographics DATA 
/* 				
/* INPUT:		COVID.NBH_DEMO_RAW			
/*			
/* OUTPUT:		COVID.DEMOGRAPHICS
/*  
/**********************************************************************************************************************
/* Modifications
/*
/*
/*
/**********************************************************************************************************************/


/*---------------------------------------------------------------------------------------------------------------------
/* CREATE Household Income TABLE
/* Categories:
/*		Under $5,000
/*		$5,000 to $9,999
/*		$10,000 to $14,999
/*		$15,000 to $19,999
/*		$20,000 to $24,999
/*		$25,000 to $29,999
/*		$30,000 to $34,999
/*		$35,000 to $39,999
/*		$40,000 to $44,999
/*		$45,000 to $49,999
/*		$50,000 to $59,999
/*		$60,000 to $69,999
/*		$70,000 to $79,999
/*		$80,000 to $89,999
/*		$90,000 to $99,999
/*		$100,000 to $124,999
/*		$125,000 to $149,999
/*		$150,000 to $199,999
/*		$200,000 and over
*/


/* Extract income DATA*/

PROC SQL;
	CREATE TABLE demo_income1 AS 
		SELECT *
		FROM COVID.NBH_DEMO_RAW	
        where category = 'Income' 
		   OR CATEGORY = 'Neighbourhood Information'
		;
QUIT;


/* Rename rows to become column headings */

PROC SQL;
	CREATE TABLE demo_income2 AS 
		SELECT *,
			CASE 
				WHEN characteristic = 'Under $5,000' 				THEN 'Inc_5000' 
				WHEN characteristic = '$5,000 to $9,999' 			THEN 'Inc_5000_9999' 
				WHEN characteristic = '$10,000 to $14,999' 			THEN 'Inc_10000_14999' 
				WHEN characteristic = '$15,000 to $19,999' 			THEN 'Inc_15000_19999' 
				WHEN characteristic = '$20,000 to $24,999' 			THEN 'Inc_20000_24999' 
				WHEN characteristic = '$25,000 to $29,999' 			THEN 'Inc_25000_29999' 
				WHEN characteristic = '$30,000 to $34,999' 			THEN 'Inc_30000_34999' 
				WHEN characteristic = '$35,000 to $39,999' 			THEN 'Inc_35000_39999' 
				WHEN characteristic = '$40,000 to $44,999' 			THEN 'Inc_40000_44999' 
				WHEN characteristic = '$45,000 to $49,999' 			THEN 'Inc_45000_49999' 
				WHEN characteristic = '$50,000 to $59,999' 			THEN 'Inc_50000_59999' 
				WHEN characteristic = '$60,000 to $69,999' 			THEN 'Inc_60000_69999' 
				WHEN characteristic = '$70,000 to $79,999' 			THEN 'Inc_70000_79999' 
				WHEN characteristic = '$80,000 to $89,999' 			THEN 'Inc_80000_89999' 
				WHEN characteristic = '$90,000 to $99,999' 			THEN 'Inc_90000_99999' 
				WHEN characteristic = '$100,000 to $124,999' 		THEN 'Inc_100000_124999' 
				WHEN characteristic = '$125,000 to $149,999' 		THEN 'Inc_125000_149999' 
				WHEN characteristic = '$150,000 to $199,999' 		THEN 'Inc_150000_199999' 
				WHEN characteristic = '$200,000 and over' 			THEN 'Inc_200000' 
				WHEN characteristic = 'Total income Average amount' THEN 'P_INCIND_Total_Avg'
				WHEN characteristic = 'Income statistics Total Population aged 15 years and over' 							THEN 'INCIND_Population_15up'
				WHEN characteristic = 'Total income Population with an amount' 					  							THEN 'INCIND_Pop_with_amount'
				WHEN characteristic = 'In low income based on the Low-income cut-offs, after tax (LICO-AT)' 				THEN 'INCIND_pop_low_inc' 
				WHEN characteristic = 'Prevalence of low income based on the Low-income cut-offs, after tax (LICO-AT) (%)' 	THEN 'P_INCIND_pop_low_inc' 

				WHEN characteristic = 'Neighbourhood Number'    THEN 'Neighbourhood_ID'
			END AS characteristic2
		FROM demo_income1
;
QUIT;

/* DROP unnecessary fields */
DATA demo_income3;
	SET demo_income2(DROP= _ID category topic DATA_source);
RUN;


/* Transpose DATA */

PROC TRANSPOSE DATA=demo_income3
	OUT=demo_income4
	NAME=NEIGHBOURHOOD_NAME;
	ID Characteristic2;
RUN;


/* save final file */

DATA demo_income5;
	SET demo_income4(DROP= _label_ NEIGHBOURHOOD_NAME);
/*DEMO_CAT = 'HH_INCOME';
attrib DEMO_CAT format=$20.;*/
RUN;

PROC CONTENTS 
	DATA=demo_income5 OUT=DATAOUT;
RUN;

		
/* consolIDate groups and save final file */

PROC SQL;
	CREATE TABLE COVID.DEMO_HH_INCOME AS 
		SELECT
			Neighbourhood_ID,
			(Inc_5000 + Inc_5000_9999 + Inc_10000_14999 + Inc_15000_19999 + Inc_20000_24999) 			AS INCHH_Under_25000,
			(Inc_25000_29999 + Inc_30000_34999 + Inc_35000_39999 + Inc_40000_44999 + Inc_45000_49999)   AS INCHH_25000_50000,
			(Inc_50000_59999 + Inc_60000_69999 + Inc_70000_79999 + Inc_80000_89999 + Inc_90000_99999) 	AS INCHH_50000_99999,
			(Inc_100000_124999 + Inc_125000_149999 + Inc_150000_199999 + Inc_200000) 			        AS INCHH_Over_100000,
			(Inc_25000_29999 + Inc_30000_34999 + Inc_35000_39999 + Inc_40000_44999 + Inc_45000_49999 +   
			 Inc_50000_59999 + Inc_60000_69999 + Inc_70000_79999 + Inc_80000_89999 + Inc_90000_99999) 	AS INCHH_25000_99999,

			INCIND_Pop_with_amount,
			INCIND_Population_15up,
			P_INCIND_Total_Avg,
			INCIND_pop_low_inc,
			P_INCIND_pop_low_inc
		FROM demo_income5
;
QUIT;


/* list DATA info*/

PROC CONTENTS
	DATA=COVID.DEMO_HH_INCOME OUT=AOUTDATA;
RUN;

/*---------------------------------------------------------------------------------------------------------------------
/* CREATE Household/dwelling Characteristics
/* Household numbers
/* Categories:
/*			1 person
/*			2 persons
/*			3 persons
/*			4 persons
/*			5 or more persons
/*			Average household size
*/

/* Extract household DATA*/

PROC SQL;
	CREATE TABLE demo_HH_num1 AS 
		SELECT *
		FROM COVID.NBH_DEMO_RAW	
        where (category = 'Families, households and marital status' and Topic = 'Household and dwelling characteristics')
		   OR CATEGORY = 'Neighbourhood Information'
		;
QUIT;


/* Rename rows to become column headings */

PROC SQL;
	CREATE TABLE demo_HH_num2 AS 
		SELECT *,
			CASE 
				WHEN characteristic = '1 person' 							 THEN 'HH_1_Person' 
				WHEN characteristic = '2 persons' 							 THEN 'HH_2_Persons' 
				WHEN characteristic = '3 persons' 							 THEN 'HH_3_Persons' 
				WHEN characteristic = '4 persons' 							 THEN 'HH_4_Persons' 
				WHEN characteristic = '5 or more persons' 					 THEN 'HH_5_Persons' 
				WHEN characteristic = 'Average household size' 				 THEN 'P_HH_Avg_Size' 
				WHEN characteristic = 'Private households by household size' THEN 'HH_Tot'
				WHEN characteristic = 'Neighbourhood Number'    			 THEN 'Neighbourhood_ID'
			END AS characteristic2

		FROM demo_HH_num1
;
QUIT;


DATA demo_HH_num3;
	SET demo_HH_num2(DROP= _ID category Topic DATA_source);
RUN;


/* Transpose DATA */

PROC transpose DATA=demo_HH_num3
	OUT=demo_HH_num4
	NAME=NEIGHBOURHOOD_NAME;
	ID Characteristic2;
RUN;


/* save final file */

DATA COVID.DEMO_HH_NUM;
	SET demo_HH_num4(DROP= _label_ NEIGHBOURHOOD_NAME);
	/*DEMO_CAT = 'HH_NUMBERS';
	attrib DEMO_CAT format=$20.;
	attrib HH_Avg format=8.1;
	*/
RUN;

/* list DATA info*/

PROC CONTENTS
	DATA=COVID.DEMO_HH_NUM OUT=AOUTDATA;
RUN;



/*---------------------------------------------------------------------------------------------------------------------
/* CREATE Household/dwelling Type
/* Household numbers
/* Categories:
/*			Neighbourhood Number
/*			Single-detached house
/*			Apartment in a building that hAS five or more storeys
/*			Other attached dwelling
/*			Movable dwelling
*/

/* Extract household DATA*/

PROC SQL;
	CREATE TABLE demo_HH_dwel1 AS 
		SELECT *
		FROM COVID.NBH_DEMO_RAW	
        where (category = 'Families, households and marital status' and Topic = 'Household and dwelling characteristics2')
		   OR CATEGORY = 'Neighbourhood Information'
		;
QUIT;


/* Rename rows to become column headings */

PROC SQL;
	CREATE TABLE demo_HH_dwel2 AS 
		SELECT *,
			CASE 
				WHEN characteristic = 'Single-detached house' 									THEN 'DWEL_SD_House' 
				WHEN characteristic = 'Apartment in a building that has five or more storeys' 	THEN 'DWEL_Apart' 
				WHEN characteristic = 'Other attached dwelling' 								THEN 'DWEL_Attached' 
				WHEN characteristic = 'Movable dwelling' 										THEN 'DWEL_Movable' 
				WHEN characteristic = 'Neighbourhood Number'    								THEN 'Neighbourhood_ID'
			END AS characteristic2

		FROM demo_HH_dwel1
;
QUIT;


DATA demo_HH_dwel3;
	SET demo_HH_dwel2(DROP= _ID category Topic DATA_source);
RUN;


/* Transpose DATA */

PROC transpose DATA=demo_HH_dwel3
	OUT=demo_HH_dwel4
	NAME=NEIGHBOURHOOD_NAME;
	ID Characteristic2;
RUN;


/* save final file */

DATA COVID.DEMO_HH_DWELLING;
	SET demo_HH_dwel4(DROP= _label_ NEIGHBOURHOOD_NAME);
/*
DEMO_CAT = 'HH_DWELLING';
attrib DEMO_CAT format=$20.;
*/
RUN;


/* list DATA info*/

PROC CONTENTS
	DATA=COVID.DEMO_HH_DWELLING OUT=AOUTDATA;
RUN;



/*---------------------------------------------------------------------------------------------------------------------
/* CREATE Populatio Categories 1 TABLE
/* Categories:
/*		Children (0-14 years)
/*		YOUTh (15-24 years)
/*		Working Age (25-54 years)
/*		Pre-retirement (55-64 years)
/*		Seniors (65+ years)
/*		Older Seniors (85+ years)
*/

/* Extract income DATA*/

PROC SQL;
	CREATE TABLE demo_popcat1 AS 
		SELECT *
		FROM COVID.NBH_DEMO_RAW	
        where (category = 'Population' 
		  and characteristic in ('Children (0-14 years)','Youth (15-24 years)','Working Age (25-54 years)',
								 'Pre-retirement (55-64 years)','Seniors (65+ years)','Older Seniors (85+ years)')
		   OR CATEGORY = 'Neighbourhood Information')

		;
QUIT;


/* Rename rows to become column headings */

PROC SQL;
	CREATE TABLE demo_popcat2 AS 
		SELECT *,
			CASE 
				WHEN characteristic = 'Children (0-14 years)' 			THEN 'AGE1_0_to_14' 
				WHEN characteristic = 'Youth (15-24 years)' 			THEN 'AGE1_15_to_24' 
				WHEN characteristic = 'Working Age (25-54 years)' 		THEN 'AGE1_25_to_54' 
				WHEN characteristic = 'Pre-retirement (55-64 years)' 	THEN 'AGE1_55_to_64' 
				WHEN characteristic = 'Seniors (65+ years)' 			THEN 'AGE1_65_to_84' 
				WHEN characteristic = 'Older Seniors (85+ years)' 		THEN 'AGE1_85_up' 
				WHEN characteristic = 'Neighbourhood Number'    		THEN 'Neighbourhood_ID'
			END AS characteristic2

		FROM demo_popcat1
;
QUIT;


DATA demo_popcat3;
	SET demo_popcat2(DROP= _ID category topic DATA_source);
RUN;


/* Transpose DATA */

PROC transpose DATA=demo_popcat3
	OUT=demo_popcat4
	NAME=NEIGHBOURHOOD_NAME;
	ID Characteristic2;
RUN;


/* save final file */

DATA COVID.DEMO_AGE_Cat1;
	SET demo_popcat4(DROP= _label_ NEIGHBOURHOOD_NAME);
	/*
	DEMO_CAT = 'AGE_CAT1';
	attrib DEMO_CAT format=$20.;
	*/
RUN;

/* list DATA info*/

PROC CONTENTS
	DATA=COVID.DEMO_AGE_Cat1 OUT=AOUTDATA;
RUN;



/*---------------------------------------------------------------------------------------------------------------------
/* CREATE Populatio Categories 1 TABLE
/* Categories:
/*	
			Male 0 to 04 years
			Male 05 to 09 years
			Male 10 to 14 years
			Male 15 to 19 years
			Male 20 to 24 years
			Male 25 to 29 years
			Male 30 to 34 years
			Male 35 to 39 years
			Male 40 to 44 years
			Male 45 to 49 years
			Male 50 to 54 years
			Male 55 to 59 years
			Male 60 to 64 years
			Male 65 to 69 years
			Male 70 to 74 years
			Male 75 to 79 years
			Male 80 to 84 years
			Male 85 to 89 years
			Male 90 to 94 years
			Male 95 to 99 years
			Male 100 years and over
			Female0 to 04 years
			Female05 to 09 years
			Female10 to 14 years
			Female15 to 19 years
			Female20 to 24 years
			Female25 to 29 years
			Female30 to 34 years
			Female35 to 39 years
			Female40 to 44 years
			Female45 to 49 years
			Female50 to 54 years
			Female55 to 59 years
			Female60 to 64 years
			Female65 to 69 years
			Female70 to 74 years
			Female75 to 79 years
			Female80 to 84 years
			Female85 to 89 years
			Female90 to 94 years
			Female95 to 99 years
			Female100 years and over
*/
/* 			silent generation 74-91
/* 			baby boomers 55-73
/* 			generation X 39-54
/* 		    millenials 23-38
/*			generation z 7-22
/*  	
/* 			SCHOOL AGE 0-19
/* 			Working 20-39
/* 			Working 40-64
/* 			seniors 65+

/* Extract population DATA*/


PROC SQL;
	CREATE TABLE demo_popcat21 AS 
		SELECT *
		FROM COVID.NBH_DEMO_RAW	
        where (category = 'Population' and characteristic contains ('Male')
           OR  category = 'Population' and characteristic contains ('Female'))
		   OR CATEGORY = 'Neighbourhood Information'

		;
QUIT;

PROC CONTENTS
	DATA=demo_popcat2	 OUT=AOUTDATA;
RUN;


/* Rename rows to become column headings */

PROC SQL;
	CREATE TABLE demo_popcat22 AS 
		SELECT *,
			CASE 
				WHEN characteristic = 'Male 0 to 04 years'					THEN 'AGEM_00_to_04'
				WHEN characteristic = 'Male 05 to 09 years'					THEN 'AGEM_05_to_09'
				WHEN characteristic = 'Male 10 to 14 years'					THEN 'AGEM_10_to_14'
				WHEN characteristic = 'Male 15 to 19 years'					THEN 'AGEM_15_to_19'
				WHEN characteristic = 'Male 20 to 24 years'					THEN 'AGEM_20_to_24'
				WHEN characteristic = 'Male 25 to 29 years'					THEN 'AGEM_25_to_29'
				WHEN characteristic = 'Male 30 to 34 years'					THEN 'AGEM_30_to_34'
				WHEN characteristic = 'Male 35 to 39 years'					THEN 'AGEM_35_to_39'
				WHEN characteristic = 'Male 40 to 44 years'					THEN 'AGEM_40_to_44'
				WHEN characteristic = 'Male 45 to 49 years'					THEN 'AGEM_45_to_49'
				WHEN characteristic = 'Male 50 to 54 years'					THEN 'AGEM_50_to_54'
				WHEN characteristic = 'Male 55 to 59 years'					THEN 'AGEM_55_to_59'
				WHEN characteristic = 'Male 60 to 64 years'					THEN 'AGEM_60_to_64'
				WHEN characteristic = 'Male 65 to 69 years'					THEN 'AGEM_65_to_69'
				WHEN characteristic = 'Male 70 to 74 years'					THEN 'AGEM_70_to_74'
				WHEN characteristic = 'Male 75 to 79 years'					THEN 'AGEM_75_to_79'
				WHEN characteristic = 'Male 80 to 84 years'					THEN 'AGEM_80_to_84'
				WHEN characteristic = 'Male 85 to 89 years'					THEN 'AGEM_85_to_89'
				WHEN characteristic = 'Male 90 to 94 years'					THEN 'AGEM_90_to_94'
				WHEN characteristic = 'Male 95 to 99 years'					THEN 'AGEM_95_to_99'
				WHEN characteristic = 'Male 100 years and over'				THEN 'AGEM_100_up'
				WHEN characteristic = 'Female 0 to 04 years'				THEN 'AGEF_00_to_04'
				WHEN characteristic = 'Female 05 to 09 years'				THEN 'AGEF_05_to_09'
				WHEN characteristic = 'Female 10 to 14 years'				THEN 'AGEF_10_to_14'
				WHEN characteristic = 'Female 15 to 19 years'				THEN 'AGEF_15_to_19'
				WHEN characteristic = 'Female 20 to 24 years'				THEN 'AGEF_20_to_24'
				WHEN characteristic = 'Female 25 to 29 years'				THEN 'AGEF_25_to_29'
				WHEN characteristic = 'Female 30 to 34 years'				THEN 'AGEF_30_to_34'
				WHEN characteristic = 'Female 35 to 39 years'				THEN 'AGEF_35_to_39'
				WHEN characteristic = 'Female 40 to 44 years'				THEN 'AGEF_40_to_44'
				WHEN characteristic = 'Female 45 to 49 years'				THEN 'AGEF_45_to_49'
				WHEN characteristic = 'Female 50 to 54 years'				THEN 'AGEF_50_to_54'
				WHEN characteristic = 'Female 55 to 59 years'				THEN 'AGEF_55_to_59'
				WHEN characteristic = 'Female 60 to 64 years'				THEN 'AGEF_60_to_64'
				WHEN characteristic = 'Female 65 to 69 years'				THEN 'AGEF_65_to_69'
				WHEN characteristic = 'Female 70 to 74 years'				THEN 'AGEF_70_to_74'
				WHEN characteristic = 'Female 75 to 79 years'				THEN 'AGEF_75_to_79'
				WHEN characteristic = 'Female 80 to 84 years'				THEN 'AGEF_80_to_84'
				WHEN characteristic = 'Female 85 to 89 years'				THEN 'AGEF_85_to_89'
				WHEN characteristic = 'Female 90 to 94 years'				THEN 'AGEF_90_to_94'
				WHEN characteristic = 'Female 95 to 99 years'				THEN 'AGEF_95_to_99'
				WHEN characteristic = 'Female 100 years and over'			THEN 'AGEF_100_up'
				WHEN characteristic = 'Neighbourhood Number'    			THEN 'Neighbourhood_ID'
			END AS characteristic2
		FROM demo_popcat21
;
QUIT;


DATA demo_popcat23;
	SET demo_popcat22(DROP= _ID category topic DATA_source);
RUN;


/* Transpose DATA */

PROC transpose DATA=demo_popcat23
	OUT=demo_popcat24
	NAME=NEIGHBOURHOOD_NAME;
	ID Characteristic2;
RUN;


/* save final file */

DATA demo_popcat25;
	SET demo_popcat24(DROP= _label_ NEIGHBOURHOOD_NAME);
	/*
	DEMO_CAT = 'AGE_CAT2';
	attrib DEMO_CAT format=$20.;
	*/
RUN;

		
/* consolIDate groups and save final file */

PROC SQL;
	CREATE TABLE COVID.DEMO_AGE_Cat2 AS 
		SELECT 
			Neighbourhood_ID,
			(AGEF_00_to_04 + AGEF_05_to_09 + AGEF_10_to_14 + AGEF_15_to_19 +
			 AGEM_00_to_04 + AGEM_05_to_09 + AGEM_10_to_14 + AGEM_15_to_19) 				AS AGE_00_to_19,
			(AGEF_20_to_24 + AGEF_25_to_29 + AGEF_30_to_34 + AGEF_35_to_39 + 
			 AGEM_20_to_24 + AGEM_25_to_29 + AGEM_30_to_34 + AGEM_35_to_39) 				AS AGE_20_to_39,
			(AGEF_40_to_44 + AGEF_45_to_49 + AGEF_50_to_54 + AGEF_55_to_59 + AGEF_60_to_64 +
			 AGEM_40_to_44 + AGEM_45_to_49 + AGEM_50_to_54 + AGEM_55_to_59 + AGEM_60_to_64) AS AGE_40_to_64,
			(AGEF_65_to_69 + AGEF_70_to_74 + AGEF_75_to_79 + AGEF_80_to_84 + AGEF_85_to_89 + 
				AGEF_90_to_94 + AGEF_95_to_99 + AGEF_100_up + 
			 AGEM_65_to_69 + AGEM_70_to_74 + AGEM_75_to_79 + AGEM_80_to_84 + AGEM_85_to_89 + 
				AGEM_90_to_94 + AGEM_95_to_99 + AGEM_100_up)								AS AGE_65_UP 

		FROM demo_popcat25
;
QUIT;

/* list DATA info*/

PROC CONTENTS
	DATA=COVID.DEMO_AGE_Cat2 OUT=AOUTDATA;
RUN;


/*---------------------------------------------------------------------------------------------------------------------
/* CREATE Education TABLE
/* Categories:
/*		No certificate, diploma or degree
/*		Secondary (high) school diploma or equivalency certificate
/*		Apprenticeship or trades certificate or diploma
/*		College, CEGEP or other non-university certificate or diploma
/*		University certificate or diploma below bachelor level
/*		Bachelor's degree
/*		University certificate or diploma above bachelor level
/*		MASter's degree
/*		Degree in medicine, dentistry, veterinary medicine or optometry
/*		Earned doctorate
*/

/* Extract education DATA*/

PROC SQL;
	CREATE TABLE demo_educ1 AS 
		SELECT *
		FROM COVID.NBH_DEMO_RAW	
        where (category = 'Education')
		   OR CATEGORY = 'Neighbourhood Information'

		;
QUIT;


/* Rename rows to become column headings */

PROC SQL;
	CREATE TABLE demo_educ2 AS 
		SELECT *,
			CASE 
				WHEN characteristic = 'No certificate, diploma or degree' 									THEN 'None' 
				WHEN characteristic = 'Secondary (high) school diploma or equivalency certificate' 			THEN 'High_School' 
				WHEN characteristic = 'Apprenticeship or trades certificate or diploma'						THEN 'Apprent_Trades' 
				WHEN characteristic = 'College, CEGEP or other non-university certificate or diploma'		THEN 'College_non_univ' 
				WHEN characteristic = 'University certificate or diploma below bachelor level'				THEN 'University_other' 
				WHEN characteristic = 'Bachelors degree' 													THEN 'University_Undergrad' 
				WHEN characteristic = 'University certificate or diploma above bachelor level'				THEN 'University_Undergrad_cert' 
				WHEN characteristic = 'Masters degree' 														THEN 'University_MASter' 
				WHEN characteristic = 'Degree in medicine, dentistry, veterinary medicine or optometry' 	THEN 'University_Med' 
				WHEN characteristic = 'Earned doctorate'													THEN 'University_Doct' 
				WHEN characteristic = 'population aged 25 to 64 years in private households'				THEN 'EDU_Tot'
				WHEN characteristic = 'Neighbourhood Number'    											THEN 'Neighbourhood_ID'
			END AS characteristic2
		FROM demo_educ1
;
QUIT;


DATA demo_educ3;
	SET demo_educ2(DROP= _ID category topic DATA_source);
RUN;


/* Transpose DATA */

PROC transpose DATA=demo_educ3
	OUT=demo_educ4
	NAME=NEIGHBOURHOOD_NAME;
	ID Characteristic2;
RUN;


DATA demo_educ5;
	SET demo_educ4(DROP= _label_ NEIGHBOURHOOD_NAME);
	/*
	DEMO_CAT = 'EDUCATION';
	attrib DEMO_CAT format=$20.;
	*/	
RUN;

PROC CONTENTS
	DATA=demo_educ4 OUT=AOUTDATA;
RUN;

/* consolIDate groups and save final file */

PROC SQL;
	CREATE TABLE COVID.DEMO_EDUCATION AS 
		SELECT 
			Neighbourhood_ID,
			EDU_Tot,
			None																AS EDU_None,
			None + High_school													AS EDU_HS_Lower,
			High_School															AS EDU_High_School, 
			Apprent_Trades + College_non_univ 									AS EDU_College_Trades,
			University_other + University_Undergrad + University_Undergrad_cert	+
			University_MASter + University_Med + University_Doct 				AS EDU_University	
		FROM demo_educ5
;
QUIT;


/* list DATA info*/

PROC CONTENTS
	DATA=COVID.DEMO_EDUCATION OUT=AOUTDATA;
RUN;



/*---------------------------------------------------------------------------------------------------------------------
/* CREATE Occupation TABLE
/* Categories:
/*		Occupation - not applicable
/*		0 Management occupations
/*		1 Business, finance and administration occupations		
/*		2 Natural and applied sciences and related occupations
/*	Y	3 Health occupations
/*		4 Occupations in education, law and social, community and government services
/*		5 Occupations in art, culture, recreation and sport
/*	Y	6 Sales and service occupations
/*	Y	7 Trades, transport and equipment operators and related occupations
/*	Y	8 Natural resources, agriculture and related production occupations
/*	Y	9 Occupations in manufacturing and utilities
*/

/* Extract occupation DATA*/

PROC SQL;
	CREATE TABLE demo_occup1 AS 
		SELECT *
		FROM COVID.NBH_DEMO_RAW	
        where (category = 'Labour' and Topic = 'Occupation - National Occupational Classification (NOC) 2016')
		   or (category = 'Labour' and Topic = 'Labour force status')
		   OR CATEGORY = 'Neighbourhood Information'
		;
QUIT;


/* Rename rows to become column headings */

/*
Neighbourhood Number
In labour force Employed
In labour force Unemployed
Occupation - not applicable
0 Management occupations
1 Business, finance and administration occupations
2 Natural and applied sciences and related occupations
3 Health occupations
4 Occupations in education, law and social, community and government services
5 Occupations in art, culture, recreation and sport
6 Sales and service occupations
7 Trades, transport and equipment operators and related occupations
8 Natural resources, agriculture and related production occupations
9 Occupations in manufacturing and utilities
In the labour force
*/
PROC SQL;
	CREATE TABLE demo_occup2 AS 
		SELECT *,
			CASE
				WHEN characteristic = 'Occupation - not applicable' 													THEN 'OCC_NA' 
				WHEN characteristic = '0 Management occupations' 														THEN 'OCC_Cat_0' 
				WHEN characteristic = '1 Business, finance and administration occupations' 								THEN 'OCC_Cat_1' 
				WHEN characteristic = '2 Natural and applied sciences and related occupations' 							THEN 'OCC_Cat_2' 
				WHEN characteristic = '3 Health occupations' 															THEN 'OCC_Cat_3' 
				WHEN characteristic = '4 Occupations in education, law and social, community and government services' 	THEN 'OCC_Cat_4' 
				WHEN characteristic = '5 Occupations in art, culture, recreation and sport' 							THEN 'OCC_Cat_5' 
				WHEN characteristic = '6 Sales and service occupations' 												THEN 'OCC_Cat_6' 
				WHEN characteristic = '7 Trades, transport and equipment operators and related occupations' 			THEN 'OCC_Cat_7' 
				WHEN characteristic = '8 Natural resources, agriculture and related production occupations' 			THEN 'OCC_Cat_8' 
				WHEN characteristic = '9 Occupations in manufacturing and utilities' 									THEN 'OCC_Cat_9' 
				WHEN characteristic = 'In the labour force'																THEN 'OCC_Tot'
				WHEN characteristic = 'Neighbourhood Number'    														THEN 'Neighbourhood_ID'
			END AS characteristic2
		FROM demo_occup1
;
QUIT;


DATA demo_occup3;
	SET demo_occup2(DROP= _ID category topic DATA_source);
RUN;


/* Transpose DATA */

PROC transpose DATA=demo_occup3
	OUT=demo_occup4
	NAME=NEIGHBOURHOOD_NAME;
	ID Characteristic2;
RUN;


/* save file 1 */

DATA COVID.DEMO_Occupation;
	SET demo_occup4(DROP= _label_ NEIGHBOURHOOD_NAME);
	/*
	DEMO_CAT = 'OCCUPATION';
	attrib DEMO_CAT format=$20.;
	*/
RUN;


/* essential occupations group final file 2 */

PROC SQL;
	CREATE TABLE COVID.DEMO_OCC_Essential AS 
		SELECT 
			Neighbourhood_ID,
			OCC_Cat_0 + OCC_Cat_1 + OCC_Cat_2 + OCC_Cat_4 + OCC_Cat_5   		AS OCC_Ess_No,
			OCC_Cat_3 + OCC_Cat_6 + OCC_Cat_7 + OCC_Cat_8 + OCC_Cat_9 + OCC_NA  AS OCC_Ess_Yes
		FROM COVID.DEMO_Occupation
;
QUIT;


/* list DATA info*/

PROC CONTENTS
	DATA=COVID.DEMO_Occupation OUT=AOUTDATA;
RUN;



/*---------------------------------------------------------------------------------------------------------------------
/* CREATE Visible Minority TABLE
/* Categories:
/*		SOUTh ASian
/*		Chinese
/*		Black
/*		Filipino
/*		Arab
/*		Latin American
/*		SOUTheASt ASian
/*		West ASian
/*		Korean
/*		Japanese
/*		Visible minority; n.i.e.
/*		Multiple visible minorities
/*		Not a visible minority
*/

/* Extract visible minority DATA*/

PROC SQL;
	CREATE TABLE demo_vismin1 AS 
		SELECT *
		FROM COVID.NBH_DEMO_RAW	
        where (category = 'Visible minority')
		   OR CATEGORY = 'Neighbourhood Information'
		;
QUIT;


/* Rename rows to become column headings */

PROC SQL;
	CREATE TABLE demo_vismin2 AS 
		SELECT *,
			CASE 
				WHEN characteristic = 'South Asian' 				THEN 'VM_South_ASian' 
				WHEN characteristic = 'Chinese' 					THEN 'VM_Chinese' 
				WHEN characteristic = 'Black' 						THEN 'VM_Black' 
				WHEN characteristic = 'Filipino' 					THEN 'VM_Filipino' 
				WHEN characteristic = 'Arab' 						THEN 'VM_Arab' 
				WHEN characteristic = 'Latin American' 				THEN 'VM_Latin_American' 
				WHEN characteristic = 'Southeast Asian' 			THEN 'VM_SOUTheASt_ASian' 
				WHEN characteristic = 'West Asian' 					THEN 'VM_West_ASian' 
				WHEN characteristic = 'Korean' 						THEN 'VM_Korean' 
				WHEN characteristic = 'Japanese' 					THEN 'VM_Japanese' 
				WHEN characteristic = 'Visible minority; n.i.e.' 	THEN 'VM_Other' 
				WHEN characteristic = 'Multiple visible minorities' THEN 'VM_Multiple' 
				WHEN characteristic = 'Not a visible minority' 		THEN 'VM_Not_Vismin' 
				WHEN characteristic = 'Neighbourhood Number'    	THEN 'Neighbourhood_ID'
			END AS characteristic2
		FROM demo_vismin1
;
QUIT;


DATA demo_vismin3;
	SET demo_vismin2(DROP= _ID category topic DATA_source);
RUN;


/* Transpose DATA */

PROC transpose DATA=demo_vismin3
	OUT=demo_vismin4
	NAME=NEIGHBOURHOOD_NAME;
	ID Characteristic2;
RUN;


/* save final file */

DATA demo_vismin5;
	SET demo_vismin4(DROP= _label_ NEIGHBOURHOOD_NAME);
	/*
	DEMO_CAT = 'VISIBLE_MIN';
	attrib DEMO_CAT format=$20.;
	*/
RUN;


/* essential occupations group final file 2 */

PROC SQL;
	CREATE TABLE COVID.DEMO_VIS_Minority AS 
		SELECT 	
			Neighbourhood_ID,
			VM_Black,
			VM_SOUTh_ASian,
			VM_Chinese + VM_Japanese + VM_Korean	AS VM_EASt_ASian,	
			VM_Filipino + VM_SOUTheASt_ASian     	AS VM_SOUTheASt_ASian,
			vm_West_ASian + VM_Arab					AS VM_West_ASian,
			VM_Latin_American,
			VM_Multiple,
			VM_Not_Vismin,
			VM_Other,
			VM_Multiple +	VM_Multiple				AS VM_Mult_Oth,
			VM_Not_Vismin							AS VM_No,
			VM_Arab + VM_Black + VM_Chinese + VM_Filipino + VM_Japanese + VM_Korean + 
			VM_Latin_American + VM_Multiple + VM_Other + VM_SOUTh_ASian + VM_SOUTheASt_ASian + VM_West_ASian AS VM_Yes
		FROM demo_vismin5
;
QUIT;


/* list DATA info*/

PROC CONTENTS
	DATA=COVID.DEMO_VIS_Minority OUT=AOUTDATA;
RUN;

/*---------------------------------------------------------------------------------------------------------------------
/* CREATE Immigration TABLE
/* Cagegories:
/*		Non-immigrants
/*		Immigrant Before 1981
/*		Immigrant 1981 to 1990
/*		Immigrant 1991 to 2000
/*		Immigrant 2001 to 2010
/*		Immigrant 2011 to 2016
/*		Non-permanent resIDents
*/

/* Extract immigration DATA*/

PROC SQL;
	CREATE TABLE demo_immig1 AS 
		SELECT *
		FROM COVID.NBH_DEMO_RAW	
        where (category = 'Immigration and citizenship' and Topic = 'Immigrant status and period of immigration')
		   OR CATEGORY = 'Neighbourhood Information'
		;
QUIT;


/* Rename rows to become column headings */

PROC SQL;
	CREATE TABLE demo_immig2 AS 
		SELECT *,
			CASE 
				WHEN characteristic = 'Non-immigrants' 				THEN 'IMM_Non_Imm' 
				WHEN characteristic = 'Immigrant Before 1981' 		THEN 'IMM_Before_1981' 
				WHEN characteristic = 'Immigrant 1981 to 1990' 		THEN 'IMM_1981_1990' 
				WHEN characteristic = 'Immigrant 1991 to 2000' 		THEN 'IMM_1991_2000' 
				WHEN characteristic = 'Immigrant 2001 to 2010' 		THEN 'IMM_2001_2010' 
				WHEN characteristic = 'Immigrant 2011 to 2016' 		THEN 'IMM_2011_2016' 
				WHEN characteristic = 'Non-permanent residents' 	THEN 'IMM_Non_Perm_res' 
				WHEN characteristic = 'Neighbourhood Number'    	THEN 'Neighbourhood_ID'
			END AS characteristic2
		FROM demo_immig1
;
QUIT;


DATA demo_immig3;
	SET demo_immig2(DROP= _ID category topic DATA_source);
RUN;


/* Transpose DATA */

PROC transpose DATA=demo_immig3
	OUT=demo_immig4
	NAME=NEIGHBOURHOOD_NAME;
	ID Characteristic2;
RUN;


/* save final file */

DATA demo_immig5;
	SET demo_immig4(DROP= _label_ NEIGHBOURHOOD_NAME);
	/*
	DEMO_CAT = 'IMMIGRATION';
	attrib DEMO_CAT format=$20.;
	*/
RUN;

/* list DATA info*/

PROC CONTENTS
	DATA=DEMO_IMMIG5 OUT=AOUTDATA;
RUN;

/* consolIDate groups and save final file */

PROC SQL;
	CREATE TABLE COVID.DEMO_IMMIGRATION AS 
		SELECT 
			Neighbourhood_ID,
			IMM_Before_1981,
			(IMM_1981_1990 + IMM_1991_2000) 									AS IMM_1981_2000,
			(IMM_2001_2010 + IMM_2011_2016) 									AS IMM_2001_2016,
			IMM_Non_Imm,
			IMM_Non_Perm_res,
			(IMM_Non_Imm + IMM_Non_Perm_res)									AS IMM_No,	
			(IMM_Before_1981+ IMM_1981_1990 + IMM_1991_2000 + IMM_2001_2010+ IMM_2011_2016) 		AS IMM_Yes
		FROM demo_immig5
;
QUIT;

PROC CONTENTS
	DATA=COVID.DEMO_IMMIGRATION OUT=AOUTDATA;
RUN;

/*---------------------------------------------------------------------------------------------------------------------
/* CREATE Commute to work TABLE
/* Cagegories:
/*		Car, truck, van - AS a driver
/*		Car, truck, van - AS a pASsenger
/*		Public transit
/*		Walked
/*		Bicycle
/*		Other method
*/

/* Extract commuting DATA*/

PROC SQL;
	CREATE TABLE demo_comm1 AS 
		SELECT *
		FROM COVID.NBH_DEMO_RAW	
        where (category = 'Journey to work')
		   OR CATEGORY = 'Neighbourhood Information'
		;
QUIT;


/* Rename rows to become column headings */

PROC SQL;
	CREATE TABLE demo_comm2 AS 
		SELECT *,
			CASE 
				WHEN characteristic = 'Car, truck, van - as a driver' 		THEN 'COMM_Vehicle_Driver' 
				WHEN characteristic = 'Car, truck, van - as a passenger' 	THEN 'COMM_Vehicle_PASs' 
				WHEN characteristic = 'Public transit' 						THEN 'COMM_Public_Transit' 
				WHEN characteristic = 'Walked' 								THEN 'COMM_Walk' 
				WHEN characteristic = 'Bicycle' 							THEN 'COMM_Bicycle' 
				WHEN characteristic = 'Other method' 						THEN 'COMM_Other' 
				WHEN characteristic = 'Total Commuting for the employed labour force aged 15 years' 	THEN 'COMM_Tot'
				WHEN characteristic = 'Neighbourhood Number'    			THEN 'Neighbourhood_ID'
			END AS characteristic2
		FROM demo_comm1
;
QUIT;


DATA demo_comm3;
	SET demo_comm2(DROP= _ID category topic DATA_source);
RUN;


/* Transpose DATA */

PROC transpose DATA=demo_comm3
	OUT=demo_comm4
	NAME=NEIGHBOURHOOD_NAME;
	ID Characteristic2;
RUN;


/* save final file */

DATA COVID.DEMO_COMMUTE;
	SET demo_comm4(DROP= _label_ NEIGHBOURHOOD_NAME);
	/*
	DEMO_CAT = 'COMMUTE';
	attrib DEMO_CAT format=$20.;
	*/
RUN;


/* list DATA info*/

PROC CONTENTS
	DATA=COVID.DEMO_COMMUTE OUT=AOUTDATA;
RUN;



/*---------------------------------------------------------------------------------------------------------------------
/* CREATE Labor Inducstry TABLE
/* Categories:
/*		11 Agriculture, forestry, fishing and hunting
/*		21 Mining, quarrying, and oil and gAS extraction
/*		22 Utilities
/*		23 Construction
/*		31-33 Manufacturing
/*		41 Wholesale trade
/*		44-45 Retail trade
/*		48-49 Transportation and warehousing
/*		51 Information and cultural industries
/*		52 Finance and insurance
/*		53 Real estate and rental and leASing
/*		54 Professional, scientific and technical services
/*		55 Management of companies and enterprises
/*		56 Administrative and support, wASte management and remediation services
/*		61 Educational services
/*		62 Health care and social ASsistance
/*		71 Arts, entertainment and recreation
/*		72 Accommodation and food services
/*		81 Other services (except public administration)
/*		91 Public administration
*/

/* Extract occupation DATA*/

PROC SQL;
	CREATE TABLE demo_ind1 AS 
		SELECT *
		FROM COVID.NBH_DEMO_RAW	
        where (category = 'Labour' and Topic = 'Industry - North American Industry Classification System (NAICS) 2012')
	   	   OR CATEGORY = 'Neighbourhood Information'
		;
QUIT;


/* Rename rows to become column headings */

PROC SQL;
	CREATE TABLE demo_ind2 AS 
		SELECT *,
			CASE 
				WHEN characteristic = '11 Agriculture, forestry, fishing and hunting' 					THEN 'IND_Cat_11' 
				WHEN characteristic = '21 Mining, quarrying, and oil and gas extraction' 				THEN 'IND_Cat_21' 
				WHEN characteristic = '22 Utilities' 													THEN 'IND_Cat_22'  
				WHEN characteristic = '23 Construction' 												THEN 'IND_Cat_23' 
				WHEN characteristic = '31-33 Manufacturing' 											THEN 'IND_Cat_31'  
				WHEN characteristic = '41 Wholesale trade' 												THEN 'IND_Cat_41' 
				WHEN characteristic = '44-45 Retail trade' 												THEN 'IND_Cat_44' 
				WHEN characteristic = '48-49 Transportation and warehousing' 							THEN 'IND_Cat_48' 
				WHEN characteristic = '51 Information and cultural industries' 							THEN 'IND_Cat_51' 
				WHEN characteristic = '52 Finance and insurance' 										THEN 'IND_Cat_52' 
				WHEN characteristic = '53 Real estate and rental and leasing' 							THEN 'IND_Cat_53' 
				WHEN characteristic = '54 Professional, scientific and technical services' 				THEN 'IND_Cat_54'  
				WHEN characteristic = '55 Management of companies and enterprises' 						THEN 'IND_Cat_55' 
				WHEN characteristic = '56 Administrative and support, waste management and remediation services'	THEN 'IND_Cat_56' 
				WHEN characteristic = '61 Educational services' 										THEN 'IND_Cat_61' 
				WHEN characteristic = '62 Health care and social assistance' 							THEN 'IND_Cat_62' 
				WHEN characteristic = '71 Arts, entertainment and recreation' 							THEN 'IND_Cat_71' 
				WHEN characteristic = '72 Accommodation and food services' 								THEN 'IND_Cat_72' 
				WHEN characteristic = '81 Other services (except public administration)' 				THEN 'IND_Cat_81' 
				WHEN characteristic = '91 Public administration' 										THEN 'IND_Cat_91' 
				WHEN characteristic = 'All industry categories'											THEN 'IND_Tot'
				WHEN characteristic = 'Neighbourhood Number'    										THEN 'Neighbourhood_ID'
			END AS characteristic2
		FROM demo_ind1
;
QUIT;


DATA demo_ind3;
	SET demo_ind2(DROP= _ID category topic DATA_source);
RUN;


/* Transpose DATA */

PROC transpose DATA=demo_ind3
	OUT=demo_ind4
	NAME=NEIGHBOURHOOD_NAME;
	ID Characteristic2;
RUN;


/* save final file */

DATA COVID.DEMO_Industry;
	SET demo_ind4(DROP= _label_ NEIGHBOURHOOD_NAME);
	/*
	DEMO_CAT = 'Industry';
	attrib DEMO_CAT format=$20.;
	*/
RUN;


/* list DATA info*/

PROC CONTENTS
	DATA=COVID.DEMO_Industry OUT=AOUTDATA;
RUN;

PROC SQL;
	CREATE TABLE COVID.DEMO_IND_Essential AS 
		SELECT 
			neighbourhood_ID,
			IND_Cat_23 + IND_Cat_31 + IND_Cat_44 + IND_Cat_48 + IND_Cat_56 + IND_Cat_62 + IND_Cat_72 + IND_Cat_81 	AS IND_Ess_Yes,
			IND_Cat_11 + IND_Cat_21 + IND_Cat_22 + IND_Cat_41 + IND_Cat_51 + IND_Cat_52 + IND_Cat_53 + 
			IND_Cat_54 + IND_Cat_55 + IND_Cat_61 + IND_Cat_71 + IND_Cat_91											AS IND_Ess_NO					
		FROM COVID.DEMO_Industry
		;
QUIT;


/*---------------------------------------------------------------------------------------------------------------------
/* CREATE Total Population TABLE
/* 
/* Categories:
		POP_density
		POP_land_area
		POP_population
/*			
*/

/* Extract low income DATA*/

PROC SQL;
	CREATE TABLE demo_pop1 AS 
		SELECT *
		FROM COVID.NBH_DEMO_RAW	
        where (category = 'Population' and Topic = 'Population and dwellings')
		   OR CATEGORY = 'Neighbourhood Information'
		;
QUIT;


/* Rename rows to become column headings */

PROC SQL;
	CREATE TABLE demo_pop2 AS 
		SELECT *,
			CASE 
				WHEN characteristic = 'Population 2016' 						THEN 'POP_population' 
				WHEN characteristic = 'Land area in square kilometres' 			THEN 'POP_land_area' 
				WHEN characteristic = 'Population density per square kilometre'	THEN 'POP_density'
				WHEN characteristic = 'Neighbourhood Number'    				THEN 'Neighbourhood_ID'
			END AS characteristic2

		FROM demo_pop1
;
QUIT;


DATA demo_pop3;
	SET demo_pop2(DROP= _ID category Topic DATA_source);
RUN;



/* Transpose DATA */

PROC transpose DATA=demo_pop3
	OUT=demo_pop4
	NAME=NEIGHBOURHOOD_NAME;
	ID Characteristic2;
RUN;


/* save final file */

DATA COVID.DEMO_POPULATION;
	SET demo_POP4(DROP= _label_ NEIGHBOURHOOD_NAME);
	/*
	DEMO_CAT = 'POPULATION';
	attrib DEMO_CAT format=$20.;
	*/
RUN;


/* list DATA info*/

PROC CONTENTS
	DATA=COVID.DEMO_POPULATION OUT=AOUTDATA;
RUN;


/*---------------------------------------------------------------------------------------------------------------------
/* Merge Demographic DATA into one file	
/*	
*/

/* Sort DATA SETs */


PROC SORT DATA=COVID.NBH_INFO;
	BY Neighbourhood_ID;
RUN;

PROC SORT DATA=COVID.DEMO_AGE_CAT1;
	BY Neighbourhood_ID;
RUN;


PROC SORT DATA=COVID.DEMO_AGE_CAT2;
	BY Neighbourhood_ID;
RUN;

PROC SORT DATA=COVID.DEMO_COMMUTE ;
	BY Neighbourhood_ID;
RUN;

PROC SORT DATA=COVID.DEMO_EDUCATION ;
	BY Neighbourhood_ID;
RUN;

PROC SORT DATA=COVID.DEMO_HH_DWELLING;
	BY Neighbourhood_ID;
RUN;

PROC SORT DATA=COVID.DEMO_HH_INCOME ;
	BY Neighbourhood_ID;
RUN;

PROC SORT DATA=COVID.DEMO_HH_NUM ;
	BY Neighbourhood_ID;
RUN;

PROC SORT DATA=COVID.DEMO_IMMIGRATION;
	BY Neighbourhood_ID;
RUN;

PROC SORT DATA=COVID.DEMO_INDUSTRY ;
	BY Neighbourhood_ID;
RUN;

PROC SORT DATA=COVID.DEMO_IND_Essential ;
	BY Neighbourhood_ID;
RUN;

PROC SORT DATA=COVID.DEMO_OCCUPATION ;
	BY Neighbourhood_ID;
RUN;

PROC SORT DATA=COVID.DEMO_OCC_Essential  ;
	BY Neighbourhood_ID;
RUN;

PROC SORT DATA=COVID.DEMO_VIS_MINORITY ;
	BY Neighbourhood_ID;
RUN;

PROC SORT DATA=COVID.DEMO_POPULATION ;
	BY Neighbourhood_ID;
RUN;


/* Merge DATA SETS by Neighbourhood_ID */

DATA DEMOGRAPHICS; 
	MERGE 
		COVID.NBH_INFO
		COVID.DEMO_AGE_CAT1
		COVID.DEMO_COMMUTE
		COVID.DEMO_EDUCATION
		COVID.DEMO_HH_DWELLING
		COVID.DEMO_HH_INCOME
		COVID.DEMO_HH_NUM
		COVID.DEMO_IMMIGRATION
		COVID.DEMO_INDUSTRY
		COVID.DEMO_IND_Essential
		COVID.DEMO_OCCUPATION
		COVID.DEMO_OCC_Essential 
 		COVID.DEMO_VIS_MINORITY
		COVID.DEMO_POPULATION
		COVID.DEMO_AGE_CAT2
		;
	BY NEIGHBOURHOOD_ID;
RUN;


/*---------------------------------------------------------------------------------------------------------------------
/* CREATE percentages based on population data
/*
*/	
	
PROC CONTENTS
DATA=COVID.DEMOGRAPHICS OUT=AOUTDATA;
RUN;

PROC SQL;
	CREATE TABLE COVID.DEMOGRAPHICS AS 
		SELECT 
			*,
			/* Age Categories / TOtal Population */				
			AGE1_0_to_14 / POP_population 			AS P_AGE1_0_to_14,
			AGE1_15_to_24 / POP_population 			AS P_AGE1_15_to_24,
			AGE1_25_to_54 / POP_population 			AS P_AGE1_25_to_54,
			AGE1_55_to_64 / POP_population 			AS P_AGE1_55_to_64,
			AGE1_65_to_84 / POP_population 			AS P_AGE1_65_to_84,
			AGE1_85_up / POP_population 			AS P_AGE1_85_UP,
			AGE_00_to_19 / POP_Population			AS P_AGE_00_to_19,
			AGE_20_to_39 / POP_Population			AS P_AGE_20_to_39,
			AGE_40_to_64 / POP_Population			AS P_AGE_40_to_64,
			AGE_65_UP / POP_Population				AS P_AGE_65_up,

			/* Commute / TOtal Commute Population */
			COMM_Bicycle / COMM_Tot 				AS P_COMM_Bicycle,
			COMM_Other /COMM_Tot 					AS P_COMM_Other,
			COMM_Public_Transit / COMM_Tot  		AS P_COMM_Public_Transit,
			COMM_Vehicle_Driver/ COMM_Tot 			AS P_COMM_Vehicle_Driver,
			COMM_Vehicle_PASs / COMM_Tot  			AS P_COMM_Vehicle_PASs,
			COMM_Walk / COMM_Tot 					AS P_COMM_Walk,

			/* dwelling / TOtal households */
			DWEL_Apart / HH_Tot 					AS P_DWEL_Apart, 
			DWEL_Attached / HH_Tot 					AS P_DWEL_Attached, 
			DWEL_Movable / HH_Tot 					AS P_DWEL_Movable,
			DWEL_SD_House / HH_Tot 					AS P_DWEL_SD_House,

			/* education / TOtal pop > 25 */
			EDU_College_Trades / EDU_Tot			AS P_EDU_College_Trades,
			EDU_High_School / EDU_Tot				AS P_EDU_High_School,
			EDU_HS_Lower/ EDU_Tot					AS P_EDU_HS_Lower,
			EDU_None / EDU_Tot						AS P_EDU_None,
			EDU_University / EDU_Tot				AS P_EDU_University,

			/* household numbers / TOtal households */
			HH_1_Person  / HH_Tot 					AS P_HH_1_Person,
			HH_2_Persons / HH_Tot 					AS P_HH_2_Persons,
			HH_3_Persons / HH_Tot 					AS P_HH_3_Persons,
			HH_4_Persons / HH_Tot 					AS P_HH_4_Persons,
			HH_5_Persons / HH_Tot 					AS P_HH_5_Persons,

			/* Immigration / total population */
			IMM_1981_2000 / POP_population			AS P_IMM_1981_2000,
			IMM_2001_2016 / POP_population			AS P_IMM_2001_2016,
			IMM_Before_1981 / POP_population		AS P_IMM_Before_1981,
			IMM_Non_Imm / POP_population			AS P_IMM_Non_Imm,
			IMM_Non_Perm_res / POP_population		AS P_IMM_1Non_Perm_Res,
			IMM_Yes / POP_Population 				AS P_IMM_Yes,
			IMM_No / POP_Population 				AS P_IMM_No,

			/* Household income  / total households */
			INCHH_25000_50000 / HH_Tot				AS P_INC_25000_50000,
			INCHH_50000_99999 / HH_Tot				AS P_INC_50000_99999,
			INCHH_Over_100000 / HH_Tot				AS P_INC_Over_100000,
			INCHH_Under_25000 / HH_Tot				AS P_INC_Under_25000,
			INCHH_25000_99999 / HH_Tot				as P_INC_25000_99999,

			/* IDustry categories / industry total pop */
			IND_Cat_11 / IND_Tot					AS P_IND_Cat_11,
			IND_Cat_21 / IND_Tot					AS P_IND_Cat_21,
			IND_Cat_22 / IND_Tot					AS P_IND_Cat_22,
			IND_Cat_23 / IND_Tot					AS P_IND_Cat_23,
			IND_Cat_31 / IND_Tot					AS P_IND_Cat_31,
			IND_Cat_41 / IND_Tot					AS P_IND_Cat_41,
			IND_Cat_44 / IND_Tot					AS P_IND_Cat_44,
			IND_Cat_48 / IND_Tot					AS P_IND_Cat_48,
			IND_Cat_51 / IND_Tot					AS P_IND_Cat_51,
			IND_Cat_52 / IND_Tot					AS P_IND_Cat_52,
			IND_Cat_53 / IND_Tot					AS P_IND_Cat_53,
			IND_Cat_54 / IND_Tot					AS P_IND_Cat_54,
			IND_Cat_55 / IND_Tot					AS P_IND_Cat_55,
			IND_Cat_56 / IND_Tot					AS P_IND_Cat_56,
			IND_Cat_61 / IND_Tot					AS P_IND_Cat_61,
			IND_Cat_62 / IND_Tot					AS P_IND_Cat_62,
			IND_Cat_71 / IND_Tot					AS P_IND_Cat_71,
			IND_Cat_72 / IND_Tot					AS P_IND_Cat_72,
			IND_Cat_81 / IND_Tot					AS P_IND_Cat_81,
			IND_Cat_91 / IND_Tot					AS P_IND_Cat_91,
			IND_Ess_Yes / IND_Tot					AS P_IND_Ess_Yes,
			IND_Ess_No / IND_Tot					AS P_IND_Ess_No,

			/* social housing units / total units */
			NBH_SH_UNITS / 89751 					AS P_NBH_SH_UNITS,
			NBH_NIA_IND								AS NIA_IND,

			/* occupation categories / occupatoin total pop */
			OCC_Cat_0 / OCC_Tot						AS P_OCC_0,
			OCC_Cat_1 / OCC_Tot						AS P_OCC_1,
			OCC_Cat_2 / OCC_Tot						AS P_OCC_2,
			OCC_Cat_3 / OCC_Tot						AS P_OCC_3,
			OCC_Cat_4 / OCC_Tot						AS P_OCC_4,
			OCC_Cat_5 / OCC_Tot						AS P_OCC_5,
			OCC_Cat_6 / OCC_Tot						AS P_OCC_6,
			OCC_Cat_7 / OCC_Tot						AS P_OCC_7,
			OCC_Cat_8 / OCC_Tot						AS P_OCC_8,
			OCC_Cat_9 / OCC_Tot						AS P_OCC_9,
			OCC_NA / OCC_Tot						AS P_OCC_NA,
			OCC_Ess_Yes / OCC_Tot					AS P_OCC_Ess_Yes,
			OCC_Ess_No / OCC_Tot					AS P_OCC_Ess_No,


			/* Visible minorities / total pop */
			VM_Black / POP_Population				AS P_VM_Black,		
			VM_EASt_ASian / POP_Population			AS P_VM_EASt_ASian,
			VM_Latin_American / POP_Population		AS P_VM_Latin_American,
			VM_Multiple / POP_Population			AS P_VM_Multiple,
			VM_Not_Vismin / POP_Population			AS P_VM_Not_Vismin,
			VM_Other / POP_Population				AS P_VM_Other,
			VM_SOUTh_ASian / POP_Population			AS P_VM_SOUTh_ASian,
			VM_SOUTheASt_ASian / POP_Population		AS P_VM_SOUTheASt_ASian,
			VM_West_ASian / POP_Population			AS P_VM_West_ASian,
			VM_No / POP_Population					AS P_VM_No,
			VM_Yes / POP_Population					AS P_VM_Yes,
			VM_Mult_Oth / POP_Population			AS P_VM_Mult_Oth
			/*
			VM_Arab / POP_Population				AS P_VM_Arab,
			VM_Chinese / POP_Population				AS P_VM_Chinese,
			VM_Filipino / POP_Population			AS P_VM_Filipino,
			VM_Japanese / POP_Population			AS P_VM_Japanese,
			VM_Korean / POP_Population				AS P_VM_Korean,*/
	FROM DEMOGRAPHICS
	ORDER BY NEIGHBOURHOOD_ID
	;
QUIT;

	
PROC CONTENTS
DATA=COVID.DEMOGRAPHICS OUT=AOUTDATA;
RUN;

/*** Data for project chart ***/

/*---------------------------------------------------------------------------------------------------------------------
/* Join Covid Data to Neighbourhood Demographics Data 
/*  	Calculate Infection rate  
/* 		remove cases with missing neighbourhood id
*/

PROC SQL;
	CREATE TABLE COVID_pres1 AS	
		SELECT 
		/*	NEIGHBOURHOOD_ID,
			NEIGHBOURHOOD_NAME,*/
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
		/*where neighbourhood_id NE  999
		GROUP BY 1,2*/
		;
QUIT;

/* 	add percentage of total cases */
proc sql;
	create table COVID_pres2 AS	
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
		FROM COVID_pres1

		;
QUIT;


proc sql;
	create table testit as 
		select 
			b.neighbourhood_id,
			b.neighbourhood_name,
			b.POP_Population,	
			total_cases,
			OCC_Tot,
			HH_Tot,
			EDU_Tot	,
			VM_Yes,
			VM_Yes / b.POP_Population					AS P_VM_Yes,
			occ_ess_yes,
			OCC_Ess_Yes / OCC_Tot					AS P_OCC_Ess_Yes,
			INCHH_50000_99999,
			INCHH_50000_99999 / HH_Tot				AS P_INC_50000_99999,
			edu_HS_LOWEr,
			EDU_HS_Lower/ EDU_Tot					AS P_EDU_HS_Lower,
			hh_5_persons,
			HH_5_Persons / HH_Tot 					AS P_HH_5_Persons,
			TOTAL_CASES/POP_POPULATION AS INFECTION_RATE format comma7.5
		FROM COVID.DEMOGRAPHICS AS B leff join 
			 COVID_pres2 AS A oN A.NEIGHBOURHOOD_ID = B.NEIGHBOURHOOD_ID
	where b.neighbourhood_id in(0)
/*	order by infection_rate desc*/
	;
quit;

proc sql;
	create table testit2 as 
		select *
		from testit 
		order by infection_rate desc;
quit;
