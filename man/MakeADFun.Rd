\name{MakeADFun}
\alias{MakeADFun}
\alias{TMBO_ranges}
\title{Construct objective function and derivatives allowing general index offsets}
\description{
\code{TMBO::MakeADFun} is just like \code{TMB::MakeADFun}, but lets you provide "dimensional" information that can be used (i) by your TMBO code, and (ii) to automatically make nice \code{REPORT()} output (ie with index-offsets and dimnames etc). That info mostly comes in the form of the \code{ranges} argument--- similar to \code{data=} and \code{parameters=}--- which is most easily specified by calling \code{TMBO_ranges}, eg:

\preformatted{
  obj <- MakeADFun(
      data= <known things>,
      parameters= <unknown things>,
      ranges=TMBO_ranges( <see below>),
      <more args>
    )
}

\code{TMBO_ranges} is "just" a wrapper for \code{list()} but is smarter about names and so on, to Save You Effort. \code{TMBO_ranges} has deliberately non-standard evaluation, so don't try to be too clever; follow the EXAMPLES.
\subsection{Ranges in tmbo}{
Named ranges are useful for code clarity in and between R{} and TMB(O), though not compulsory (you \emph{can} instead just use \code{DIMRANGE(myar,3)} etc in TMBO). Range examples:

\preformatted{
  obj <- MakeADFun( <your stuff>, ranges=TMBO_ranges(
    SAMP_YEARS=1987:2003,           # consecutive integers
    CATCH_YEARS= c( 1980, 2008),    # just a pair (start and end)
    SEXES= c( 'Female', 'Male')     # characters
  ))
}

Ranges for TMBO on the R{} side are either integer (numeric is usually fine) or character. Integer ranges can either be consecutive sequences with step +1, eg \code{1986:1992}, or a pair with the first no larger than the second, eg \code{c(1986,1992)} or \code{c(1,1)} but not \code{c(1,0)}. On the C side, the corresponding range is declared as eg \code{ICONSEQ( Years);}.

Note that most integer variables in R{} actually end up as \code{numeric}, which is normally fine and you don't need to convert explicitly; but be aware that \code{numeric} ranges will be coerced to \code{integer} with a check that no rounding is taking place. So don't use eg \code{c(5.3, 11.7)}, is what I'm saying.

Character ranges are declared on the C side as \code{CHIND( Sexes);} or \code{CHIND_EXPAND( Sexes, Male, Female);}, although they are "really" integer ranges starting at 1 from TMBO's PoV. They can be used just like integer ranges, in eg \code{FOR( s, Sexes)} and \code{VECTORO( int, x, Sexes);} or \code{VECTOR1( int, x, Sexes)}; see SUBTLE DIFFERENCE below.

The difference between \code{CHIND} and \code{CHIND_EXPAND} is that the latter also requires you to name the actual \emph{elements} of the character range, and it turns each into a variable that can be mentioned explicitly in your TMB code. So, if \code{Sexes=c("Female","Male")} in R{}, then with \code{CHIND_EXPAND( Sexes, Male, Female);} in TMB you can write not just \code{FOR( s, SEXES)} but also eg \code{myvec( Female_) = 99;} (note the trailing underscore). If you just use \code{CHIND( Sexes);} then \code{FOR( s, Sexes)} is fine but you can't refer to \code{Female_}. Plain \code{CHIND} is fine if there's no reason to write qualitatively different TMB code for different "levels" of the character range, and is also unavoidable if you don't know in advance what the "levels" will be. \code{CHIND_EXPAND} makes sure the TMB order matches the R{} order (ie the order given inside \code{CHIND_EXPAND} is irrelevant, as long as there's the same names overall), so you don't have to worry about making sure they're the same. If you are using \code{CHIND_EXPAND} in TMB code, then the R-side information in \code{TMBO_ranges} should be wrapped in \code{list}, eg \code{ranges=TMBO_ranges( list( Sexes), ...)}.
}
\subsection{Subtle difference between o and 1}{Hopefully I've explained this somewhere else too; it doesn't really belong here, but... Anyway: \code{VECTOR1}, \code{MATRIX1}, variables in TMBO are guaranteed to use 1-based indexing. \code{VECTORO} etc can of course be 1-based too if that's what's specified in their declaration, and there is \emph{no} difference between the behaviour of VMA1 and 1-based VMAO variables within TMBO. The subtle difference \emph{only} applies on R{}'s PoV, and only if/when you \code{REPORT()} the variable. Then, the 1-based version will return a standard R{} vector/matrix/array, with the character range turned into \code{names} or \code{dimnames}. In contrast, the O-based version will always generate an \code{offarray}.
}
}
\usage{
MakeADFun( data, parameters, ..., ranges = list())
TMBO_ranges(...)
}
\arguments{
\item{ data, parameters}{As per \code{TMB::MakeADFun} (qv).}
\item{ ranges}{Optional list of named ranges (for vec/mat/array indices), which can be referenced in TMB code. See \bold{Details}.}
\item{  ...}{In \code{MakeADFun}:like \code{TMB:MakeAdFun} (qv). In \code{TMBO_ranges}:a set of integer or character ranges, either variables that already exist, or created on-the-fly during this call, and each possibly wrapped in a call to \code{list()}. See \bold{Details}.}
}
\value{
\code{MakeADFun}, like its namesake in package \pkg{TMB}, returns a list with components ($fn, $gr, etc) suitable for use with an R{} optimizer, such as \code{nlminb} or \code{optim}.
You don't need to know what \code{TMBO_ranges} returns, because you will only invoke this inside a call to \code{TMBO::MakeADFun}. But since you ask: it's a list.
}
\details{
\code{TMBO_ranges} tries hard to figure out what to call the ranges, to save you the unutterable tedium of eg \code{Sexes=Sexes}. If you already have a variable called \code{Sexes}, you can just pass it straight into \code{TMBO_ranges} without naming it.

For chinds (a character vector used as a range--- like a \code{dimnames} or \code{names}), you can make its elements (as well as the whole chind) available in TMBO code by wrapping it in \code{list}, eg \code{TMBO_ranges( ..., list( COLOURS))} if \code{COLOURS} already exists, or or \code{TMBO_ranges( ... list( COLOURS=c( "Red", "Green", "Blue"))} if it doesn't. The corresponding TMBO declaration needs to be \code{CHIND( COLOURS, Blue, Green, Red)}, ie naming the (same) elements, but the order can be different--- it will Just Work. Elsewhere in your TMBO code, you can then write eg \code{thing(Red_)=99}; note that underscore, which shouldn't be in the \code{CHIND} statement. Note also that you have to explicitly call \code{list} inside the call to \code{TMBO_ranges}; you can't predefine the thing as a list and then pass it in, which would count as "trying to be too clever" here. Non-standard evaluation, like I said...

If you don't wrap a chind in \code{list}, and/or if in TMBO you just declare it as \code{CHIND( COLOURS)}don't then TMBO code can still refer to the entire range \code{COLOURS}, when declaring a new variable or in FOR-loops, but cannot mention the individual colours by name.
}
\seealso{\code{MakeADFun} in package \pkg{TMB}.
}
\examples{
"Use 'runExample()' to list examples. Then run one of them, and look at its code."
Samp_years <- 2003:2008 # can use either a sequence...
Birth_years <- c( 1960, 1990) # or a start/end pair
Sexes <- c( 'Female', 'Male')
Stages <- c( 'Young', 'Old')
# Next is pretty useless except as 'range' arg in a call to 'MakeADFun'. But...
TMBO_ranges(
  Samp_years,                 # Pre-defined
  Birth_years=c( 1960, 1990), # On-the-fly; also NB start/end pair
  list( Sexes),               # Female_ and Male_ will be variables inside TMBO
  Stages,                     # no Young_ or Old_ available inside TMBO
  Morphs= c( 'Hairy', 'Baldy'),  # On-the-fly
  Lightness= list( Shade= c( 'Dark', 'Light')) # bad, ambiguous; but "Lightness" takes priority
)
}
\keyword{misc}
