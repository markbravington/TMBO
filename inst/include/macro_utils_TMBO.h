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



