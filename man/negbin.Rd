\name{negbin}
\alias{negbin}
\alias{nb}
%- Also NEED an `\alias' for EACH other topic documented here.
\title{GAM negative binomial families}
\description{The \code{gam} modelling function is designed to be able to use 
the \code{\link{negbin}} family (a modification of MASS library \code{negative.binomial} family 
by Venables and Ripley), or the \code{\link{nb}} function designed for integrated estimation of 
parameter \code{theta}. \eqn{\theta} is the parameter such that \eqn{var(y) = \mu + \mu^2/\theta}, where \eqn{\mu = E(y)}.

Two approaches to estimating \code{theta} are available (with \code{\link{gam}} only):

\itemize{
\item With \code{negbin} then if `performance iteration' is used for smoothing parameter estimation 
(see \code{\link{gam}}), then smoothing parameters are chosen by GCV and 
\code{theta} is chosen in order to ensure that the Pearson estimate of the scale 
parameter is as close as possible to 1, the value that the scale parameter should have.

\item If `outer iteration' is used for smoothing parameter selection with the \code{nb} family then 
\code{theta} is estimated alongside the smoothing parameters by ML or REML.

}
To use the first option, set the \code{optimizer} argument of \code{\link{gam}} to \code{"perf"} (it can sometimes fail to converge).
}

\usage{
negbin(theta = stop("'theta' must be specified"), link = "log")
nb(theta = NULL, link = "log")
}
\arguments{
\item{theta}{Either i) a single value known value of theta or ii) two values of theta specifying the 
endpoints of an interval over which to search for theta (this is an option only for \code{negbin}). 
For \code{nb} then a positive supplied \code{theta} is treated as a fixed known parameter, otherwise 
it is estimated (the absolute value of a negative \code{theta} is taken as a starting value).}
\item{link}{The link function: one of \code{"log"}, \code{"identity"} or \code{"sqrt"}}
}
\value{
For \code{negbin} an object inheriting from class \code{family}, with additional elements
\item{dvar}{the function giving the first derivative of the variance function w.r.t. \code{mu}.}
\item{d2var}{the function giving the second derivative of the variance function w.r.t. \code{mu}.}
\item{getTheta}{A function for retrieving the value(s) of theta. This also useful for retriving the 
estimate of \code{theta} after fitting (see example).}

For \code{nb} an object inheriting from class \code{extended.family}.
}

\details{\code{nb} allows estimation of the \code{theta} parameter alongside the model smoothing parameters, but is only useable with \code{\link{gam}} (not \code{bam} or \code{gam}).

For \code{negbin}, if a single value of \code{theta} is supplied then it is always taken as the known fixed value and this is useable with \code{\link{bam}} and \code{\link{gamm}}. If \code{theta} is two 
numbers (\code{theta[2]>theta[1]}) then they are taken as specifying the range of values over which to search for 
the optimal theta. This option should only be used with performance iteration estimation (see \code{\link{gam}} argument \code{optimizer}), in which case  the method 
of estimation is to choose \eqn{\hat \theta}{theta}  so that the GCV (Pearson) estimate 
of the scale parameter is one (since the scale parameter 
is one for the negative binomial). In this case \eqn{\theta}{theta} estimation is nested within the IRLS loop 
used for GAM fitting. After each call to fit an iteratively weighted additive model to the IRLS pseudodata, 
the \eqn{\theta}{theta} estimate is updated. This is done by conditioning on all components of the current GCV/Pearson 
estimator of the scale parameter except \eqn{\theta}{theta} and then searching for the 
\eqn{\hat \theta}{theta} which equates this conditional  estimator to one. The search is 
a simple bisection search after an initial crude line search to bracket one. The search will 
terminate at the upper boundary of the search region is a Poisson fit would have yielded an estimated 
scale parameter <1.

The following \code{negbin} based approaches are now deprecated:

If outer iteration is used then \eqn{\theta}{theta} is estimated by searching for the value yielding the lowest AIC.
The search is either over the supplied array of values, or is a grid search over the supplied range, followed by a 
golden section search. A full fit is required for each trial \eqn{\theta}{theta}, so the process is slow, but speed
is enhanced by making the changes in \eqn{\theta}{theta} as small as possible, from one step to the next, and 
using the previous smothing parameter and fitted values to start the new fit. 

In a simulation test based on 800 replicates of
the first example data, given below, the GCV based (performance iteration) method yielded models with, 
on avergage 6\% better MSE performance than the AIC based (outer iteration) method. 
\code{theta} had a 0.86 correlation coefficient between the two methods.
\code{theta} estimates averaged 3.36 with a standard deviation of 0.44 for the AIC based method and
3.22 with a standard deviation of 0.43 for the GCV based method. However the GCV based method is 
less computationally reliable, failing in around 4\% of replicates. 

}

%- maybe also `usage' for other objects documented here.

\author{ Simon N. Wood \email{simon.wood@r-project.org}
modified from Venables and Ripley's \code{negative.binomial} family.
}

\references{
Venables, B. and B.R. Ripley (2002) Modern Applied Statistics in S, Springer.
}

\section{WARNINGS}{
\code{\link{gamm}} and \code{\link{bam}} do not support \code{theta} estimation

The negative binomial functions from the MASS library are no longer supported.
}

\examples{
library(mgcv)
set.seed(3)
n<-400
dat <- gamSim(1,n=n)
g <- exp(dat$f/5)

## negative binomial data... 
dat$y <- rnbinom(g,size=3,mu=g)
## known theta fit ...
b0 <- gam(y~s(x0)+s(x1)+s(x2)+s(x3),family=negbin(3),data=dat)
plot(b0,pages=1)
print(b0)

## same with theta estimation...
b <- gam(y~s(x0)+s(x1)+s(x2)+s(x3),family=nb(),data=dat)
plot(b,pages=1)
print(b)
b$family$getTheta(TRUE) ## extract final theta estimate

## unknown theta via performance iteration...
b1 <- gam(y~s(x0)+s(x1)+s(x2)+s(x3),family=negbin(c(1,10)),
          optimizer="perf",data=dat)
plot(b1,pages=1)
print(b1)

## another example...
set.seed(1)
f <- dat$f
f <- f - min(f)+5;g <- f^2/10
dat$y <- rnbinom(g,size=3,mu=g)
b2 <- gam(y~s(x0)+s(x1)+s(x2)+s(x3),family=nb(link="sqrt"),
         data=dat,method="REML") 
plot(b2,pages=1)
print(b2)
rm(dat)
}
\keyword{models} \keyword{regression}%-- one or more ..


