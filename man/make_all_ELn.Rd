\name{make_all_ELn}
\alias{make_all_ELn}
\title{Generate array macros}
\description{
\code{make_all_ELn} creates C header files with repetitive macros needed for TMBO arrays. You probably never need to call it; it's normally run invisibly and once only by the \pkg{TMBO} package itself, at installation or first use. If you ever need even-higher-dim arrays than \code{TMBO} provides by default (currently 7), then you can run \code{make_all_ELn} manually. Now, 7 might sound like a lot, but it is actually not enough for many realistic CKMR models.

Note that TMB itself (as of version 1.9.6) "only" supports arrays of up to 7D. If you want to add more, you can easily do so by modifying \code{system.file("include/tmbutils/array.hpp",package="TMB")} yourself. Just search for the lines with \code{int i7} or \code{int n7}, and add extra functions in the extremely obvious way. (I could write code to do this automatically, but it's not the job of \code{TMBO} to patch the source of \code{TMB}!)
}
\usage{make_all_ELn( n, files= TRUE, count_dims= FALSE)
}
\arguments{
\item{ n}{Maximum array dimension}
\item{ files}{Default \code{TRUE} should update the header files in package \pkg{TMBO} itself. \code{FALSE} returns the macros themselves, as R{} character vectors. Otherwise, \code{files} should be a character vector with the paths to the file(s) to be created. It can be either length-1 or length-2. In either case, two files will be created (because some macros are needed in the first pass, and some in the second). If \code{length(files)==1}, then the second filename will have be the same as the first with the first occurrence of the digit "1" replaced by "2".}
\item{ count_dims}{The newer fancier OOB-checker should also trap attempts to index an array with the wrong number of subscripts (compared to its declaration), which otherwise causes a typical TMB crash. It's not working yet, so default is FALSE! This does require a bit of non-macro actual C code (\code{_TMBO__dimbo} in "TMBO2.h").}
}
\value{The filenames, or the macros themselves iff \code{files==FALSE}.
}
\examples{
# Boring...
make_all_ELn( 3, FALSE)
}
\keyword{misc}
