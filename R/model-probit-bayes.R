#' Bayesian Probit Regression
#'
#' @param formula a symbolic representation of the model to be
#'   estimated, in the form \code{y ~ x1 + x2}, where \code{y} is the
#'   dependent variable and \code{x1} and \code{x2} are the explanatory
#'   variables, and \code{y}, \code{x1}, and \code{x2} are contained in the
#'   same dataset. (You may include more than two explanatory variables,
#'   of course.) The \code{+} symbol means ``inclusion'' not
#'   ``addition.'' You may also include interaction terms and main
#'   effects in the form \code{x1*x2} without computing them in prior
#'   steps; \code{I(x1*x2)} to include only the interaction term and
#'   exclude the main effects; and quadratic terms in the form
#'   \code{I(x1^2)}.
#' @param model the name of a statistical model to estimate.
#'   For a list of supported models and their documentation see:
#'   \url{http://docs.zeligproject.org/articles/}.
#' @param data the name of a data frame containing the variables
#'   referenced in the formula or a list of multiply imputed data frames
#'   each having the same variable names and row numbers (created by
#'   \code{Amelia} or \code{\link{to_zelig_mi}}).
#' @param ... additional arguments passed to \code{zelig},
#'   relevant for the model to be estimated.
#' @param by a factor variable contained in \code{data}. If supplied,
#'   \code{zelig} will subset
#'   the data frame based on the levels in the \code{by} variable, and
#'   estimate a model for each subset. This can save a considerable amount of
#'   effort. For example, to run the same model on all fifty states, you could
#'   use: \code{z.out <- zelig(y ~ x1 + x2, data = mydata, model = 'ls',
#'   by = 'state')} You may also use \code{by} to run models using MatchIt
#'   subclasses.
#' @param cite If is set to 'TRUE' (default), the model citation will be printed
#'   to the console.
#'
#' @details
#' Additional parameters avaialable to this model include:
#' \itemize{
#'   \item \code{weights}: vector of weight values or a name of a variable in the dataset
#'   by which to weight the model. For more information see:
#'   \url{http://docs.zeligproject.org/articles/weights.html}.
#'   \item \code{burnin}: number of the initial MCMC iterations to be discarded (defaults to 1,000).
#'   \item \code{mcmc}: number of the MCMC iterations after burnin (defaults to 10,000).
#'   \item \code{thin}: thinning interval for the Markov chain. Only every thin-th draw from the
#'   Markov chain is kept. The value of mcmc must be divisible by this value. The default value is 1.
#'   \item \code{verbose}: defaults to FALSE. If TRUE, the progress of the sampler (every 10\%) is
#'   printed to the screen.
#'   \item \code{seed}: seed for the random number generator. The default is \code{NA} which
#'   corresponds to a random seed of 12345.
#'   \item \code{beta.start}: starting values for the Markov chain, either a scalar or vector with
#'   length equal to the number of estimated coefficients. The default is \code{NA}, such that the
#'   maximum likelihood estimates are used as the starting values.
#' }
#' Use the following parameters to specify the model's priors:
#' \itemize{
#'     \item \code{b0}: prior mean for the coefficients, either a numeric vector or a scalar.
#'     If a scalar value, that value will be the prior mean for all the coefficients. The default is 0.
#'     \item \code{B0}: prior precision parameter for the coefficients, either a square matrix (with
#'     the dimensions equal to the number of the coefficients) or a scalar. If a scalar value, that
#'     value times an identity matrix will be the prior precision parameter. The default is 0, which
#'     leads to an improper prior.
#' }
#' Use the following arguments to specify optional output for the model:
#' \itemize{
#'     \item \code{bayes.resid}: defaults to FALSE. If TRUE, the latent Bayesian residuals for all
#'     observations are returned. Alternatively, users can specify a vector of observations for
#'     which the latent residuals should be returned.
#' }
#' @return Depending on the class of model selected, \code{zelig} will return
#'   an object with elements including \code{coefficients}, \code{residuals},
#'   and \code{formula} which may be summarized using
#'   \code{summary(z.out)} or individually extracted using, for example,
#'   \code{coef(z.out)}. See
#'   \url{http://docs.zeligproject.org/articles/getters.html} for a list of
#'   functions to extract model components. You can also extract whole fitted
#'   model objects using \code{\link{from_zelig_model}}.
#'
#'
#' @examples
#' data(turnout)
#' z.out <- zelig(vote ~ race + educate, model = "probit.bayes",data = turnout, verbose = FALSE)
#' summary(z.out)
#'
#' @seealso Vignette: \url{http://docs.zeligproject.org/articles/zelig_probitbayes.html}
#' @import methods
#' @export Zelig-probit-bayes
#' @exportClass Zelig-probit-bayes
#'
#' @include model-zelig.R
#' @include model-probit.R

zprobitbayes <- setRefClass("Zelig-probit-bayes",
                             contains = c("Zelig-bayes",
                                          "Zelig-probit"))

zprobitbayes$methods(
  initialize = function() {
    callSuper()
    .self$name <- "probit-bayes"
    .self$family <- "binomial"
    .self$link <- "probit"
    .self$linkinv <- eval(call(.self$family, .self$link))$linkinv
    .self$year <- 2013
    .self$category <- "dichotomous"
    .self$authors <- "Ben Goodrich, Ying Lu"
    .self$description = "Bayesian Probit Regression for Dichotomous Dependent Variables"
    .self$fn <- quote(MCMCpack::MCMCprobit)
    # JSON from parent
    .self$wrapper <- "probit.bayes"
  }
)

zprobitbayes$methods(
  mcfun = function(x, b0=0, b1=1, ..., sim=TRUE){
    mu <- pnorm(b0 + b1 * x)
    if(sim){
        y <- rbinom(n=length(x), size=1, prob=mu)
        return(y)
    }else{
        return(mu)
    }
  }
)
