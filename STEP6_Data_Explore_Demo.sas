
/**********************************************************************************************************************
/* NAME:		STEP_DATA_Explore_Demo
/* DESCRIPTION:	Exploration of Covid Demographic DATA
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

/* data for project */


VM_Yes / POP_Population					AS P_VM_Yes,
OCC_Ess_Yes / OCC_Tot					AS P_OCC_Ess_Yes,
INCHH_50000_99999 / HH_Tot				AS P_INC_50000_99999,
EDU_HS_Lower/ EDU_Tot					AS P_EDU_HS_Lower,

/*---------------------------------------------------------------------------------------------------------------------
/* list data info
*/
proc contents
data=COVID.COVID_NBH_SUMMARY OUT=Aoutdata;
run;

proc means data=COVID.COVID_NBH_SUMMARY;
  output out=aoutmeans;
run;

/*---------------------------------------------------------------------------------------------------------------------
/* Proc Freq
*/

/* case count, fatalities by neighbourhood */
ods output onewayfreqs=class_freqs;
proc freq data=COVID.COVID_NBH_SUMMARY;
  tables TOTAL_CASES;
run;
ods output close;

ods output onewayfreqs=class_freqs;
proc freq data=COVID.COVID_NBH_SUMMARY;
  tables neighbourhood_id * INFECTION_RATE;
run;
ods output close;

proc sql;
	create table testit as 
		select
			neighbourhood_id,
			NEIGHBOURHOOD_NAME,
			POP_POPULATION,
			infection_rate,
			total_cases
		from covid.covid_nbh_summary
		order by infection_rate desc
;
quit;



/*---------------------------------------------------------------------------------------------------------------------
/* plot histogram for variables infection_rates
*/


ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Charts.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "Test"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "NBH Infection Rates");
ods graphics on / width = 8in; 


ods graphics on;
PROC univariate
	DATA=COVID.COVID_NBH_SUMMARY;
	histogram infection_rate neighbourhood_id;
	var infection_rate neighbourhood_id;
	TITLE 'Infection rate by Neighbourhood ';
RUN;

/*---------------------------------------------------------------------------------------------------------------------
/* Charts
*/

/* Step9: display the box-whisker plot of infection rate by neighbourhood_id*/


proc sort 
data= Covid.covid_nbh_summary;
by neighbourhood_id;
run;

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Charts.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "Test"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "NBH Infection Rates");
ods graphics on / width = 8in; 

TITLE 'Neighbourhood Infection Rates';

proc boxplot
data=Covid.covid_nbh_summary;
plot infection_rate * neighbourhood_id;
run;

/*---------------------------------------------------------------------------------------------------------------------
/* neighbourhood infection rates and cases comparison 
/* gridattrs=(color=green pattern=longdash thickness=1)
*/
proc sql outobs=14;
	create table testit as 
		select *
	from covid.covid_nbh_summary
	order by infection_rate desc
;
run;

ods excel file="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\Charts\Charts.xlsx" ;
ods excel options(autofilter="1-5" sheet_name = "Test"
embedded_titles='yes' sheet_interval = 'none');

ods excel options(sheet_interval = 'proc' sheet_name = "Neighbourhood Cases");
ods graphics on / width = 15in; 

TITLE 'Neighbourhood Infection Rates and Total Cases';

proc sgplot data=testit cycleattrs;;
   	scatter x=neighbourhood_id y=total_cases / name='v1' ;
   	needle x=neighbourhood_id y=infection_rate/y2axix name='v2';
	keylegend "v1" / title="Y Axis" position=bottomleft;
	keylegend "v2" / title="Y2 Axis" position=bottomright;
	xaxis VALUES = (0 TO 140 BY 1) type=discrete discreteorder=data;
	yaxis  min=0 label='Y1 axis' values=(0 to 3000 by 50);
	y2axis min=0.005 label='Y2 axis' values=(0.005 to 0.10 by 0.0025);
    xaxis display=(nolabel) grid;
    yaxis label="total cases" grid;
run;
ods listing close;


/*---------------------------------------------------------------------------------------------------------------------
/* list data info
*/


/* means */

proc means 
data=COVID.COVID_NBH_Summary;
VAR P_OCC_Ess_Yes;
class infection_rate;
run;

/*---------------------------------------------------------------------------------------------------------------------
/* Frequency Distribution
/*
/* frequency distribution
/* high p-value means no significance and can be dropped
/* proc freq for categorical
/* mean for numerical
*/

proc freq
data=COVID.COVID_NBH_Summary;
table infection_rate * P_OCC_Ess_Yes/chisq;
/* list the fields you want in the proc freq*/
run;


/*---------------------------------------------------------------------------------------------------------------------
/* plot histogram for infection_rates
/*
*/

ods graphics on;
proc univariate
data=COVID.COVID_NBH_Summary;
histogram infectioN_rate;
var infection_rate;
run;


/* plot chart for variables total_cases and episode_wend
ods graphics on;
proc gplot data=COVID.COVID_NBH_Summary;
plot total_cases * episode_wend ;
run;
quit;

/*---------------------------------------------------------------------------------------------------------------------
/* plot histogram for Essential Workers and neighbourhood_id
/*
*/


ods graphics on;
proc univariate
data=COVID.COVID_NBH_Summary;
histogram P_IND_Ess_Yes P_OCC_Ess_Yes neighbourhood_id;
var P_IND_Ess_Yes P_OCC_Ess_Yes neighbourhood_id;
run;



/* plot chart for variables infection_rate and neighbourhood_id*/

ods graphics on;
proc gplot data=COVID.COVID_NBH_Summary;
plot INFECTION_RATE * neighbourhood_id ;
run;
quit;


/* plot infection_Rate distribution*/

ods graphics on;
proc univariate
data=COVID.COVID_NBH_Summary;
histogram infection_rate neighbourhood_id;
var infection_rate neighbourhood_id;
run;


