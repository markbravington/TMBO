# This is package TMBO 

"%||%" <-
function( L, R) if(!is.null(L)) L else R


".onAttach" <-
function( libname, pkgname){
## Loads TMB and offarray onto search path *below* TMB. 
## Thus, iff you're using TMBO interactively, all the TMB and offarray
## functionality will be automatically available
## without needing to remember to have done library( TMB) *first*

  s <- search()
  pozzo <- match( 'package:TMBO', s, 0)
  if( !pozzo){
    packageStartupMessage( 
        "Can't find myself... not attaching anything else")
  } else { # normally...
    libr_sodding_ary <- baseenv()[[ 'libr' %&% 'ary']]
    if( 'package:TMB' %not.in% s){
      libr_sodding_ary( TMB, pos=pozzo+1)
    }

    if( 'package:offarray' %not.in% s){
      libr_sodding_ary( offarray, pos=pozzo+1)
    }
  }
}


".onLoad" <-
function( libname, pkgname){
  # Boring array macros for 1..N dimensions get auto-generated
  incpath <- system.file( 'include', package='TMBO', lib.loc=libname)
  boringar <- file.path( incpath, 'boring_array_bits1.h')
  
  if( !file.exists( boringar)){
    make_all_ELn( 7, boringar)
  }
  
  if( !nzchar( Sys.getenv( 'CPP_IN_R'))){
    extract_confession() # get compiler's real magickal name
  }
}


"add_chinds_from_dims" <-
function( thing_name, thing){
  # Gets re-environmented before running
  # dimseq uses dimnames or names on non-offarrays
  ds <- dimseq( thing, drop=FALSE)
  if( !is.list( ds)){ # must be base-R vector
    ds <- list( ds)
  }
  thing_chindi <- rep( 0L, length( ds))
  
  if( length( ds) > 1){
    chinds <- which( sapply( ds, is.character))
    if( length( chinds)){
      # Index of these chinds in all_chinds
      thing_chindi[ chinds] <- length( all_chinds) + seq_along( chinds)

      # Lookup table ...
      chind_names <- sprintf( '%s(%i)', thing_name, chinds)

      # Append... NB all_chinds will be in parent env
      all_chinds[ chind_names] <<- ds[ chinds]
    }
  } else if( is.character( ds[[1]])){
    # vector, or 1D offarray, with names
    thing_chindi <- length( all_chinds)+1L
    all_chinds[[ thing_name]] <<- ds[[1]]
  } # else thing_chindi is all 0, and no need to update all_chinds
  
return( thing_chindi)
}


"compile" <-
function( file, ...,
  dev= exists( '..TMBO', mode='environment'),
  ppcheck= FALSE,
  stop_after_cpp1= FALSE,
  ppflags= NULL,
  flags= NULL
){
  # Make sure we can run preprocessor
  if( !nzchar( Sys.which( 'cpp'))){
stop( "Needs 'cpp' preprocessor--- your PATH is not set up for compilation. You'll need to fix that. Good luck!")
  }

  if( file_ext( file)==''){
    file <- file %&% '.cpp'
  }
  full_file <- normalizePath( file, winslash='/', mustWork=TRUE)
  pp_full_file <- sub( '.cpp$', '_TMBOpp1.cpp', full_file)

  # Allow "local" hash-includes, as well as TMBO.h
  ipath <- if( dev)
      file.path( attr( ..TMBO, 'path'), 'inst/include')
    else
    system.file( 'include', package='TMBO')

  ipaths <- c( ipath, dirname( full_file))
  CPP <- Sys.getenv( 'CPP_IN_R', 'cpp') # eventually will be auto-set via forcing .shlib_internal to bloody TELL me...
  pplog <- system2( CPP, sprintf( '-std=c++20 -E -CC %s %s %s', 
      paste( '-I ' %&% ipaths, collapse=' '), 
      paste( ppflags, collapse=' '), 
      full_file),
      stderr=TRUE, stdout= TRUE) # used to have stdout=pp_full_file, but nogo on Linux cozza stderr=TRUE

  writeLines( pplog, con= pp_full_file)
  # @status may not exist, which I think is fine; if it does and is 0, that's fine; otherwise, bad
  status <- attr( pplog, "status") %||% 0 
  if( status != 0){
    pplog <- c( attr( pplog, 'errmsg'), pplog) # if any
    attr( pplog, 'status') <- status
return( pplog)
  }

  if( stop_after_cpp1){
return( 0)
  }

  # Tidy up preprocessed...
  rl <- readLines( pp_full_file)

  # Some PP workarounds, eg VA_ARGS:
  deflines <- grep( '^ *#define ', rl)
  rl[ deflines] <- gsub( '([ ,)])__VA_OPT_ARGS_HERE__([ ,)])',
      '\\1__VA_ARGS__ __VA_OPT__(,)\\2', rl[ deflines])
  rl[ deflines] <- gsub( '([ ,(])__VA_ARGS_HERE__([ ,)])',
      '\\1__VA_ARGS__\\2', rl[ deflines])
  # ... could do a similar thing for __FILE__ / __FILE_NAME__

  # _CHINDID__<var> settings when a variable is declared:
  # transform strings into refs to other CHINDIDs
  # Single word is OK--- presumably name of a CHIND
  # So is DIMRANGE(x,<n>) where <n> is integer literal
  # otherwise, 0
  # NB CHINDID declaration lines must end in / and *
  # Also, only change those with quoted "args"--- direct assigns from 
  # <BLAH>_sameshapeas() should be left alone
  chlines <- grep( '^ *(vector<int>|int) _CHINDID__[[:alnum:]]+.* (=|<<) .*"', rl)
  for( i in seq_along( chlines)){
    chendi <- eval( parse( text= sprintf( 'c(%s)', 
        rl[ chlines[ i]] |> 
          sub( '.*(=|<<) ', '', x=_) |>
          sub( ';+ */[*]', '', x=_) )))
    chendi <- gsub( ' +', '', chendi) # elim spaces
    is_chindname <- grepl( '^[a-zA-Z]\\w+$', chendi)
    is_nonvec_dimrange <- grepl( '^DIMRANGE[(]\\w+,[0-9]+[)]$', chendi)

    # DIMRANGE(x,i) --> _CHIND__x(i)
    chendi[ is_nonvec_dimrange] <- chendi[ is_nonvec_dimrange] |> 
        sub( '.*[(]', '', x=_) |> # remove DIMRANGE
        sub( ',', '(', x=_, fixed=TRUE) |> # functionize
        sub( ')', '-1)', x=_, fixed=TRUE) # remember 0-offset !!!
        
    # DIMRANGE( x) --> _CHIND__x
    is_vec_dimrange <- grepl( '^DIMRANGE[(]\\w+[)]$', chendi)
    chendi[ is_vec_dimrange] <- sub( '.*[(](\\w+)[)]$', '\\1', 
        chendi[ is_vec_dimrange])
    chendi <- '_CHINDID__' %&% chendi
    chendi[ !is_chindname & !is_vec_dimrange & !is_nonvec_dimrange] <- '0'
     
    rl[ chlines[ i]] <- sub( '(<<|=) .*', 
        sprintf( '\\1 %s; /*', paste( chendi, collapse=', ')), 
        rl[ chlines[ i]])
  } # for chlines
  
  if( ppcheck){ 
    # Don't include anything except TMBO2.h
    includes <- grep( '^ *#include ', rl)
    includes <- includes[ !grepl( '(TMBO2|boring_array_bits2|macro_utils_TMBO).h', rl[ includes])]
    rl[ includes] <- '//PPDEBUG ' %&% rl[ includes]
  }

  # Remove empty multiline comments: nested comments don't work :/
  # Might need multiple passes cozza nestedness
  rl <- paste( rl, collapse='\n')
  olenr <- nchar( rl)
  repeat{
    rl <- gsub( r"{(?m)/[*]\s*[*]/}", '', rl, perl=T)
    lenr <- nchar( rl)
    if( lenr==olenr){
  break
    }
    olenr <- lenr
  }

  # And remove explanatory comments from TMBO.h. They are all wrapped 
  # in /*** ... ***/, and are not nested. User comments should be left alone.
  rl <- gsub( "(?sU)/[*]{3}.*[*]{3}/", '', rl, perl=T)

  # And 3 or more blank lines in a row...
  rl <- gsub( r"{(?s)\n\n(\n+)}", '\n\n', rl, perl=TRUE)

  writeLines( rl, pp_full_file)

  if( ppcheck){
    # 2nd pass sans TMB.h or other includes, to show what TMB would really "see"
    # Already commented out, but also (from before I did that): ...
    # ... defining TMBO_PPBDEBUG will exclude <TMB.h> itself
    pplog <- try( system2( 'cpp', sprintf( '%s -DTMBO_PPDEBUG %s', 
      paste( '-I ' %&% ipaths, collapse=' '), pp_full_file),
      stdout= TRUE))
    pp2_status <- attr( pplog, 'status') %||% 0
    # Restore #includes prior to full compilation (if doing that)
    if( pp2_status>0){
      pplog <- c( attr( pplog, 'errmsg'), pplog)
    }
    pplog <- as.vector( pplog) %that.dont.match% '^# [0-9]+ '
    pplog <- sub( '^//PPDEBUG ', '', pplog)
    rl <- readLines( pp_full_file)
    rl <- sub( '^//PPDEBUG ', '', rl)    
    writeLines( rl, pp_full_file)
return( structure( pp2_status, pplog=pplog))      
  }

  # Now some EPIC GHASTLY hacking to ensure that TMBO's include path is used (and first) by TMB::compile. See NOTE in doco.
  # Also I *tried* to ensure that error reports are kept. I have failed. R is crazy here.
  
  
  xcompile <- TMB::compile
  e <- new.env( parent=environment( xcompile))
  real_shlib_internal <- evalq( .shlib_internal, e)
#  e2 <- new.env( parent=environment( real_shlib_internal))
#  environment( real_shlib_internal) <- e2
  e$real_shlib_internal <- real_shlib_internal

#  environment( mock_system) <- e # only in new local copy
#  e2$system <- mock_system # gets called by real_shlib_internal
#  e$sysoutput <- character() # will hold "printed" results of system()

  environment( mock_shlib_internal) <- e # only in new local copy
  e$.shlib_internal <- mock_shlib_internal
  
  environment( xcompile) <- e
  
  # mc <- match.call( expand.dots=FALSE)
  # mc[ names( mc) %except% names( formals( xcompile)]
  whatever <- try( xcompile( pp_full_file, flags=flags, ...))
  if( whatever %is.not.a% 'try-error'){
    # Rename it...
    dynlo <- dir( dirname( full_file), pattern='_TMBOpp1[.](dll|so)', 
        full.names=TRUE)
    file.rename( dynlo, sub( '_TMBOpp1[.]', '.', dynlo))
    whatever <- 0
  } else {
    whatever <- 1
    attr( whatever, 'log') <- e$sysoutput
  }
    
return( whatever)
}


"extract_confession" <-
function(){
  # Get the sodding name of the sodding C compiler that sodding R uses
  # 'capture.output( tools:::.shlib_internal)' does not work becoz 'system'...
  shlibbo <- evalq( .shlib_internal, asNamespace( 'TMB'))
  e <- new.env( parent=environment( shlibbo))
  
  # .shlib_internal( "-n") calls system(), but does not use the result
  # Redirect it to save the output into a charvec
  system_fix <- function( ...){
      mc <- match.call( expand.dots=TRUE)
      mc$intern <- TRUE
      mc$ignore.stdout <- mc$ignore.stderr <- mc$show.output.on.console <- FALSE
      mc[[1]] <- quote( base::system)
      res <- eval.parent( mc)
      assign( 'sysout', res, environment( sys.function()))
    return( NULL)
  }
    
  environment( system_fix) <- e
  e$system <- system_fix
  e$sysout <- NULL
  environment( shlibbo) <- e
  tf <- tempfile()
  sink( tf) 
  try( shlibbo( list( '-n', system.file( 'examples/vectoro1.cpp', package='TMBO'))))
  sink()
  
  compiloo <- ''
  if( is.character( e$sysout) && length( e$sysout) && grepl( 'vectoro1', e$sysout[1])){
    compiloo <- sub( ' .*', '', e$sysout[1])
    if( !nzchar( Sys.which( compiloo))){
      compiloo <- 'cpp' # :(
    }
  }
  bingo <- nzchar( compiloo)
  if( bingo){
    Sys.setenv( CPP_IN_R=compiloo)
  } else {
warning( r"--{Can't auto-deduce C compiler's name. If "cpp" doesn't work for you, set envar "CPP_IN_R" via 'Sys.setenv()'}--")
  }
  
return( bingo)
}


"gsub_template" <-
function( x, ...){
## eg f(x, sub1='string', sub2='more') or
## f( x, returnList( sub1, sub2))

  l <- list( ...)
  if( (length( l)==1) && is.list( l[[1]])){
    l <- l[[1]] # presumably returnList case
  }
  
  for( il in names( l)){
    x <- gsub( sprintf( '<%s>', il), l[[ il]], x)
  }
return( x)
}


"make_all_ELn" <-
function( n, files=TRUE, count_dims=FALSE){
## Create lots of macro definitions for different array dimensions
## Originally just the key "EL<n>" macros, hence the name... now many more

  commasepi <- function( string, sep=', ') 
      paste( sprintf( string, 1:i), collapse=sep)

# If there was a comprehensible way to use a bool-returning assert( test, msg), that could be switched off by NDEBUG for speed, then these could check whether the right number of subscripts are being used--- coz TMB doesn't !!! EG
#   EL1( x, i) x( assert_or_true( _NDIM__##x==1) ? ((i)-firstel__x(1)) : (-1) )
# But assertions seem like a total nightmare in the wonderful world of TMB & friends...
  
  
  EL <- character( n)
  EL_template <- '#define EL<i>( x, <arglist>) x( <indlist>)'
  for( i in 1 %upto% n){
    EL[ i] <- gsub_template( EL_template,
        i= i,
        arglist= commasepi( 'i%i'), 
        indlist= commasepi( '(i%1$i)-FIRSTEL__##x( %1$i-1)')
      )
  }

  # Debug versions of EL do a lot more checks...
  # No point in checking ninds for the all-macro version, coz it still
  # triggers eigen_assert()
  #   '#define EL<i>( x, <arglist>) x( TMBOOB_dimcheck(<i>-x.dim.size(),' %&%
  debug_EL <- character( n)
  debug_EL_template <- '#define EL<i>( x, <arglist>) x( <indlist>)'
  
  for( i in 1 %upto% n){
    debug_EL[ i] <- gsub_template( debug_EL_template,
        i= i,
        arglist= commasepi( 'i%i'), 
        indlist= commasepi( 
            '_TMBOOB_check((i%1$i)-FIRSTEL__##x( %1$i-1),' %&% 
            'x.dim(%1$i-1), _TMBOOBmessa( #x, %1$i))')
      )
  }

  # Fancier debug version that can check ninds; needs runtime C checking
  debug2_EL <- character( n)
  debug2_EL_template <- 
      '#define EL<i>( x, <arglist>) x[ _TMBOOB_checkA( x.mult, x.dim, FIRSTEL__##x, _TMBOOBmess( #x), <i>, <arglist>)]'
  for( i in 1 %upto% n){
    debug2_EL[ i] <- gsub_template( debug2_EL_template,
        i= i,
        arglist= commasepi( 'i%i') 
      )
  }  

  if( count_dims){
    debug_EL <- debug2_EL
  }

  SET_ARRAY_CHINDS_template <- substring( first=2, r"--{
#define SET_ARRAY_CHINDS_D<i>( x, <arglist>) \
  vector<int> _CHINDID__##x( <i>); _CHINDID__##x << <stringylist>;
}--")
  SET_ARRAY_CHINDS <- character( n)
  for( i in 1 %upto% n){        
    SET_ARRAY_CHINDS[ i] <- gsub_template( SET_ARRAY_CHINDS_template,
        i=i, 
        arglist= commasepi( 'DR%i'),
        stringylist= commasepi( '#DR%i')
      )
  }

  # substring( first=2, ...) to remove initial <CR>
  ARRAYO_fl_template <- substring( first=2, r"--{  
#define _ARRAYO_TMBO_fl_D<i>( tipe, x, <fllist>) \
  array<tipe> x(<dimlist>); \
  vector<int> FIRSTEL__##x(<i>); \
  FIRSTEL__##x << <setfirstels>;
}--")
  ARRAYO_fl <- character( n)
  for( i in 1 %upto% n){
    ARRAYO_fl[ i] <- gsub_template( ARRAYO_fl_template,
        i=i, 
        fllist= commasepi( 'f%1$i, l%1$i'), 
        dimlist= commasepi( '(l%1$i)-(f%1$i)+1'),
        # setfirstels= commasepi( '  FIRSTEL__##x(%1$i-1) = f%1$i;', '\\\\\n')
        setfirstels= commasepi( 'f%i')
      )
  }

  ARRAYO_dr_template <- substring( first=2, r"--{
#define _ARRAYO_TMBO_D<i>( tipe, x, <arglist>) \
  _ARRAYO_TMBO_intermediate( tipe, x, <i>, <deparenlist>)
}--")
  ARRAYO_dr <- character( n)
  for( i in 1 %upto% n){        
    ARRAYO_dr[ i] <- gsub_template( ARRAYO_dr_template,
        i=i, 
        arglist= commasepi( 'DR%i'),
        deparenlist= commasepi( 'DEPAREN( DR%i)')
      )
  }

  ARRAY1_dr_template <- substring( first=2, r"--{
#define _ARRAY1_TMBO_D<i>( tipe, x, <arglist>) \
  <checklist>; \
  _ARRAYO_TMBO_intermediate( tipe, x, <i>, <lastarglist>);
}--")
  ARRAY1_dr <- character( n)
  for( i in 1 %upto% n){        
    ARRAY1_dr[ i] <- gsub_template( ARRAY1_dr_template,
        i=i, 
        arglist= commasepi( 'DR%i'),
        checklist= commasepi( 'CHECK1( DEPAREN( DR%i))', '; '),
        lastarglist= commasepi( '1, LASTARG( DEPAREN( DR%i))') 
      )
  }

  if( isF( files)){
    nvecs <- ls( environment()) 
    nvecs <- nvecs %SUCH.THAT% is.character( get( .))
    nvecs <- nvecs %SUCH.THAT% (length( get( .))==n)
return( mget( nvecs))
  }
  
  if( isT( files)){ # use boring_array_bits<n>.h in package
    path <- if( exists( '..TMBO', mode='environment')){
        # Devel version of package
        file.path( attr( ..TMBO, 'path'), 'inst/include')
      } else {
        system.file( 'include', package='TMBO')
      }
    files <- file.path( path, 'boring_array_bits1.h')
  }
  
  writeLines( c(
      SET_ARRAY_CHINDS),
      con= files[1]
    )
      
  # If just one file, 2nd one has same name but "2" instead of "1" 
  if( length( files)==1){
    files[ 2] <- file.path( dirname( files[1]), 
        sub( '1', '2', basename( files[1])))
stopifnot( files[2] != files[1])    
  }
  
  writeLines( c( 
      '#ifndef TMBOOBOO2',
      EL, 
      '#else',
      debug_EL,
      '#endif', '',
      ARRAYO_fl, '', 
      ARRAYO_dr, '',
      ARRAY1_dr),
      con=files[2]
    )
return( files)
}


"MakeADFun" <-
function( 
  data, 
  parameters, 
  ..., 
  ranges=list()
){
stopifnot( 
    is.list( data), all( nzchar( names( data))), 
    is.list( parameters), all( nzchar( names( parameters))),
    is.list( ranges)
  )

  if( length( ranges)){
    range_mode <- sapply( ranges, mode)
stopifnot(
      all( range_mode %in% cq( numeric, character, list)),
      all( nzchar( names( ranges)) | range_mode=='list'),
      all( lengths( ranges) > 0)
    )
  }

  all_chinds <- list() # for reconstructing chinds during report()
  # Make all_chinds updatable:
  environment( add_chinds_from_dims) <- environment()
  
  # var_chindi <- list() # extra "data" expected by TMBO code
  for( did in names( data)){
    # firstel works on everything
    data[[ 'FIRSTEL__' %&% did]] <- firstel( data[[ did]])
    data[[ '_CHINDID__' %&% did]] <- add_chinds_from_dims( did, data[[ did]])
  } # for data

  for( pid in names( parameters)){
    # firstel works on everything
    data[[ 'FIRSTEL__' %&% pid]] <- firstel( parameters[[ pid]])    
    data[[ '_CHINDID__' %&% pid]] <- add_chinds_from_dims( 
        pid, parameters[[ pid]])
  } # for parameters

  # Like stopifnot() but with specific error message
  rangefail_ifnot <- function( cond) if( !cond) stop( 'Invalid range "%s"', rid)
  
  for( ir in seq_along( ranges)){
    rid <- names( ranges)[ ir] # "" if for CHIND_EXPAND; use name of listee
    rangeum <- ranges[[ ir]]
    if( is.list( rangeum)){ # for CHIND_EXPAND in TMB
stopifnot( length( rangeum)==1)    
      if( !nzchar( rid)){ # ie unless explicitly renaming
        rid <- names( rangeum)[1]
      }
      rangeum <- rangeum[[1]]
      data[ rangeum %&% '_'] <- seq_along( rangeum)  
    }
    
    if( is.character( rangeum)){
      all_chinds[[ rid]] <- rangeum
      data[[ '_CHINDID__' %&% rid]] <- length( all_chinds)
      rangeum <- c( 1L, length( rangeum))
    } else {
rangefail_ifnot( 
        length( rangeum)>0 && 
        all( is.finite( rangeum)) && 
        all( floor( rangeum)==rangeum))

      # No need for _CHINDID__<x> here cos it's hash-defined as 0 by ICONSEQ
      # data[[ '_CHINDID__' %&% rid]] <- 0L
      storage.mode( rangeum) <- 'integer'
      if( length( rangeum) != 2){ # probably an actual sequence, mebbe length-1
rangefail_ifnot( all( diff( rangeum)==1))
        rangeum <- rangeum[ c( 1, length( rangeum))]
      }
rangefail_ifnot( 
        rangeum[1] <= rangeum[2])
    }

    data[[ 'FIRSTEL__' %&% rid]] <- rangeum[1]
    data[[ 'LASTEL__' %&% rid]] <- rangeum[2]
  } #   for ranges
  
  mc <- match.call( expand.dots=TRUE)
  mc$ranges <- NULL
  mc$data <- data
  mc$parameters <- parameters
  mc[[1]] <- quote( TMB::MakeADFun)
  Obj <- eval.parent( mc)
  
  # Obj$report: modify for returned offarrays, and chinds
  orep <- Obj$report
  nrep <- new_report
  formals( nrep) <- formals( orep)
  formals( nrep)$TMBO <- TRUE
  e <- new.env( parent=environment( orep))
  e$raw_TMB_report <- orep
  e$all_chinds <- all_chinds
  if( !exists( '%||%', baseenv())){ 
    e$'%||%' <- `%||%`
  }
  environment( nrep) <- e
  Obj$report <- nrep
  
return( Obj)
}


"mock_shlib_internal" <-
function( args){
  # Hacks the makefile, to add TMBO's include path at the start of the paths in PKG_CPPFLAGS
  mvfile <- Sys.getenv( 'R_MAKEVARS_USER')
  flubbo <- readLines( mvfile)
  greppo <- grep( '^PKG_CPPFLAGS=', flubbo)
  if( length( greppo) != 1){
stop( "Can't figure out how to add TMBO include path. Need 3-step compilation...")
  }
  
    flubbo[ greppo]  <- sub( '=', sprintf( '= -I"%s" ', 
        system.file( 'include', package='TMBO')), flubbo[ greppo])
  writeLines( flubbo, mvfile)
real_shlib_internal( args)
}


"mock_system" <-
function( ...){
## DOESN'T WORK PROPERLY but I don't wanna just delete it
## base::system() gets called inside .shlib_internal(), which chooses not to capture the output
## And that is intensely annoying
## So, hackity chop chop
cat( 'HELLO!\n')
  mc <- match.call( base::system, expand.dots=TRUE)
#   mc$intern <- TRUE
  mc[[1]] <- quote( base::system)
  # This should just be utils::capture.output, but that triggers R CMD CHECK warning about utils
  # ... fair enough really. So, hide it...
  flub <- asNamespace( 'utils')$capture.output( eval.parent( mc))
  res <- attr( flub, 'status')
  if( is.null( res)){
    res <- 0
  }
  sysoutput <<- c( flub) # sysoutput will exist in enviro of this function, when called
  cat( flub, sep='\n') # normal behaviour would be to display it
return( res)
}


"new_report" <-
function( fake_args_for_now, TMBO=TRUE){
## Never called as-is! This is really a template...
## it replaces $report, and has its args & envir changed, during MakeADFun()
## Has access to original report, and all_chinds, via its envir

  # Call original TMB $report()
  mc <- match.call( expand.dots=TRUE)
  mc[[1]] <- raw_TMB_report # will be in this fun's environment
  replist <- eval.parent( mc) # ie TMB's report()
  if( !TMBO || !length( replist)){
return( replist)
  }
  
  # Look for reportees that are just firstels of "real" TMB objects
  items <- names( replist)
  
  all_chindables <- chindables <- items[ which( startsWith( items, '_CHINDID_'))]
  offables <- items[ which( startsWith( items, 'FIRSTEL_'))]
  ables <- sub( '.*__', '', chindables)
  really_there <- ables %in% items # eg all CHINDs might be exported, to avoid stupid compiler warnings
  chindables <- chindables[ really_there]
  ables <- ables[ really_there]

  names( chindables) <- ables
  names( offables) <- sub( '.*__', '', offables)
stopifnot( all( names( offables) %in% ables))
  
  for( i in ables){
    chindi <- replist[[ chindables[ i] ]]
    if( i %in% names( offables)){
      offi <- replist[[ offables[ i] ]]
  
      # Default is integer-offset (not char)
      dimi <- dim( replist[[ i]]) %||% length( replist[[ i]])
        
      dimseqi <- vector( 'list', length( dimi))
      for( j in which( chindi==0)){
        dimseqi[[ j]] <- seq( from=offi[ j], by=1L, length= dimi[ j])
      }
      for( k in which( chindi>0)){
        dimseqi[[ k ]] <- all_chinds[[ chindi[ k] ]]
      }
      
      replist[[ i]] <- offarray( replist[[ i]], dimseq= dimseqi)
    } else if( any( chindi>0)) { 
      # Regular vector (names) or matrix/array (dimnames)
      if( length( chindi)==1){
        names( replist[[i]]) <- all_chinds[[ chindi]]
      } else {
        # Surprisingly, this works: puts NULL into a list when OOB
        chindi[ chindi==0] <- length( all_chinds)+1
        dimnames( replist[[i]]) <- unname( all_chinds[ chindi])
      }
    } # else leave it alone; vanillist R object without (dim)names
  } # for (chind)ables, which includes offables
  
  replist[ c( all_chindables, offables)] <- NULL
  
return( replist)
}


"runExample" <-
function( 
  name, 
  all= FALSE,
  exfolder= NULL,
  subarch= FALSE, # obsolete post R4.3
  dontrun= FALSE,
  clean= FALSE,
  ppflags= NULL,
  ...
){
  mc <- match.call( expand.dots=TRUE)
  mc$subarch <- subarch # force
  
  if( is.null( mc$exfolder)){
    # Override TMB default. And forcibly copy example(s) into "temp" subfolder, to avoid clutter
    # I prefer that to TMB's normal behaviour
    TMBOx <- system.file( 'examples', package = 'TMBO')
    temp <- file.path( TMBOx, 'temp')
    if( !dir.exists( temp)){
      mkdir( temp)
    }
    legit <- dir( TMBOx, pattern='[.]R$')
    legit <- legit %such.that% file.exists( 
        file.path( TMBOx, sub( 'R$', 'cpp', .)))
    if( !missing( name) && !all){
      legit <- legit[ startsWith( legit, name)]
    }
    if( !length( legit)){
      msg <- if( all || missing( name)) 'Examples not found' else 
        sprintf( "Example '%s' not found", name)
stop( msg)
    }
    for( i in 1:2){
      file.copy( file.path( TMBOx, legit), file.path( temp, legit), 
          overwrite=TRUE)
      legit <- sub( 'R$', 'cpp', legit)
    }
    
    mc$exfolder <- temp
  }
  if( clean){
    DYN.UNLOAD( name, warn_if_not_loaded= FALSE)
    try( unlink( dir( mc$exfolder, pattern=name %&% '_TMBOpp1', 
        full.names=TRUE)))
  }
  
  if( !dontrun){
    # In case compilation fails, at least restore setwd()... 
    # ... unlike TMB default  
    mc$dontrun <- substitute( !file.exists( dynlib( name)))
  }
  
  TMB_runex <- TMB::runExample
  environment( TMB_runex) <- asNamespace( 'TMBO') # to use TMBO::compile
  mc[[1]] <- TMB_runex
  
  owd <- getwd()
  res <- try( eval.parent( mc))
  setwd( owd)
  
  if( (res %is.a% 'list') && identical( names( res), cq( value, visible))){
    res <- res$value
  }
invisible( res)
}


"TMBO_ranges" <-
function( ...){
  dotcall <- match.call( expand.dots=FALSE)$...
  just_name <- sapply( dotcall, is.name)
  l <- list( ...)
  naml <- names( l) %||% character( length( l))
  get_name_from_arg <- !nzchar( naml) & just_name
  naml[ get_name_from_arg] <- sapply( dotcall[ get_name_from_arg], 
      as.character)

  # NB do.on() looks vectory, but actually requires && and ||
  # cos it's applied one element at a time      
  listified <- do.on( dotcall, 
      is.call(.) && (as.character( .[[1]])=='list') )
  list_OK <- do.on( dotcall[ listified], 
    (length(.)==2) && (is.name( .[[2]]) || nzchar( names(.)[2])))
  if( !all( list_OK)){
stop( sprintf( "Invalid list() args [%s] to 'TMBO_ranges'", 
    paste( which( listified[ !list_OK]), collapse=',')))
  }
  
  lfnames <- do.on( dotcall[ listified], 
      names( .)[2] %||% as.character( .[[2]]))
  naml[ listified & !nzchar( naml)] <- lfnames # given name takes priority
  
  names( l) <- naml
return( l)
}

