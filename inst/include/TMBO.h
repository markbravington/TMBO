/***
  Use as #include <TMBO.h>, INSTEAD OF <TMB.hpp>.
  First-pass preprocessing with cpp -CC <yourfile> to some output dot-cpp
  MUST use -CC option, otherwise defines won't work
  Then needs a pass thru R or SED mainly to zap empty and TMBO-specific multi-line comments (not user comments).
  Then "normal" compilation should work fine.
  Probably does *not* need C++20 (which is good cos Eigen won't compile with it) unless __VA_OPT__ is needed in 2nd pass (to be avoided). At present __VA_OPT__ is not used at all, but might be in *this* file only (coz we could enforce C++20 during preprossing *only*).
  This file includes key defns.

  Be careful with #define etc in your own code if it is coming thru here. for #define, probably use HASH_DEFINE etc (with no # character in front). Then the macro will only be expanded during "normal" TMB compilation. If #if etc are only depending on your own macros/defs, then you can prolly use the normal #<directive> directly; if relying on TMB's definitions, deffo use HASH_<directive> instead.

  With #include, you probably *do* want that for your own sub-files, but *not* for "system header" like Eigen--- for those, do eg this:
  HASH_INCLUDE <Eigen.h>
  HASH_INCLUDE <RcppArmadillo.h>
  The other might work, but I haven't tried it.

  And *OMIT* TMB.h itself altogether (it will be handled during "normal" compilation).
  
  Comments like this one (with three asterisks) will be stripped, but normal user comments won't be.
***/

#define TMBO_PASS1

#define HASH_DEFINE TMBO_NOTHING#define
#define HASH_INCLUDE TMBO_NOTHING#include
#define HASH_UNDEF TMBO_NOTHING#undef
#define HASH_IF TMBO_NOTHING#if
#define HASH_IFDEF TMBO_NOTHING#ifdef
#define HASH_IFNDEF TMBO_NOTHING#ifndef
#define HASH_ELSE TMBO_NOTHING#else
#define HASH_ELIF TMBO_NOTHING#elif
#define HASH_ENDIF TMBO_NOTHING#endif
#define HASH_PRAGMA TMBO_NOTHING#pragma
#define TMBO_FILE_NAME TMBO_NOTHING#
#define TMBO_VARGS(x) __VA_##x##ARGS__
#define TMBO_VA(x,y) __VA_##x##__(y,)
#define TMBO_NOEXPAND( x, y) x##y
#define TMBO_NOTHING


HASH_DEFINE TMBO_PASS2

/*** 
  DONT_WARN_ABOUT( CHINDID) avoidS stupid warnings about "var not used"...
 Lite method is by updating silly variable. Full-on is to REPORT *every* chindid... might be slight overhead. Default is Lite, but if that gives stupid warnings, then set the macro FULLON_ANTISTUPID_WARNINGS before including TMBO, at possible cost of microseconds 
***/
#ifdef FULLON_ANTISTUPID_WARNINGS
  #define DONT_WARN_ABOUT( x) REPORT( x)
#else
  #define DONT_WARN_ABOUT( x) flubbadub += flubbadubbadoo*sizeof(x)
  int flubbadub = 0;
  int flubbadubbadoo = 0;
#endif 

/*** OOBery
TMBOOBOO and TMBOOBOOB are synonyms. 
Must come before including TMBO2.h (actually boring_array_bits2.h) 
cos it affects which version of EL<n>() gets used.
Originally had defns of _TMBOOB_check() and _TMBOOB_dimcheck() here
but they need TMB macros for Rf_error, so must be deferred to TMBO2.h.
If TMBOOB_check fun is needed, do it before TMB_MAGIC. If not, define as a macro for 2nd pass.
***/

#ifdef TMBOOBOO
  #define TMBOOBOOB 1
#endif

#ifdef TMBOOBOOB
  HASH_DEFINE TMBOOBOOB2 1
  HASH_DEFINE TMBOOBOO2 1
#else
  HASH_DEFINE _TMBOOB_checkV( i, f, ...) (i)-f
  HASH_DEFINE _TMBOOB_checkM1( i, j, f, ...) (i)-f
  HASH_DEFINE _TMBOOB_checkM2( i, j, f, ...) (j)-f
#endif


/*** Includes
May need explicit include-paths in 2nd pass. Use macros in the CPP call 
I think the "else" version is fine though.
***/
#ifdef TMBO2_IPATH 
  HASH_INCLUDE TMBO2_IPATH
#else
  HASH_INCLUDE <macro_utils_TMBO.h>
  HASH_INCLUDE <boring_array_bits2.h>
  HASH_DEFINE boringTMBO2_done yes
  HASH_INCLUDE <TMBO2.h>
#endif

#define TMB_MAGIC template<class Type> /*
*/ Type objective_function<Type>::operator() ()
#define TMBO_MAGIC TMB_MAGIC

#include <macro_utils_TMBO.h>


/*** 
  Some of these meta-defines have an apparently surplus extra blank comment at the end. Unfortunately, those _do_ seem to be necessary, otherwise spurious characters get appended (looks like they are from earlier in the macro); I suspect this is a GCC bug. Anyway, the blank extra comment fixes it..!
***/

/*** 
  TMBO_assert() [currently in TMBO2.h] returns middle arg if condition OK, or if not debugging; otherwise, it aborts with error message. Possibly a bad name for it, possibly a bad implementation too... ***/

/*** For predefined integer ranges, eg YEARS ***/
#define ICONSEQ( r) DATA_INTEGER( FIRSTEL__##r); DATA_INTEGER( LASTEL__##r); /*
*/ DONT_WARN_ABOUT( FIRSTEL__##r); /*
*/ DONT_WARN_ABOUT( LASTEL__##r); /*
*/ HASH_DEFINE _CHINDID__##r 0 /*
*/ HASH_DEFINE r (FIRSTEL__##r,LASTEL__##r) /*
*/

/*** OFFARRAY: Label x for special REPORT treatment ***/
#define OFFARRAY( x) /*
*/ HASH_DEFINE _IS_OFFARRAY__##x yes /*
*/ DONT_WARN_ABOUT( _CHINDID__##x); /*
*/

/*** Functoid helper: hardly necessary, but... ***/
#define FUNCTOID( fun) auto fun = [&]

/*** Vectors--- last line of MINIMAL_VECTOR_DEFS is key ... ***/
/*** Diff between MINIMAL and MOST is that the latter includes
flubbadub calcs to circumvent stupid warnings, so you can't use it inside a parameter list--- eg, and perhaps just ie, for a functoid 
***/
/*** It's arguable that I should set a flag '_IS_VMAO_xx' if 'xx' gets defined as an VMAO, so that I can check that flag in case the user ever attempts to redefine 'xx', and signal a compile error. That's obscure, because I think that could only "legally" happen with a functoid, anyway (otherwise the compiler would trap it... perhaps?). Anyway, I haven't.
***/

#define MINIMAL_VECTORO_DEFS( x) /*
*/ HASH_DEFINE _HAS_CHINDID__##x yes /*
*/ HASH_DEFINE LASTEL__##x (FIRSTEL__##x + x.size()-1) /*
*/ HASH_DEFINE x(i) x( _TMBOOB_checkV( i, FIRSTEL__##x, x.size(), _TMBOOBmess( #x))) /*
*/

#define MOST_VECTORO_DEFS( x) /*
*/ OFFARRAY( x) /*
*/ DONT_WARN_ABOUT( FIRSTEL__##x); /*
*/ DONT_WARN_ABOUT( _CHINDID__##x); /*
*/ MINIMAL_VECTORO_DEFS( x) /*
*/

#define RVECTORO_DEFS( metatipe, x) metatipe##VECTOR( x); DATA_INTEGER( FIRSTEL__##x); DATA_INTEGER( _CHINDID__##x); /*
*/ MOST_VECTORO_DEFS( x)

#define DATA_VECTORO( x) RVECTORO_DEFS( DATA_, x)
#define DATA_IVECTORO( x) RVECTORO_DEFS( DATA_I, x)
#define PARAMETER_VECTORO( x) RVECTORO_DEFS( PARAMETER_, x)
#define VECTORO( tipe, x, DR) int _CHINDID__##x = #DR; /*
*/ VECTORO_pass2( tipe, x, DR) /*
*/ MOST_VECTORO_DEFS( x)

#define USE_VECTORO( tipe, x) /*
*/ vector<tipe> x, int FIRSTEL__##x, int _CHINDID__##x /*
*/ MINIMAL_VECTORO_DEFS( x)
#define PASS_VECTORO( x) x, FIRSTEL__##x, _CHINDID__##x

/*** Offset-1 doesn't get OFFARRAY, and has simpler first/last ***/
#define MINIMAL_VECTOR1_DEFS( x) /*
*/ HASH_DEFINE _HAS_CHINDID__##x yes /*
*/ HASH_DEFINE FIRSTEL__##x 1 /*
*/ HASH_DEFINE LASTEL__##x x.size() /*
*/ HASH_DEFINE x(i) x( _TMBOOB_checkV( i, 1, x.size(), _TMBOOBmess( #x))) /*
*/
#define MOST_VECTOR1_DEFS( x) /*
*/ DONT_WARN_ABOUT( _CHINDID__##x); /*
*/ MINIMAL_VECTOR1_DEFS( x) /*
*/

#define RVECTOR1_DEFS( metatipe, x) metatipe( x); DATA_INTEGER( _CHINDID__##x); /* 
*/ MOST_VECTOR1_DEFS( x)

#define DATA_VECTOR1( x) RVECTOR1_DEFS( DATA_VECTOR, x)
#define DATA_IVECTOR1( x) RVECTOR1_DEFS( DATA_IVECTOR, x)
#define PARAMETER_VECTOR1( x) RVECTOR1_DEFS( PARAMETER_VECTOR, x)
#define DATA_FACTOR1( x) RVECTOR1_DEFS( DATA_FACTOR, x)
#define VECTOR1( tipe, x, DR_OR_NELS) int _CHINDID__##x = #DR_OR_NELS; /*
*/ VECTOR1_pass2( tipe, x, DR_OR_NELS); /*
*/ MOST_VECTOR1_DEFS( x)

#define USE_VECTOR1( tipe, x) /*
*/ vector<tipe> x, int _CHINDID__##x /*
*/ MINIMAL_VECTOR1_DEFS( x)
#define PASS_VECTOR1( x) x, _CHINDID__##x

#define VECTORO_sameshapeas( tipe, x, templatum) VECTORO( tipe, x, DIMRANGE( templatum)) /*
*/ _CHINDID__##x = _CHINDID__##templatum; /*
*/

#define VECTOR1_sameshapeas( tipe, x, templatum) VECTOR1( tipe, x, DIMRANGE( templatum)); /*
*/ _CHIND__##x = _CHIND__##templatum; /*
*/


/***
Convenience 0-based for initial conversion to TMBO; does *not* convert to offarray in R
***/
#define VECTORZ( tipe, x, len) VECTORO( tipe, x, (0,len-1)); /*
*/ HASH_UNDEF _IS_OFFARRAY__##x /*
*/

#define DPN_VECTORZ( DP, numtype, x) /*
*/ DP##_##numtype##VECTOR( x); /*
*/ int FIRSTEL__##x=0; int _CHINDID__##x = 0; /*
*/ MOST_VECTORO_DEFS( x) /*
*/ HASH_UNDEF _IS_OFFARRAY__##x /*
*/

#define DATA_VECTORZ( x) DPN_VECTORZ( DATA, , x)
#define DATA_IVECTORZ( x) DPN_VECTORZ( DATA, I, x)
#define PARAMETER_VECTORZ( x) DPN_VECTORZ( PARAMETER, , x)

/***
  Workaround for TMB bug, presumably cozza some C++ bollox.
  The following should work, but doesn't:
  vector<Type> lglk_bits{LnL_POP1, LnL_POP2};
  Nor does, but should, vector<Type> lglk_bits << a,b,...;
  Using "<<" is key, but then gotta prespec the size of the goddamn vector, 
  surely even C++ can work THAT out nope apparabloodymently not
***/

#define CREATE_AND_FILL_VECTORO( tipe, x, firstel, ...) \
   VECTORO( tipe, x, (firstel, NARGS(__VA_ARGS__)+firstel-1)); x << __VA_ARGS__;


/*** 
  Annoyingly, there's no matrix.dim "method" though there is for arrays. So we need to create yet another function-macro, _DIM__##x, to do that, depending on whether x is matrix or array.
  In theory, mebbe good to have a _DIM__##x(i) that checks 1 <= i <= length( dims( x)) using assert() etc. But that would mean work for me; and what's one more incomprehensible potential user-error within the grand scheme of TMB..?
  eg roughly _DIM__##x( i) ( i==0 ? x.rows() : TMBO_assert( i==1, x.cols(), 
  "Dim-number of matrix must be 1 or 2"))
  But not yet
***/

#define GENERAL_MATRIX_BODY( x) /*
*/ HASH_DEFINE _HAS_CHINDID__##x yes /*
*/ HASH_DEFINE _DIM__##x( i) ( i==0 ? x.rows() : x.cols()) /*
*/ HASH_DEFINE x( i, j) x( _TMBOOB_checkM1( i, j, FIRSTEL__##x(0), x.rows(), _TMBOOBmess( #x)), _TMBOOB_checkM2( i, j, FIRSTEL__##x(1), x.cols(), _TMBOOBmess( #x)) ) /*
*/

/*** I've moved DONT_WARN_ABOUT() calls to OFFARRAY or direct, so we don't need the next... hopefully...
***/
#define OLD_GENERAL_MATRIX_BODY( x) /*
*/ DONT_WARN_ABOUT( _CHINDID__##x); /*
*/ INNER_GENERAL_MATRIX_BODY( x) /*
*/

/*** No-error-trap version is:
HASH_DEFINE x( i,j) x( (i)-FIRSTEL__##x(0), (j)-FIRSTEL__##x(1)) 
***/

#define RMATRIXO_DEFS( metatipe, x) metatipe##MATRIX( x); /*
*/ DATA_IVECTOR( FIRSTEL__##x); /*
*/ DATA_IVECTOR( _CHINDID__##x); /*
*/ OFFARRAY( x) /*
*/ GENERAL_MATRIX_BODY( x)

#define MATRIXO1( tipe, x, DR1, DR2, O1) vector<int> _CHINDID__##x( 2); _CHINDID__##x << #DR1, #DR2; /*
*/ MATRIX##O1##_pass2( tipe, x, DR1, DR2) /*
*/ GENERAL_MATRIX_BODY( x)

#define DATA_MATRIXO( x) RMATRIXO_DEFS( DATA_, x)
#define DATA_IMATRIXO( x) RMATRIXO_DEFS( DATA_I, x)
#define PARAMETER_MATRIXO( x) RMATRIXO_DEFS( PARAMETER_, x)
#define MATRIXO( tipe, x, DR1, DR2) MATRIXO1( tipe, x, DR1, DR2, O) /*
*/ OFFARRAY( x) /*
*/

#define USE_MATRIXO( tipe, x) /*
*/ matrix<tipe> x, vector<int> FIRSTEL__##x, vector<int> _CHINDID__##x /*
*/ GENERAL_MATRIX_BODY( x)
#define PASS_MATRIXO( x) x, FIRSTEL__##x, _CHINDID__##x

#define RMATRIX1_DEFS( metatipe, x) metatipe##MATRIX( x); vector<int> FIRSTEL__##x(2); FIRSTEL__##x << 1,1; /*
*/ DATA_IVECTOR( _CHINDID__##x); /*
*/ DONT_WARN_ABOUT( _CHINDID__##x); /*
*/ GENERAL_MATRIX_BODY( x)

#define DATA_MATRIX1( x) RMATRIX1_DEFS( DATA_, x)
#define DATA_IMATRIX1( x) RMATRIX1_DEFS( DATA_I, x)
#define PARAMETER_MATRIX1( x) RMATRIX1_DEFS( PARAMETER_, x)
#define MATRIX1( tipe, x, DR1, DR2) MATRIXO1( tipe, x, DR1, DR2, 1)

/*** No point in separate USE/PASS defns for 1vsO, since 
  FIRSTEL exists automatically
***/
#define USE_MATRIX1( tipe, x) USE_MATRIXO( tipe, x)
#define PASS_MATRIX1( x) PASS_MATRIXO( x)

#define MATRIXO_sameshapeas( tipe, x, templatum) vector<int> _CHINDID__##x = _CHINDID__##templatum; /*
*/ MATRIXO_pass2( tipe, x, DIMRANGE( templatum, 1), DIMRANGE( templatum, 2)); /*
*/ GENERAL_MATRIX_BODY( x) /*
*/ OFFARRAY( x) /*
*/

#define MATRIX1_sameshapeas( tipe, x, templatum) vector<int> _CHINDID__##x = _CHINDID__##templatum; /*
*/ MATRIX1_pass2( tipe, x, DIMRANGE( templatum, 1), DIMRANGE( templatum, 2)) /*
*/ GENERAL_MATRIX_BODY( x)

/***
   Zero-based convenience version that *won't* convert to offarray in R
***/
#define MATRIXZ( tipe, x, l1, l2) MATRIXO( tipe, x, (0,l1-1), (0,l2-1)) /*
*/ HASH_UNDEF _IS_OFFARRAY__##x /*
*/ HASH_UNDEF _HAS_CHINDID__##x /*
*/

#define DPN_MATRIXZ( DP, numtype, x) /*
*/ DP##_##numtype##MATRIX( x); /*
*/ vector<int> FIRSTEL__##x(2); FIRSTEL__##x.setZero(); /*
*/ vector<int> _CHINDID__##x = FIRSTEL__##x; /*
*/ GENERAL_MATRIX_BODY( x)

#define DATA_MATRIXZ( x) DPN_MATRIXZ( DATA, , x)
#define DATA_IMATRIXZ( x) DPN_MATRIXZ( DATA, I, x)
#define PARAMETER_MATRIXZ( x) DPN_MATRIXZ( PARAMETER, , x)


/*** ARRAYS HERE
Details of ARRAYO_pass2_D<n>, EL<n>, in TMBO2 (boring...2); SET_ARRAY_CHINDS_D<n> here, in boring...1
***/
#include <boring_array_bits1.h>

/*** 
Not bothering to create _NDIM__##x now, coz it can't be defined at declaration and so it has to be a variable, which might as well just be x.dim 
***/
#define GENERAL_ARRAY_BODY( x) /*
*/ HASH_DEFINE _DIM__##x( i) x.dim( i) /*
*/ HASH_DEFINE _HAS_CHINDID__##x yes /*
*/ HASH_DEFINE x( ...) _CONCAT2_TMBO(EL, _NARGS_TMBO(__VA_ARGS_HERE__))(x, __VA_ARGS_HERE__) /*
*/

#define _metatype_ARRAYO( metatype, x) metatype##ARRAY( x); DATA_IVECTOR( _CHINDID__##x); DATA_IVECTOR( FIRSTEL__##x); /*
*/  OFFARRAY( x) /*
*/  GENERAL_ARRAY_BODY( x)

#define DATA_ARRAYO( x) _metatype_ARRAYO( DATA_, x)
#define DATA_IARRAYO( x) _metatype_ARRAYO( DATA_I, x)
#define PARAMETER_ARRAYO( x) _metatype_ARRAYO( PARAMETER_, x)

#define CONCAT(a, b) a ## b
#define CONCAT2(a, b) CONCAT(a, b)

/*** SET_ARRAY_CHINDS_D<n> happens now; ARRAYO_pass2_D<n> is deferred ***/
#define ARRAYO( tipe, x, ...) CONCAT2( SET_ARRAY_CHINDS_D, NARGS(__VA_ARGS__))(x, __VA_ARGS__); /*
*/ CONCAT2( _ARRAYO_TMBO_D, NARGS(__VA_ARGS__))(tipe, x, __VA_ARGS__) /*
*/  GENERAL_ARRAY_BODY( x) /*
*/  OFFARRAY( x)

#define USE_ARRAYO( tipe, x) /*
*/ array<tipe> x, vector<int> FIRSTEL__##x, vector<int> _CHINDID__##x /*
*/ GENERAL_ARRAY_BODY( x)
#define PASS_ARRAYO( x) x, FIRSTEL__##x, _CHINDID__##x


#define ARRAY1( tipe, x, ...) CONCAT2( SET_ARRAY_CHINDS_D, NARGS(__VA_ARGS__))(x, __VA_ARGS__) /*
*/ CONCAT2( _ARRAY1_TMBO_D, NARGS(__VA_ARGS__))(tipe, x, __VA_ARGS__) /*
*/  GENERAL_ARRAY_BODY( x)

#define ARRAY1_sameshapeas( tipe, x, templatum) vector<int> FIRSTEL__##x = FIRSTEL__##templatum; vector<int> _CHINDID__##x = _CHINDID__##templatum; array<tipe> x( templatum.dim); /*
*/ GENERAL_ARRAY_BODY( x) /*
*/

#define ARRAYO_sameshapeas( tipe, x, templatum) ARRAY1_sameshapeas( tipe, x, templatum) /*
*/ OFFARRAY( x) /*
*/

/*** 
2.4.30: Convenience versions from standard R arrays, that are 0-based in C but don't convert to offarray() if exported to R. For now, ndims must be user-specified; poor baby.
***/

#define ARRAYZ_1D( tipe, x, l1) /*
*/ ARRAYO( tipe, x, (0,l1-1)) /*
*/ HASH_UNDEF _IS_OFFARRAY__##x /*
*/

#define ARRAYZ_2D( tipe, x, l1, l2) /*
*/ ARRAYO( tipe, x, (0,l1-1), (0,l2-1)) /*
*/ HASH_UNDEF _IS_OFFARRAY__##x /*
*/

#define ARRAYZ_3D( tipe, x, l1, l2, l3) /*
*/ ARRAYO( tipe, x, (0,l1-1), (0,l2-1), (0,l3-1)) /*
*/ HASH_UNDEF _IS_OFFARRAY__##x /*
*/

#define ARRAYZ_4D( tipe, x, l1, l2, l3, l4) /*
*/ ARRAYO( tipe, x, (0,l1-1), (0,l2-1), (0,l3-1), (0,l4-1)) /*
*/ HASH_UNDEF _IS_OFFARRAY__##x /*
*/

#define ARRAYZ_5D( tipe, x, l1, l2, l3, l4, l5) /*
*/ ARRAYO( tipe, x, (0,l1-1), (0,l2-1), (0,l3-1), (0,l4-1), (0,l5-1)) /*
*/ HASH_UNDEF _IS_OFFARRAY__##x /*
*/

/***
For DATA/PARAMETER arrays, we can avoid dim-specific definitions. The only way to extract the number of dimensions, I think, is via 'ar.dim.size()'
***/
#define DPN_ARRAYZ( DP, numtype, x) /*
*/ DP##_##numtype##ARRAY( x); /*
*/ vector<int> _CHINDID__##x = x.dim * 0; /*
*/ vector<int> FIRSTEL__##x = _CHINDID__##x; /*
*/ GENERAL_ARRAY_BODY( x) /*
*/

#define DATA_ARRAYZ( x) DPN_ARRAYZ( DATA, , x)
#define DATA_IARRAYZ( x) DPN_ARRAYZ( DATA, I, x)
#define PARAMETER_ARRAYZ( x) DPN_ARRAYZ( PARAMETER, , x)


/*** CHARACTER INDICES ***/

#define CHIND( r) DATA_INTEGER( _CHINDID__##r); DATA_INTEGER( LASTEL__##r); int FIRSTEL__##r = 1; /*
*/ DONT_WARN_ABOUT( FIRSTEL__##r); /*
*/ DONT_WARN_ABOUT( LASTEL__##r); /*
*/ DONT_WARN_ABOUT( _CHINDID__##r); /*
*/ HASH_DEFINE _HAS_CHINDID__##x yes /*
*/ HASH_DEFINE r (1,LASTEL__##r) /*
*/

#define DECLARE_CHINDEL( el) DATA_INTEGER( el##_);

#define CHIND_EXPAND( r, ...) FOR_EACH( DECLARE_CHINDEL, __VA_ARGS__) /* 
*/ CHIND( r); assert( NARGS( __VA_ARGS__)== LASTEL__##r);

 
// REPORT
#define REPORT( x) HASH_IFDEF _IS_OFFARRAY__##x /*
*/   REPORT( FIRSTEL__##x); /*
*/ HASH_ENDIF /*
*/ HASH_IFDEF _HAS_CHINDID__##x /*
*/   REPORT( _CHINDID__##x); /*
*/ HASH_ENDIF /*
*/ REPORT( x)
