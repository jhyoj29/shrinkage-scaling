* ----------------------------------------------------------------------
* Import Data
* ----------------------------------------------------------------------

clear 
cd "D:\git\shrinkage-scaling\1_Cross-section_Scaling" 

insheet using Scaling_foodaccom.csv, names

replace rate = subinstr(rate, "%", "", .)
destring rate, replace

* ----------------------------------------------------------------------
* EDA 
* ----------------------------------------------------------------------

//EDA
summarize pop10 pop20 fdac10 fdac20, format

// remove null
destring fdac10, replace ignore(" ")
destring fdac20, replace ignore(" ")

//null값 찾기
misstable summarize fdac10 fdac20

* ----------------------------------------------------------------------
* Scaling - Food & Accommodation
* ----------------------------------------------------------------------

// log transfomation (log(Y) = log(Y₀) + β*log(N))
generate ln_fdac10 = ln(fdac10)
generate ln_fdac20 = ln(fdac20)
generate ln_pop10 = ln(pop10)
generate ln_pop20 = ln(pop20)

// cross-sectional scaling (only depop city)
// t=2010
regress ln_fdac10 ln_pop10 if rate < 0
scalar beta_2010 = _b[ln_pop10]  
scalar r2_2010 = e(r2)
local beta_2010_str = string(beta_2010, "%4.3f")
display "2010 Scaling Exponent β: " beta_2010

// t=2020
regress ln_fdac20 ln_pop20 if rate < 0
scalar beta_2020 = _b[ln_pop20]  
scalar r2_2020 = e(r2)
local beta_2020_str = string(beta_2020, "%4.3f")
display "2020 Scaling Exponent β: " beta_2020

// 2010 graph
twoway (scatter ln_fdac10 ln_pop10, mcolor(navy) msize(small) msymbol(circle)) ///
       (lfit ln_fdac10 ln_pop10, lcolor(red) lwidth(thick)), ///
		by(cntry, title("2010 Food and Accommodation-pop scaling")  ///
        graphregion(color(white))) ///
		xtitle("LN[Population]") ytitle("LN[Food and Accommodation 2010]") ///
		legend(off) ///
		scheme(s1mono)
		
graph export "2010_foodaccom.png", replace

// 2020 graph
twoway (scatter ln_fdac20 ln_pop20, mcolor(navy) msize(small) msymbol(circle)) ///
       (lfit ln_fdac20 ln_pop20, lcolor(red) lwidth(thick)), ///
		by(cntry, title("2020 Food and Accommodation-pop scaling")  ///
        graphregion(color(white))) ///
		xtitle("LN[Population]") ytitle("LN[Food and Accommodation 2020]") ///
		legend(off) ///
		scheme(s1mono)
		
graph export "2020_foodaccom.png", replace
	   
// 2010 vs 2020 graph	
regress ln_fdac10 ln_pop10 if rate < 0 
local beta_2010_str = string(_b[ln_pop10], "%4.2f")
local r2_2010_str = string(e(r2), "%4.2f")

regress ln_fdac20 ln_pop20 if rate < 0 
local beta_2020_str = string(_b[ln_pop20], "%4.2f")
local r2_2020_str = string(e(r2), "%4.2f")

twoway (scatter ln_fdac10 ln_pop10 if rate < 0 , mcolor(navy%80) msize(small) msymbol(circle)) ///
       (lfit ln_fdac10 ln_pop10 if rate < 0 , lcolor(navy) lwidth(medium)) ///
       (scatter ln_fdac20 ln_pop20 if rate < 0 , mcolor(red%80) msize(small) msymbol(triangle)) ///
       (lfit ln_fdac20 ln_pop20 if rate < 0 , lcolor(red) lwidth(medium)), ///
       xtitle("LN[Population]") ytitle("LN[Food and Accommodation Businesses]") ///  
	   xlabel(5(2)15) ylabel(0(2)10) ///
       legend(order(1 "2010" 3 "2020") position(4) ring(0) region(lcolor(none) fcolor(none)) cols(1) size(*1.2)) ///
       graphregion(color(white)) ///
       scheme(s1mono) ///
       aspectratio(1) ///
       xsize(6) ysize(6) ///
       text(9.5 5 "2010: β=`beta_2010_str'  R{sup:2}=`r2_2010_str'",size(*1.3) placement(e)) ///
       text(8.8 5 "2020: β=`beta_2020_str'  R{sup:2}=`r2_2020_str'",size(*1.3) placement(e))

graph export "Figure_appendix_foodaccom.png", replace
	   
