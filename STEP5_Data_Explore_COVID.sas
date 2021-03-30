/**********************************************************************************************************************
/* NAME:		STEP5_DATA_Explore_COVID
/* DESCRIPTION:	Exploration of Covid DATA
/* DATE:		Feb 7, 2021
/* AUTHOR:		Marlene Martins
/* NOTES:		
/* 				
/* INPUT:		COVID.COVID_SUMMARY_Date	
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
/* COVID.COVID_DATA
/*---------------------------------------------------------------------------------------------------------------------

/*---------------------------------------------------------------------------------------------------------------------
/* Explore FSA DATA
/* 
*/

PROC sql;
	create table DATA1 AS 
			select 
			FSA,
			NEIGHBOURHOOD_ID,
			COUNT(*) AS REC_COUNT
		from COVID.COVID_DATA	
		GROUP BY 1,2
	;
QUIT;

/* FSA PROC FREQ */

ods OUTPUT onewayFREQs=class_FREQs;
PROC FREQ DATA=COVID.COVID_DATA;
  tables neighbourhood_id fsa;
RUN;
ods OUTPUT close;


/*---------------------------------------------------------------------------------------------------------------------
/* PROC CONTENTS
*/

PROC CONTENTS
DATA=COVID.COVID_DATA OUT=AOUTDATA;
RUN;

PROC CONTENTS
DATA=COVID.COVID_NBH_SUMMARY OUT=AOUTDATA;
RUN;

PROC CONTENTS
DATA=COVID.COVID_SUMMARY_Date OUT=AOUTDATA;
RUN;

PROC CONTENTS
DATA=COVID.COVID_SUMMARY OUT=AOUTDATA;
RUN;

/*---------------------------------------------------------------------------------------------------------------------
/* PROC MEANS
*/
PROC MEANS DATA=COVID.COVID_DATA;
  OUTPUT OUT=aOUTMEANS;
RUN;

PROC MEANS DATA=COVID.COVID_NBH_SUMMARY;
  OUTPUT OUT=aOUTMEANS;
RUN;

PROC MEANS DATA=COVID.COVID_SUMMARY_Date;
  OUTPUT OUT=aOUTMEANS;
RUN;

PROC MEANS DATA=COVID.COVID_SUMMARY;
  OUTPUT OUT=aOUTMEANS;
RUN;

/*---------------------------------------------------------------------------------------------------------------------
/* Covid DATA FREQuency distribution by neighbourhood 
*/

PROC FREQ
DATA=COVID.COVID_DATA;
table neighbourhood_id NEIGHBOURHOOD_NAME/OUT=AOUTFREQ;
RUN;

/* case count by age_group */
PROC FREQ
DATA=COVID.COVID_DATA;
table age_group * case_count/chisq
OUT=aOUTFREQ;
RUN;

/* case count by episode week ending */
PROC FREQ
DATA=COVID.COVID_DATA;
table episode_wend * case_count /chisq
OUT=aOUTFREQ;
RUN;

/* fatal count by week ending*/
PROC FREQ
DATA=COVID.COVID_DATA;
where case_fatal = 1;
table episode_wend * case_fatal /
OUT=aOUTFREQ;
RUN;

/* case count by characteristics */
PROC SQL;
	CREATE TABLE DATAOUT AS 
		SELECT 
			episode_date,
		/*	episode_Mend,
			neighbourhood_id,
			neighbourhood_name,
		/*	age_group,
			client_gender,*/
		count(*),
			SUM(case_count) 		AS CASE_COUNT,
			SUM(case_fatal)			AS CASE_FATAL,
			SUM(TOT_hospitalized)	AS TOT_HOSPITALIZED,
			SUM(TOT_in_icu)			AS TOT_IN_ICU,
			SUM(TOT_intubated)		AS TOT_INTUBATED,
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
/*ORDER BY 1*/
;
quit;

PROC MEANS DATA=DATAOUT;
  OUTPUT OUT=aOUTMEANS;
RUN;


/* case count, fatal count by age_group */
ods OUTPUT onewayFREQs=class_FREQs;
PROC FREQ DATA=COVID.COVID_DATA;
  tables age_group case_count case_fatal;
RUN;
ods OUTPUT close;


PROC FREQ
DATA=COVID.COVID_DATA;
table age_group * case_fatal/chisq;
/* list the fields you want in the PROC FREQ*/
RUN;

/* case count, fatalities by neighbourhood */
ods OUTPUT onewayFREQs=class_FREQs;
PROC FREQ DATA=COVID.COVID_DATA;
  tables neighbourhood_id case_count case_fatal;
RUN;
ods OUTPUT close;


ods OUTPUT onewayFREQs=class_FREQs;
PROC FREQ DATA=COVID.COVID_DATA;
  tables episode_wend case_count case_fatal;
RUN;
ods OUTPUT close;

ods OUTPUT onewayFREQs=class_FREQs;
PROC FREQ DATA=COVID.COVID_SUMMARY2;
  tables episode_wend total_cases/POP_POPULATION;
RUN;
ods OUTPUT close;

/*---------------------------------------------------------------------------------------------------------------------
/* Charts and Graphs
/*---------------------------------------------------------------------------------------------------------------------

/*---------------------------------------------------------------------------------------------------------------------
/* PLOT SEVEN DAY  moving average curve and total cases 
*/

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Charts.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "Cases by Date"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'PROC' sheet_name = "CASES 7 DAY");
ods graphics on / width = 8in; 

/* Set the Titles/Footnotes */

TITLE justify=center color=CX000000 font="Arial" height=12 pt 
	'Total Cases, 7 day Rolling Avg & Cumulative Cases';

PROC sgplot DATA=COVID.COVID_SUMMARY_Date cycleattrs;
	styleattrs  dataContrastColors=( CX000000 CXFF0000 CXC0A8E5);
    series x=episode_date y=AVG_7_DAY_ROL / name='v1'   legendlabel="7 Day Rolling Avg";
	series x=episode_date y=cumulative_cases /y2axis name='v2'   legendlabel="Cumulative Cases";
    scatter x=episode_date y=total_cases;
   	keylegend "v1" / title="Y Axis" position=bottomleft;
  	keylegend "v2" / title="Y2 Axis" position=bottomright;
	yaxis  min=0 label='Y1 axis' values=(0 to 3000 by 50);
	y2axis min=1 label='Y2 axis' values=(1 to 100000 by 10000);
   	xaxis display=(nolabel) grid;
   	yaxis label="Total Cases" grid;
	y2axis label="Cumulative Cases" grid;
RUN;
ods listing close;


/*---------------------------------------------------------------------------------------------------------------------
/* plot chart for variables total_cases and episode_wend
*/


ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Charts.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "Cases by Date"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'PROC' sheet_name = "CASES 7 DAY");
ods graphics on / width = 8in; 

/* Set the Titles/Footnotes */

TITLE justify=center color=CX000000 font="Arial" height=12 pt 
	'Total Cases, 7 day Rolling Avg & Cumulative Cases';

proc sql;
	create table dataout as 
		select 
			age_group,
			sum(total_cases) as total_cases
		from covid.covid_summary
		group by 1
		order by 1
	;
quit;

PROC gplot DATA=dataout ;
	plot total_cases * age_group ;
	TITLE 'Total COVID cases by Age Group';

RUN;
quit;


proc chart data=dataout;
vbar total_cases / discrete type=freq;
by age_group;
run;
quit;
/*

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Charts.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "Test"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'PROC' sheet_name = "CASES Per Week Ending");
ods graphics on / width = 8in; 


PROC gplot DATA=COVID.COVID_SUMMARY ;
	plot total_cases * episode_wend ;
	TITLE 'Total COVID cases by Episode Week Ending';

RUN;
quit;

/*---------------------------------------------------------------------------------------------------------------------
/* plot chart for variables total_cases and age_Grouop
*/


ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Charts.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "Test"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'PROC' sheet_name = "CASES Age Group");
ods graphics on / width = 8in; 


PROC gplot DATA=COVID.COVID_SUMMARY ;
	plot total_cases * age_group ;
	TITLE 'Total COVID cases by Age Group';

RUN;
quit;

/*---------------------------------------------------------------------------------------------------------------------
/* plot chart for variables total_cases by neighbourhood_id
*/

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Charts.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "Test"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'PROC' sheet_name = "CASES by Neighbourhood");
ods graphics on / width = 8in; 

PROC gplot DATA=COVID.COVID_SUMMARY;
	plot total_cases * neighbourhood_id ;
	TITLE 'Total COVID cases by Neighbourhood_ID';
RUN;
quit;
ods listing close;

/*---------------------------------------------------------------------------------------------------------------------
/* plot chart for variables total_cases by neighbourhood_id
*/

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Charts.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "Test"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'PROC' sheet_name = "CASES by Neighbourhood Summarized");
ods graphics on / width = 20in; 
PROC gplot DATA=COVID.COVID_NBH_Summary;
	plot total_cases * neighbourhood_id ;
	TITLE 'Total COVID cases by Neighbourhood ID Summarized';
RUN;
quit;
ods listing close;


/*---------------------------------------------------------------------------------------------------------------------
/* bubble plot chart for variables total_cases 
*/

title 'Bubble Plot';
PROC sgplot DATA=COVID.COVID_SUMMARY noborder;
    bubble x=episode_wend y=age_group size=total_cases / fillattrs=graphDATA1 bradiusmin=5px bradiusmax=35px
                DATAlabel=total_cases DATAlabelpos=center;
    xaxis grid display=(noline noticks nolabel);
    yaxis grid display=(noline noticks nolabel);
RUN;




/*---------------------------------------------------------------------------------------------------------------------
/* plot histogram for variables total_cases and neighbourhood_id
*/

ods graphics on;
PROC univariate
	DATA=COVID.COVID_summary;
	histogram total_cases episode_wend;
	var total_cases episode_wend;
	TITLE 'Total Cases by Week Ending ';
RUN;

/* plot histogram for variables total_cases and neighbourhood_id*/

ods graphics on;
PROC univariate
	DATA=COVID.COVID_NBH_Summary;
	histogram total_cases neighbourhood_id;
	var total_cases neighbourhood_id;
	TITLE 'Total Cases by Neighbourhood';
RUN;



/* plot histogram for variables total_cases and neighbourhood_id*/
/* junk 
ODS GRAPHICS ON;
TITLE "HISTOGRAM AND PROBABILITY PLOT FOR CASE_COUNT BY AGE";
PROC UNIVARIATE DATA=COVID.COVID_NBH_Summary;
CLASS NEIGHBOURHOOD_ID;
VAR total_cases;
HISTOGRAM total_cases;
INSET SKEWNESS KURTOSIS;
PROBPLOT total_cases;
INSET SKEWNESS KURTOSIS;
RUN;
ODS GRAPHICS OFF;
*/

TITLE "Box and Whisker Plot for To";
PROC SGPLOT DATA=COVID.COVID_NBH_SUMMARY;
	VBOX total_cases / CATEGORY=NEIGHBOURHOOD_ID;
RUN;
ODS GRAPHICS OFF;


/*---------------------------------------------------------------------------------------------------------------------
/* JUNK
*/
/* samples */

/*
RUN;
PROC sgplot DATA = demoplot noautolegend;
vbarparm category = terminal_id response = pershort /x2axis fillattrs =
(color = lightred) ;

/* box plto
/* Open the LISTING destination and assign the LISTING style to the graph */ 
ods listing style=listing;
ods graphics / width=5in height=2.81in;
title 'Mileage by Type and Origin';

/* RUN PROC SGPLOT on DATA SASHELP.CARS, selecting for sedans and sports cars 
PROC sgplot DATA=sashelp.cars(where=(type in ('Sedan' 'Sports'))) ;
  /*  generate a vertical box plot that groups by vehicle type
   *  and shows mileage by manufacturing region */
  vbox mpg_city / category=origin group=type groupdisplay=cluster
    lineattrs=(pattern=solid) whiskerattrs=(pattern=solid); 
  xaxis display=(nolabel);
  yaxis grid;
  keylegend / location=inside position=topright across=1;
RUN;


/* variable exploration (PROC MEANS, */



/****Other junk ****/

TITLE "DESCRIPTIVE STATISTICS ON ";
PROC MEANS DATA=COVID.COVID_DATA N MEAN STDERR CLM;

RUN;

ODS GRAPHICS ON;

TITLE "HISTOGRAM AND PROBABILITY PLOT FOR CASE_COUNT BY AGE";
PROC UNIVARIATE DATA=COVID.COVID_DATA;
CLASS AGE_GROUP;
VAR CASE_COUNT;
HISTOGRAM CASE_COUNT;
INSET SKEWNESS KURTOSIS;
PROBPLOT CASE_COUNT;
INSET SKEWNESS KURTOSIS;
RUN;

ODS GRAPHICS OFF;



ODS GRAPHICS ON;

TITLE "HISTOGRAM AND PROBABILITY PLOT FOR CASE_COUNT BY AGE";
PROC UNIVARIATE DATA=COVID.COVID_NBH_WEND_SUMMARY;
CLASS NEIGHBOURHOOD_ID;
VAR CASE_COUNT;
HISTOGRAM CASE_COUNT;
INSET SKEWNESS KURTOSIS;
PROBPLOT CASE_COUNT;
INSET SKEWNESS KURTOSIS;
RUN;

ODS GRAPHICS OFF;


TITLE "Box and Whisker Plot for Colesterol by Weigt Status";
PROC SGPLOT DATA=COVID.COVID_NBH_SUMMARY;
	VBOX case_count / CATEGORY=NEIGHBOURHOOD_ID;
RUN;
ODS GRAPHICS OFF;



/*---------------------------------------------------------------------------------------------------------------------
/* LInear Regression
/*

/* skaterplot */
/* Determine if there is a linear relationship between the two */
ODS GRAPHICS ON / WIDTH= 1000 IMAGEMAP=ON;
PROC SGSCATTER DATA=COVID.COVID_Summary;
	PLOT total_cases * age_group / REG;
RUN;


PROC CORR DATA=COVID.COVID_NBH_WEND_Summary PLOTS=MATRIX(NVAR=ALL HISTOGRAM);
VAR _nUMERIC_;
RUN;

PROC CORR DATA=COVID.COVID_NBH_WEND_Summary PLOTS=MATRIX(NVAR=ALL HISTOGRAM);
VAR _nUMERIC_;
RUN;

/* REGRESSION*/

PROC REG DATA= ACT.FITNESS;
MODEL = RUNTIME=OXYGEN_CONSUMPTION;


/*---------------------------------------------------------------------------------------------------------------------
/* LOGISTIC REGRESSION :this is what I need
/*  Classification (y/N, character values, etc)
/* binary (y/n)
/* Who is going to get Covid
*/

PROC LOGISTIC DATA=COVID.COVID_DATA PLOTS=ALL;
	CLASS Age_Group (PARAM=REF REF= '19 and younger');
	/*UNITS AGE=5 BALANCE=1000;*/
	MODEL case_count (EVENT='yes') = age_group  / CLODDS=PL;
RUN;




