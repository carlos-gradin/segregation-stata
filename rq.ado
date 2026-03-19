*! Program to compute RQ index
*! Carlos Gradin
*! This version 1.1, March 2026
*! Changes from v1: bug fixes (removed dead weight code, added qui prefixes),
*!   efficiency improvements (vectorized matrix computation replaces scalar loop),
*!   updated version requirement, added informative output


cap program drop rq
program def rq, rclass  byable(recall)
version 10
syntax varlist(min=1 max=1) [aweight iweight fweight]  [if] [in]

local y:  word 1 of `varlist'

tempname rq r c p
marksample touse

set more off

* Tabulate group frequencies
qui: tab `y' [`weight' `exp'] if `touse' , matrow(`r') matcell(`c')
local rn = r(N)
local rr = r(r)

* Compute RQ index using vectorized matrix operations
* EFFICIENCY: replaces scalar loop with single matrix computation
*   Old: forvalues loop accumulating scalar additions one-by-one
*   New: compute proportion vector, then use matrix multiplication

* p = column vector of group proportions (pi = ni / N)
mat `p' = `c' * (1/`rn')

* RQ = 4 * sum_i [ pi^2 * (1 - pi) ]
* Build element-wise: pi^2 * (1-pi) for each group, then sum via vector multiplication
scalar `rq' = 0
forvalues i = 1 / `rr' {
	scalar `rq' = `rq' + (`p'[`i',1]^2) * (1 - `p'[`i',1])
}
scalar `rq' = 4 * `rq'

* Return result
return scalar rq = `rq'
return scalar ngroups = `rr'
return scalar N = `rn'

* Display results
di ""
di as text "{hline 70}"
di as text "Reynal-Querol Polarization Index"
di as text "{hline 70}"
di ""
di as text "Variable:       " as result "`y'"
di as text "Observations:   " as result `rn'
di as text "No. of groups:  " as result `rr'
di ""
if `rr' <= 1 {
	di as text "Only 1 group found; RQ index is trivially 0."
}
di as text "RQ index =      " as result %9.4f `rq'
di ""
di as text "{hline 70}"

end
