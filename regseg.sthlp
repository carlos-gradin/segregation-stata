{smcl}
{* March 2026}{...}
{hline}
help for {hi:regseg (Version 2.0)}{right:Carlos Grad{c i'}n (March 2026)}
{hline}

{title:Regression-based segregation and stratification indices}
(For standard segregation indices see {help dicseg}; for low-pay segregation see {help lowseg})

{p 4 4 2}
{cmd:regseg} [{it:catvar1} [{it:catvar2} ...]] {it:groupvar} [{it:weights}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}]
[,  {cmdab:cont:inuous}{it:(varlist)} {cmdab:f:ormat}{it:(%9.#f)} {cmdab:sc:} {cmdab:no:graph} {cmdab:x:}{it:(newvar)} {cmdab:y:}{it:(newvar)} {cmdab:xt:itle}{it:(xtitle)} {cmdab:yt:itle}{it:(ytitle)} {cmdab:gr:aph_options}{it:(graph_options)} ]

{p 4 4 2} {cmd:fweights}, {cmd:aweights} and {cmd:iweights} are allowed; see {help weights}.


{title:Description}

{p 4 4 2}
{cmd:regseg} computes regression-based segregation and stratification indices. It estimates an OLS regression of a binary group variable on one or more predictor variables and measures segregation as goodness of fit.

{p 4 4 2}
The approach is as follows:

{p 8 4 2}
1. Estimate an OLS regression of {it:groupvar} (e.g. gender) on predictor variables.
Variables in the main varlist (except the last, which is {it:groupvar}) are treated as {bf:categorical} (entered as factor variables).
Variables in the {opt cont()} option are treated as {bf:continuous}.

{p 8 4 2}
2. Generate a new variable ({it:groupvar}_pred) with the predicted values.
When only categorical predictors are used, each individual's prediction equals the mean of the group variable in their cell (e.g. the proportion of the reference group in their occupation).
When continuous predictors are included, the prediction is the linear fit E[{it:groupvar} | X].

{p 8 4 2}
3. Compute segregation as three ratios measuring how well the predictors explain group membership:

{p 12 4 2}
- {bf:Gini ratio} = Gini(prediction) / Gini(group) = Segregation Gini index

{p 12 4 2}
- {bf:Dissimilarity ratio} = MAD(prediction) / MAD(group) = Duncan-Duncan Dissimilarity index

{p 12 4 2}
- {bf:Variance ratio} = Var(prediction) / Var(group) = R-squared

{p 12 4 2}
- {bf:SD ratio} = SD(prediction) / SD(group)

{p 4 4 2}
{it:groupvar} is a dichotomous variable identifying two groups (e.g. male/female, white/nonwhite). It must be the {bf:last} variable listed in the varlist.

{p 4 4 2}
All other variables in the varlist are treated as {bf:categorical predictors} (units such as occupations, industries, census tracts, schools, etc.).

{p 4 4 2}
Variables listed in {opt cont()} are treated as {bf:continuous predictors} (e.g. mean years of education, income, etc.).

{p 4 4 2}
At least one predictor (categorical or continuous) must be specified.

{p 4 4 2}
Each row of the output shows the measure for the prediction, the measure for the group variable, and their ratio. The ratio corresponds to a standard segregation index:

{p 8 4 2}
The Gini ratio equals the Gini segregation index (Hutchens, 1991).

{p 8 4 2}
The Dissimilarity ratio equals the Duncan and Duncan (1955) D index.

{p 8 4 2}
The Variance ratio equals the R-squared from the regression.

{p 4 4 2}
A Karmel-MacLachlan index is also reported.


{title:Options}

{p 4 8 2}
{cmdab:cont:inuous}{it:(varlist)} specifies one or more continuous predictor variables. These are entered directly (not as factor variables) on the right-hand side of the OLS regression.
Categorical predictors are listed in the main varlist (before {it:groupvar}); continuous predictors are listed in this option.

{p 4 8 2}
{cmdab:f:ormat}{it:(%9.#f)} to change numeric format, the default is {cmdab:f:ormat}{it:(%9.4f)}.

{p 4 8 2}
{cmdab:sc:} to compute the segregation curve and save the curve variables to the dataset.
The curve is built using predicted values as virtual group proportions, so that the area
between the curve and the 45-degree line exactly equals the Gini goodness-of-fit ratio.
For categorical-only models this is identical to the standard segregation curve (since
predicted values equal actual group proportions). For models with continuous predictors,
this yields the curve consistent with the reported Gini index.

{p 8 8 2}
{cmdab:no:graph} to suppress graphing of the segregation curve. The curve variables are
still saved to the dataset.

{p 8 8 2}
{cmdab:x:}{it:(newvar)} {cmdab:y:}{it:(newvar)} to specify names for the curve variables
(cumulative group 1 share on x-axis, cumulative group 2 share on y-axis).
Default names are _E and _F. Variables are kept in the dataset after the command.

{p 8 8 2}
{cmdab:xt:itle}{it:(xtitle)},{cmdab:yt:itle}{it:(ytitle)} to change the title of the segregation curve axes.

{p 8 8 2}
{cmdab:gr:aph_options}{it:(graph_options)} to change default graph options for the segregation curve.


{title:Saved results}

{p 4 4 2}
Matrix:

{p 8 8 2}
r(seg) : segregation indices (Gini, D, KM, R2, SDratio)

{p 4 4 2}
Scalars:

{p 8 8 2}
r(Gini), r(Gini_pred), r(Gini_group) : Gini segregation index and its components

{p 8 8 2}
r(D), r(D_pred), r(D_group) : Dissimilarity index and its components

{p 8 8 2}
r(KM) : Karmel-MacLachlan index

{p 8 8 2}
r(R2), r(Var_pred), r(Var_group) : R-squared and variance components

{p 8 8 2}
r(SDratio), r(SD_pred), r(SD_group) : SD ratio and its components

{p 8 8 2}
r(freq1), r(freq2), r(nunits)

{p 4 4 2}
Locals:

{p 8 8 2}
r(catvars) : list of categorical predictor variables included

{p 8 8 2}
r(contvars) : list of continuous predictor variables included


{title:Examples}

{p 4 8 2}
. {stata use segdata.dta, clear }

{p 4 8 2}
{bf:Basic usage} (single categorical predictor):

{p 4 8 2}
. {stata regseg occupation white [aw=pwgtp]}

{p 4 8 2}
. {stata ret list}

{p 4 8 2}
{bf:Multiple categorical predictors} (occupation and industry):

{p 4 8 2}
. {stata regseg occupation industry white [aw=pwgtp]}

{p 4 8 2}
{bf:Continuous predictor only} (stratification by mean education):

{p 4 8 2}
. {stata regseg white [aw=pwgtp], cont(meanyrs)}

{p 4 8 2}
{bf:Categorical and continuous predictors combined}:

{p 4 8 2}
. {stata regseg occupation white [aw=pwgtp], cont(meanyrs)}

{p 4 8 2}
{bf:With segregation curve}:

{p 4 8 2}
. {stata regseg occupation white [aw=pwgtp], sc}

{p 4 8 2}
{bf:Gender segregation}:

{p 4 8 2}
. {stata regseg occupation2 sex [aw=pwgtp]}

{p 4 8 2}
{bf:With custom format}:

{p 4 8 2}
. {stata regseg occupation white [aw=pwgtp], f(%9.6f)}


{p 4 8 2}
For bootstrapping (BC estimates), using saved scalars (copy and paste in the command line or in a .do file):

{p 8 8 2}
 {stata use segdata.dta, clear }

{p 8 8 2}
 cap program drop rseg

{p 8 8 2}
 program def rseg

{p 12 8 2}
 regseg occupation2 sex [aw=pwgtp]

{p 8 8 2}
 end

{p 8 8 2}
 bootstrap r(Gini) r(D) r(R2) r(SDratio) r(KM) , reps(10): rseg

{p 8 8 2}
 estat bootstrap


{title:Differences from Version 1.0}

{p 4 4 2}
Version 2.0 generalizes the command in several ways:

{p 8 4 2}
- {bf:Multiple categorical predictors}: You can now include more than one categorical predictor in the varlist (e.g. occupation and industry).

{p 8 4 2}
- {bf:Continuous predictors}: The {opt cont()} option allows including continuous variables (e.g. mean years of education) in the regression.

{p 8 4 2}
- {bf:No external dependencies}: The {cmd:matsort} package is no longer required. Computations use a data-based (collapse and sort) approach instead of matrix operations.

{p 8 4 2}
- {bf:Full backward compatibility}: Calling {cmd:regseg} with a single categorical predictor and group variable (as in v1.0) produces the same results.


{title:Author}

{p 4 4 2}{browse "http://webs.uvigo.es/cgradin": Carlos Grad{c i'}n}
<cgradin@uvigo.es>{break}
Facultade de CC. Econ{c o'}micas{break}
Universidade de Vigo{break}
36310 Vigo, Galicia, Spain.


{title:References}

{p 4 8 2}
Duncan, Otis D. and Duncan, Beverly (1955), A Methodological Analysis of Segregation Indexes, American Sociological Review, 20(2): 210-217.

{p 4 8 2}
Hutchens, Robert M. (1991), Segregation Curves, Lorenz Curves, and Inequality in the Distribution of People across Occupations, Mathematical Social Sciences, 21: 31-51.

{p 4 8 2}
Karmel, T. and Maclachlan M. (1988), Occupational Sex Segregation - Increasing or Decreasing, Economic Record, 64: 187-195.


{title:Also see}

{p 4 13 2}
{help dicseg} if installed; {help lowseg} if installed; {help localseg} if installed


