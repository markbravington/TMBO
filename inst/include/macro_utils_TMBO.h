/***
  I think a lot of these ideas may originally be due to Paul Mensonides: thank you! More details of specific tricks:

  Amazing recursive macros (requires VA_OPT, so C++20) from David Mazieres (also crediting Paul Fultz), at:
  https://www.scs.stanford.edu/~dm/blog/va-opt.html 

  Multiline (newline-inserting) macros, needed for HASH_DEFINE in pass 2, from Potatoswatter's reply at:
  https://stackoverflow.com/questions/2271078/how-to-make-g-preprocessor-output-a-newline-in-a-macro/2567304#2567304

  De-parenthisation from Nero's reply at:
  https://stackoverflow.com/questions/24481810/how-to-remove-the-enclosing-parentheses-with-macro
  
  Overloading macros based on number of args: several, but eg netcoder's reply at
  https://stackoverflow.com/questions/11761703/overloading-macro-on-number-of-arguments
  
  Concatenation workarounds to generate non-standard tokens, eg in HASH_DEFINE:
  can't remember, just possibly I even figured it out myself, dunno.
  
  Int-to-string (for __LINE__) from eg Tim Leaf in response to:
  https://stackoverflow.com/questions/2670816/how-can-i-use-the-compile-time-constant-line-in-a-string
  
  Although I don't recall using it directly, Jonathan Heathcoate has a great article on related things at:
  jhnet.co.uk/articles/cpp_magic
***/

/*** To unwrap pairs in ranges ***/
#define DEPAREN(X) ESC(ISH X)
#define ISH(...) ISH __VA_ARGS__
#define ESC(...) ESC_(__VA_ARGS__)
#define ESC_(...) VAN ## __VA_ARGS__
#define VANISH

/*** Overloading (used several places) ***/
#define GET_MACRO_32(_0, _1, _2, _3, NAME, ...) NAME

/*** Did this myself! Baby steps... ***/
#define _ARG2( a, b) b
#define _ARG1( a) a
#define LASTARG( ...) GET_MACRO_32( _0, _1, __VA_ARGS__, _ARG2, _ARG1)( __VA_ARGS__)

/*** Recursive, for CHIND_EXPAND which could have lots of args. Original has EXPAND4 as top line. That really expands a *lot*, though, allowing over 300 args IIRC, so I've trimmed it one level... ***/

#define PARENS ()
#define EXPAND(...) EXPAND3(EXPAND3(EXPAND3(EXPAND3(__VA_ARGS__))))
#define EXPAND4(...) EXPAND3(EXPAND3(EXPAND3(EXPAND3(__VA_ARGS__))))
#define EXPAND3(...) EXPAND2(EXPAND2(EXPAND2(EXPAND2(__VA_ARGS__))))
#define EXPAND2(...) EXPAND1(EXPAND1(EXPAND1(EXPAND1(__VA_ARGS__))))
#define EXPAND1(...) __VA_ARGS__

#define FOR_EACH(macro, ...)                                    \
  __VA_OPT__(EXPAND(FOR_EACH_HELPER(macro, __VA_ARGS__)))
#define FOR_EACH_HELPER(macro, a1, ...)                         \
  macro(a1)                                                     \
  __VA_OPT__(FOR_EACH_AGAIN PARENS (macro, __VA_ARGS__))
#define FOR_EACH_AGAIN() FOR_EACH_HELPER


/***
Needed by ARRAY stuff, but also by CREATE_AND_FILL_VECTORO. Expanded from 20 to 50 in 2.4.30
***/
#define ARG50(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29, a30, a31, a32, a33, a34, a35, a36, a37, a38, a39, a40, a41, a42, a43, a44, a45, a46, a47, a48, a49, a50, ...) a50

#define NARGS(...) ARG50(dummy, __VA_ARGS__, 48, 47, 46, 45, 44, 43, 42, 41, 40, 39, 38, 37, 36, 35, 34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)


