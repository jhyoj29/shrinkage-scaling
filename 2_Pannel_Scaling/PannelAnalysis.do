* ----------------------------------------------------------------------
* Import Data
* ----------------------------------------------------------------------

clear 
cd "D:\git\shrinkage-scaling\2_Pannel_Scaling" 

insheet using Scaling_Pannel.csv, names

* ----------------------------------------------------------------------
* EDA & Filtering
* ----------------------------------------------------------------------

describe
summarize 

encode cityid, gen(city_num)
keep if depop == 1 
summarize if depop ==1, format

//log transformation
foreach var in grdp rtl_cmp fdac_cmp emp ht_cmp grad elmtry wlt_cmp ent_cmp bed {
    gen ln_`var' = ln(`var')
}
gen ln_pop = ln(pop)

//set pannel 
xtset city_num year


* ----------------------------------------------------------------------
* Scaling Anlaysis - 1) Model Selction(POLS vs FE vs RE)
* ----------------------------------------------------------------------

* (1) Pooled OLS
reg ln_emp ln_pop if emp < ., vce(cluster city_num)
estimates store pooled

* (2) Fixed Effect
xtreg ln_emp ln_pop i.year if emp < ., fe vce(cluster city_num)
estimates store fixed

* (3) Random Effect
xtreg ln_emp ln_pop i.year if emp < ., re vce(cluster city_num)
estimates store random

* Model Comparison
esttab pooled fixed random, ///
    b(%9.3f) se(%9.3f) ///
    stats(N r2 r2_a aic bic, fmt(%9.0g %9.3f %9.3f %9.3f %9.3f) ///
          labels("Observations" "R-squared" "Adj R-squared" "AIC" "BIC")) ///
    title("Results") ///
    mtitle("Pooled" "FE" "RE") ///
    star(* 0.10 ** 0.05 *** 0.01)

* Hausman test
xtreg ln_emp ln_pop i.year, fe
estimates store fixed
xtreg ln_emp ln_pop i.year, re
estimates store random

hausman fixed random 


* ----------------------------------------------------------------------
* Scaling Anlaysis - 2) Random Effect Pannel Analysis
* ----------------------------------------------------------------------

estimates clear

local varlist rtl_cmp fdac_cmp emp ht_cmp grad elmtry wlt_cmp ent_cmp bed


//GRDP Variable Analysis (Excluding Vietnam)
xtreg ln_grdp ln_pop i.year if grdp < . & COUNTRY != "베트남", re vce(cluster city_num)
estimates store model_grdp

foreach var of local varlist {

    //Only analyze with no missing values
    xtreg ln_`var' ln_pop i.year if `var' < ., re vce(cluster city_num)
    estimates store model_`var'
}

* Model Comparison
esttab model_* , ///
     b(%9.3f) se(%9.3f) ///
    stats(N r2_o r2_w r2_b, fmt(%9.3f) labels("Obs" "R2 Overall" "R2 Within" "R2 Between")) ///
    title("Random Effects Models") ///
    mtitles( "grdp" "rtl_cmp" "fdac_cmp" "emp" "ht_cmp" "grad" "elmtry" "wlt_cmp" "ent_cmp" "bed") ///
    star(* 0.10 ** 0.05 *** 0.01)
	
	

esttab model_* using "results.rtf", ///
    b(%9.3f) ci(%9.3f) ///
    stats(N r2_o r2_w r2_b, fmt(%9.3f) labels("Obs" "R2 Overall" "R2 Within" "R2 Between")) ///
    title("Random Effects Models") ///
    mtitles("grdp" "rtl_cmp" "fdac_cmp" "emp"  "ht_cmp" "grad" "elmtry" "wlt_cmp" "ent_cmp" "bed") ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    replace
	
