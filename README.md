
<!-- README.md is generated from README.Rmd. Please edit that file -->

# annotater

<img src='man/figures/logo.png' align="right" height="138" /> The goal
of annotater is to annotate package load calls in text strings and R/Rmd
files, so we can have an idea of the overall purpose of the libraries
we’re loading.

### What do my loaded packages do?

![look\!](https://raw.githubusercontent.com/luisdva/annotater/master/inst/media/annotcalls.gif)

### Where did I get them?

![look\!](https://raw.githubusercontent.com/luisdva/annotater/master/inst/media/repos2.gif)

Another main feature helps us annotate the package load calls with their
respective repositories and versions. Thanks to [Jonathan
Carroll](https://github.com/jonocarroll) for the suggestion.

This project came about after teaching workshops or helping peers and
realizing that many issues relate to package installation failures and
dependency issues for packages that were not even used in a problematic
script. Scripts get passed around, code is copied and pasted, and we
might not know what certain packages are for.

## Installation

Install the development version of `annotater` from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("luisDVA/annotater")
```

I suggest restarting RStudio after the installation for the addins to
load properly.

### When using the addins, make sure the focus (blinking cursor) is on an open RStudio R file in the ‘source’ pane.

## Example

This is a basic example with a simple character string.

``` r
library(annotater)
test_string <-c("library(boot)\nrequire(Matrix)")
writeLines(annotate_pckg_calls(test_string))
```

Entire .R files can also be parsed and annotated with the
`annotate_script` function.

Try it out\! Feedback welcome
