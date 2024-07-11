// Arrays with offset indices

#include <TMBO.h>

TMB_MAGIC{  
  PARAMETER( par);
  PARAMETER_VECTOR1( fec_s); // by SEXES

  ICONSEQ( YEARS);
  ICONSEQ( AGES);
  CHIND( SEXES);
  DATA_ARRAYO( C_sya);

  Type totC = Type( 0);
  FOR( s, SEXES) FOR( y, YEARS) FOR( a, AGES)
    totC += C_sya( s, y, a);
    
  REPORT( totC);

  ARRAYO_sameshapeas( int, X, C_sya); // different type
  X.setZero();
  X += 5;
  REPORT( X); // TMB turns it into double when reporting

  ARRAYO( Type, zz1, SEXES, YEARS, AGES);
  REPORT( zz1);

  ARRAY1( Type, zz2, SEXES, 3);
  FOR( s, SEXES) FOR( j, 1, 3)
    zz2( s, j) = 1/(1.0 + fec_s(s) + j);
  REPORT( zz2);


  ARRAYO_sameshapeas( int, zz3, zz2);
  zz3. setZero();
  // Loop expression does not make a lot of sense, coz it depends on numeric
  // value of SEXES. But, for the sake of argument:
  FOR( i, DIMRANGE( zz3, 1)) FOR( j, DIMRANGE( zz3, 2))
    zz3( i, j)  = (i+17)/j;
  REPORT( zz3); // returns offarray, coz ARRAYO

  ARRAY1_sameshapeas( int, zz4, zz2);
  REPORT( zz4);  // looks same as zz3, but just base-R coz ARRAY1

  Type lglk= 0;
  lglk = pow( totC - par, 2);

return (-lglk);
};
