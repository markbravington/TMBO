require(TMB)
dyn.load(dynlib("chind1"))
stopifnot( require( offarray)) # not 'requireNamespace' coz 'offarray()' itself

GONDWANA <- c( "Australia", "South_America", "Antarctica")
SEXES <- c( 'Female', 'Male')
NINETIES <- 1990:1999


obj <- MakeADFun(
    data= list( gondy= offarray( 0, dimseq=list( GONDWANA))),
    parameters= list( par=c( 0.02, 0.7)), 
    ranges= TMBO_ranges( 
        NINETIES, # full seq
        NOUGHTIES= c( 2000, 2009), # start & end
        list( SEXES), # list() => TMB code can use MALE_ and FEMALE_
        GONDWANA, # no list(), so cannot use Australia_ in TMB
        list( PRIMARIES= cq( Red, Green, Blue)) # eg Blue_ is OK
      ),
    DLL= 'chind1',
    silent= TRUE
  )

# Nice outputs from REPORT
obj$report()
