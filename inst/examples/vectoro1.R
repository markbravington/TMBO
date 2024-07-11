require(TMB)
dyn.load(dynlib("vectoro1"))
stopifnot( require( offarray)) # not 'requireNamespace' coz 'offarray()' itself

## Set up model
obj <- MakeADFun(
    data= list( offy= offarray( 5:10, first=4)),
    parameters= list( par=c( 0.02, 0.7)),
    ranges= list(),
#    type= 'Fun', # much faster compilation, but obj$fn(obj$par) doesn't work :/ NFIY
    DLL="vectoro1",
    silent=TRUE
  )

Rfn <- function( p) sum( sqr( p[1] + lgamma( offy) - p[2] * sqrt( offy)))
# Tell it where to find offy:
environment( Rfn) <- list2env( obj$env$data, parent= .GlobalEnv)
obj$Rfn <- Rfn
  
# Same result from R & C?  
try({
obj$fn( obj$par)
obj$Rfn( obj$par)

# Nice outputs from REPORT
obj$report()
})
invisible( obj) # returned
