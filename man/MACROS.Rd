\name{MACROS}
\alias{MACROS}
\title{C-side syntax of TMBO}
\description{
TMBO's syntax is so trivially simple that it almost doesn't need this documentation, which looks more scary than it is. But I guess documentation is always good, and if I didn't write my own, I couldn't really complain about other people not doing it properly, which would be frustrating. So here goes.

Basically, to use TMBO features you have to:

1. Slightly modify the start of your TMB code and (some) of its \code{#include} directives;

2. Slightly change the syntax of (some) variables acquired from R{} (\code{DATA_} and \code{PARAMETER_} statements);

3. Optionally, declare some Ranges acquired from from R{}, which are a bit like a special type of \code{DATA};

3. Declare new TMB variables via eg \code{MATRIX1( int, z, 3, 3)} instead of \code{matrix<int> z(3,3)}, or \code{ARRAYO( Type, nfish, YEARS, SEXES, AGES)} instead of \code{array<Type> nfish(...)};

4. Optionally, use the much simpler syntax of \code{FOR} in place of "simple" for-loops.

5. Optionally, to embed a function within your TMB code, you can use the \code{FUNCTOID} syntax.
}
\section{Ranges}{
If you are only using the 1-based and non-character-indexed aspects of TMBO, just to make your TMB variables start at 1 like their R{} counterparts, then you don't really need to know this. Just declare variables with eg \code{MATRIX1(x,Ni,Nj)} and \code{DATA_IARRAY1(my_nice_R_shaped_array)} etc, and see the section on \code{FOR}-loops. But it won't overtax most brains to just read this anyway...

A Range in TMBO is really just a pair of integers in parentheses, eg \code{(7,11)} which "means" all integers from 7 through to 11 inclusive. You can use Ranges only in two places: when declaring new TMB variables via eg \code{VECTORO} etc; and in simplified for-loops with \code{FOR}. You can specify a Range "manually", eg \code{FOR(i,(1,N))} (though \code{FOR(i,1,N) is simpler and also works), but you can also have named Ranges passed in from R, eg }ICONSEQ( SAMP_YEARS)'. Named ranges are often simpler to mention in loops and further declarations. You can also have "chinds" passed in from R{}, which are character Ranges like the \code{names} or \code{dimnames} of an R{} variable. Internally in your TMB code, chinds are just Ranges starting from 1, but the information about them is propagated into new variables that use that chind, and then back to R{} by \code{REPORT()}. Variables coming in from R{} via \code{DATA_MATRIXO} etc may have a chind associated with each of their dimensions--- you don't have to do anything explicit to make that happen. The character information associated with a chind--- whether it was originally declared explicitly via \code{CHIND}, or implicitly by association with a \code{DATA_MATRIX} etc that has chind(s) as its Range(s)--- gets used in any variables it's passed onto only when they are \code{REPORT}ed to R{}, at which point their names/dimnames are set accordingly.

The Range(s) of an existing variable \code{x} (one Range per dimension) can be accessed via eg \code{DIMRANGE(x,3)} for the 3rd dimension, and used in declarations and FOR-loops: eg \code{VECTORO(y,DIMRANGE(x,3))} and \code{FOR( j, DIMRANGE(y))}. If \code{x} is a vector, you can only refer to \code{DIMRANGE(x)} without the second argument.

Ranges are not genuine variables within TMB, which is why you can only use them within specific TMBO contexts. However, you can access the ends of the range as if they were genuine variables, using eg \code{FIRSTEL(v)} and \code{LASTEL(v)} for vector \code{v}, or \code{FIRSTEL(ar,3)} for the first index of the 3rd dimension of array \code{ar}. Thus, \code{DIMRANGE(ar,3)} is in fact (almost) exactly equivalent to writing \code{(FIRSTEL(ar,3),LASTEL(ar,3))}.
}
\section{Functoids}{
Sometimes you want to embed a function within your TMB objective code, so that it knows about (and can change) your TMB variables directly, without having to pass zillions of them every time you call your embedded function. You can do this by defining a "functoid", as in the "functoid.cpp" example. The raw C++ syntax is not thaaat bad, but it's simpler to just use the word \code{FUNCTOID}, as per the example.

Because functoids have free & full access to variables that already exist inside your TMB objective (which BTW have to be declared \emph{before} the functoid definition), you often don't need to pass \code{VMAO}-type arguments explicitly. However, if you do, you need to use the syntax of \code{USE_VECTORO} (when declaring the functoid) and \code{PASS_VECTORO} (when calling it), as per the "functoid.cpp" example--- analogously for \code{MATRIXO}, \code{VECTOR1}, etc.

The only thing you can't do with a functoid, is to \emph{create} a variable inside it that will be visible outside it (i.e., in the main body of your objective, or in other functoids). Just declare anything like that before calling the functoid.

Note that you mustn't try to associate a type with the \code{FUNCTOID}. It turns out that the actual type of the functoid \emph{always} has to be \code{auto} "becoz C++", but that's done already for you by using the word \code{FUNCTOID}.
}
\section{Pseudo-usage}{\preformatted{
  ### Declaring variables from R
  #
  # DATA_VECTORO( x)
  # DATA_IVECTORO( x)
  # DATA_MATRIXO( x)
  # DATA_IMATRIXO( x)
  # DATA_ARRAYO( x)
  # DATA_IARRAYO( x)
  #
  # DATA_VECTOR1( x)
  # # ... and similarly DATA_IVECTOR1 etc
  #
  # PARAMETER_VECTORO( x)
  # PARAMETER_VECTOR1( x)
  # # ... and similarly PARAMETER_MATRIX1 etc
  #
  # DATA_FACTOR1( x)
  #
  # ## Declaring new variables
  #
  # VECTORO( tipe, x, R)
  # MATRIXO( tipe, x, R1, R2)
  # ARRAYO( tipe, x, ...)
  #
  # VECTORO_sameshapeas( tipe, x, template)
  # MATRIXO_sameshapeas( tipe, x, template)
  # ARRAYO_sameshapeas( tipe, x, template)
  #
  # VECTOR1( tipe, x, RorN)
  # MATRIX1( tipe, x, RorN1, RorN2)
  # ARRAY1( tipe, x, ...)
  #
  # VECTOR1_sameshapeas( tipe, x, template)
  # MATRIX1_sameshapeas( tipe, x, template)
  # ARRAY1_sameshapeas( tipe, x, template)
  #
  # # Declaring ranges
  #
  # ICONSEQ( inds)
  # CHIND( ch)
  # CHIND_EXPAND( ch, ...)
  #
  # ## Access to range information
  # DIMRANGE( v)
  # DIMRANGE( matORar, idim)
  # FIRSTEL( vORr)
  # LASTEL( vORr)
  # FIRSTEL( matORar, idim)
  # LASTEL( matORar, idim)
  #
  # ## FOR-loop simplifiers
  #
  # FOR( index_name, R)
  # FOR( index_name, lower, upper)
  # ROF( index_name, upper, lower)
  #
  # ## Functoids
  #
  # FUNCTOID fun( ...)
  # USE_VECTORO( tipe, x)
  # USE_MATRIXO( tipe, x)
  # USE_ARRAYO( tipe, x)
  # PASS_VECTORO( x)
  # PASS_MATRIXO( x)
  # PASS_ARRAYO( x)
  # USE_VECTOR1( tipe, x)
  # USE_MATRIX1(tipe,  x)
  # USE_ARRAY1( tipe, x)
  # PASS_VECTOR1( x)
  # PASS_MATRIX1( x)
  # PASS_ARRAY1( x)
  #
  # ## Headers and directives
  #
  # TMB_MAGIC  # instead of objective squiggle blalblah
  # TMBO_MAGIC # synonym
  #
  # HASH_INCLUDE filespec
  # HASH_DEFINE ...
  # HASH_PRAGMA ...,  HASH_IF ...,  HASH_ENDIF ..., etc
}
}
\section{Pseudo-arguments}{
\describe{
\item{tipe}{A C++ "type" acceptable to TMB. Usually \code{Type} or \code{int}. IDK what else is allowed.}
\item{x}{Name of variable}
\item{R{}, R1, R2}{A Range (see below)}
\item{RorN, RorN1, RorN2}{An integer, chind, or (less likely) a Range that starts at 1.}
\item{...}{in \code{ARRAYO}, these must be Ranges, like \code{R} in \code{VECTORO}. In \code{ARRAY1}, these must be integers or Ranges, like \code{RorN} in \code{VECTOR1}. In \code{CHIND_EXPAND}, it's all the names of the members of the chind, eg \code{CHIND_EXPAND( COLOURS, Red, Green, Blue)}, which will lead to integer variables in TMB called \code{Red_}, \code{Green_}, and \code{Blue_} whose values are passed in automatically from R{}. In \code{FUNCTOID}, it's the parameter list of your functoid. In the various \code{HASH_BLAH} macros, it's whatever you would put after the \code{#blah}, which will happen during the "main" (ie second pass) compilation.}
\item{template}{An existing variable whose dimensions, offsets, and names/dimnames (but not necessarily C++ "type") are to be applied to the new variable \code{x}. EG suppose you already have a 7-dimensional \code{DATA_IARRAYO} called \code{observed_nkinpairs}; you might well want \code{expected_nkinpairs} of type \code{Type} with exactly the same dimensions. The nomenclatural minefield around \code{Type} is not my fault BTW...}
\item{v}{in \code{DIMRANGE(v)}, a TMBO vector}
\item{matORar}{in \code{DIMRANGE( matORar, idim)}, a TMBO matrix or array}
\item{vORr}{in \code{FIRSTEL} and \code{LASTEL}, either a TMBO vector or a Range}
\item{idim}{in \code{DIMRANGE}, \code{FIRSTEL}, and \code{LASTEL}, which of the dimensions to return}
\item{index_name}{in \code{FOR}, the name of the integer variable that becomes the loop index.}
\item{upper, lower}{in \code{ROF}, the loop will step downwards from \code{upper} to \code{lower} inclusive. In \code{FOR} it steps upwards from \code{lower} to \code{upper} inclusive.}
}
}
\section{Technicalities}{
\subsection{Directives}{\code{TMBO} uses two-phase compilation, whereby the first phase sets up some variables & macros used in the second phase. Some "standard" C preprocessor directives should only be expanded in the second phase, not the first; examples are including "system" header files (as opposed to bits of code you wrote yourself and are just keeping in a separate file, for which normal \code{#include} should be used), and perhaps defining some object macros. To make that happen, just write eg \code{HASH_INCLUDE <systemhead.hpp>} instead of \code{#include <systemhead.hpp>} etc.
}
\subsection{Propagation of chinds}{A new variable that is declared using a \code{DIMRANGE} from an existing variable, will acquire any chind that was associated with that particular \code{DIMRANGE}. However, this requires a bit of trickery, and it's fragile; \code{DIMRANGE(x,2)} will work but \code{DIMRANGE(x,1+1)} won't propagate the chind (which only matters for post-hoc formatting after \code{REPORT}; TMB \emph{calculations} will not be affected). Nor will the otherwise-equivalent \code{(FIRSTEL(x,2),LASTEL(x,2))} give you the (presumably) desired \code{REPORT}.
}
}
\keyword{misc}
