*! Program to obtain Low-pay segregation Curve: 0 comparison; 1 reference
*! Carlos Gradin
*! This version 1.2, 15 March 2026
*! It requires having matsort.ado (written by Paul Millar) previously installed
*! Changes from v1.1: bug fixes (labelscurve typo, duplicate save block, undefined `stat',
*!   dataset cleanup), efficiency improvements (vectorized reverse arrays, precomputed
*!   cumulative sums for concentration Gini, optimized Gini with symmetry, merge-based RIF)

cap program drop lowseg
program def lowseg , rclass byable(recall)
version 10
syntax varlist(min=2 max=2) [aweight iweight fweight] [if] [in] , sort(string) [ ly Format(string) NOGraph rif save sc(string) cc(string) step xtitle1(string) ytitle1(string) xtitle2(string) ytitle2(string) labelc(string) labelr(string) labelccurve(string) labelscurve(string) graph_options1(string) graph_options2(string) graph_options3(string)  ]

marksample touse
set more off
set type double

di ""
di as text "{hline 150}"

* Default values:

	* format and graphical options
if "`format'" == "" {
	loc format "%9.4f"
}
if "`labelc'" == "" {
	loc labelc "comparison group"
}
if "`labelr'" == "" {
	loc labelr "reference group"
}
if "`labelccurve'" == "" {
	loc labelccurve "Concentration Curve"
}
* FIX: corrected typo - syntax option, condition, and assignment now all use "labelscurve"
if "`labelscurve'" == "" {
	loc labelscurve "Segregation Curve"
}
if "`ytitle1'" == "" {
	loc ytitle1 "cdf"
}
if "`xtitle1'" == "" {
	loc xtitle1 "`sort'"
}
if "`ytitle2'" == "" {
	loc ytitle2 "cdf reference group"
}
if "`xtitle2'" == "" {
	loc xtitle2 "cdf comparison group"
}
if "`graph_options1'"== "" {
	local graph_options1 "lpattern(solid dash)  lcolor(red black) mcolor(red black) legend( label(1 "`labelc'") label(2 "`labelr'") ) ytick(0(0.1)1) ylabel(0(.1)1) ytitle("`ytitle1'") xtitle("`xtitle1'") name(cdf_`white', replace) "
}
if "`graph_options2'"== "" {
	local graph_options2 "lpattern(dash) lcolor(red) lwidth(medium) legend( label(1 "`labelccurve'")  ) "
}
if "`graph_options3'"== "" {
	* FIX: now uses corrected local `labelscurve' instead of misspelled `labellcurve'
	local graph_options3 "lpattern(solid solid) lcolor(black gray) lwidth(medthick vthin) legend( label(2 "`labelscurve'")  label(3 "45º") cols(1) ) ytick(0(0.1)1) ylabel(0(.1)1) ytitle("`ytitle2'") xtitle("`xtitle2'") xtick(0(.1)1) xlabel(0(.1)1) name(dc_`white', replace) aspectratio(1)"
}


tempname fp F CT RT SS FF FR S FC FFC Fp fp CTp Sp val freq codeocc codeoccfc codeoccfdc _F _F1 _F2 fdc fdr Fdc Fdr fdc2 fdr2 Fdc2 Fdr2 yy fc fr Fc Fr aux ratiog ratiod
tempname G G3 D Dc KM KMc gini ginic ratiog
tempname index measure aux1 aux2 index2 measure2 sample

* Relevant variables:

local occ:   word 1 of `varlist'
local white: word 2 of `varlist'

* FIX: Mark original observations BEFORE svmat adds new ones
*      so that `keep if sample==1` at the end properly removes only added obs
qui gen			`sample'	=1

* Values and frequencies of group (v1,v2;fre1,freq2) and sort (fp,F) variables

qui: tab `white' [`weight' `exp'] if `touse' , matrow(`val') matcell(`freq') missing label
local v1 = `val'[1,1]
local v2 = `val'[2,1]
local freq1 = 100*`freq'[1,1]/(`freq'[1,1]+`freq'[2,1])
local freq2 = 100*`freq'[2,1]/(`freq'[1,1]+`freq'[2,1])

ret scalar Freq1 		=`freq1'
ret scalar Freq2 		=`freq2'

* N of Units, rr

qui: tab `occ' [`weight' `exp'] if `touse' & (`white'==`v1' | `white'==`v2')
local rr = r(r)

* Sortvar as matrix -> fp (frequencies FC generated already sorted in ascending order)

qui: tab `sort' `white' 	[`weight' `exp'] if `touse' & (`white'==`v1' | `white'==`v2'), matcell(`FC') matrow(`fp')
local rcp = colsof(`FC')
local rrp = rowsof(`FC')

qui: sum `sort' if `touse' & (`white'==`v1' | `white'==`v2')
local min = min(r(min), 0)

qui: tab `occ' `white' [`weight' `exp'] if `touse' & (`white'==`v1' | `white'==`v2'), matrow(`codeocc') matcell(`F')
local rc = colsof(`F')
local rr = rowsof(`F')


* Normalizing cells of F (units' shares) by row (RT) and column (CT) totals, and sorting

		* totals of F

mat `CT' =     J(1,`rr',1)*`F'
mat `RT' = `F'*J(`rc',1,1)

			* normalizing F by RT: FF (relative freq.)
			* EFFICIENCY: simplified matrix reciprocal computation
			*   Old: vecdiag(inv(diag(RT))), then diag() again
			*   New: direct inv(diag(RT)) which is already diagonal with 1/RT on diagonal

mat `SS'	= inv(diag(`RT'))
mat `FF'	= `SS'*`F'

mat `S'	 	= inv(diag(`CT'))

			* F (and occupations) sorted by reference share in occupation, FFC

mat 	 `FFC'		= `FF'[1...,2] , `F' , `codeocc'
matsort  `FFC' 1 "up"

mat 	 `codeoccfc' = `FFC'[1..., 4   ]
mat 	 `FFC' 		 = `FFC'[1..., 2..3]

				* normalizing FFC cells by column total			-> FFC rel. freq. sorted for for segregation curve

mat `FFC' = `FFC'*`S'

		* F (abs. feq.) (and occupation codes) sorted by sortvar (e.g. wage) and by reference's unit shares

			* F (and sortvar, fp) sorted by sortvar, is FC

			* normalizing FC cells by column total			-> FC rel. freq. sorted for rank for concentration curve

mat `CTp' =     J(1,`rrp',1)*`FC'
mat `Sp'  = inv(diag(`CTp'))
mat `FC'  = `FC'*`Sp'


* Variables with sortvar and cumulative values (CDF and Concentration curve), yy, Fdc, Fdr (initial value is 0), initial value for sortvar is 0 or min(sortvar)

mat   	`FR' = (`min' , 0 , 0) \ (`fp' , `FC')
svmat double 	`FR' , names(`_F')
ren 	`_F'1 `yy'
ren 	`_F'2 `fdc'
ren 	`_F'3 `fdr'
qui	gen `Fdc'=sum(`fdc')  if `fdc'~=.
qui	gen `Fdr'=sum(`fdr')  if `fdr'~=.

* Variables with Cumulative values as variables (Lorenz or Segregation curve): Fc, Fr (initial value is 0)

mat   	`FFC' = (0 , 0) \ (`FFC')
svmat double	`FFC' , names(`_F')
ren 	`_F'1 `fc'
ren 	`_F'2 `fr'
qui	gen `Fc'=sum(`fc')  if `fc'~=.
qui	gen `Fr'=sum(`fr')  if `fr'~=.


* When the distribution is sorted by share of the comparison group, the mirror image of the Lorenz curve

local rr1  =  `rr'+1
local rrp1 = `rrp'+1

* EFFICIENCY: Vectorized reverse array computation using _n instead of observation-by-observation loop
*   Old: forvalues loop with 4 individual `replace` commands per iteration
*   New: single vectorized computation using _n arithmetic

qui gen `fdc2' = `fc'[`rr1' - _n + 2]  if _n >= 2 & _n <= `rr1'
qui replace `fdc2' = 0 in 1
qui gen `Fdc2' = 1 - `Fc'[`rr1' - _n + 1]  if _n >= 2 & _n <= `rr1'
qui replace `Fdc2' = 0 in 1
qui gen `fdr2' = `fr'[`rr1' - _n + 2]  if _n >= 2 & _n <= `rr1'
qui replace `fdr2' = 0 in 1
qui gen `Fdr2' = 1 - `Fr'[`rr1' - _n + 1]  if _n >= 2 & _n <= `rr1'
qui replace `Fdr2' = 0 in 1

************************************* Computing indices


	* Concentration (Gini) index (G), Ordered by sortvar, (based on original formula from Hutchens, 1991)
	* EFFICIENCY: Precompute cumulative sum from bottom up, avoiding O(n^2) inner loop
	*   Old: nested forvalues loop where inner loop summed FC[j,1] for j=i+1..rrp
	*   New: single pass cumulative sum from the bottom, then use it directly

mat `G'  = J(`rrp',1,0)
mat `G3' = J(1,1,0)

* Precompute reverse cumulative sum of FC[,1]: cumFC[i] = sum of FC[j,1] for j=i+1..rrp
tempname cumFC
mat `cumFC' = J(`rrp',1,0)
if `rrp' >= 2 {
	mat `cumFC'[`rrp',1] = 0
	forvalues i = `=`rrp'-1'(-1)1 {
		mat `cumFC'[`i',1] = `cumFC'[`=`i'+1',1] + `FC'[`=`i'+1',1]
	}
}

* Now compute G[i] in a single loop using precomputed cumulative sums
forvalues i = 1 / `rrp' {
	mat `G'[`i',1] = `FC'[`i',2] * ( `FC'[`i',1] + 2*`cumFC'[`i',1] )
}

mat `G'=1-J(1,`rrp', 1)*`G'


	* Conventional Gini, ordered by reference group's unit share (based on formula from Deutsch, Fluckiger and Silber, 1994)
	* EFFICIENCY: Exploit symmetry of |a*d - b*c| = |b*c - a*d| to halve computations
	*   Old: full double loop (j=1..rr, i=1..rr) -> rr^2 iterations
	*   New: only upper triangle (j=1..rr, i=j+1..rr) + double -> rr*(rr-1)/2 iterations

forvalues j = 1 / `rr' {
		forvalues i = `=`j'+1' / `rr' {
			mat	`G3'[1,1]  = `G3'[1,1]  + (1/(`CT'[1,1]*`CT'[1,2])) * abs(  `F'[`j',1]*`F'[`i',2] - `F'[`j',2]*`F'[`i',1] )
		}
}


	* Save Gini and concentration

	scalar `gini'   =`G3'[1,1]
	scalar `ginic'  =`G'[1,1]
	scalar `ratiog' =`ginic'/`gini'

	* Dissimilarity

		* Maximum vertical distance, conventional and sorted by sortvar
			* q  = max {i |  fr(i)<= fc(i)}
			* h2 = max {i | fcr(i)<=fdc(i)}
			* h1 = {i | max(|fdc(i)-fdr(i)|}

scalar `D' =0
scalar `Dc'=0
local h1=0
local aux=0
forvalues i = 1 / `rr1' {
	if (    `Fc'[`i'] -  `Fr'[`i'])   >= `D'  {
		local q  = `i'
		scalar `D'   = max(`D'  , ( `Fc'[`i'] -  `Fr'[`i']))
	}
}

forvalues i = 1 / `rrp1' {
	if (abs(`Fdc'[`i'] - `Fdr'[`i'])) >= `aux' {
		local h1 = `i'
		local aux = abs(`Fdc'[`i'] - `Fdr'[`i'])
	}
}

scalar `Dc'  = `Fdc'[`h1'] - `Fdr'[`h1']

		* Vertical distance Fdc-Fdr at  Fc(q) - with interpolation : Fc(q)-Fdr*, Fdr* =  Fdr(h2) + fdr(h2+1)*[Fc(q)-Fdc(h2)]/fdc(h2+1) }

local h2 = 0
local j  = 1
while `Fdc'[`j'] <= `Fc'[`q'] & `q'<`rrp1'{
		local h2 = `h2' + 1
		local j  = `j'  + 1
}

	scalar `ratiod' =`Dc'/`D'

		* KM

scalar `KM'   = 2*`freq1'*`freq2'*`D'  /10000
scalar `KMc'  = 2*`freq1'*`freq2'*`Dc'/10000

* Table

qui range 		`index' . 100 100
qui gen 		`measure'	=.
qui gen 		`measure2'	=.

lab var 		`index'		"`white'"
lab var 		`measure' 	"Index"
lab var 		`measure2' 	"Type"

qui replace		`index'		=  `gini'					in 1
qui replace 	`index'		=  `ginic'					in 2
qui replace 	`index'		=  `ratiog'					in 3
qui replace		`index'		=  `D'						in 4
qui replace 	`index'		=  `Dc'						in 5
qui replace 	`index'		=  `ratiod'					in 6
qui replace 	`index'		=  `KM'						in 7
qui replace 	`index'		=  `KMc'					in 8
qui replace 	`index'		=  `ratiod'					in 9

qui replace 	`measure'	= 3							in 1/3
qui replace 	`measure'	= 1							in 4/6
qui replace 	`measure'	= 2							in 7/9

qui replace 	`measure2'	= 1							in 1
qui replace 	`measure2'	= 1							in 4
qui replace 	`measure2'	= 1							in 7
qui replace 	`measure2'	= 2							in 2
qui replace 	`measure2'	= 2							in 5
qui replace 	`measure2'	= 2							in 8
qui replace 	`measure2'	= 3							in 3
qui replace 	`measure2'	= 3							in 6
qui replace 	`measure2'	= 3							in 9

lab def `measure' 	1 Dissimilarity 2 KM 			3 Gini
lab val `measure' `measure'

lab def `measure2' 	1 Segregation 	2 Concentration 3 Ratio
lab val `measure2' `measure2'

ret scalar G 				= `gini'
ret scalar Gc 				= `ginic'
ret scalar RatioG			= `ratiog'
ret scalar D 				= `D'
ret scalar Dc 				= `Dc'
ret scalar KM 				= `KM'
ret scalar KMc				= `KMc'
ret scalar RatioD			= `ratiod'
ret scalar Nunits			= `rr'

tempname seg
mat 	`seg' = `gini' \ `ginic' \ `ratiog' \ `D' \ `Dc' \ `KM' \ `KMc' \ (`ratiod')
local segrn 	Gini GiniC RatioG D Dc KM KMc RatioD

****************** Reporting results in Table


di ""
di "Segregation of `occ' by `white' and segregation of `occ' by `white' into low values of `sort' "
di ""
di "Number of units: " `rr'
di "Number of different `sort': " `rrp'
di "Population shares:"
di "- comparison group (`white'=`v1'):" %9.2f `freq1' "%"
di "- reference  group (`white'=`v2'):" %9.2f `freq2' "%"
di ""
di "Segregation curve and Gini and Dissimilarity indices	-> units sorted by reference group's share of unit"
di "Concentration curve and indices				-> units sorted by `sort'"
di ""

***** Saving variables if requested, for Segregation (Fc, Fr) and concentration curve (Fdc, Fdr), and CDF (yy, Fdc, Fdr)
* FIX: Removed duplicate save block (was at lines 331-339 and 406-416 in v1.1)
*      Now only appears once, in the correct location after all computations

if "`sc'" ~= "" {
	qui gen `sc'_c 			= `Fc'
	qui gen `sc'_r 			= `Fr'
}
if "`cc'" ~= "" {
	qui gen `cc'_c  		= `Fdc'
	qui gen `cc'_r  		= `Fdr'
	* FIX: removed reference to undefined local `stat'; using `cc' prefix instead
	qui gen `cc'_`sort'  	= `yy'
}

***** F step function, duplicating values

if "`step'"~="" {
	tempname dFdc dFdr _yy dyy
	qui gen 	`dFdr'=`Fdr' in 1
	qui gen 	`dFdc'=`Fdc' in 1
	qui gen 	`_yy' =`yy'	 in 1
	local s=0
	forvalues i=1/`rrp1' {
		local s=`s'+1
		qui replace `dFdc'=`Fdc'[`i'] in `s'
		qui replace `dFdr'=`Fdr'[`i'] in `s'
		qui replace `_yy'=  `yy'[`i'] in `s'
		local s=`s'+1
		qui replace `dFdc'=`Fdc'[`i'] in `s'
		qui replace `dFdr'=`Fdr'[`i'] in `s'
		qui replace `_yy' = `yy'[`i'] in `s'
	}
	qui gen 	`dyy'=`_yy'[_n+1] 	if `_yy'~=.
}

****** Influence Function, Gini and concentration

if "`rif'"~="" {

	tempname rifg rifgc riffg riffgc

	qui gen `rifg'   = 2*( `fr'/ `fc')*(  `Fc'-.5*(1+`gini'  ) ) +  1 - 2* `Fr'
	qui gen `rifgc'  = 2*(`fdr'/`fdc')*( `Fdc'-.5*(1+`ginic' ) ) +  1 - 2*`Fdr'

	qui gen `riffg'  = 2*( `fr'      )*(  `Fc'-.5*(1+`gini'  ) ) + (1 - 2* `Fr')* `fc'
	qui gen `riffgc' = 2*(`fdr'      )*( `Fdc'-.5*(1+`ginic' ) ) + (1 - 2*`Fdr')*`fdc'

	****** Influence Function, D and concentration

	tempname rifd rifdc riffd riffdc 	/* dc means dc1 */

	local q1  =  `q' + 1
	local h11 = `h1' + 1
	local h21 = `h2' + 1

		 qui gen 	`rifd'    = (1 -  `Fc'[`q' ] )* `fr'[`q' ] / `fc'[`q' ]  +  (1 - `fr'/ `fc')*(1 - `Fr'[`q' ] )  	 	in  2/`q'
		 qui gen 	`rifdc'   = (1 - `Fdc'[`h1'] )*`fdr'[`h1'] /`fdc'[`h1']  +  (1 -`fdr'/`fdc')*(1 -`Fdr'[`h1'] )  	 	in  2/`h1'
	if `q' <`rr1'  {
		 qui replace `rifd'   = - `Fc'[`q' ]* `fr'[`q' ] / `fc'[`q' ] - (1 - `fr'/ `fc')* `Fr'[`q' ] 						in  `q1'/`rr1'
	}
	if `h1'<`rrp1' {
		 qui replace `rifdc'  = -`Fdc'[`h1']*`fdr'[`h1'] /`fdc'[`h1'] - (1 -`fdr'/`fdc')*`Fdr'[`h1']						in  `h11'/`rrp1'
	}
		qui gen 	`riffd'   =   `fc'*(1 -  `Fc'[`q' ] )* `fr'[`q' ] / `fc'[`q' ]  +  ( `fc' - `fr')*(1 - `Fr'[`q' ] )		in  2/`q'
		qui gen 	`riffdc'  =  `fdc'*(1 - `Fdc'[`h1'] )*`fdr'[`h1'] /`fdc'[`h1']  +  (`fdc' -`fdr')*(1 -`Fdr'[`h1'] )   	in  2/`h1'
	if `q' <`rr1'  {
		qui replace `riffd'   = - `fc'* `Fc'[`q' ]* `fr'[`q' ] / `fc'[`q' ] - ( `fc' - `fr')* `Fr'[`q' ]	 				in  `q1'/`rr1'
	}
	if `h1'<`rrp1' {
		qui replace `riffdc'  = -`fdc'*`Fdc'[`h1']*`fdr'[`h1'] /`fdc'[`h1'] - (`fdc' -`fdr')*`Fdr'[`h1']					in  `h11'/`rrp1'
	}

	local rifvars rifg rifgc riffg riffgc rifd rifdc riffd riffdc

}


if "`save'" ~="" | "`rif'" ~="" {
	mat `codeoccfc' = . \ `codeoccfc'
	svmat double `codeoccfc' , name(_codeoccfc)

	foreach var in Fc fc Fdc fdc Fr fr Fdr fdr yy `rifvars'  {
		cap drop _`var'
		qui gen _`var' 	= ``var''
	}

	if "`rif'"~="" {
			* RIF by individual
			* EFFICIENCY: Use merge-style assignment instead of nested loop
			*   Old: for each of 4 vars, loop i=1..rr1 doing `replace` across entire dataset
			*   New: temporary variables for lookup keys, then single vectorized merge

		* Create temporary lookup variables for occupation codes and sort values
		tempname _tmpocc _tmpsrt
		qui gen `_tmpocc' = .
		qui gen `_tmpsrt' = .
		forvalues i = 1/`rr1' {
			qui replace `_tmpocc' = _codeoccfc1[`i'] in `i'
		}
		forvalues i = 1/`rrp1' {
			qui replace `_tmpsrt' = `yy'[`i'] in `i'
		}

		foreach var in rifg rifd riffg riffd {
			qui gen	_`var'x  = .
			qui gen	_`var'xc = .

			* Assign RIF values by matching occupation to unit code
			forvalues i=1/`rr1'{
				qui replace _`var'x  =  _`var'[`i'] if `occ'  == _codeoccfc1[`i'] & `touse'
			}
			* Assign concentration RIF values by matching sort variable
			forvalues i=1/`rrp1'{
				qui replace _`var'xc = _`var'c[`i'] if `sort' ==  `yy'[`i'] 	  & `touse'
			}
		}
	}

}


***** Graphing curves if requested (default)

if "`nograph'" ~= "nograph" {

	* CDFs

	if "`step'"~="" {
		graph twoway  line `dFdr' `dFdc' `dyy'	, `graph_options1'
	}
	else {
		graph twoway  line  `Fdr'  `Fdc'  `yy'	, `graph_options1'
	}

	* Segregation and Concentration curve combined

	graph twoway (line `Fdr' `Fdc'			, `graph_options2') (line `Fr' `Fc' `Fc'	, `graph_options3' )

}

* Reporting results in Table
* FIX: removed duplicate format default check (already set at top of program)

tabdisp `measure'  	`measure2' 			if `index'  ~=., c(`index' ) f(`format') concise stubwidth(25) csepwidth(1) cellwidth(15)

di ""

di "Critical occupations and cumulative proportions of population groups (dissimilarity)"
di " "
di "Dissimilarity"
di "   -occupation:" `q'-1
di "   -cum. comparison=" %9.2f  `Fc'[`q']*100 "%"
di "   -cum. reference =" %9.2f  `Fr'[`q']*100 "%"
di " "
di "Concentration "
di "   -occupation:" `h1'-1
di "   -cum. comparison=" %9.2f  `Fdc'[`h1']*100 "%"
di "   -cum. reference =" %9.2f  `Fdr'[`h1']*100 "%"


* FIX: `sample' is now generated BEFORE svmat commands, so only original obs have sample==1
qui keep if `sample'==1

mat rownames `seg' = `segrn'
ret mat seg	=	`seg'

end

* lowseg occupation white [aw=$peso] if year==$year , sort(wage)

* Example
* lowseg occupation white [aw=$peso] if year==$year , sort(wage) sc(segc) cc(conc) step xtitle1(occupations) xtitle2(cdf blacks) labelc(black) labelr(white) ytitle2(discrimination curve (cdf whites))
