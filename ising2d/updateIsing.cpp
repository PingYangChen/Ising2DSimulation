// [[Rcpp::depends(RcppArmadillo)]]
#include<math.h>
#include<RcppArmadillo.h>
#include<Rcpp.h>
using namespace Rcpp;
using namespace arma;

//[[Rcppplugins(cpp11)]]

//[[Rcpp::export]]
NumericVector updateIsing(NumericVector x, const double temp, const int method, const int bdgrids)
{
  
	vec newx(x.begin(), x.size(), false);
	double e1, e0, pGS, pMH, Snn;
  if (method == 1) {
		for (int i = 0; i < (bdgrids*bdgrids); i++)
		{
			if (((i % bdgrids) > 0) & ((i % bdgrids) < (bdgrids - 1)) & (i >= bdgrids) & (i < (bdgrids*(bdgrids - 1)))) {
				Snn = newx[i-1] + newx[i+1] + newx[i-bdgrids] + newx[i+bdgrids];
				e1 = std::exp(-newx[i]*Snn/temp);
				e0 = std::exp(-(-newx[i])*Snn/temp);
				pGS = e1/(e1 + e0);
				if (as_scalar(randu(1, 1)) < pGS) newx[i] *= -1.0;
				//newx[i] = (2*(randu(1, 1) > pGS) - 1)*newx[i];
			}
		}
	}
	if (method == 2){
		uvec spin = randi<uvec>(bdgrids*bdgrids, distr_param(0, bdgrids*bdgrids - 1));
		for (int i = 0; i < (bdgrids*bdgrids); i++)
		{
			if (((spin[i] % bdgrids) > 0) & ((spin[i] % bdgrids) < (bdgrids - 1)) & (spin[i] >= bdgrids) & (spin[i] < (bdgrids*(bdgrids - 1)))) {					
				Snn = newx[(spin[i]-1)] + newx[(spin[i]+1)] + newx[(spin[i]-bdgrids)] + newx[(spin[i]+bdgrids)];
				pMH = std::exp(-2*newx[spin[i]]*Snn/temp);
				if (as_scalar(randu(1, 1)) < pMH) newx[spin[i]] *= -1.0;
				//newx[spin[i]] <- (2*(randu(1, 1) > pMH) - 1)*newx[spin[i]];
			}
		}
	}		
  return(as<NumericVector>(wrap(newx)));
}

