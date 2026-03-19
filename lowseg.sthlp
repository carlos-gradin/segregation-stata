{smcl}
{* March 2026}{...}
{hline}
help for {hi:lowseg (Version 1.2)}{right:Carlos Grad{c i'}n (March 2026)}
{hline}

{title:Segregation into low-paying occupations: concentration curve and indices for two groups}
(For conventional two-group segregation see {help dicseg}; for multigroup segregation see {help localseg})

{p 8 17 2} {cmd:lowseg} {it:unitvar} {it:groupvar} [{it:weights}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}]
, {cmdab:sort}{it:(sortvar)} [ {cmdab:f:ormat}{it:(%9.#f)} {cmdab:no:graph} {cmd:rif} {cmd:save} {cmdab:sc}{it:(stub)} {cmdab:cc}{it:(stub)} {cmd:step}
{cmdab:xtitle1}{it:(string)} {cmdab:ytitle1}{it:(string)} {cmdab:xtitle2}{it:(string)} {cmdab:ytitle2}{it:(string)}
{cmdab:labelc}{it:(string)} {cmdab:labelr}{it:(string)} {cmdab:labelccurve}{it:(string)} {cmdab:labelscurve}{it:(string)}
{cmd:graph_options1}{it:(string)} {cmd:graph_options2}{it:(string)} {cmd:graph_options3}{it:(string)} ]

{p 4 4 2} {cmd:fweights}, {cmd:aweights} and {cmd:iweights} are allowed; see {help weights}.


{title:Important}

{p 4 4 2}
It requires {cmd:matsort}, written by Paul Millar, to be previously installed; if not, install it by typing:

{p 8 4 2}
. net install matsort, all from(http://fmwww.bc.edu/RePEc/bocode/m)


{title:Description}

{p 4 4 2}
{cmd:lowseg} extends the conventional two-group segregation framework to measure the {it:stratification}
of occupations, i.e. whether one group is systematically segregated into low-paying (or low-quality) jobs.
It implements the methods proposed by Grad{c i'}n (2020).

{p 4 4 2}
The command computes:

{p 8 4 2}
(1) The conventional {bf:segregation curve} and associated indices (Gini and Dissimilarity), where units are sorted
by the reference group's share (gender ratio), following the standard approach (Duncan and Duncan 1955; Hutchens 1991).

{p 8 4 2}
(2) The {bf:concentration curve} and associated indices (Gini and Dissimilarity concentration), where units are
sorted by a variable measuring the quality of occupations (e.g. average earnings), as proposed by Grad{c i'}n (2020).

{p 4 4 2}
The concentration curve plots the cumulative proportions of workers for both groups across occupations indexed by
their quality (e.g. pay), instead of by the gender ratio as in the segregation curve. If the concentration curve
lies below the diagonal, there is {it:first-order stochastic dominance} (FOSD) indicating that the comparison group
is segregated into low-paying occupations (low-pay segregation). If it lies above, there is high-pay segregation.

{p 4 4 2}
The joint analysis of the segregation and concentration curves and their associated indices provides an integrated
framework for examining not only the extent of segregation but also its ordinal nature.

{p 8 4 2}
{it:unitvar} is a categorical variable identifying units (e.g. occupations, census tracts, schools).

{p 8 4 2}
{it:groupvar} is a dichotomous variable identifying two groups (comparison group = lowest value; reference group = highest value),
such as gender (female vs. male) or race (non-white vs. white).

{p 8 4 2}
{it:sortvar} (required) is a variable that ranks units by their quality (e.g. average earnings by occupation). Units are
sorted in ascending order of this variable.


{title:Reported indices}

{p 4 4 2}
{bf:Segregation indices} (units sorted by the reference group's share of each unit):

{p 8 4 2}
{bf:Gini} {c -} The Gini segregation index. This is the area between the segregation curve and the diagonal,
divided by its maximum value (Jahn, Schmid, and Schrag 1947; Duncan and Duncan 1955). It takes values between 0 (no
segregation) and 1 (full segregation), and ranks distributions consistently with non-intersecting segregation curves.

{p 8 4 2}
{bf:D} {c -} The Dissimilarity index (Hornseth 1947; Duncan and Duncan 1955). This is the maximum vertical distance between
the segregation curve and the diagonal. It represents the proportion of workers from each group that would
need to change occupation to achieve full integration. Values range from 0 to 1.

{p 8 4 2}
{bf:KM} {c -} The Karmel and MacLachlan (1988) index, a weighted version of D that accounts for group sizes:
KM = 2 * (N{sup:c}/N) * (N{sup:r}/N) * D.

{p 4 4 2}
{bf:Concentration indices} (units sorted by the sort variable, e.g. average earnings):

{p 8 4 2}
{bf:Gini{sub:c}} {c -} The Gini concentration index. This is twice the area between the concentration curve and
the diagonal (Somers 1962; Blackburn and Jarman 1997; Grad{c i'}n 2020). It takes positive values when
the comparison group is segregated into low-paying occupations (low-pay segregation), and negative values
when segregated into high-paying occupations (high-pay segregation). Bounded by [{c -}Gini, Gini].

{p 8 4 2}
{bf:D{sub:c}} {c -} The Dissimilarity concentration index. This is the largest vertical distance (in absolute
value, with the sign preserved) between the concentration curve and the diagonal (Grad{c i'}n 2020).
Positive values indicate low-pay segregation; negative values indicate high-pay segregation. Bounded by [{c -}D, D].

{p 8 4 2}
{bf:KM{sub:c}} {c -} The Karmel and MacLachlan concentration index, a weighted version of D{sub:c}.

{p 4 4 2}
{bf:Concentration ratios} (Grad{c i'}n 2020):

{p 8 4 2}
{bf:Ratio{sub:G}} = Gini{sub:c} / Gini {c -} The proportion of overall Gini segregation that is low-pay (or high-pay if negative).

{p 8 4 2}
{bf:Ratio{sub:D}} = D{sub:c} / D {c -} The proportion of Dissimilarity segregation that is low-pay (or high-pay if negative).

{p 8 4 2}
Both ratios range from {c -}1 to 1.


{title:Options}

{dlgtab:Required}

{p 4 8 2}
{cmdab:sort}{it:(sortvar)} specifies the variable by which units are ranked to measure low-pay segregation.
This is typically average earnings or wages by occupation.

{dlgtab:Output and format}

{p 4 8 2}
{cmdab:f:ormat}{it:(%9.#f)} changes the numeric display format. Default is {cmd:format(%9.4f)}.

{p 4 8 2}
{cmd:save} saves the segregation and concentration curve coordinates as new variables in the dataset
(prefixed with underscores): _Fc, _fc, _Fr, _fr (segregation curve); _Fdc, _fdc, _Fdr, _fdr (concentration curve);
_yy (sort variable values); _codeoccfc1 (unit codes, sorted).

{p 4 8 2}
{cmdab:sc}{it:(stub)} saves new variables for the segregation curve coordinates:
{it:stub}_c (cumulative comparison group) and {it:stub}_r (cumulative reference group).

{p 4 8 2}
{cmdab:cc}{it:(stub)} saves new variables for the concentration curve coordinates:
{it:stub}_c (cumulative comparison group), {it:stub}_r (cumulative reference group), and {it:stub}_{it:sortvar} (sort variable values).

{p 4 8 2}
{cmd:rif} computes and saves recentered influence function (RIF) variables for the Gini and Dissimilarity
indices and their concentration counterparts. Useful for decomposition analyses and standard error estimation.
Requires {cmd:save} to also be specified.

{dlgtab:Graphical options}

{p 4 8 2}
{cmdab:no:graph} suppresses all graphs (CDFs and curves).

{p 4 8 2}
{cmd:step} draws the CDFs as step functions instead of connecting points with lines.

{p 4 8 2}
{cmdab:labelc}{it:(string)} sets the label for the comparison group in the CDF graph legend. Default: "comparison group".

{p 4 8 2}
{cmdab:labelr}{it:(string)} sets the label for the reference group in the CDF graph legend. Default: "reference group".

{p 4 8 2}
{cmdab:labelccurve}{it:(string)} sets the legend label for the concentration curve. Default: "Concentration Curve".

{p 4 8 2}
{cmdab:labelscurve}{it:(string)} sets the legend label for the segregation curve. Default: "Segregation Curve".

{p 4 8 2}
{cmdab:xtitle1}{it:(string)}, {cmdab:ytitle1}{it:(string)} change the axis titles of the CDF graph.
Defaults: xtitle1 = {it:sortvar}; ytitle1 = "cdf".

{p 4 8 2}
{cmdab:xtitle2}{it:(string)}, {cmdab:ytitle2}{it:(string)} change the axis titles of the segregation/concentration curve graph.
Defaults: xtitle2 = "cdf comparison group"; ytitle2 = "cdf reference group".

{p 4 8 2}
{cmd:graph_options1}{it:(string)}, {cmd:graph_options2}{it:(string)}, {cmd:graph_options3}{it:(string)}
override the default graph options for the CDF graph, the concentration curve overlay, and the
segregation curve overlay, respectively.


{title:Saved results}

{p 4 4 2}
Scalars:

{col 10}{cmd:r(G)}{col 30}Gini segregation index
{col 10}{cmd:r(Gc)}{col 30}Gini concentration index
{col 10}{cmd:r(RatioG)}{col 30}Gini concentration ratio (Gc/G)
{col 10}{cmd:r(D)}{col 30}Dissimilarity segregation index
{col 10}{cmd:r(Dc)}{col 30}Dissimilarity concentration index
{col 10}{cmd:r(RatioD)}{col 30}Dissimilarity concentration ratio (Dc/D)
{col 10}{cmd:r(KM)}{col 30}Karmel-MacLachlan segregation index
{col 10}{cmd:r(KMc)}{col 30}Karmel-MacLachlan concentration index
{col 10}{cmd:r(Nunits)}{col 30}Number of units
{col 10}{cmd:r(Freq1)}{col 30}Population share (%) of comparison group
{col 10}{cmd:r(Freq2)}{col 30}Population share (%) of reference group

{p 4 4 2}
Matrix:

{col 10}{cmd:r(seg)}{col 30}Column vector of all indices (Gini, GiniC, RatioG, D, Dc, KM, KMc, RatioD)


{title:Graphs}

{p 4 4 2}
Unless {cmd:nograph} is specified, the command produces two graphs:

{p 8 4 2}
{bf:Graph 1: CDFs.} The cumulative distribution functions of the comparison and reference groups, with
occupations indexed by the sort variable (e.g. average earnings). The CDF of the comparison group lying to the
left (above) the reference group's CDF indicates low-pay segregation.

{p 8 4 2}
{bf:Graph 2: Segregation and Concentration curves.} This combines the segregation curve (units sorted by
gender ratio) and the concentration curve (units sorted by {it:sortvar}) with the 45-degree line. The
concentration curve is bounded between the segregation curve and its mirror image.


{title:Interpretation}

{p 4 4 2}
The framework distinguishes between {it:segregation} (unequal distribution across occupations) and
{it:stratification} (segregation into low- or high-quality occupations):

{p 8 4 2}
{c -} If Gini{sub:c} > 0 and D{sub:c} > 0 (concentration curve below the diagonal): the comparison group is
segregated into low-paying occupations.

{p 8 4 2}
{c -} If Gini{sub:c} < 0 and D{sub:c} < 0 (concentration curve above the diagonal): the comparison group is
segregated into high-paying occupations.

{p 8 4 2}
{c -} If Gini{sub:c} {c ~~} 0 (concentration curve near the diagonal): the employment distribution is
approximately pay-neutral.

{p 8 4 2}
{c -} The concentration ratios (Ratio{sub:G}, Ratio{sub:D}) measure the proportion of segregation that is
low-pay, ranging from {c -}1 to 1.


{title:Examples}

{p 4 8 2}
. {stata use segdata.dta, clear}

{p 4 4 2}
{bf:Basic usage} (occupational segregation of women into low-paying occupations):

{p 4 8 2}
. {stata lowseg occupation white [aw=pwgtp], sort(wage)}

{p 4 8 2}
. {stata ret list}

{p 4 4 2}
{bf:Saving curve coordinates}:

{p 4 8 2}
. {stata lowseg occupation white [aw=pwgtp], sort(wage) sc(segc) cc(conc)}

{p 4 4 2}
{bf:Step-function CDFs with custom labels}:

{p 4 8 2}
. {stata lowseg occupation white [aw=pwgtp], sort(wage) step labelc(female) labelr(male)}

{p 4 4 2}
{bf:Custom axis titles}:

{p 4 8 2}
. {stata lowseg occupation white [aw=pwgtp], sort(wage) sc(segc) cc(conc) step xtitle1(occupations) xtitle2(cdf blacks) labelc(black) labelr(white) ytitle2(discrimination curve (cdf whites))}

{p 4 4 2}
{bf:Suppressing graphs}:

{p 4 8 2}
. {stata lowseg occupation white [aw=pwgtp], sort(wage) nograph}

{p 4 4 2}
{bf:Computing RIF for decomposition analyses}:

{p 4 8 2}
. {stata lowseg occupation white [aw=pwgtp], sort(wage) save rif nograph}

{p 4 4 2}
{bf:Bootstrapping} (copy and paste the following into the command line or a .do file):

{p 8 8 2}
 {stata use segdata.dta, clear}

{p 8 8 2}
 cap program drop lpseg

{p 8 8 2}
 program def lpseg

{p 12 8 2}
 lowseg occupation white [aw=pwgtp], sort(wage) nograph

{p 8 8 2}
 end

{p 8 8 2}
 bootstrap r(G) r(Gc) r(RatioG) r(D) r(Dc) r(RatioD) r(KM) r(KMc), reps(100): lpseg

{p 8 8 2}
 estat bootstrap


{title:Author}

{p 4 4 2}{browse "http://webs.uvigo.es/cgradin": Carlos Grad{c i'}n}
<cgradin@uvigo.es>{break}
Facultade de CC. Econ{c o'}micas{break}
Universidade de Vigo{break}
36310 Vigo, Galicia, Spain.


{title:References}

{p 4 8 2}
Blackburn, Robert M. and Jennifer Jarman (1997), Occupational Gender Segregation, {it:Social Research Update}, 16, University of Surrey.

{p 4 8 2}
Deutsch, Joseph, Yves Fl{c u"}ckiger, and Jacques Silber (1994), Measuring Occupational Segregation: Summary Statistics and the Impact of Classification Errors and Aggregation, {it:Journal of Econometrics}, 61: 133{c -}146.

{p 4 8 2}
Duncan, Otis D. and Beverly Duncan (1955), A Methodological Analysis of Segregation Indexes, {it:American Sociological Review}, 20(2): 210{c -}217.

{p 4 8 2}
Grad{c i'}n, Carlos (2013), Segregation of Roma into Low-Paying Occupations in Romania, UNU-WIDER Working Paper 2013/106.

{p 4 8 2}
Grad{c i'}n, Carlos (2020),
{browse "https://doi.org/10.1080/00036846.2019.1682113": Segregation of Women into Low-Paying Occupations in the United States},
{it:Applied Economics}, 52(17): 1905{c -}1920.

{p 4 8 2}
Hornseth, Richard A. (1947), A Note on the Measurement of Racial Integration of Schools by Means of Informational Concepts, {it:Journal of the American Statistical Association}, 42: 546{c -}556.

{p 4 8 2}
Hutchens, Robert M. (1991), Segregation Curves, Lorenz Curves, and Inequality in the Distribution of People across Occupations, {it:Mathematical Social Sciences}, 21: 31{c -}51.

{p 4 8 2}
Jahn, Julius A., Calvin F. Schmid, and Clarence Schrag (1947), The Measurement of Ecological Segregation, {it:American Sociological Review}, 12(3): 293{c -}303.

{p 4 8 2}
Kakwani, Nanak C. (1980), {it:Income Inequality and Poverty: Methods of Estimation and Policy Applications}, Oxford University Press.

{p 4 8 2}
Karmel, Tom and Maclachlan, Maureen (1988), Occupational Sex Segregation {c -} Increasing or Decreasing, {it:Economic Record}, 64: 187{c -}195.

{p 4 8 2}
Semyonov, Moshe and Frank L. Jones (1999), Dimensions of Gender Occupational Differentiation in Segregation and Inequality: A Cross-National Analysis, {it:Social Indicators Research}, 46: 225{c -}247.

{p 4 8 2}
Somers, Robert H. (1962), A New Asymmetric Measure of Association for Ordinal Variables, {it:American Sociological Review}, 27(6): 799{c -}811.


{title:Also see}

{p 4 13 2}
{help dicseg} if installed; {help localseg} if installed; {help duncan} if installed; {help hutchens} if installed; {help seg} if installed


