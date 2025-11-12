* ----------------------------------------------------------------------
* Import Data
* ----------------------------------------------------------------------

clear 
cd "D:\git\shrinkage-scaling\1_Cross-section_Scaling" 

insheet using scaling_GRDP.csv, names

replace rate = subinstr(rate, "%", "", .)
destring rate, replace

* ----------------------------------------------------------------------
* EDA & imputation
* ----------------------------------------------------------------------

//EDA
summarize pop10 pop20 grdp10 grdp20 if rate < 0, format


//Stochastic Imputation 

misstable summarize grdp10 grdp20

generate growth_rate = (grdp20 - grdp10)/grdp10 if !missing(grdp10) & !missing(grdp20)
regress growth_rate pop10 pop20 if !missing(growth_rate)

predict growth_pred if missing(grdp10)
predict growth_resid if !missing(growth_rate), residuals

summarize growth_resid
scalar sigma_growth = r(sd)

set seed 12345
generate random_error = rnormal(0, sigma_growth) if missing(grdp10)
replace growth_pred = growth_pred + random_error if missing(grdp10)

replace grdp10 = grdp20/(1 + growth_pred) if missing(grdp10)

drop growth_rate growth_pred growth_resid random_error

* ----------------------------------------------------------------------
* Scaling - GRDP
* ----------------------------------------------------------------------

// log transfomation (log(Y) = log(Y₀) + β*log(N))
generate ln_grdp10 = ln(grdp10)
generate ln_grdp20 = ln(grdp20)
generate ln_pop10 = ln(pop10)
generate ln_pop20 = ln(pop20)

// cross-sectional scaling (only depop city)
// t=2010
regress ln_grdp10 ln_pop10 if rate < 0
scalar beta_2010 = _b[ln_pop10]  
scalar r2_2010 = e(r2)
local beta_2010_str = string(beta_2010, "%4.3f")
display "2010 Scaling Exponent β: " beta_2010

// t=2020
regress ln_grdp20 ln_pop20 if rate < 0
scalar beta_2020 = _b[ln_pop20]  
scalar r2_2020 = e(r2)
local beta_2020_str = string(beta_2020, "%4.3f")
display "2020 Scaling Exponent β: " beta_2020

twoway (scatter ln_grdp10 ln_pop10 if rate < 0 , mcolor(blue) msize(small) msymbol(circle)) ///
       (lfit ln_grdp10 ln_pop10 if rate < 0 , lcolor(blue) lwidth(medium)) ///
       (scatter ln_grdp20 ln_pop20 if rate < 0 , mcolor(red) msize(small) msymbol(triangle)) ///
       (lfit ln_grdp20 ln_pop20 if rate < 0 , lcolor(red) lwidth(medium)), ///
       title("GRDP-pop scaling: 2010 vs 2020" "(depop)") ///
       subtitle("2010 β = `beta_2010_str', 2020 β = `beta_2020_str'") ///
       xtitle("LN[Population]") ytitle("LN[GRDP]") ///
       legend(label(1 "2010") label(2 "2010 fitted line") ///
              label(3 "2020") label(4 "2020 fitted line")) ///
       graphregion(color(white)) ///
       scheme(s1mono)
graph export "2010_2020_GRDP.png", replace


// 2010 graph
twoway (scatter ln_grdp10 ln_pop10, mcolor(navy) msize(small) msymbol(circle)) ///
       (lfit ln_grdp10 ln_pop10, lcolor(red) lwidth(thick)), ///
		by(cntry, title("2010 GRDP-pop scaling")  ///
        graphregion(color(white))) ///
		xtitle("LN[Population]") ytitle("LN[GRDP 2010]") ///
		legend(off) ///
		scheme(s1mono)
		
graph export "2010_GRDP.png", replace

// 2020 graph
twoway (scatter ln_grdp20 ln_pop20, mcolor(navy) msize(small) msymbol(circle)) ///
       (lfit ln_grdp20 ln_pop20, lcolor(red) lwidth(thick)), ///
		by(cntry, title("2020 GRDP-pop scaling")  ///
        graphregion(color(white))) ///
		xtitle("LN[Population]") ytitle("LN[GRDP 2020]") ///
		legend(off) ///
		scheme(s1mono)
		
graph export "2020_GRDP.png", replace

// 2010 vs 2020 graph	
regress ln_grdp10 ln_pop10 if rate < 0
local beta_2010_str = string(_b[ln_pop10], "%4.2f")
local r2_2010_str = string(e(r2), "%4.2f")

regress ln_grdp20 ln_pop20 if rate < 0 
local beta_2020_str = string(_b[ln_pop20], "%4.2f")
local r2_2020_str = string(e(r2), "%4.2f")

twoway (scatter ln_grdp10 ln_pop10 if rate < 0, mcolor(navy%80) msize(small) msymbol(circle)) ///
       (lfit ln_grdp10 ln_pop10 if rate < 0 , lcolor(navy) lwidth(medium)) ///
       (scatter ln_grdp20 ln_pop20 if rate < 0 , mcolor(red%80) msize(small) msymbol(triangle)) ///
       (lfit ln_grdp20 ln_pop20 if rate < 0 , lcolor(red) lwidth(medium)), ///
       xtitle("LN[Population]") ytitle("LN[GRDP]") ///
       legend(order(1 "2010" 3 "2020") position(4) ring(0) region(lcolor(none) fcolor(none)) cols(1) size(*1.2)) ///
       graphregion(color(white)) ///
       scheme(s1mono) ///
       aspectratio(1) ///
       xsize(6) ysize(6) ///
       text(19.5 8 "2010: β=`beta_2010_str'  R{sup:2}=`r2_2010_str'",size(*1.3) placement(e)) ///
       text(19 8 "2020: β=`beta_2020_str'  R{sup:2}=`r2_2020_str'",size(*1.3) placement(e))

graph export "Figure_appedix_grdp.png", replace


