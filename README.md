
<!-- README.md is generated from README.Rmd. Please edit that file -->

# annotater

The goal of annotater is to annotate package load calls in strings and R
scripts, so we can have an idea of the overall purpose of the libraries
we’re loading.

This project came about after teaching workshops or helping peers and
realizing that many issues relate to package installation failures and
dependency issues for packages that are not even used in a problematic
script. Scripts get passed around, code is copied and pasted, and we
might not know what certain packages are for.

## Installation

You can install the development version of annotater from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("luisDVA/annotater")
```

Alternatively:

``` r
# install.packages("remotes")
remotes::install_github("luisDVA/annotater")
```

## Example

This is a basic example with a simple character string.

``` r
library(annotater)
test_string <-c("library(boot)\nrequire(Matrix)")
writeLines(annotate_pckg_calls(test_string))
#> library(boot) # Bootstrap Functions (Originally by Angelo Canty for S)
#> require(Matrix) # Sparse and Dense Matrix Classes and Methods
```

Entire .R files can also be parsed and annotated with the
*annotate\_script* function.

*annotater* now includes an RStudio addin to make annotations on the
active R file in the source pane.

Try it out\!
