// Character indexing (names and dimnames)

#include <TMBO.h> // *NOT* TMB.h; it will auto-appear later, don't worry

TMB_MAGIC {  
PARAMETER_VECTOR1( par);

CHIND( SEXES);
DATA_VECTORO( gondy);

VECTORO( int, v, SEXES); // REPORT(VECTOR/MATRIX/ARRAY) gives offarray
v.setZero();
REPORT( v);

VECTOR1( int, zub, SEXES); // REPORT( VECTOR1) etc gives base-R object
zub.setZero();
zub += 3;
REPORT( zub);

// NB v2 does not have to be same type as gondy here
VECTORO_sameshapeas( Type, v2, gondy);
v2 = gondy + 3;
REPORT( v2);

CHIND_EXPAND( PRIMARIES, Green, Red, Blue); // different order cf R
VECTOR1( int, roygbiv, PRIMARIES);
roygbiv( Red_)= 1;
roygbiv( Green_)= 4;
roygbiv( Blue_)= 5;
REPORT( roygbiv);      // will still be right!

Type lglk= 0;
FOR( i, DIMRANGE( gondy)){
  lglk -= pow( par(1) + gondy(i) * par(2), 2);
}

return (-lglk);
};
