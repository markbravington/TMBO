#ifndef TMBOOBOO2
#define EL1( x, i1) x( (i1)-FIRSTEL__##x( 1-1))
#define EL2( x, i1, i2) x( (i1)-FIRSTEL__##x( 1-1), (i2)-FIRSTEL__##x( 2-1))
#define EL3( x, i1, i2, i3) x( (i1)-FIRSTEL__##x( 1-1), (i2)-FIRSTEL__##x( 2-1), (i3)-FIRSTEL__##x( 3-1))
#define EL4( x, i1, i2, i3, i4) x( (i1)-FIRSTEL__##x( 1-1), (i2)-FIRSTEL__##x( 2-1), (i3)-FIRSTEL__##x( 3-1), (i4)-FIRSTEL__##x( 4-1))
#define EL5( x, i1, i2, i3, i4, i5) x( (i1)-FIRSTEL__##x( 1-1), (i2)-FIRSTEL__##x( 2-1), (i3)-FIRSTEL__##x( 3-1), (i4)-FIRSTEL__##x( 4-1), (i5)-FIRSTEL__##x( 5-1))
#define EL6( x, i1, i2, i3, i4, i5, i6) x( (i1)-FIRSTEL__##x( 1-1), (i2)-FIRSTEL__##x( 2-1), (i3)-FIRSTEL__##x( 3-1), (i4)-FIRSTEL__##x( 4-1), (i5)-FIRSTEL__##x( 5-1), (i6)-FIRSTEL__##x( 6-1))
#define EL7( x, i1, i2, i3, i4, i5, i6, i7) x( (i1)-FIRSTEL__##x( 1-1), (i2)-FIRSTEL__##x( 2-1), (i3)-FIRSTEL__##x( 3-1), (i4)-FIRSTEL__##x( 4-1), (i5)-FIRSTEL__##x( 5-1), (i6)-FIRSTEL__##x( 6-1), (i7)-FIRSTEL__##x( 7-1))
#else
#define EL1( x, i1) x[ _TMBOOB_checkA( x.mult, x.dim, FIRSTEL__##x, _TMBOOBmess( #x), 1, i1)]
#define EL2( x, i1, i2) x[ _TMBOOB_checkA( x.mult, x.dim, FIRSTEL__##x, _TMBOOBmess( #x), 2, i1, i2)]
#define EL3( x, i1, i2, i3) x[ _TMBOOB_checkA( x.mult, x.dim, FIRSTEL__##x, _TMBOOBmess( #x), 3, i1, i2, i3)]
#define EL4( x, i1, i2, i3, i4) x[ _TMBOOB_checkA( x.mult, x.dim, FIRSTEL__##x, _TMBOOBmess( #x), 4, i1, i2, i3, i4)]
#define EL5( x, i1, i2, i3, i4, i5) x[ _TMBOOB_checkA( x.mult, x.dim, FIRSTEL__##x, _TMBOOBmess( #x), 5, i1, i2, i3, i4, i5)]
#define EL6( x, i1, i2, i3, i4, i5, i6) x[ _TMBOOB_checkA( x.mult, x.dim, FIRSTEL__##x, _TMBOOBmess( #x), 6, i1, i2, i3, i4, i5, i6)]
#define EL7( x, i1, i2, i3, i4, i5, i6, i7) x[ _TMBOOB_checkA( x.mult, x.dim, FIRSTEL__##x, _TMBOOBmess( #x), 7, i1, i2, i3, i4, i5, i6, i7)]
#endif

 
#define _ARRAYO_TMBO_fl_D1( tipe, x, f1, l1) \
  array<tipe> x((l1)-(f1)+1); \
  vector<int> FIRSTEL__##x(1); \
  FIRSTEL__##x << f1;

 
#define _ARRAYO_TMBO_fl_D2( tipe, x, f1, l1, f2, l2) \
  array<tipe> x((l1)-(f1)+1, (l2)-(f2)+1); \
  vector<int> FIRSTEL__##x(2); \
  FIRSTEL__##x << f1, f2;

 
#define _ARRAYO_TMBO_fl_D3( tipe, x, f1, l1, f2, l2, f3, l3) \
  array<tipe> x((l1)-(f1)+1, (l2)-(f2)+1, (l3)-(f3)+1); \
  vector<int> FIRSTEL__##x(3); \
  FIRSTEL__##x << f1, f2, f3;

 
#define _ARRAYO_TMBO_fl_D4( tipe, x, f1, l1, f2, l2, f3, l3, f4, l4) \
  array<tipe> x((l1)-(f1)+1, (l2)-(f2)+1, (l3)-(f3)+1, (l4)-(f4)+1); \
  vector<int> FIRSTEL__##x(4); \
  FIRSTEL__##x << f1, f2, f3, f4;

 
#define _ARRAYO_TMBO_fl_D5( tipe, x, f1, l1, f2, l2, f3, l3, f4, l4, f5, l5) \
  array<tipe> x((l1)-(f1)+1, (l2)-(f2)+1, (l3)-(f3)+1, (l4)-(f4)+1, (l5)-(f5)+1); \
  vector<int> FIRSTEL__##x(5); \
  FIRSTEL__##x << f1, f2, f3, f4, f5;

 
#define _ARRAYO_TMBO_fl_D6( tipe, x, f1, l1, f2, l2, f3, l3, f4, l4, f5, l5, f6, l6) \
  array<tipe> x((l1)-(f1)+1, (l2)-(f2)+1, (l3)-(f3)+1, (l4)-(f4)+1, (l5)-(f5)+1, (l6)-(f6)+1); \
  vector<int> FIRSTEL__##x(6); \
  FIRSTEL__##x << f1, f2, f3, f4, f5, f6;

 
#define _ARRAYO_TMBO_fl_D7( tipe, x, f1, l1, f2, l2, f3, l3, f4, l4, f5, l5, f6, l6, f7, l7) \
  array<tipe> x((l1)-(f1)+1, (l2)-(f2)+1, (l3)-(f3)+1, (l4)-(f4)+1, (l5)-(f5)+1, (l6)-(f6)+1, (l7)-(f7)+1); \
  vector<int> FIRSTEL__##x(7); \
  FIRSTEL__##x << f1, f2, f3, f4, f5, f6, f7;


#define _ARRAYO_TMBO_D1( tipe, x, DR1) \
  _ARRAYO_TMBO_intermediate( tipe, x, 1, DEPAREN( DR1))

#define _ARRAYO_TMBO_D2( tipe, x, DR1, DR2) \
  _ARRAYO_TMBO_intermediate( tipe, x, 2, DEPAREN( DR1), DEPAREN( DR2))

#define _ARRAYO_TMBO_D3( tipe, x, DR1, DR2, DR3) \
  _ARRAYO_TMBO_intermediate( tipe, x, 3, DEPAREN( DR1), DEPAREN( DR2), DEPAREN( DR3))

#define _ARRAYO_TMBO_D4( tipe, x, DR1, DR2, DR3, DR4) \
  _ARRAYO_TMBO_intermediate( tipe, x, 4, DEPAREN( DR1), DEPAREN( DR2), DEPAREN( DR3), DEPAREN( DR4))

#define _ARRAYO_TMBO_D5( tipe, x, DR1, DR2, DR3, DR4, DR5) \
  _ARRAYO_TMBO_intermediate( tipe, x, 5, DEPAREN( DR1), DEPAREN( DR2), DEPAREN( DR3), DEPAREN( DR4), DEPAREN( DR5))

#define _ARRAYO_TMBO_D6( tipe, x, DR1, DR2, DR3, DR4, DR5, DR6) \
  _ARRAYO_TMBO_intermediate( tipe, x, 6, DEPAREN( DR1), DEPAREN( DR2), DEPAREN( DR3), DEPAREN( DR4), DEPAREN( DR5), DEPAREN( DR6))

#define _ARRAYO_TMBO_D7( tipe, x, DR1, DR2, DR3, DR4, DR5, DR6, DR7) \
  _ARRAYO_TMBO_intermediate( tipe, x, 7, DEPAREN( DR1), DEPAREN( DR2), DEPAREN( DR3), DEPAREN( DR4), DEPAREN( DR5), DEPAREN( DR6), DEPAREN( DR7))


#define _ARRAY1_TMBO_D1( tipe, x, DR1) \
  CHECK1( DEPAREN( DR1)); \
  _ARRAYO_TMBO_intermediate( tipe, x, 1, 1, LASTARG( DEPAREN( DR1)));

#define _ARRAY1_TMBO_D2( tipe, x, DR1, DR2) \
  CHECK1( DEPAREN( DR1)); CHECK1( DEPAREN( DR2)); \
  _ARRAYO_TMBO_intermediate( tipe, x, 2, 1, LASTARG( DEPAREN( DR1)), 1, LASTARG( DEPAREN( DR2)));

#define _ARRAY1_TMBO_D3( tipe, x, DR1, DR2, DR3) \
  CHECK1( DEPAREN( DR1)); CHECK1( DEPAREN( DR2)); CHECK1( DEPAREN( DR3)); \
  _ARRAYO_TMBO_intermediate( tipe, x, 3, 1, LASTARG( DEPAREN( DR1)), 1, LASTARG( DEPAREN( DR2)), 1, LASTARG( DEPAREN( DR3)));

#define _ARRAY1_TMBO_D4( tipe, x, DR1, DR2, DR3, DR4) \
  CHECK1( DEPAREN( DR1)); CHECK1( DEPAREN( DR2)); CHECK1( DEPAREN( DR3)); CHECK1( DEPAREN( DR4)); \
  _ARRAYO_TMBO_intermediate( tipe, x, 4, 1, LASTARG( DEPAREN( DR1)), 1, LASTARG( DEPAREN( DR2)), 1, LASTARG( DEPAREN( DR3)), 1, LASTARG( DEPAREN( DR4)));

#define _ARRAY1_TMBO_D5( tipe, x, DR1, DR2, DR3, DR4, DR5) \
  CHECK1( DEPAREN( DR1)); CHECK1( DEPAREN( DR2)); CHECK1( DEPAREN( DR3)); CHECK1( DEPAREN( DR4)); CHECK1( DEPAREN( DR5)); \
  _ARRAYO_TMBO_intermediate( tipe, x, 5, 1, LASTARG( DEPAREN( DR1)), 1, LASTARG( DEPAREN( DR2)), 1, LASTARG( DEPAREN( DR3)), 1, LASTARG( DEPAREN( DR4)), 1, LASTARG( DEPAREN( DR5)));

#define _ARRAY1_TMBO_D6( tipe, x, DR1, DR2, DR3, DR4, DR5, DR6) \
  CHECK1( DEPAREN( DR1)); CHECK1( DEPAREN( DR2)); CHECK1( DEPAREN( DR3)); CHECK1( DEPAREN( DR4)); CHECK1( DEPAREN( DR5)); CHECK1( DEPAREN( DR6)); \
  _ARRAYO_TMBO_intermediate( tipe, x, 6, 1, LASTARG( DEPAREN( DR1)), 1, LASTARG( DEPAREN( DR2)), 1, LASTARG( DEPAREN( DR3)), 1, LASTARG( DEPAREN( DR4)), 1, LASTARG( DEPAREN( DR5)), 1, LASTARG( DEPAREN( DR6)));

#define _ARRAY1_TMBO_D7( tipe, x, DR1, DR2, DR3, DR4, DR5, DR6, DR7) \
  CHECK1( DEPAREN( DR1)); CHECK1( DEPAREN( DR2)); CHECK1( DEPAREN( DR3)); CHECK1( DEPAREN( DR4)); CHECK1( DEPAREN( DR5)); CHECK1( DEPAREN( DR6)); CHECK1( DEPAREN( DR7)); \
  _ARRAYO_TMBO_intermediate( tipe, x, 7, 1, LASTARG( DEPAREN( DR1)), 1, LASTARG( DEPAREN( DR2)), 1, LASTARG( DEPAREN( DR3)), 1, LASTARG( DEPAREN( DR4)), 1, LASTARG( DEPAREN( DR5)), 1, LASTARG( DEPAREN( DR6)), 1, LASTARG( DEPAREN( DR7)));

