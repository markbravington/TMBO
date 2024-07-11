#define ORIG_GENERAL_ARRAY_BODY( x, ndim) /*
*/ HASH_DEFINE _NDIM__##x ndim /*
*/ HASH_DEFINE _DIM__##x( i) x.dim( i) /*
*/ HASH_DEFINE _HAS_CHINDID__##x yes /*
*/ HASH_DEFINE x( ...) EL##ndim( x, __VA_ARGS_HERE__) /*
*/

#define ORIG_metatype_ARRAYO( metatype, x, ndim) metatype##ARRAY( x); DATA_IVECTOR( _CHINDID__##x); DATA_IVECTOR( FIRSTEL__##x);  assert( x.dim.size()==ndim); /*
*/  OFFARRAY( x) /*
*/  GENERAL_ARRAY_BODY( x, ndim)

#define ORIG_ARRAYO( tipe, x, ndim, ...) SET_ARRAY_##ndim##D_CHINDS( x, __VA_ARGS__); /*
*/ _CREATE_ARRAYO_##ndim##D_pass2( tipe, x, __VA_ARGS__); /*
*/  OFFARRAY( x) /*
*/  ORIG_GENERAL_ARRAY_BODY( x, ndim)


#define GENERAL_ARRAY_BODY( x) /*
*/ HASH_DEFINE _DIM__##x( i) x.dim( i) /*
*/ HASH_DEFINE _HAS_CHINDID__##x yes /*
*/ HASH_DEFINE x( ...) _CONCAT2_TMBO(EL, _NARGS_TMBO(__VA_ARGS_HERE__))(x, __VA_ARGS_HERE__)

#define _metatype_ARRAYO( metatype, x) metatype##ARRAY( x); DATA_IVECTOR( _CHINDID__##x); DATA_IVECTOR( FIRSTEL__##x); /*
*/  OFFARRAY( x) /*
*/  GENERAL_ARRAY_BODY( x)

#define DATA_ARRAYO( x) _metatype_ARRAYO( DATA_, x)
#define DATA_IARRAYO( x) _metatype_ARRAYO( DATA_I, x)
#define PARAMETER_ARRAYO( x) _metatype_ARRAYO( PARAMETER_, x)

#define ARG20(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, ...) a20
#define NARGS(...) ARG20(dummy, __VA_ARGS__, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)

#define CONCAT(a, b) a ## b
#define CONCAT2(a, b) CONCAT(a, b)
/*** SET_ARRAY_CHINDS_D<n> happens now; ARRAYO_pass2_D<n> is deferred ***/
#define ARRAYO( tipe, x, ...) CONCAT2( SET_ARRAY_CHINDS_D, NARGS(__VA_ARGS__))(x, __VA_ARGS__); /*
*/ CONCAT2(ARRAYO_pass2_D, NARGS(__VA_ARGS__))(tipe, x, __VA_ARGS__) */
*/  OFFARRAY( x) /*
*/  GENERAL_ARRAY_BODY( x)



#define OLD_ARRAYO( tipe, x, ndim, ...) SET_ARRAY_##ndim##D_CHINDS( x, __VA_ARGS__); /*
*/ _CREATE_ARRAYO_##ndim##D_pass2( tipe, x, __VA_ARGS__); /*
*/  OFFARRAY( x) /*
*/  GENERAL_ARRAY_BODY( x, ndim)

#define _metatype_ARRAY1( metatype, x, ndim) metatype##ARRAY( x); \
  DATA_IVECTOR( _CHINDID__##x); \
  vector<int> FIRSTEL__##x( ndim); \
  FIRSTEL__##x.setZero(); \
  FIRSTEL__##x += 1; /*
*/  GENERAL_ARRAY_BODY( x, ndim)

#define DATA_ARRAY1( x, ndim) _metatype_ARRAY1( DATA_, x, ndim)
#define DATA_IARRAY1( x, ndim) _metatype_ARRAY1( DATA_I, x, ndim)
#define PARAMETER_ARRAY1( x, ndim) _metatype_ARRAY1( PARAMETER_, x, ndim)
#define ARRAY1( tipe, x, ndim, ...) SET_ARRAY_##ndim##D_CHINDS( x, __VA_ARGS__); /*
*/ _CREATE_ARRAY1_##ndim##D_pass2( tipe, x, __VA_ARGS__); /*
*/  GENERAL_ARRAY_BODY( x, ndim)

/*** _ARRAYO_<n>D_shaped and _ARRAY1_<n>D_shaped ***/
#include <boring_array_bits1.h>

#define ARRAYO_sameshapeas( tipe, x, ndim, templatum) _ARRAYO_##ndim##D_sameshape( tipe, x, templatum)
#define ARRAY1_sameshapeas( tipe, x, ndim, templatum) _ARRAY1_##ndim##D_sameshape( tipe, x, templatum)


