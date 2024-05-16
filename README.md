[Available on CRAN](https://cran.r-project.org/package=rshift) and [R-universe](https://alexhroom.r-universe.dev/rshift)

# rshift
An R library for paleoecology and regime shift analysis.  
These functions assume your data is in tidy format.

`rshift` leverages [extendr](https://extendr.github.io/) to use algorithms written in Rust, making it faster
than any R implementation! 

## Installation
rshift is available on CRAN and R-universe, so can be installed via the RStudio package manager, or by running

```install.packages('rshift', repos = c('https://alexhroom.r-universe.dev', 'https://cloud.r-project.org'))```

Note that as rshift uses Rust code, if building from source [rustc and cargo are required](https://www.rust-lang.org/tools/install).

## Current features
`rshift` mainly focuses around Rodionov (2004)'s STARS algorithm. A detailed explanation of the algorithm, 
and how to use it for regime shift analysis in R, is [available here](https://cran.r-project.org/web/packages/rshift/vignettes/STARSmanual.pdf), 
or in R itself with the command `vignette("STARSmanual")` 

It also contains a few other tools for analysing time series/paleoecological data. 
For further documentation and help with rshift, either run `help(packages = "rshift")`, 
or view the documentation [here](https://www.rdocumentation.org/packages/rshift). 

## Development
`rshift` was originally developed as part of a NERC GW4+ undergraduate placement, 
with Dunia H. Urrego and Felipe Franco-Gaviria of the University of Exeter. 
In particular, it was part of the [BioResilience](https://blogs.exeter.ac.uk/bioresilience/) project.

Now, it is maintained and improved on a volunteer/free time basis; 
if you have any improvements or suggestions, please create an issue or pull request as necessary.

## Selected publications using rshift
- [Espinoza, Ismael G., et al. "Holocene fires and ecological novelty in the high Colombian Cordillera Oriental." Frontiers in Ecology and Evolution (2022)](https://doi.org/10.3389/fevo.2022.895152)

- [Catherwood, Avery A. and Knapp, Paul A. "Increasing precipitation variability and climate-growth responses of five tree species in North Carolina, USA" Environmental Research: Climate (2023)](https://doi.org/10.1088/2752-5295/ad0445)

*(If you use rshift in your publication, please let me know and I'd love to include it here!)*
