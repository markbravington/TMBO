#define _ARG12_TMBO(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, ...) a12
#define _NARGS_TMBO(...) _ARG12_TMBO(dummy, __VA_ARGS__, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)

#define _CONCAT_TMBO(a, b) a ## b
#define _CONCAT2_TMBO(a, b) _CONCAT_TMBO(a, b)

#define _ARRAYO_TMBO_intermediate( tipe, x, ndim, ...) _ARRAYO_TMBO_fl_D##ndim( tipe, x, __VA_ARGS__) 

#define _ARRAYO_TMBO_D1( tipe, x, DR1) _ARRAYO_TMBO_intermediate( tipe, x, 1, DEPAREN( DR1))
#define _ARRAYO_TMBO_fl_D1( tipe, x, f1, l1) \
  array<tipe> x((l1)-(f1)+1); \
  vector<int> FIRSTEL__##x(1); \
  FIRSTEL__##x << f1;
// Auto-generated array stuff...




