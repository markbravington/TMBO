// Offset matrices, and some range examples

#include <TMBO.h> // *NOT* TMB.h; it will auto-appear later, don't worry

TMB_MAGIC{  
  PARAMETER_VECTOR1( par);

  DATA_MATRIXO( offy)

  ICONSEQ( YEARS); // a range

  // It is neatest to use named ranges in loops, rather than DIMNAMES
  MATRIXO( Type, yy, YEARS, YEARS);
  FOR( y1, YEARS) FOR( y2, YEARS) 
    yy( y1, y2) = (y1+1.0)/(y2+2.0);
  REPORT( yy);

  // Next will be filled with garbage (TMB doesn't auto-initialize)
  MATRIXO( Type, newmat, (3,5), DIMRANGE( offy, 1));
  REPORT( newmat);

  MATRIX1( Type, squaremat, 4, 4);
  squaremat. setZero();
  squaremat( 2, 2) = 1;
  REPORT( squaremat);

  MATRIXO_sameshapeas( Type, sqrt_offy, offy);
  
  // but you _can_ use DIMNAMES... or full manual...
  FOR( i, DIMRANGE( offy, 1))
    FOR( j, FIRSTEL( offy, 2), LASTEL( offy, 2)){
      sqrt_offy(i,j)= sqrt( offy(i,j));
  };

  REPORT( sqrt_offy);
  
  Type lglk= 0;
  FOR( i, DIMRANGE( offy, 1))  FOR( j, DIMRANGE( offy, 2)){
    lglk -= pow( par(1) + offy(i,j) - par(2) * sqrt_offy( i,j), 2);
  };

return (-lglk);
};
