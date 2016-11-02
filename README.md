# Ising2DSimulation

This app runs on RShiny, please check if the users had shiny package installed.  If not, please install shiny package in R.  Also, the MCMC updating procedure is written by C++ including armadillo linear algebra library.  Thus, the Rcpp related packages are needed.
```R
install.packages(c("shiny", "Rcpp", "RcppArmadillo", "inline"))
```
To use this app, please open your R software and send the following commands.
```R
library(shiny)
runGitHub("Ising2DSimulation", "PingYangChen")
```
Note that, it is normal that this app might take some time to initiate.
