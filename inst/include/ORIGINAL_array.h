#define GENERAL_ARRAY_BODY( x, ndim) /*
*/ HASH_DEFINE _NDIM__##x ndim /*
*/ HASH_DEFINE _DIM__##x( i) x.dim( i) /*
*/ HASH_DEFINE _HAS_CHINDID__##x yes /*
*/ HASH_DEFINE x( ...) EL##ndim( x, __VA_ARGS_HERE__) /*
*/

#define _metatype_ARRAYO( metatype, x, ndim) metatype##ARRAY( x); DATA_IVECTOR( _CHINDID__##x); DATA_IVECTOR( FIRSTEL__##x);  assert( x.dim.size()==ndim); /*
*/  OFFARRAY( x) /*
*/  GENERAL_ARRAY_BODY( x, ndim)

#define DATA_ARRAYO( x, ndim) _metatype_ARRAYO( DATA_, x, ndim)
#define DATA_IARRAYO( x, ndim) _metatype_ARRAYO( DATA_I, x, ndim)
#define PARAMETER_ARRAYO( x, ndim) _metatype_ARRAYO( PARAMETER_, x, ndim)
#define ARRAYO( tipe, x, ndim, ...) SET_ARRAY_##ndim##D_CHINDS( x, __VA_ARGS__); /*
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


