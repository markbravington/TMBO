#define PARAMETER_VECTORO( x) RVECTORO_DEFS( PARAMETER_, x)
#define VECTORO( tipe, x, DR) int _CHINDID__##x = #DR; /*
*/ VECTORO_pass2( tipe, x, DR) /*
*/ MOST_VECTORO_DEFS( x)

/*** Offset-1 doesn't get OFFARRAY, and has simpler first/last ***/
#define MOST_VECTOR1_DEFS( x) /*
*/ DONT_WARN_ABOUT( _CHINDID__##x); /*
*/ HASH_DEFINE FIRSTEL__##x 1 /*
*/ HASH_DEFINE LASTEL__##x x.size() /*
*/ HASH_DEFINE _HAS_CHINDID__##x yes /*
*/ HASH_DEFINE x(i) x( _TMBOOB_checkV( i, 1, x.size(), _TMBOOBmess( #x))) /*
*/

#define MOST_VECTORO_DEFS( x) /*
*/ OFFARRAY( x) /*
*/ DONT_WARN_ABOUT( FIRSTEL__##x); /*
*/ DONT_WARN_ABOUT( _CHINDID__##x); /*
*/ HASH_DEFINE _HAS_CHINDID__##x yes /*
*/ HASH_DEFINE LASTEL__##x (FIRSTEL__##x + x.size()-1) /*
*/ HASH_DEFINE x(i) x( _TMBOOB_checkV( i, FIRSTEL__##x, x.size(), _TMBOOBmess( #x))) /*
*/


#define PASS_VECTORO( x) _TYPE__##x, 

#define USE_VECTORO( x)

HASH_DEFINE x( i) 