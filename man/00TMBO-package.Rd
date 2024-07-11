\name{TMBO-package}
\alias{TMBO}
\alias{TMBO-package}
\docType{package}
\title{R-style indexing and convenience for TMB}
\description{
\code{TMBO} helps you simplify your TMB-style [see far below] C++ code to work more easily with R{}. Your variables can now use 1-based indexing just like in R{} rather than 0-based, minimizing coding confusion and pointless mental overhead. And if you use my R{} package \pkg{offarray} too, your indices can start at any offset you like, in both R{} and TMB. You can get nice polite OOB (Out-Of-Bounds) messages in R{} showing exactly where the problem occurred and with what values, instead of crashing your R{} session. What's more, R-side \code{names} and \code{dimnames} can be respected and propagated back to R{}; there's a much simpler for-loop syntax for TMB; and there's a neat way of defining "nested" functions, i.e. inside your objective. All these features are optional; regular TMB code will be unaffected. These might sound trivial but believe me they are \emph{not} when you are writing hundreds to thousands of lines of stock-assessment or CKMR code!

Here's some TMBO code:

\preformatted{
  ...
  #include <TMBO.h>
  TMB_MAGIC{
  PARAMETER_VECTOR1( parz);          // parz(1) is *first* element !!!
  ICONSEQ( Samp_years);              // range from R--- eg 1987 to 2003
  CHIND( Sexes);                     // character index range, from R
  // Data from R: in this case, an 'offarray' which I happen to know has
  // dims Samp_years and Sexes
  DATA_MATRIXO( C_ys);
  /*
   Declare inside TMBO, instead of vector<Type> totC_s(...)
   In this case, a base-R vector starting
   at 1 (not an offarray), with names
  */
  VECTOR1( Type, totC_s, Sexes);
  FOR( s, Sexes){                    // so simple!
    Type temp= 0;
    FOR( y, Samp_years)              // or eg FOR( y, (2003, 2008))
      temp += C_ys( y, s);           // natural syntax
    totC_s( s) = temp;
  };
  REPORT( totC_s);                   // in R you will get eg this:
  //  Female    Male
  // 11772.3  8711.2
  return( 99.99);
  };                                 // And they all lived happily ever after
}

\code{TMBO} is very easy to use. On the R{} side, just do \code{library(TMBO)} instead of \code{library(TMB)}, to get lookalikes of \code{\link{MakeADFun}}, \code{\link{compile}}, and \code{\link{runExample}}; check their docu for extra TMBO-specific features. On the C side, the syntax extensions are straightforward; you can see many of them above.

TMBO variables that are acquired from R--- eg \code{DATA_ARRAYO( a3d_thing)}--- or declared inside TMB---eg \code{MATRIX1( int, zmat, 7, 11)}--- are just TMB variables that work exactly as usual inside TMB, with the \emph{sole} exception of subscripting individual elements in \emph{your own} code. Thus, \code{zmat.size()} will still be the number of elements in \code{zmat}, but the very first element is now \emph{referred to} as \code{zmat(1,1)} and the very last is \code{zmat(7,11)}. Note that TMB's built-in operations on entire vectors, matrices, and arrays are oblivious to the index offsets. When you \code{REPORT()} such a TMB variable, the R-side output will be made nice, with any \code{names}, \code{dimnames}, and index offsets as appropriate.

To turn on OOB checking, you just need to set the argument \code{ppflags="-DTMBOOBOO"} when you call \code{\link{compile}}. TMBO can only OOB-check variables that you've declared with TMBO's macros, eg \code{DATA_VECTORO}, \code{PARAMETER_MATRIX1}, \code{ARRAYO}--- not ones you've created with \code{vector<Type>} etc. When you've eliminated OOBs, remember to recompile without the checking, coz it will slow things down otherwise.

For more examples, \code{runExample()} will list them, and also run them individually or collectively. They are all in the folder \code{system.file( "examples", package="TMBO")}, so that you can examine the C++ and the (minimal) R{} sources.

Detailed documentation of the C macros is in \code{?MACROS}. There is also an FAQ, available via \code{RShowDoc("TMBO-FAQ",package="TMBO")}; please note its advisory warning at the start! See also \code{package?offarray}, and note the byte-compiler issue.
}
\section{One based and general offsets}{
Many people will just be happy to be able to use 1-based and "named" indexing in TMB, to match R{}; they don't need to read the rest of this subsection, which is about general index offsets. Just stick to \code{FOR(i,(1,N))} and \code{MATRIX1} and \code{DATA_VECTOR1} etc; that's fine.

But not me; \emph{I} want to start \emph{my} array indices \emph{wherever I prefer}, eg so that \code{catch[2000]} in R{} or \code{catch(2000)} in TMB means the catch in year 2000 (without also storing 2000 unused elements dating back to 1AD!). This is extremely useful in "real-world" biological/population-dynamics modelling situations such as mark-recapture or, especially, stock-assessment; and it's also useful for the many mathematical algorithms that are naturally written in terms of vectors/arrays that start at some other index (e.g. Wynn's epsilon algorithm, starting at "i=-1"). When I have to write complicated (100s to 1000s of lines) code for stock-assessment and particularly Close-Kin Mark-recapture, for which 9-dimensional arrays and loops are not uncommon, I really don't want to have to remember how to shift all my loop indices, or think about whether I need to add 1 to ranges and differences, or... etc. Making "out-by-1" (or out by much more!) mistakes in complicated code is \emph{incredibly common}, and sometimes can be very hard to diagnose.

Therefore, my \code{offarray} R{} package (from c. 2018) lets you index arrays etc exactly where you want, as well as speeding-up/simplifying multidimensional loops. I find it indispensible for moderately-complicated R{} code such as simple CKMR (though the full complexity of eg age-structured length-based fish stock assessment is just too much for R). And the \pkg{TMBO} package works seamlessly with \code{offarray}. So you can have R{} variables like this:

\preformatted{
  Rprompt> C_ys
          Female  Male
  [1987,]  24083 92992
  [1988,]  10354  6710
  [1989,]  77635 76861
}

where \code{C_ys[1988,"Male"]==6710; and in TMBO you could JUST refer to }C_ys(1988,Male_)'. And things coming out of REPORT() will have the correct offsets/names/dimnames in R{}. And so on.
}
\section{Functoids}{
TMB does not make it easy (or, at least, does not actually tell you how) to define "nested" functions that can access/change variables in your objective function. People have sometimes used horrendously complicated things, apparently called "functors", to get round this.

In fact, there is quite an easy way, but it's rather obscure: you just need something that appears to be called a "non-anonymous anonymous lambda function", and which has a very slightly weird declaration syntax that I have prettied up for you; just declare your nested function \code{fun} via \code{FUNCTOID( fun)( <args>){<code>}}. In view of the completely ludicrous official name, I decided to give these things a nickname instead, hence "functoid". I don't care what you call it. See the example "functoid.cpp".

Functoids are "just" a base feature of C++ anyway, and they don't "belong" particularly in TMBO, except that it is a good place to mention their existence (and I have added a homeopathic dose of syntactic sugar, via the \code{FUNCTOID} declaration macro). However, a bit of extra care is required because of TMBO's offset-index extensions, as follows. Because a functoid can already access all the variables in your objective function, you don't usually need to explictly pass in any \code{VECTORO}-etc arguments. However, if you do want to, then you need to wrap the argument (say \code{x}, a \code{VECTORO} of type \code{Type}) in \code{USE_VECTORO( Type, x)} when declaring the functoid, and then pass in the actual version of \code{x} (say \code{y}) via \code{PASS_VECTORO( y)} when calling the functoid--- analogously for \code{MATRIXO}, \code{VECTOR1}, etc.

The main things to be aware of with functoids, are that:

\itemize{
\item you must declare any variables that the functoid will use \emph{before} you define the functoid itself;
\item any variables created \emph{within} the functoid will \emph{not} be visible outside it;
\item \emph{never} declare an argument to the functoid with the same name as a variable in the objective!
}

IS.IT.RISKY?

Clearly, TMBO is written by me (MVB) not the TMB core folk, and so you might wonder if you are taking a risk by using it; what if MVB loses interest / gets busy / gets squashed by a bus? What will happen to your code?

It's a fair question, but I would say that TMBO is pretty safe and future-proof, for the following reasons.

1. There is no interference or modification of TMB itself; it's all done by C macros (see below). Thus, even if TMB's internal workings get changed in future, things should still work fine. (If TMB's \emph{interface} changes, your vanilla TMB code would also stop working anyway, regardless of TMBO or not.)

2. The \pkg{TMBO} package has (or soon will have) minimal R{} dependencies, apart from package \pkg{TMB} itself. Currently it imports \code{mvbutils} and \code{offarray}, but I will change that by manually including a few basic \code{mvbutils} functions, and making \code{offarray} into a "Suggests"; \code{offarray} is not required if you are happy to stick to 1-based base-R-like variables.

3. TMBO consists of a \emph{small} amount of R{} wrapping, and a \emph{large} number of C macros that augment your C++ code before the \pkg{TMB} package compiles it. As much as possible is actually done by C macros not R{}, in the interests of "clarity" and "stability"; the C macro language is not going to change much, nor disappear. ("Clarity" is perhaps a stretch, because the macros are hard to understand; they use heavy-duty macro trickery from the internet. But the macros certainly are \bold{stable}.) The R{} wrapping, which mostly lives in \code{TMBO::MakeADFun}, sets up a few more variables in R{} that are passed into TMB and referenced in the augmented C++ code, makes some tiny further tweaks to that code (in \code{\link{compile}}), and also (in \code{TMBO:::new_report}) tweaks the results of \code{$report()} in R{}.

3a. Actually, there is a bit of C code to access TMB's internal structures (array elements), but it's only activated when OOB-checking is on.

4. You can always run \code{compile( <myTMBOfile>, ppcheck=TRUE)} to get legal TMB code that will subsequently work with "vanilla" TMB. It won't look pretty, and you will have to manually add some helper variables to \code{data=...} in R{}, to take care of offsets etc, but it will run. Even if you are using general offsets (non-1), you could if desperate get the TMB code to work without \code{offarray}.

5. I do need to modify \code{offarray} at some point, to work around a bug in R{}'s byte-compiler, but there's a perfectly functional workaround in the package as it stands. (See \bold{Quirks}.)
\subsection{Tmb code in packages}{
\code{TMBO} is a very new package, and I've only tested it for standalone compilation (and only on Windows, mea culpa), not for incorporating your own TMB code into your own package. Presumably your DESCRIPTION file will need to say "Imports: TMB, TMBO" and your NAMESPACE file will need some simple mods. At present, the only "duplicated" functions from TMB itself are \code{\link{MakeADFun}}, \code{\link{compile}}, and \code{\link{runExample}}, but I might need to add other more-obscure ones over time. To avoid dull warnings, you'll need to \emph{not} import those from TMB itself. See "Writing R{} extensions" (sorry... there's no way around that!).

Putting TMB code into a package is apparently tricky enough that another helper package, \code{TMBtools}, is needed. I'm not sure how that will all interact. A further complication with \code{TMBO} code is the preliminary steps of pre-processing and R{} tidy-up, which will entail modifications to "Makevars" etc; OMG. AFAICS makefiles are the worst thing in the universe and I am greatly not looking forward to the task, in the strongest possible terms. However, it is definitely do-able, and someone who knows what they are doing could probably get it working in 10mins. Assistance would be welcome!
}
\subsection{Dependencies}{
This is a minor note that should go somewhere, though perhaps not right here! It concerns the dependencies of \code{TMBO}, in particular \code{TMB} and \code{offarray}. The \code{TMBO} DESCRIPTION file lists those packages in "Imports" not "Depends", to avoid them getting unwantedly attached to the search-path whenever \code{TMBO} is only used as an import rather than itself being attached (eg in your own packages). However, in normal non-packagey use when you just call \code{library(TMBO)}, you'll want the functionality of \code{TMB} and \code{offarray} to be exposed automatically--- but you don't want the \code{TMB} version of eg \code{\link{MakeADFun}} to accidentally override the \code{TMBO} version, and you don't want to have to remember to do \code{library(TMB)} \emph{before} \code{library(TMBO)}. Thus, \code{TMBO} has an \code{.onAttach} hook which will attach \code{TMB} and \code{offarray} \emph{below} \code{TMBO} (so that \code{TMBO} versions take priority). This only executes when you call \code{library(TMBO)} explicitly. It should work. Cross yer fingers.

HOW.DOES.TMBO.WORK?

The FOR-loop equivalents (FOR and ROF) are very simple macros that save typing, increase clarity, and reduce the very real possibility of errors: \code{for( i...; ...; j++)}, anyone?

The main trick in \code{TMBO} is the index offsets. Basically, when you declare eg \code{x} as \code{VECTORO}, that leads to the creation of an "alias" for \code{x}: a C function-macro with the name \code{x}, which shifts its argument by an offset before invoking the "real" \code{x(...)} on that shifted value. Because C does not recursively expand macros (unless devious trickery is used), that "real" \code{x}-access is left alone. And because a function-macro cannot share a name with an object-macro, any references to \code{x} that are \emph{not} \code{x(<subscript(s)>)} are unmodified. The macro alias version of \code{x} is created by \code{#define} when you write eg \code{VECTORO( <sometype>, x, <dimrange>)}. But because you can't define new macros within a macro definition in C, a second pass of CPP is necessary to make everything work.

Those shifted-subscript macros are fairly simple, but there is more complexity in the creation macros such as \code{VECTOR1} and \code{DATA_ARRAYO}, which allow efficient declaration of offset variables (either coming in from R{}, or declared from new in your TMB code). Those declaration macros have to create the alias macros, but also have to set up some helper variables in TMB (mostly passed in automatically from R) to store the index-offsets and relevant information about character indexing.

There is also a modified \code{REPORT()} macro that invisibly reports some extra helper variables, and a modified version of \code{$report} in the result of \code{\link{MakeADFun}}. The latter can stitch together the raw \code{TMB::report} output to make nice R-side variables with the correct offsets, names, and/or dimnames.

\code{TMB::MakeADFun} inspects its \code{data=} and \code{parameters=} arguments a bit more carefully, to set up those extra helper variables. It also has a \code{ranges=} parameter, where you can define named ranges (integer or character) than can be referred to your TMBO code: for example,

\preformatted{
  ranges= list(
      Samp_years= c( 1987, 2003),
      list( SEXES=c( 'Female', 'Male"))
    )
}

(For convenience, it's usually better to use \code{\link{TMBO_ranges}} (qv) rather than \code{list}, but the idea is the same.) Again, any \code{ranges=} result in extra variables passed invisibly via an augmented \code{data} argument to \code{TMB::MakeADFun}, and referenced in the augmented C++ code. The \code{report} function from \code{TMB::MakeADFun} is also tweaked so that it automatically calls a modified cleverer version, described next.

WHAT.IS.TMB?

The C++-software/R-package TMB, for automatic differentiation and automatic Laplace approximation (and more) of code that you write in a dialect of C++, is an amazingly powerful and practically indispensible tool for modern statistical modelling. Thank you, Kasper K & co!!! However, it must also be acknowledged that TMB can be quite painful to work with. Some of that seems to be unavoidable side-effects of the intrinsic gruesomeness of templated-C++, but the 0-based indexing restriction is quite fixable. As is the (lack of) error messaging on OOBs. And for-loops in C are just horrible: verbose and error-prone. Here is a genuine example, including a genuine comment, from a colleague's CKMR code (only slightly tweaked by me):

\preformatted{
    // this is one of the worst things I've ever written...
    for(int rj=0; rj<REGIONS.size(); rj++){
      for(int ibj=0; ibj<JCOHORTS.size(); ibj++){
        int bj= JCOHORTS( ibj);
        for(int iyj=0; iyj<SAMPY.size(); iyj++){
          int yj = SAMPY( ibj);
          for(int ibc=0; ibc<ACOHORTS.size(); ibc++){
            int bc= ACOHORTS( bc);
            for(int iyc=0; iyc<SAMPY.size(); iyj++){
              int yc= SAMPY( yc);
              for(int rc=0; rc<REGIONS.size(); rc++){
                Type temp= 0;
                for(int iw=0; iw<MAX_WEANAGE - MIN_WEANAGE; iw++){
                  int w= MIN_WEANAGE + iw;
                  temp += Pr_w(w) *
                      Pr_rr_t( rj , rc, tsep( yj, yc, bj+w));
                } // for w
                Pr_r_by_MOP( rj, ibj, iyj, ibc, iyc, rc) = temp;
              }
            }
          }
        }
      }
    }
}

Even if you are very used to writing code like that, its sheer length and ugliness does not exactly facilitate comprehension nor future maintenance. Oh, and there's at least two typo bugs in there which, unfortunately, compile without errors. Did you spot them?

The TMBO equivalent could be:

\preformatted{
    FOR( rj, REGIONS) FOR( bj, JCOHORTS) FOR( yj, SAMPY)
      FOR( bc, ACOHORTS) FOR( yc, SAMPY) FOR( rc, REGIONS){
        Type temp= 0;
        FOR( w, MIN_WEANAGE, MAX_WEANAGE)
          temp += Pr_w(w) *
              Pr_rr_t( rj, rc, tsep( yj, yc, bj+w));
        Pr_r_by_MOP(rj, bj, yj, bc, yc, rc) = temp;
      };
}

Nuff said! And BTW the opportunity for those typos did not even arise.
}
}
\section{Gratuitous observation}{Pascal and Fortran programmers are well used to the "luxury" of indices starting wherever you bloody well tell them to--- a feature of those languages for over 40 years! (And even C itself will let you do so, if you are mildly devious.) Contrast that with the "advanced modern power" of C++23... :/
}
\section{Limitations}{
These are pretty minor...:

1. With TMB (and C++ in general), you can declare a variable and initialize it in a single operation, eg

\preformatted{
    vector<Type> blurble << pi, 2*pi, 4*pi;
}

But with TMBO, you have to first declare offsetty variables in a single step, and only then can you put stuff into them:

\preformatted{
    VECTORO( Type, blurble, (1, 3));
    blurble << pi, 2*pi, 4*pi;
}

2. Extractors such as \code{<vector>.segment()} \code{<matrix>.row(i)} and \code{<matrix>.col(i)} and \code{<matrix>.block(...)} still use zero-based indices. Although I probably could cook up some macros to fix that (eg \code{ROW(<matrix>,i)}) which would work whether \code{<matrix>} is TMBO or not), I doubt that those functions are used much in the context of 1-based or general-offset-based work. I'm not sure they even exist in TMB for arrays (though they should).
}
\section{Quirks}{
I should mention that \code{offarray} (as of version 1.0.183) has a bad interaction with (a bug in) R{}'s byte-compiler--- so you have to turn off the byte-compiler to use \code{offarray} reliably. That can be done by running a tiny script; see \code{\link{offarray}} documentation for details. I use \code{offarray} all the time, and there are no problems after turning off the BC. At some point I will write some C code to get round it.

One TMBO quirk at the moment is that I've had to do some epic fly-hacking in order to get TMBO's include path picked up by \code{TMB::compile}. It does work, but crikey... There are a couple of less devious ways to address that. Arguably the cleanest, would be to make compilation 3-phase rather than 2-phase at present; there would be \emph{two} successive CPP passes using \bold{only} TMBO headers, leading to a completely standard TMB file that's been full macro-expanded WRTO TMBO constructs, ie with no remaining mention of TMBO at all. (The file contents would be pretty ugly, though... but maybe that doesn't matter). The second way I can think of, is to set the TMBO header as an object-macro during invocation of the first CPP pass, and fixing "TMBO.h" to make sure that explicit paths are expanded into the hash-includes for the second pass. The third would be to hack the hash-includes before the second pass, during the R{} code that tidies up the CPP output. All these alternatives are more work than the fly-hacking, however. I don't think this "quirk" amounts to a risk for the future, because I certainly \emph{could} implement the first or third alternatives, and \emph{probably} could do the second.
}
\keyword{misc}
