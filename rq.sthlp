{smcl}
{* March 2026}{...}
{hline}
help for {hi:rq (Version 1.1)}{right:Carlos Grad{c i'}n (March 2026)}
{hline}

{title:Title}

{p 4 4 2}
{cmd:rq} {hline 2} Ethnic polarization index (Reynal-Querol, 2002)


{title:Syntax}

{p 8 17 2}
{cmd:rq} {it:varname} [{it:weights}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}]

{p 4 4 2}
{cmd:fweights}, {cmd:aweights}, and {cmd:iweights} are allowed; see {help weights}.


{title:Description}

{p 4 4 2}
{cmd:rq} computes the ethnic polarization index proposed by Reynal-Querol (2002),
related to the Esteban and Ray (1994) polarization measure. It can be used with
either individual-level data (each observation is a person) or data aggregated
by group (each observation is a group, using frequency weights).

{p 4 4 2}
{it:varname} indicates the categorical variable of interest (e.g., ethnic group,
religion, language, ...).


{title:Formula}

{p 4 4 2}
The index is defined as:

{p 8 4 2}
RQ = 4 * {it:sum_i} [ pi{c ²} * (1 - pi) ]

{p 4 4 2}
which is equivalent to:

{p 8 4 2}
RQ = 1 - {it:sum_i} [ (0.5 - pi){c ²} * pi / 0.25 ]

{p 4 4 2}
where {it:pi} is the proportion of members of group {it:i} in the population.

{p 4 4 2}
The index ranges from 0 (complete homogeneity, only one group) to 1 (two equally
sized groups, maximum polarization). It reaches its maximum when the population
is split into two groups of equal size.


{title:Saved results}

{p 4 4 2}
Scalars:

{p 8 8 2}
{cmd:r(rq)} {space 6} the Reynal-Querol polarization index

{p 8 8 2}
{cmd:r(ngroups)} {space 1} number of groups

{p 8 8 2}
{cmd:r(N)} {space 7} number of (weighted) observations


{title:Examples}

{p 4 8 2}
Basic usage with individual-level data:

{p 8 8 2}
. {stata rq ethnicity [aw=weight] if country==1}

{p 4 8 2}
Using the {cmd:by} prefix to compute the index for each country:

{p 8 8 2}
. {stata bysort country: rq ethnicity [aw=weight]}

{p 4 8 2}
For bootstrapping (bias-corrected estimates), using saved scalars:

{p 8 8 2}
cap program drop reyq

{p 8 8 2}
program def reyq

{p 12 8 2}
rq ethnicity [aw=weight]

{p 8 8 2}
end

{p 8 8 2}
bootstrap r(rq) , reps(1000): reyq

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
Esteban, Joan Maria and Debraj Ray (1994), On the Measurement of Polarization,
{it:Econometrica}, 62(4): 819-851.

{p 4 8 2}
Montalvo, Jos{c e'} G. and Marta Reynal-Querol (2005), Ethnic Polarization,
Potential Conflict, and Civil Wars, {it:American Economic Review}, 95(3): 796-816.

{p 4 8 2}
Reynal-Querol, Marta (2002), Ethnicity, Political Systems, and Civil Wars,
{it:Journal of Conflict Resolution}, 46(1): 29-54.


{title:Also see}

{p 4 13 2}
{help er} if installed; {help dicseg} if installed; {help lowseg} if installed


