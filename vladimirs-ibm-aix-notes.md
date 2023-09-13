# Vladimir's IBM AIX notes

Various notes on AIX specific topics:

# Using dbx debugger


>  (dbx) run --version
>  (dbx) run --version

- See the stack trace (gdb `bt` command) with


>  (dbx) where
>  (dbx) where

- Set a breakpoint to a function with:


>  (dbx) stop in processResponse
>  (dbx) stop in processResponse

- Set a breakpoint to a line number with `stop at `[unnamed link](/wiki/spaces/%22filename%22)`linenr`:


>  (dbx) stop at "prima_saml_support.cpp":330
>  (dbx) stop at "prima_saml_support.cpp":330

- Move in the stack with `frame 0-n`


>  (dbx) frame 2
>  (dbx) frame 2

- Quit the debugger with `quit`


>  (dbx) quit
>  (dbx) quit

# Linking dynamic libraries

To test how to make (shared object) libraries:

- Preliminaries: I have a program (`usemylib.c`) using a library (`mylibfunc.c`) with a function (`print_hello`) advertised in a header file (`mylibfunc.h`).  Compile the program and the library into object files:

- Link a program with an object file:


>  xlc -o usemylib-static-o usemylib.o mylibfunc.o
>  xlc -o usemylib-static-o usemylib.o mylibfunc.o

- Create a static library, link a program with the library


>  ar -rv libmylibfunc-static.a mylibfunc.o
>  xlc -o usemylib-static-lib usemylib.o -L . -lmylibfunc-static
>  ar -rv libmylibfunc-static.a mylibfunc.o
>  xlc -o usemylib-static-lib usemylib.o -L . -lmylibfunc-static


- Create a shared library - reuse shared object created in previous step


>  ar -rv libmylibfunc-shr.a mylibfunc-shr.o
>  xlc -o usemylib-shr-lib usemylib.o -L . -lmylibfunc-shr
>  ./usemylib-shr-lib # needs libmylibfunc-shr.a
>  ldd usemylib-shr-lib
>  >> usemylib-shr-lib needs:
>          /usr/lib/libc.a(shr.o)
>          ./libmylibfunc-shr.a(mylibfunc-shr.o)
>          /unix
>          /usr/lib/libcrypt.a(shr.o)
>  ar -rv libmylibfunc-shr.a mylibfunc-shr.o
>  xlc -o usemylib-shr-lib usemylib.o -L . -lmylibfunc-shr
>  ./usemylib-shr-lib # needs libmylibfunc-shr.a
>  ldd usemylib-shr-lib
>  >> usemylib-shr-lib needs:
>          /usr/lib/libc.a(shr.o)
>          ./libmylibfunc-shr.a(mylibfunc-shr.o)
>          /unix
>          /usr/lib/libcrypt.a(shr.o)

- Alternatively with `makeC++SharedLib`: note that this wrapper script creates an Object, not a library - it's an quivalent to creating a shared object two steps above.


>  makeC++SharedLib -o mylibfunc-shr-cpp.o -p 0 mylibfunc.o  -L /usr/vac/lib 
>  xlc -o usemylib-shr-o-cpp usemylib.o mylibfunc-shr-cpp.o
>  makeC++SharedLib -o mylibfunc-shr-cpp.o -p 0 mylibfunc.o  -L /usr/vac/lib 
>  xlc -o usemylib-shr-o-cpp usemylib.o mylibfunc-shr-cpp.o

# Running interactive LoadLeveler jobs

>  poe ./prog.exe –llfile ./llfile

# Starting sendmail as an AIX service

The startsrc command does not know any default arguments to the service and they must be explicitly passed.  For sendmail, this is:

>  startsrc -s sendmail -a "-bd -q30m"
