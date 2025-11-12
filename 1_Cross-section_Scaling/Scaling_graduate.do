* ----------------------------------------------------------------------
* Import Data
* ----------------------------------------------------------------------

clear 
cd "D:\git\shrinkage-scaling\1_Cross-section_Scaling" 

insheet using Scaling_graduate.csv, names

replace rate = subinstr(rate, "%", "", .)
destring rate, replace

replace grad10 = subinstr(grad10, ",", "", .)
destring grad10, replace

replace grad20 = subinstr(grad20, ",", "", .)
destring grad20, replace
* ----------------------------------------------------------------------
* EDA 
* ----------------------------------------------------------------------

//EDA
summarize pop10 pop20 grad10 grad20 if rate < 0, format


//Stochastic Imputation 

misstable summarize grad10 grad20

generate gradrate20 = grad20/pop20 if !missing(grad20) & !missing(pop20)
generate popgrowth = (pop20-pop10)/pop10 if !missing(pop10) & !missing(pop20)

generate growth_rate = (grad20 - grad10)/grad10 if !missing(grad10) & !missing(grad20)

regress growth_rate gradrate20 popgrowth if !missing(growth_rate)

predict growth_pred if missing(grad10)
predict growth_resid if !missing(growth_rate), residuals

summarize growth_resid
scalar sigma_growth = r(sd)

set seed 12345
generate random_error = rnormal(0, sigma_growth) if missing(grad10)
replace growth_pred = growth_pred + random_error if missing(grad10)

replace grad10 = grad20/(1 + growth_pred) if missing(grad10)

drop growth_rate growth_pred growth_resid random_error


* ----------------------------------------------------------------------
* Scaling - University Graduates
* ----------------------------------------------------------------------

// log transfomation (log(Y) = log(Y₀) + β*log(N))
generate ln_grad10 = ln(grad10)
generate ln_grad20 = ln(grad20)
generate ln_pop10 = ln(pop10)
generate ln_pop20 = ln(pop20)


// cross-sectional scaling (only depop city)
// t=2010
regress ln_grad10 ln_pop10 if rate < 0 & grad10 <.
scalar beta_2010 = _b[ln_pop10]
scalar r2_2010 = e(r2)
display "2010 Scaling Exponent β: " beta_2010

// t=2020
regress ln_grad20 ln_pop20 if rate < 0
scalar beta_2020 = _b[ln_pop20]
scalar r2_2020 = e(r2)
display "2020 Scaling Exponent β: " beta_2020

// 2010 graph
twoway (scatter ln_grad10 ln_pop10, mcolor(navy) msize(small) msymbol(circle)) ///
       (lfit ln_grad10 ln_pop10, lcolor(red) lwidth(thick)), ///
		by(cntry, title("2010 graduate-pop scaling")  ///
        graphregion(color(white))) ///
		xtitle("LN[Population]") ytitle("LN[graduate 2010]") ///
		legend(off) ///
		scheme(s1mono)
		
graph export "2010_graduate.png", replace

// 2020 graph
twoway (scatter ln_grad20 ln_pop20, mcolor(navy) msize(small) msymbol(circle)) ///
       (lfit ln_grad20 ln_pop20, lcolor(red) lwidth(thick)), ///
		by(cntry, title("2020 graduate-pop scaling")  ///
        graphregion(color(white))) ///
		xtitle("LN[Population]") ytitle("LN[graduate 2020]") ///
		legend(off) ///
		scheme(s1mono)
		
graph export "2020_graduate.png", replace


// 2010 vs 2020 graph	
regress ln_grad10 ln_pop10 if rate < 0 
local beta_2010_str = string(_b[ln_pop10], "%4.2f")
local r2_2010_str = string(e(r2), "%4.2f")

regress ln_grad20 ln_pop20 if rate < 0 
local beta_2020_str = string(_b[ln_pop20], "%4.2f")
local r2_2020_str = string(e(r2), "%4.2f")

twoway (scatter ln_grad10 ln_pop10 if rate < 0 , mcolor(navy%80) msize(small) msymbol(circle)) ///
       (lfit ln_grad10 ln_pop10 if rate < 0 , lcolor(navy) lwidth(medium)) ///
       (scatter ln_grad20 ln_pop20 if rate < 0 , mcolor(red%80) msize(small) msymbol(triangle)) ///
       (lfit ln_grad20 ln_pop20 if rate < 0 , lcolor(red) lwidth(medium)), ///
       xtitle("LN[Population]") ytitle("LN[University Graduates]") ///  
	   xlabel(5(2)15) ylabel(2(2)12) ///
       legend(order(1 "2010" 3 "2020") position(4) ring(0) region(lcolor(none) fcolor(none)) cols(1) size(*1.2)) ///
       graphregion(color(white)) ///
       scheme(s1mono) ///
       aspectratio(1) ///
       xsize(6) ysize(6) ///
       text(12 5 "2010: β=`beta_2010_str'  R{sup:2}=`r2_2010_str'",size(*1.3) placement(e)) ///
       text(11.3 5 "2020: β=`beta_2020_str'  R{sup:2}=`r2_2020_str'",size(*1.3) placement(e))

graph export "Figure_appendix_graduate.png", replace