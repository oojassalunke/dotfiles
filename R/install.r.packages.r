#!/usr/bin/env Rscript

install.packages('data.table', repos='https://Rdatatable.github.io/data.table')
install.packages('magrittr')

install.packages('remotes')		# a lighter-weight devtools package
remotes::install_github('jalvesaq/colorout')
remotes::install_github('cran/setwidth')
