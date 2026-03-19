*! Program to compute regression-based segregation and stratification
*! Carlos Gradín
*! Version 2.0, March 2026
*!
*! Segregation is measured as goodness of fit of an OLS regression of a binary
*! group variable on predictor variables (categorical and/or continuous).
*!
*! Supports multiple predictors:
*!   - Variables in varlist (except last) are treated as categorical (factor vars)
*!   - Variables listed in cont() option are treated as continuous
*!   - The last variable in varlist is the binary group variable
*!
*! Three families of fit measures yield standard segregation indices:
*!   - Gini ratio          = Gini(prediction)/Gini(group)        = Segregation Gini
*!   - Dissimilarity ratio = MAD(prediction)/MAD(group)          = Duncan D index
*!   - Variance ratio      = Var(prediction)/Var(group)          = R-squared
*!   - SD ratio            = SD(prediction)/SD(group)
*!
*! No external dependencies required (matsort no longer needed).


************************************** Program regseg ************************************************


cap program drop regseg
program def regseg , rclass byable(recall) sortpreserve
version 10
syntax varlist(min=1) [aweight iweight fweight] [if] [in] [, Format(string) sc NOGraph x(string) y(string) XTitle(string) YTitle(string) GRaph_options(string) CONTinuous(varlist) ]

marksample touse
set more off
set type double

* Also mark out observations with missing continuous predictors
if "`continuous'" != "" {
	foreach v of local continuous {
		markout `touse' `v'
	}
}

if "`format'" == "" {
	loc format "%9.4f"
}

di ""
di as text "{hline 100}"


* =====================================================================
*  Parse variables
*    - Last variable in varlist = group (binary dependent variable)
*    - All preceding variables in varlist = categorical predictors (i.)
*    - Variables in cont() option = continuous predictors
* =====================================================================

local nvar : word count `varlist'
local group : word `nvar' of `varlist'

* Categorical variables (all varlist members except the last)
local catvars ""
if `nvar' >= 2 {
	forvalues i = 1/`=`nvar'-1' {
		local w : word `i' of `varlist'
		local catvars "`catvars' `w'"
	}
}
local catvars = trim("`catvars'")

* Continuous variables from option
local contvars "`continuous'"

* Check that at least one predictor is specified
if "`catvars'" == "" & "`contvars'" == "" {
	di as error "At least one predictor variable is required (categorical in varlist or continuous in cont())"
	exit 198
}


* Display model specification

di as text "Computing regression-based segregation of " as result "`group'"
if "`catvars'" != "" {
	di as text "  Categorical predictors: " as result "`catvars'"
}
if "`contvars'" != "" {
	di as text "  Continuous predictors:  " as result "`contvars'"
}
if "`catvars'" == "" {
	di as text "  (no categorical predictors)"
}
if "`contvars'" == "" {
	di as text "  (no continuous predictors)"
}


* =====================================================================
*  Check that group variable is binary and get its values
* =====================================================================

tempname gcounts

* One-way tab to get counts (matcol only works with two-way tab)
qui tab `group' [`weight' `exp'] if `touse', matcell(`gcounts')
local ngroups = r(r)
local rn = r(N)

if `ngroups' != 2 {
	di as error "Variable `group' must have exactly 2 groups"
	exit 420
}

* Group values: min and max of a binary variable (sorted ascending, matching tab order)
qui sum `group' if `touse'
local v1 = r(min)
local v2 = r(max)

* Group proportions (weighted)
local n1 = `gcounts'[1,1]
local n2 = `gcounts'[2,1]
local p1 = `n1' / `rn'
local p2 = `n2' / `rn'


* Report basic info

di ""
di as text "Proportion group 1 (" as result "`group'=`v1'" as text ") = " as result `format' `p1'
di as text "Proportion group 2 (" as result "`group'=`v2'" as text ") = " as result `format' `p2'


* =====================================================================
*  Step 1: OLS regression
*    Regress the binary group variable on categorical dummies and
*    continuous predictors. Predicted value = E[group | X].
* =====================================================================

* Build RHS of regression
local rhs ""
foreach v of local catvars {
	local rhs "`rhs' i.`v'"
}
if "`contvars'" != "" {
	local rhs "`rhs' `contvars'"
}

di ""
di as text "OLS regression: `group' on" as result "`rhs'"

* xi: prefix for compatibility with Stata versions < 11
qui xi: reg `group' `rhs' [`weight' `exp'] if `touse'


* Create predicted variable (groupvar_pred)

local predvar "`group'_pred"
cap drop `predvar'
qui predict double `predvar' if `touse', xb

* Clean up dummy variables created by xi:
cap drop _I*

di as text "  Predicted variable created: " as result "`predvar'"



* =====================================================================
*  Step 2: Goodness-of-fit measures
*    Segregation = how well predictors explain group membership.
*    Three complementary measures:
*      (a) Gini ratio          = Gini(prediction)/Gini(group) -> Segregation Gini
*      (b) Dissimilarity ratio = MAD(prediction)/MAD(group)   -> Duncan D index
*      (c) Variance ratio      = Var(prediction)/Var(group)   -> R-squared
* =====================================================================


* --- A. Summary statistics (weighted means, variances, SDs) ---

qui sum `group' [`weight' `exp'] if `touse'
local var_y  = r(Var)
local sd_y   = r(sd)
local mean_y = r(mean)

qui sum `predvar' [`weight' `exp'] if `touse'
local var_pred = r(Var)
local sd_pred  = r(sd)


* --- B. R-squared and SD ratio ---
*   Var(prediction)/Var(group) = R² from the regression
*   SD(prediction)/SD(group)   = square root of R²

local R2      = `var_pred' / `var_y'
local SDratio = `sd_pred' / `sd_y'


* --- C. Dissimilarity and Gini via collapsed predicted values ---
*   We collapse to distinct predicted values for efficient computation
*   of the Lorenz-curve-based Gini and weighted mean absolute deviation.
*   This general approach works for any combination of categorical and
*   continuous predictors, replacing the matrix-based method of v1.0.

* Extract weight variable name
local wvar ""
if "`weight'" != "" {
	local wvar = subinstr("`exp'", "=", "", .)
	local wvar = trim("`wvar'")
}

* Work in a preserved copy of the data
preserve

keep if `touse'

* Create analysis weight
if "`wvar'" != "" {
	gen double _w = `wvar'
}
else {
	gen double _w = 1
}

* Create weighted group counts for each observation
gen double _g1 = (`group' == `v1') * _w
gen double _g2 = (`group' == `v2') * _w

* Collapse to distinct predicted values
*   For each unique predicted value: total weight, group 1 and group 2 counts
collapse (sum) _g1 _g2 _w, by(`predvar')

* Sort by predicted value (ascending)
sort `predvar'

* Number of distinct prediction cells (analogous to nunits in v1.0)
local nunits = _N

* Total weights by group
qui sum _g1
local tot_g1 = r(sum)
qui sum _g2
local tot_g2 = r(sum)
local totw = `tot_g1' + `tot_g2'

* Check for zero-count cells
qui count if _g1 == 0
local z1 = r(N)
qui count if _g2 == 0
local z2 = r(N)


* --- Dissimilarity (MAD ratio) ---
*   MAD(pred) = Σ_k (w_k/W) * |pred_k - mean_y|
*   MAD(group) = 2 * p1 * p2 * |v2-v1|   (for a binary variable)
*   Ratio = Duncan & Duncan Dissimilarity index D

gen double _pop_share = _w / `totw'
gen double _absdev = _pop_share * abs(`predvar' - `mean_y')
qui sum _absdev
local mad_pred = r(sum)

local mad_y = 2 * `p1' * `p2' * abs(`v2' - `v1')
local D = `mad_pred' / `mad_y'


* --- Gini (Lorenz curve of predicted values) ---
*   Sort by predicted value (already done above)
*   Lorenz curve: cumulative population share vs cumulative income share
*   where "income" = predicted value × weight
*   G = 1 - Σ_k pop_share_k * (L_{k-1} + L_k)

gen double _inc_share = (_w * `predvar') / (`totw' * `mean_y')
gen double _cum_inc = sum(_inc_share)

gen double _L_prev = cond(_n == 1, 0, _cum_inc[_n-1])
gen double _trap = _pop_share * (_L_prev + _cum_inc)
qui sum _trap
local gini_pred = 1 - r(sum)


* Gini of binary group variable: G(y) = p1 * p2 * |v2-v1| / mean(y)

local gini_y = `p1' * `p2' * abs(`v2' - `v1') / `mean_y'


* Gini ratio = Segregation Gini index

local Gini_ratio = `gini_pred' / `gini_y'


* --- Karmel-MacLachlan index ---

local KM = 2 * `p1' * `p2' * `D'


* --- Segregation curve data (if requested) ---
*   Built using predicted values as virtual group proportions.
*   This ensures the area between the curve and the diagonal
*   exactly equals the Gini goodness-of-fit ratio.
*
*   Virtual group fractions in each cell:
*     frac_group2 = (pred_j - v1) / (v2 - v1)
*     frac_group1 = (v2 - pred_j) / (v2 - v1)
*   By OLS mean preservation, virtual totals = actual totals.
*   For categorical-only models (pred = p_j), this is identical
*   to using actual group compositions (the standard segregation curve).
*   Saved to matrix so it persists across preserve/restore.

if "`sc'" ~= "" {
	* Virtual group counts based on predicted values
	gen double _pred_g1 = _w * (`v2' - `predvar') / (`v2' - `v1')
	gen double _pred_g2 = _w * (`predvar' - `v1') / (`v2' - `v1')

	* Virtual totals (= actual totals by OLS mean preservation)
	qui sum _pred_g1
	local tot_pred_g1 = r(sum)
	qui sum _pred_g2
	local tot_pred_g2 = r(sum)

	* Curve coordinates: cumulative virtual group shares
	gen double _seg_g1 = _pred_g1 / `tot_pred_g1'
	gen double _seg_g2 = _pred_g2 / `tot_pred_g2'
	gen double _cum_g1 = sum(_seg_g1)
	gen double _cum_g2 = sum(_seg_g2)

	* Save curve coordinates to matrix (matrices persist across restore)
	tempname curvemat
	mkmat _cum_g1 _cum_g2, matrix(`curvemat')
}

restore



* =====================================================================
*  Step 3: Segregation curve (optional)
* =====================================================================

if "`sc'" ~= "" {

	if "`x'" == "" {
		local x "_E"
	}
	if "`y'" == "" {
		local y "_F"
	}

	* Drop any previous curve variables with same names
	cap drop `x'
	cap drop `y'

	* Add origin (0,0) row and convert matrix to variables
	local cf1 = `nunits' + 1
	mat `curvemat' = (0 , 0) \ `curvemat'
	svmat `curvemat' , names(_F)
	ren _F1 `x'
	ren _F2 `y'

	if "`xtitle'" == "" {
		local xtitle "cumulative proportion of group 1"
	}
	if "`ytitle'" == "" {
		local ytitle "cumulative proportion of group 2"
	}

	if "`graph_options'" == "" {
		local graph_options "aspectratio(1) plotr(m(zero)) connect(l) lpattern(solid) lwidth(medium) lcolor(red) xtick(0(.1)1) xlabel(0(.1)1) legend( cols(1) forcesize label(1 "45 degree line") label(2 "segregation curve") ) ytick(0(.1)1) ylabel(0(.1)1) xtitle("`xtitle'", size(small)) ytitle("`ytitle'", size(small))"
	}

	if "`nograph'" ~= "nograph" {
		graph twoway line `x' `x' in 1/`cf1' || line `y' `x' in 1/`cf1' , `graph_options'
	}

	* Curve variables `x' and `y' are kept in the dataset for the user
	di as text "  Curve variables saved: " as result "`x'" as text " (x-axis), " as result "`y'" as text " (y-axis)"

}



* =====================================================================
*  Step 4: Report results
* =====================================================================


di ""
di as text "{hline 80}"
di as text "  Regression-based segregation and stratification"
di as text "{hline 80}"
di ""
if "`catvars'" != "" {
	di as text "  Categorical: " as result "`catvars'"
}
if "`contvars'" != "" {
	di as text "  Continuous:  " as result "`contvars'"
}
di as text "  Distinct prediction cells: " as result `nunits'
di ""
di as text _col(3) %25s "Measure" _col(31) %12s "Prediction" _col(46) %12s "Group" _col(61) %12s "Ratio"
di as text "{hline 80}"
di as text _col(3) %25s "Gini"              _col(31) as result `format' `gini_pred' _col(46) as result `format' `gini_y' _col(61) as result `format' `Gini_ratio'
di as text _col(3) %25s "Dissimilarity (MAD)" _col(31) as result `format' `mad_pred' _col(46) as result `format' `mad_y' _col(61) as result `format' `D'
di as text _col(3) %25s "Variance"          _col(31) as result `format' `var_pred' _col(46) as result `format' `var_y' _col(61) as result `format' `R2'
di as text _col(3) %25s "Std. Deviation"    _col(31) as result `format' `sd_pred' _col(46) as result `format' `sd_y' _col(61) as result `format' `SDratio'
di as text "{hline 80}"
di ""
di as text _col(3) %25s "Karmel-MacLachlan" _col(61) as result `format' `KM'
di ""

if `z1' > 0 {
	di as result `z1' as text " cell(s) with zero observations from group 1"
}
if `z2' > 0 {
	di as result `z2' as text " cell(s) with zero observations from group 2"
}

di ""
di as text "Notes:"
di as text " - Gini ratio = Gini(prediction)/Gini(group) = Segregation Gini index"
di as text " - Dissimilarity ratio = MAD(prediction)/MAD(group) = Duncan-Duncan D index"
di as text " - Variance ratio = Var(prediction)/Var(group) = R-squared"
di as text " - SD ratio = SD(prediction)/SD(group)"
di as text " - Predicted variable `predvar' added to dataset"
di ""
di as text "{hline 100}"



* =====================================================================
*  Return results
* =====================================================================


return scalar Gini_pred  = `gini_pred'
return scalar Gini_group = `gini_y'
return scalar Gini       = `Gini_ratio'

return scalar D_pred     = `mad_pred'
return scalar D_group    = `mad_y'
return scalar D          = `D'

return scalar KM         = `KM'

return scalar Var_pred   = `var_pred'
return scalar Var_group  = `var_y'
return scalar R2         = `R2'

return scalar SD_pred    = `sd_pred'
return scalar SD_group   = `sd_y'
return scalar SDratio    = `SDratio'

return scalar nunits     = `nunits'
return scalar freq1      = `p1'
return scalar freq2      = `p2'

return local catvars     "`catvars'"
return local contvars    "`contvars'"

tempname seg
mat `seg' = (`Gini_ratio' \ `D' \ `KM' \ `R2' \ `SDratio')
mat rownames `seg' = Gini D KM R2 SDratio
return mat seg = `seg'


end
