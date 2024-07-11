\name{compile}
\alias{compile}
\title{Compile a TMB CPP file into dyn-load-able, using TMBO features}
\description{
Like \code{TMB::compile} (qv) but allowing TMBO features: offset arrays (things don't have to start at zero) and greatly simplified for-loops.

The mechanism is to first run the C preprocessor on your file eg "mymod.cpp" to handle \emph{only} the special TMBO macros, producing an intermediate file eg "mymod_TMBOpp1.cpp", then tidy that up with a small amount of regexing in R{}, then run \code{TMB::compile} on it, then rename the result back to "mymod.dll" or "mymod.so".

Your original file needs to have "#include <TMBO.h>" instead of "#include <TMB.h>", otherwise this won't work. Also, any \emph{system} headers (eg of RcppEigen) should be written \code{HASH_INCLUDE <syshead>" not "#include", so that they don}t get expanded during the first pass, but only during the second.. However, your \emph{own} headers (eg if you have split your code into various source files) should be "#include" as usual.
\subsection{Compiler name}{
If \code{compile} works for you out-of-the-box, don't read this bit. If not...

As of version 2.0.x of package \pkg{TMBO}, the preprocessing pass defaults to trying to run a program called "cpp", which I thought stood generally for "Chucky's Pre-Processor" ;). It works (for me...) on Windows, because that program lives in the same folder as "g++" which actually does R{}'s compilation; I think they're synonyms FAPP, so I could instead have called "g++" with "-E" option (only preprocess). But "cpp" might not work on all platforms, and "g++" presumably does not (it's GNU, so maybe not for Macs). So for pre-processing on non-Windows, \emph{you} might need to use a different "program".

As of v2.1.x, I have added some logic in \code{.onLoad} to \emph{hopefully} autodeduce the right name. But if that doesn't work, you can specify the compiler's name manually \emph{before} calling \code{compile} (or, better, before loading \code{TMBO}) eg via \code{Sys.setenv( CPP_IN_R="clangaroo")} or whatever the magic name should be on your system. If you are a Linucian you probably know exactly what to do. Whatever you supply has to accept arguments "-E" (preprocess only) and "-CC" (include comments in macros), otherwise no go.

The main compilation pass eventually calls \code{tools:::.shlib_internal} (via \code{TMB::compile}) which knows what the real compiler is called, so that should be fine. You can actually force \code{.shlib_internal} to reveal the real compiler's name, so that's what's in my autodeduce code--- but it has required some more superhacking, because R{} has (accidentally, I \emph{hope}) made it \emph{far more difficult} than it needs to be. Sigh. Again.
}
}
\usage{
compile( file, ..., dev= exists( '..TMBO', mode='environment'),
  ppcheck= FALSE,
  stop_after_cpp1= FALSE,
  ppflags= NULL,
  flags= NULL
)
}
\arguments{
\item{ file}{The main source file, optionally with path. Extension ".cpp" will be automatically added if needed..}
\item{ ...}{Passed to \code{TMB::compile} (qv). See also \code{flags} argument.}
\item{ dev}{Leave this alone, it's just for me.}
\item{ ppcheck}{if TRUE, do 2 passes of preprocessing and tidy-up, but then stop before normal TMB compilation. The output is returned as a character vector, showing pretty much what \code{TMB::compile} would see. Maybe helpful if you are getting incomprehensible compiler errors. Note that the \emph{first} round of preprocessing and tidy-up always gets stored in an intermediate file, regardless of \code{ppcheck}; see \bold{Value}.}
\item{ stop_after_cpp1}{surely this is self-explanatory? You'll just get a file called "<file>_TMBOpp1.cpp", before the R-side tidy-up (which is essential before the second pass).}
\item{ ppflags}{optional character vector of flags to give to the first preprocessor pass, eg \code{-DTMBOOBOOB} (when that is working...)}
\item{ flags}{optional string, or character vector which will be concatenated into a string, that gets passed to \code{TMB::compile}. Probably flags of some kind used for something; the documentation has not enlightened me... On Windows, you might want to use eg \code{flags="&> logfile.log"}, so that any compilation errors are sent to that file.}
}
\value{
Various files are produced (see below). From a purely R{} PoV, though, the return value shows the outcome of the compilation attempts: 0 (success) or 1 (failure). That's the usual convention, strange as it may seem: so \code{if(compile(...))} actually means "if compilation fails". If \code{ppcheck=TRUE}, no compilation per se is attempted, just two rounds of preprocessing.
The "normal" error case is that \code{ppcheck} is FALSE, preprocessing (first pass) succeeds, but compilation/second-preprocessing-pass fails. In that case, the logfile contains the compiler's error log (if you remembered to set a logfile via \code{...}).
If \code{ppcheck=TRUE}, then the result will have attribute \code{pplog}, a character vector containing (if succhess) what TMB itself would see, after expanding all the TMBO macros.
If preprocessing fails (in the first pass regardless of \code{ppcheck}, or just in the second pass if \code{ppcheck} is TRUE) then the result will again have attribute \code{pplog} showing the complaints.
That's the plan, anyway: IDK if all 3 types of error return exactly what they're supposed to, especially not on Linux.
The files produced go into the same folder as \code{file} itself. The first is an intermediate C++ file "<myfile>_TMBOpp1.cpp", arising from the first preprocessing pass. If that pass gives an error, that intermediate file may be incomplete. If successful, the intermediate file is then tidied up a bit in R{} and saved back under the same name before considering \code{ppcheck}, so you never get \emph{pure} successful CPP output unless you have set \code{stop_after_cpp1=TRUE}.
If full compilation succeeds, you should get a DLL (aka "shared-object file") with the same name as . If compilation fails and you remembered to ask for a logfile, there will be one; good luck deciphering it... Probably there's some kinda ".o" files representing some kinda C-level muckery, too.
}
\note{
As the in-code comments say, there is some spectacular hacking inside \code{TMBO::compile}, to ensure that TMBO's include-path gets seen by \code{TMB::compile}. The latter calls \code{tools:::.shlib_internal} at some point, so the trick is to intercept that and kludge the desired path into the makefile... ugggh. It works fine, but there really should be a better way! TMB folk may be able to suggest one.

These further0 notes are really just for me. One TMBO-only alternative would be 3-phase compilation, with the 2nd phase being a pure CPP run on \code{pp_full_file} allowing \bold{only} <TMBO2.h> as the include file. That's close to what \code{ppcheck=TRUE} does now, but seems Ugly.

Another \bold{might} be to define a macro during the first call to CPP that contains the TMBO include path; this would then be incorporated into the HASH_INCLUDES that get added for the 2nd pass; the macro would give the full include path for "TMBO2.h" (and "boring_array_bits2.h" and ...).
}
\examples{
\dontrun{
## Normally use 'runExample( "vectoro1")' instead
## But this is useful if you wanna see all the TMBO macros expanded
file.copy( system.file( 'examples/arrayo1.cpp', package='TMBO'),
    './arrayo1.cpp') # avoid messing up package's own folder
compile( './arrayo1.cpp', ppcheck=TRUE)
}
}
\keyword{misc}
