// Out-of-bounds trapping. Note 'ppflags="-DTMBOOBOO"' to trap (for debugging purposes only); otherwise, R will crash on OOB. Different OOBs are shown here on different runs; which sort is controlled by 'data$which_oob'.

// Make OOB-check the default here
// Normally you'd turn on OOBing by 'compile(...,ppflags="-DTMBOOBOO")' rather than defining it in the source!
// But TMB'S runExample() makes that difficult, so plonk it here instead. Must come before including TMBO.h

#define TMBOOBOO 1

#include <TMBO.h> // *NOT* TMB.h; it will auto-appear later, don't worry

TMB_MAGIC {  
PARAMETER_VECTOR1( par);

// A bit like enum. Here I only want 1 value from the menu, but I 
CHIND_EXPAND( oob_types, VEC, MAT, AR, ARNELS);
DATA_INTEGER( which_oob);

// Declarations
DATA_VECTORO( offy);
VECTORO_sameshapeas( Type, sqrt_offy, offy);


Type lglk= 0;

int clean_and_tidy = 1;

// Declarations need to be unconditional (sez compiler, not me)
MATRIX1( int, matty, 3, 3);
ARRAY1( int, bingle, 2, 3, 4);

MATRIXO( Type, thrub, (0,2), (0,3));
FOR( i, 0, 2) FOR( j, 0, 3) thrub(i,j) = 1.0/(1+i+j);
REPORT( thrub);

// Make a TMBOOBOO...
if( which_oob==VEC_){
  FOR( i, FIRSTEL( offy), LASTEL( offy)+1){
    sqrt_offy( i)= sqrt( offy( i));
    lglk += sqrt_offy( i) * par(1);
  };
} else if( which_oob==MAT_){
  matty( 3, 4) = 1;
} else if( which_oob==AR_){
  bingle( 2, 999, 1) = 0;
} else if( which_oob==ARNELS_){
  bingle( 2, 999) = 0;
} else if( which_oob==0) {
  // everything is copacetic...
} else {
  Rf_error( "You have made a meta-error");
};

REPORT( clean_and_tidy);

return (-lglk);
};
