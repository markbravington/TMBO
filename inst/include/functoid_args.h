// Functoids
#define USE_VECTORO( tipe, x) vector<tipe> x, int FIRSTEL__##x, int _CHINDID__##x /*
*/ MOST_VECTORO_DEFS( x) /*




#define MOST_VECTORO_DEFS( x) /*
*/ OFFARRAY( x) /*
*/ DONT_WARN_ABOUT( FIRSTEL__##x); /*
*/ DONT_WARN_ABOUT( _CHINDID__##x); /*
*/ HASH_DEFINE _HAS_CHINDID__##x yes /*
*/ HASH_DEFINE LASTEL__##x (FIRSTEL__##x + x.size()-1) /*
*/ HASH_DEFINE x(i) x( _TMBOOB_checkV( i, FIRSTEL__##x, x.size(), _TMBOOBmess( #x))) /*
*/

#define RVECTORO_DEFS( metatipe, x) metatipe##VECTOR( x); DATA_INTEGER( FIRSTEL__##x); DATA_INTEGER( _CHINDID__##x); /*
*/ MOST_VECTORO_DEFS( x)

