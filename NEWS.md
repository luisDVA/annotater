# annotater 0.2.4

* Make annotations robust to CRAN packages installed with pak
* Examples that work better in the minimal checking environments

# annotater 0.2.3

* Fix failing tests
* Better annotations for packages installed from R-universe and RSPM
* Dataset annotation added
* Modern tidyselect syntax (thanks to PR by Hadley Wickham)

# annotater 0.2.2

* Bug fixes
* Add function to expand metapackages
* Fix failing test affecting purrr

# annotater 0.2.1

* Additional unit tests
* Preparation for CRAN submission
* Metapackage disclaimer in documentation

# annotater 0.2.0

* Adds support for packages loaded with the `pacman` package  

* Fixes library load call matching for indented code

# annotater 0.1.3

* Added the `annotate_fun_calls` annotator, cooler logo, and support for quoted package names.

# annotater 0.1.2

* Repo sources vertically aligned for nicer annotations.

# annotater 0.1.1

* Better notation for `annotate_repo_source()` and package versions added to annotation text.

# annotater 0.1.0

* Added a `NEWS.md` file to track changes to the package.

* `annotate_repo_source()` and its corresponding addin now support packages from GitHub, GitLab, CRAN, and Bioconductor.
