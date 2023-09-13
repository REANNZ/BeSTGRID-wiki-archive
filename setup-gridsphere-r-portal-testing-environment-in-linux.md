# Setup Gridsphere R Portal Testing Environment in Linux

# Setup Steps

- Step1 Install Java

; Step 2 Install R
- Download R from http

//www.r-project.org/



- Extract R



- Change to the R install directory



- Compile and Install R.



- Create symbolic link for R



- Step 3 Install rJava and JRI

rJava is a simple R-to-Java interface and it is included inside the R package, so install rJava is very straight-forward. 

First of all, you need to start *R*, then issue the following command inside *R*.

``` 
install.packages("rJava")
```

After the installation you should find rJava is installed at /usr/local/lib/R/library/rJava/, and JRI is shipped as part of rJava, i.e. /usr/local/lib/R/library/rJava/jri

- Step 4 Check out the source files and compile them with your favorite IDE

; Step 5 Use the following script to run the program

``` 

#!/bin/sh
R_HOME=/usr/local/R/lib/R

JRI_LD_PATH=${R_HOME}/lib:${R_HOME}/bin

PROGRAM_PATH=/root/workspace/Solvers/bin/

JRI_PATH=/usr/local/R/lib/R/library/rJava/jri

if test -z "$LD_LIBRARY_PATH"; then
  LD_LIBRARY_PATH=$JRI_LD_PATH
else
  LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$JRI_LD_PATH
fi

if test -z "$CLASSPATH"; then
  CLASSPATH=$PROGRAM_PATH
else
  CLASSPATH=$CLASSPATH:$PROGRAM_PATH
fi

export R_HOME
export LD_LIBRARY_PATH
export CLASSPATH
echo $CLASSPATH
if [ -z "$1" ]; then
    echo ""
    echo " Usage: run <class> [...]"
    echo ""
    echo " For example: ./run rtest"
    echo " Set CLASSPATH variable if other than .:examples is desired"
    echo ""
else
    java -Djava.library.path=${JRI_PATH} -cp $CLASSPATH:${JRI_PATH}/JRI.jar $*
fi

```

Remember to change the PATH variables to correct value.

; Step 6 Add "execute" permission to the script file (Assumed the script is called myrun)

``` 
chmod a+x myrun
```

; Step 7 Now you can run the program by

``` 
./myrun tests.TestExchange
```
