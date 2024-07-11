// General-offset and 1-offset vectors

#include <TMBO.h> // *NOT* TMB.h; it will auto-appear later, don't worry

#define STUPID_WARNINGS_OK yes

TMB_MAGIC {  
PARAMETER_VECTOR1( par);

// Declaration of offset thing
DATA_VECTORO( offy)
// element access, plus basic stuff...
Type thrub = offy( 5) + offy.size();
REPORT( thrub);

VECTORO( Type, sqrt_offy, DIMRANGE(offy));
FOR( i, FIRSTEL(offy), LASTEL(offy)){
  sqrt_offy(i)= sqrt( offy(i));
};
REPORT( sqrt_offy);

const int N=3;
VECTORO( int, weeble, (1,N)); // will be offarray, but starts at 1
VECTOR1( int, weebleN, N); // 1-based, will REPORT into standard R vector
weeble.setZero();
weebleN = weeble + 2;
REPORT( weeble);
REPORT( weebleN);

VECTORO_sameshapeas( Type, lgamma_offy, offy);
FOR( i, DIMRANGE( offy)){
  lgamma_offy(i)= lgamma( offy( i));
};

Type lglk= 0;
FOR( i, DIMRANGE( offy)){
  lglk -= pow( par(1) + lgamma_offy(i) - par(2) * sqrt_offy( i), 2);
}

return (-lglk);
};
