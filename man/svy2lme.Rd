\name{svy2lme}
\alias{svy2lme}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Linear mixed models by pairwise likelihood
}
\description{
Fits linear mixed models by profile pairwise composite likelihood. At the moment, it can only handle two-stage designs and two-level models, where the model clusters and sampling clusters are the same. In fact, at the moment you don't even get standard errors. In the future, settings where the model structure is nested in the design structure should be feasible. 
}
\usage{
svy2lme(formula, data, p1, p2, N2 = NULL)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{formula}{
Model formula as in the \code{lme4} package
}
  \item{data}{
data frame
}
  \item{p1}{
Vector of stage-one sampling probabilities
}
  \item{p2}{
Vector of stage-two sampling probabilities: these are treated as if they were sampled with replacement. 
}
  \item{N2}{
Size of the stage-one sampling units (in the population). The stage-two sampling is treated as SRS without replacement.
}
}
\details{
The population pairwise likelihood would be the sum of the loglikelihoods for a pair of observations, taken over all pairs of observations from the same cluster.  This is estimated by taking a weighted sum over pairs in the sample, with the weights being the reciprocals of pairwise sampling probabilities. The advantage over standard weighted pseudolikelihoods is that there is no large-cluster assumption needed and no rescaling of weights. The disadvantage is some loss of efficiency (to an extent that isn't well understood).

The code uses \code{lme4::lmer} to parse the formula and produce starting values, profiles out the fixed effects, and then uses \code{minqa::bobyqa} to maximise the resulting profile deviance. 

}
\value{
A list with values
\item{opt }{The output of the optimiser for the profile pairwise loglikelihood}
 \item{beta }{The fixed effects coefficients}
}
\references{
J.N.K. Rao, François Verret and Mike A. Hidiroglou "A weighted composite likelihood approach to inference for two-level models from survey data" Survey Methodology, December 2013  Vol. 39, No. 2, pp. 263-282

Grace Y. Yi , J. N. K. Rao and Haocheng Li "A WEIGHTED COMPOSITE LIKELIHOOD APPROACH FOR ANALYSIS OF SURVEY DATA UNDER TWO-LEVEL MODELS" Statistica Sinica Statistica Sinica
Vol. 26, No. 2 (April 2016), pp. 569-587
}
\author{
Thomas Lumley
}
\examples{

df<-data.frame(x=rnorm(1000*20),g=rep(1:1000,each=20), t=rep(1:20,1000))
df$u<-with(df, rnorm(1000)[g])

df$y<-with(df, x+u+rnorm(1000,s=2))

## oversample extreme `u` to bias random-intercept variance
pg<-exp(abs(df$u/2)-2)[df$t==1]

in1<-rbinom(1000,1,pg)==1
in2<-rep(1:5, length(in1))

sdf<-subset(df, (g %in% (1:1000)[in1]) & (t %in% in2))

p1<-rep(pg[in1],each=5)
N2<-rep(20,nrow(sdf))

## Population values
lme4::lmer(y~x+(1|g), data=df)

## Naive estimator
lme4::lmer(y~x+(1|g), data=sdf)

##pairwise estimator
pair<-svy2lme(y~x+(1|g),data=sdf,p1=p1,N2=N2)
## fixed effects
pair$beta
## residual StdDev
(s<-exp(pair$opt$par[1]/2))
## random intercept StdDev 
s*pair$opt$par[-1]


}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{regression }% use one of  RShowDoc("KEYWORDS")
\keyword{survey }% __ONLY ONE__ keyword per line