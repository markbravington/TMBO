// Include TMB itself, and define FOR-loop macros
// Should be expanded ONLY during 2nd pass... prolly orta include ifdef check
// Inept attempt at paranoia, TBH
#ifdef TMBO_PASS1
DO NOT INCLUDE ME IN FIRST PASS!
#endif

#ifndef TMBO_PASS2
DO NOT USE ME DIRECTLY--- ONLY IN 2ND PASS!
#endif

#if !TMBO_PPDEBUG
#include <TMB.hpp>
#endif

#ifdef TMBOOBOO2
   char _TMBO__OOBmsg[200]; // globvar easiest

   void guts_make_errmsg( const char* msg, int badi, int ninds, va_list inds){
    char *ch = _TMBO__OOBmsg, *const chend = _TMBO__OOBmsg + 199;

    _TMBO__OOBmsg[ 199] = 0; // just in case
    ch += snprintf( ch, 199, "%s(", msg);
    int ind2;
    for( int ii=1; ii<badi; ii++){
      ind2 = va_arg( inds, int);
      if( ch<chend) ch += snprintf( ch, chend-ch, "%i,", ind2);
    };
    ind2 = va_arg( inds, int);
    if( ch<chend) ch += snprintf( ch, chend-ch, "!%i!,", ind2);
    for( int ii=badi+1; ii<=ninds; ii++){
      ind2 = va_arg( inds, int);
      if( ch<chend) ch += snprintf( ch, chend-ch, "%i,", ind2);
    };
    if( ch<chend){
      ch--;
      ch += snprintf( ch, chend-ch, ")"); // replace final comma with paren
    };
  };
  
  void make_errmsg( const char* msg, int badi, int ninds, ...){
    va_list inds;
    va_start( inds, ninds);
    guts_make_errmsg( msg, badi, ninds, inds);
  };
  
  int _TMBOOB_checkV( int i, int first, int toohi, const char* msg){
    if( (i<first) | ((i-first)>=toohi)){
      make_errmsg( msg, 1, 1, i);
      Rf_error( _TMBO__OOBmsg);
  return 0; // safe    
    };
  return i-first;
  };

  int _TMBOOB_checkM1( int i, int j, int first, int toohi, const char* msg){
    if( (i<first) | ((i-first)>=toohi)){
      make_errmsg( msg, 1, 2, i, j);
      Rf_error( _TMBO__OOBmsg);
  return 0; // safe    
    };
  return i-first;
  };

  int _TMBOOB_checkM2( int i, int j, int first, int toohi, const char* msg){
    if( (j<first) | ((j-first)>=toohi)){
      make_errmsg( msg, 2, 2, i, j);
      Rf_error( _TMBO__OOBmsg);
  return 0; // safe    
    };
  return j-first;
  };

  
  int _TMBOOB_checkA( vector<int> mult, vector<int> dim, vector<int> firstel, 
      const char* msg, int ninds, ...){
    if( mult.size() != ninds){
      char _TMBO__OOBmsg[200];
      // Ludicrous warnings about typecasting mult.size()
      // snprintf( _TMBO__OOBmsg, 199, "%s: %i indices, should be %i", msg, ninds, mult.size());
      // FFS...
      snprintf( _TMBO__OOBmsg, 199, "%s(): %i indices, should be %lld", msg, ninds, mult.size());
      Rf_error( _TMBO__OOBmsg);
      // IDK when Rf_errors actually "happen"-- maybe not immediate. Return safe value JIC
  return( 0);
    };

    va_list ptr;
    va_start( ptr, ninds);
    int off = 0;
    for( int i=0; i<ninds; i++){
      int ind = va_arg( ptr, int) - firstel[ i];
      if( (ind < 0) || (ind >= dim(i))){
        // Assemble _TMBO__OOBmsg showing actual index values. Bad one is surrounded by !!
        // C gets absolutely disgusting here. C++ ain't much better.
        // Restart index loop to collect values
        va_list ptr2;
        va_start( ptr2, ninds);
        guts_make_errmsg( msg, i+1, ninds, ptr2);
        Rf_error( _TMBO__OOBmsg);
  return( 0);
      };
      off += ind * mult[ i];
    };

  return( off);
  };
  
#endif

// Rather than directly include macro utils.h and boring_array_bits2.h,
// let TMBO.h set details of inclusion( eg path), via HASH_DEFINE
// #include <macro_utils_TMBO.h>

#define FIRSTEL_range( f, l) f
#define FIRSTEL_vec( x) FIRSTEL__##x
#define FIRSTEL_vecorange_unwrapped( ...) GET_MACRO_32( _0, _1, __VA_ARGS__, FIRSTEL_range, FIRSTEL_vec)(__VA_ARGS__)
#define FIRSTEL_vecorange( x) FIRSTEL_vecorange_unwrapped( DEPAREN( x))
#define FIRSTEL_nonvec( x, idim) FIRSTEL__##x( (idim)-1)
#define FIRSTEL( ...) GET_MACRO_32( _0, _1, __VA_ARGS__, FIRSTEL_nonvec, FIRSTEL_vecorange)(__VA_ARGS__)

#define LASTEL_range( f, l) l
#define LASTEL_vec( x) LASTEL__##x
#define LASTEL_vecorange_unwrapped( ...) GET_MACRO_32( _0, _1, __VA_ARGS__, LASTEL_range, LASTEL_vec)(__VA_ARGS__)
#define LASTEL_vecorange( x) LASTEL_vecorange_unwrapped( DEPAREN( x))
#define LASTEL_nonvec( x, idim) (FIRSTEL__##x( (idim)-1) + _DIM__##x((idim)-1)-1)
#define LASTEL( ...) GET_MACRO_32( _0, _1, __VA_ARGS__, LASTEL_nonvec, LASTEL_vecorange)(__VA_ARGS__)

#define NUMEL( ...) ((GET_MACRO_32( _0, _1, __VA_ARGS__, LASTEL_nonvec, LASTEL_vec)(__VA_ARGS__)) - \
  (GET_MACRO_32( _0, _1, __VA_ARGS__, FIRSTEL_nonvec, FIRSTEL_vec)(__VA_ARGS__)) + 1)

#define DIMRANGE1( x) (FIRSTEL(x),LASTEL(x))
#define DIMRANGE2( x, i) (FIRSTEL(x,i),LASTEL(x,i))
#define DIMRANGE(...) GET_MACRO_32( _0, _1, __VA_ARGS__, DIMRANGE2, DIMRANGE1)(__VA_ARGS__)

#define _CHECK1from2( a, b) assert( a==1);
#define _OK( a) ;
#define CHECK1( ...) GET_MACRO_32( _0, _1, __VA_ARGS__, _CHECK1from2, _OK)( __VA_ARGS__)

#define VECTORO_fl( tipe, x, first, last) vector<tipe> x ( (last)-(first)+1); int FIRSTEL__##x = (first);
#define VECTORO_unwrapped( tipe, x, ...) VECTORO_fl( tipe, x, __VA_ARGS__)
#define VECTORO_pass2( tipe, x, DR) VECTORO_unwrapped( tipe, x, DEPAREN( DR)) 

#define VECTOR1_fl( tipe, x, last) vector<tipe> x ( last);
#define VECTOR1_unwrapped( tipe, x, ...) VECTOR1_fl( tipe, x, __VA_ARGS__)
#define VECTOR1_pass2( tipe, x, DR) CHECK1( DEPAREN( DR)); VECTOR1_unwrapped( tipe, x, LASTARG( DEPAREN( DR))) 

// IDKY the extra layer of indirection/unwrapping is needed--- but experiment shows that it is...
#define MATRIXO_fl( tipe, x, f1, l1, f2, l2) \
  matrix<tipe> x((l1)-(f1)+1,((l2)-(f2)+1)); \
  vector<int> FIRSTEL__##x(2); FIRSTEL__##x << f1, f2; 
#define MATRIXO_unwrapped( tipe, x, ...) MATRIXO_fl( tipe, x, __VA_ARGS__)
#define MATRIXO_pass2( tipe, x, DR1, DR2) MATRIXO_unwrapped( tipe, x, DEPAREN( DR1), DEPAREN( DR2)) 

// MATRIX1: if range is supplied rather than single number, make sure range starts with 1
#define MATRIX1_fl( tipe, x, l1, l2) MATRIXO_fl( tipe, x, 1, l1, 1, l2)
#define MATRIX1_unwrapped( tipe, x, ...) MATRIX1_fl( tipe, x, __VA_ARGS__)
#define MATRIX1_pass2( tipe, x, DR1, DR2) CHECK1( DEPAREN( DR1)); CHECK1( DEPAREN( DR2)); \
MATRIX1_unwrapped( tipe, x, LASTARG( DEPAREN( DR1)), LASTARG( DEPAREN( DR2)))


// ARRAYS: stuff used by EL
#define _ARG20_TMBO(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, ...) a20
#define _NARGS_TMBO(...) _ARG20_TMBO(dummy, __VA_ARGS__, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)

#define _CONCAT_TMBO(a, b) a ## b
#define _CONCAT2_TMBO(a, b) _CONCAT_TMBO(a, b)

// OOB messages
#define _TMBO__STRINGIZE_DETAIL(x) #x
#define _TMBO__STRINGIZE(x) _TMBO__STRINGIZE_DETAIL(x)
#define _TMBOOBmess( par) ("TMBOOB at L" _TMBO__STRINGIZE( __LINE__) " of " __FILE__ ": " par)

// Avoid double inclusion
#ifndef boringTMBO2_done
#include <boring_array_bits2.h>
#endif

#define _ARRAYO_TMBO_intermediate( tipe, x, ndim, ...) _CONCAT_TMBO( _ARRAYO_TMBO_fl_D, ndim)( tipe, x, __VA_ARGS__) 

// Functoids




// FOR loops
#define FOR3( var, from, to) for( int var=(from); var<=(to); var++)
#define FOR2_unwrapped( var, ...) FOR3( var, __VA_ARGS__)
#define FOR2( var, paren_pair) FOR2_unwrapped( var, DEPAREN( paren_pair))
#define FOR(...) GET_MACRO_32(_0, __VA_ARGS__, FOR3, FOR2)(__VA_ARGS__)
// Counting down...
#define ROF( var, from, to) for( int var=(from); var >= (to); var--)
