require(TMB)
# The normal way to turn OOB-checks on:
# compile( 'oob1.cpp', ppflags= '-DTMBOOBOO')

dyn.load(dynlib("oob1"))
stopifnot( require( offarray)) # not 'requireNamespace' coz 'offarray()' itself

oobs <- c( 'VEC', 'MAT', 'AR', 'ARNELS')
obj <- MakeADFun(
    data= list( offy= offarray( 5:10, first=4), 
        which_oob=0), # no OOBs, no probs
    parameters= list( par=c( 0.02, 0.7)), 
    ranges= list( oob_types=list( oobs)), 
    DLL= 'oob1',
    silent= TRUE
  ) 
  
# The use of match() below is a bit unusual. 'which_oob' does need to be an int, not a character, so match() works, but...
# The main use-case for CHINDs is as a vector etc of values, rather than setting one particular val.
# What I would usually do myself, is something like this:
if( FALSE){
  oobvals <- structure( seq_along( oobs), names=oobs) # so oobvals[ 'VEC']==1 etc
  mvbutils::extract.named( as.list( oobvals)) # creates variables VEC, MAT, AR, ARNELS; int scalars with obvious vals
  # then can refer directly to VEC etc, eg in
  obj <- MakeADFun( ...,
    data = list( ..., which_oob= VEC),
    ...
  )
}

obj <- try( MakeADFun(
    data= list( offy= offarray( 5:10, first=4), 
        which_oob= match('VEC', oobs)), 
    parameters= list( par=c( 0.02, 0.7)), 
    ranges= list( oob_types=list( oobs)),
    DLL= 'oob1',
    silent= TRUE
  )) 

obj <- try( MakeADFun(
    data= list( offy= offarray( 5:10, first=4), 
        which_oob= match( 'MAT', oobs)), 
    parameters= list( par=c( 0.02, 0.7)), 
    ranges= list( oob_types=list( c( 'VEC', 'MAT', 'AR', 'ARNELS'))), 
    DLL= 'oob1',
    silent= TRUE
  )) 
  
obj <- try( MakeADFun(
    data= list( offy= offarray( 5:10, first=4), 
        which_oob= match( 'AR', oobs)), 
    parameters= list( par=c( 0.02, 0.7)), 
    ranges= list( oob_types=list( c( 'VEC', 'MAT', 'AR', 'ARNELS'))), 
    DLL= 'oob1',
    silent= TRUE
  )) 
  
obj <- try( MakeADFun(
    data= list( offy= offarray( 5:10, first=4), 
        which_oob= match( 'ARNELS', oobs)), 
    parameters= list( par=c( 0.02, 0.7)), 
    ranges= list( oob_types=list( c( 'VEC', 'MAT', 'AR', 'ARNELS'))), 
    DLL= 'oob1',
    silent= TRUE
  )) 

#   ... and you will see NICE messages about OOB above.
# Normally, you need to 'compile(...,ppflags="-DTMBOOBOO")' for OOBing to work. 
# Here I switched it on in the C code, just for demo purposes. Go look.
# If you switch it off, you'll get proper old-fashioned crashes.

