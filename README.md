
<!-- README.md is generated from README.Rmd. Please edit that file -->

# annotater <img src='man/figures/logo.png' align="right" width="120" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/annotater)](https://CRAN.R-project.org/package=annotater)
[![Codecov test
coverage](https://codecov.io/gh/luisDVA/annotater/branch/master/graph/badge.svg)](https://app.codecov.io/gh/luisDVA/annotater?branch=master)
[![](http://cranlogs.r-pkg.org/badges/last-month/annotater?color=orange)](https://cran.r-project.org/package=annotater)
[![](http://cranlogs.r-pkg.org/badges/grand-total/annotater?color=blue)](https://cran.r-project.org/package=annotater)
<!-- badges: end -->

The goal of annotater is to add informative comments to the package load
calls in character strings, R, RMarkdown, or Quarto files, so that we
can have an idea of the overall purpose of the libraries we are loading.

## Installation

Install the CRAN release or the development version with:

``` r
# Install from CRAN:
install.packages("annotater")
# development version
## install.packages("remotes")
remotes::install_github("luisDVA/annotater")
```

Restart RStudio after installation for the addins to load properly.

## Usage

Either through functions or working interactively with the RStudio
addins, package load calls can be enhanced with different types of
relevant information, added as comments next to each call. The example
code below shows the output for the different functions.

### What do my loaded packages do?

Package tiles from the respective DESCRIPTION files can be added to the
load calls.

``` r
library(brms) # Bayesian Regression Models using 'Stan'
library(picante) # Integrating Phylogenies and Ecology
library(report) # Automated Reporting of Results and Statistical Models
library(tidybayes) # Tidy Data and 'Geoms' for Bayesian Models
```

### Where did I get them?

Package installation sources and installed version numbers are added to
the load calls. Supports installations from CRAN, Bioconductor, GitHub,
GitLab, and R-universe.

``` r
library(brms)      # CRAN v2.21.0
library(forcats)   # CRAN v1.0.0
library(report)    # [github::easystats/report] v0.6.1
library(tidybayes) # CRAN v3.0.6
```

------------------------------------------------------------------------

The two annotation types are also available together:

``` r
library(picante) # Integrating Phylogenies and Ecology CRAN v1.8.2
library(forcats) # Tools for Working with Categorical Variables (Factors) CRAN v1.0.0
library(report) # Automated Reporting of Results and Statistical Models [github::easystats/report] v0.6.1
library(tidybayes) # Tidy Data and 'Geoms' for Bayesian Models CRAN v3.0.6
```

### Which functions or datasets from a package are being used?

For a given package, annotater can make notes of the functions or
datasets that are being used in the current file.

For functions in use:

``` r
library(ggplot2) # ggplot aes geom_bar
library(dplyr) # group_by summarize mutate
library(palmerpenguins) # No used functions found
library(forcats) # fct_reorder
library(data.table) # No used functions found

data(penguins)

summary_stats <- penguins |>
  group_by(species, sex) |>
  summarize(
    mnmass = mean(body_mass_g),
    medmass = median(body_mass_g)
  ) |>
  mutate(species = fct_reorder(species, mnmass))

ggplot(summary_stats, aes(x = species, y = medmass, fill = sex)) +
  geom_bar(stat = "identity", position = "dodge")
```

Loaded datasets:

``` r
library(ggplot2) # No loaded datasets found
library(dplyr) # No loaded datasets found
library(palmerpenguins) # penguins
library(forcats) # No loaded datasets found
library(data.table) # No loaded datasets found

data(penguins)

summary_stats <- penguins |>
  group_by(species, sex) |>
  summarize(
    mnmass = mean(body_mass_g),
    medmass = median(body_mass_g)
  ) |>
  mutate(species = fct_reorder(species, mnmass))

ggplot(summary_stats, aes(x = species, y = medmass, fill = sex)) +
  geom_bar(stat = "identity", position = "dodge")
```

## `pacman` compatibility

Users of the [`pacman`](https://cran.r-project.org/package=pacman)
package can now use all annotater functions on `p_load()` calls. This
includes calls with multiple package names
(e.g. `p_load(ggplot2,purrr)`), which will be split up across lines for
readability.

## R version and session information an as annotation

The addin ‘Annotate with R version’ will add the current machine’s R
version, platform, operating system and RStudio version to the
beginnning of a file. This can be useful for reproducibility and
debugging.

``` r
# R version 4.4.3 (2025-02-28)
# Platform: x86_64-pc-linux-gnu
# Running under: Linux Mint 22.1
# Rstudio 2024.12.0.467 (Kousa Dogwood)
# 
library(brms)
library(dplyr)
library(tidybayes)
```

### A note on the tidyverse and other metapacakges

The tidyverse package is a metapackage with few exported functions of
its own, so the annotation tools provided here
(e.g. `annotate_fun_calls`) will not match the functions from the
various individual packages (such as dplyr or readr) that are attached
when loading tidyverse.

Consider using the `expand_metapackages` function first if annotations
for function calls or datasets are desired. Load calls for metapackages
will be split into separate `library()` calls for the individual
packages that form the core of tidyverse, tidymodels, and easystats.

``` r
library(tidyverse)
library(tidymodels)
```

Becomes:

``` r
####
library(ggplot2)
library(tibble)
library(tidyr)
library(readr)
library(purrr)
library(dplyr)
library(stringr)
library(forcats)
library(lubridate)
####
####
library(broom)
library(dials)
library(dplyr)
library(ggplot2)
library(infer)
library(modeldata)
library(parsnip)
library(purrr)
library(recipes)
library(rsample)
library(tibble)
library(tidyr)
library(tune)
library(workflows)
library(workflowsets)
library(yardstick)
####
```

## Code of Conduct

Please note that the annotater project is released with a [Contributor
Code of Conduct](https://annotater.liomys.mx/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.
