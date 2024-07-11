require(TMB)
dyn.load(dynlib("arrayo1"))
stopifnot( require( offarray)) # not 'requireNamespace' coz 'offarray()' itself

# Could use TMBO_ranges() here, but plain list() is OK since all args are named
rangs <- list( SEXES=c( 'Female', 'Male'), YEARS=1987:1990, AGES=6:8)
C_sya <- autoloop( indices=rangs, 
      1/(YEARS+(SEXES=='Female')+AGES))

## Set up model
obj <- MakeADFun(
    data= list( C_sya= C_sya),
    parameters= list( par=0.5, fec_s=c( Female= 3, Male= 1)),
    ranges= rangs,
    DLL="arrayo1",
    silent=TRUE
  )

Rfn <- function( p) sum( sqr( p[1] + lgamma( offy) - p[2] * sqrt( offy)))
# Tell it where to find offy:
environment( Rfn) <- list2env( obj$env$data, parent= .GlobalEnv)
obj$Rfn <- Rfn
  
# Same result from R & C?  
obj$fn( obj$par)
obj$Rfn( obj$par)

# Nice outputs from REPORT
obj$report()

invisible( obj) # returned
