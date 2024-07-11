\name{runExample}
\alias{runExample}
\title{Run TMBO example}
\description{
Compile and run a test example from the \pkg{TMBO} package--- just like \code{TMB::runExample} (qv). See the latter for details. To see what examples exist, just do \code{runExample()}.

If an example doesn't work, try also passing an (unnamed) argument "&> logfile.log" to get the error log. That's on Windows only; Linux syntax is something different (whatever you do to redirect the output of \code{g++}.) See also \code{TMBO::compile} and the \code{ppdebug} argument, in case of TMBO preprocessing woes.

The result of the example (usually its final line) is returned invisibly (unlike the TMB version), so eg if that's an object from \code{\link{MakeADFun}}, you can assign it and play around with it further.
}
\usage{
runExample(
  name,
  all= FALSE,
  exfolder= NULL,
  subarch= FALSE,
  dontrun= FALSE,
  clean= FALSE,
  ppflags= NULL,
  ...
)
}
\arguments{
\item{ name}{string with \emph{just} the name of the example (no path, no extension). If missing and if \code{all=FALSE}, \code{runExample} returns the possible values.}
\item{ all}{set TRUE to run 'em all}
\item{ exfolder}{where to look for the example, and where to build it. Defaults to \code{<lib>/TMBO/examples}. May result}
\item{ subarch}{obsolete post R4.3; leave it!}
\item{ dontrun}{You might just want to compile it, not run it.}
\item{ clean}{Recompile from scratch?}
\item{ ppflags}{Character vector to be passed to \code{\link{compile}}, just for the preprocessing step. EG to trap OOBs nicely, "-DTMBOOBOO"; or for example "oob1" where the default is to trap OOBs, "-DFORCE_CRASH" to show what happens if you don't.}
\item{ ...}{All args as per \code{TMB::runExample} (qv). Any un-named unmatched ones are passed to \code{compile}, though it's a bit hard to predict which ones those will be.}
}
\value{The result of the final line of the example (assuming it worked), invisibilized for brevity. If no arguments are given, the names of the available examples are returned.
}
\examples{
runExample()
\dontrun{
runExample( 'vectoro1')
}
}
\keyword{misc}
