/**********************************************************************************************************************
/* NAME:		STEP1_Data_Import
/* DESCRIPTION:	Import source files 
/* DATE:		Jan 25, 2021
/* AUTHOR:		Marlene Martins
/* NOTES:		Data downloaded form City of Toronto Open data Portal:
/* 				- Covid19 Cases in Toronto
/*				- Neighbourhood Profiles Demographic Data
/*				- Social Housing Unit by Density by Neighbourhood
/*				- NIA: Neighbourhood Improvement Areas in Toronto
/*  
/**********************************************************************************************************************
/* Modifications
/*
/*
/*
/**********************************************************************************************************************


/*---------------------------------------------------------------------------------------------------------------------
/* Assign files for COVID related Input data
/*
*/

/* Neighbourhood Demographics Source File*/
libname NBH_DEMO XLSX "\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\DATA\Input\NBH_Demographics.xlsx";   

/* Toronto Covid Cases Source File*/
libname COVID_FL XLSX "\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\DATA\Input\Covid19_cases.xlsx";   


/* Neighbourhoods Improvement Areas*/
libname NBH_NIA XLSX "\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\DATA\Input\NBH_NIA.xlsx";   


/* Neighbourhoods Social HOusing */
libname NBH_SH XLSX "\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\DATA\Input\NBH_social_housing.xlsx";   


/* Neighbourhoods Reference File*/
libname NBH_REF XLSX "\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\DATA\Input\NBH_Reference.xlsx";   


/*---------------------------------------------------------------------------------------------------------------------
/* Read in required data from Covid Data file
/*---------------------------------------------------------------------------------------------------------------------

/* because Excel field names often have spaces */
options validvarname=any;
 
/*---------------------------------------------------------------------------------------------------------------------
/* Import Covid Toronto Case data 
/* 		Data is updated daily
/* 		Before upload, ensure spaces in column names have been converted to "_"
/*		Save csv as xlsx
*/
proc datasets lib=COVID_FL; quit;

data COVID.COVID_DATA_RAW;
  set COVID_FL.DATA;  
run;

/*---------------------------------------------------------------------------------------------------------------------
/* Import Neighbourhood Demographics data 
/* 		Data has been pre-selected in XLSX
/*		Does not change
*/

proc datasets lib=NBH_DEMO; quit;

data COVID.NBH_DEMO_RAW;
  set NBH_DEMO.DATA;  
run;


/*---------------------------------------------------------------------------------------------------------------------
/* Import Neighbourhood social housing data 
/* 		Data has been saved XLSX
/*		Does not change
*/

proc datasets lib=NBH_SH ; quit;

data COVID.NBH_SH_RAW;
  set NBH_SH.DATA;  
run;


/*---------------------------------------------------------------------------------------------------------------------
/* Import Neighbourhood Improvement Areas data
/* 		Data has been saved XLSX
/*		Does not change
*/

proc datasets lib=NBH_NIA ; quit;

data COVID.NBH_NIA_RAW;
  set NBH_NIA.DATA;  
run;


/*---------------------------------------------------------------------------------------------------------------------
/* Import Neighbourhood Reference data
/* 		Not needed
*/

proc datasets lib=NBH_REF ; quit;

data COVID.NBH_DATA;
  set NBH_REF.DATA;  
run;

/*---------------------------------------------------------------------------------------------------------------------
/* Export file
/* 		
*/
/*---------------------------------------------------------------------------------------------------------------------
/* Export
/*COVID.COVID_SUMMARY_Date
COVID.COVID_SUMMARY_NBH_Date 
*/
proc export data = COVID.COVID_NBH_Summary
 outfile = "\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\DATA\COVID_NBH_Summary.Xlsx"
 dbms = xlsx replace; 
 sheet = "DATA"; 
 run; 


proc export data = COVID.COVID_SUMMARY_Date
 outfile = "\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\DATA\COVID_Summary_Date.Xlsx"
 dbms = xlsx replace; 
 sheet = "DATA"; 
 run; 

proc export data = COVID.COVID_SUMMARY_NBH_Date
 outfile = "\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\DATA\COVID_Summary_NBH_Date.Xlsx"
 dbms = xlsx replace; 
 sheet = "DATA"; 
 run; 



 proc export data=COVID.COVID_NBH_Summaryo dbms=csv

outfile="\\nappgsd01\domesticbanking\Retail Lending\Credit Cards - Common\Business Analytics\BI Team\Credit Card Reporting\Projects\ADH0820\DATA\COVID_NBH_Summaryo.CSV"

replace;
