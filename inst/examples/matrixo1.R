require(TMB)
dyn.load(dynlib("matrixo1"))
stopifnot( require( offarray)) # not 'requireNamespace' coz 'offarray()' itself

## Set up model
offy <- offarray( cbind( 5:10, 5:10+10), first=c( 4, 1)) 

obj <- MakeADFun(
    data= list( offy= offy),
    parameters= list( par=c( 0.02, 0.7)),
    ranges= list( YEARS=1987:1990),
    DLL="matrixo1",
    silent=TRUE
  )

Rfn <- function( p) sum( ( p[1] + offy - p[2] * sqrt( offy))^2L)
# Tell it where to find offy:
environment( Rfn) <- list2env( obj$env$data, parent= .GlobalEnv)
obj$Rfn <- Rfn
  
# Same result from R & C?  
obj$fn( obj$par)
obj$Rfn( obj$par)

# Nice outputs from REPORT
obj$report()

invisible( obj) # returned
