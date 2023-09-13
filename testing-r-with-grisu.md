# Testing R with Grisu

Submit script below as an R job with Grisu to test the following parts of the R (serial mode) installation on a cluster:

- HTTP proxy is set correctly
- TMP directory is set correctly
- The CRAN mirror at Auckland University is accessible
- That CRAN packages can be downloaded and installed by the grid user
- That CRAN packages that have been installed by the grid user can be loaded

``` 

# add TMP as library path
Sys.getenv("TMP")
libloc=Sys.getenv("TMP")
.libPaths(libloc)
# Chekc http proxy settings
Sys.getenv("http_proxy")
# Select CRAN mirror for repository
options(repos="http://cran.stat.auckland.ac.nz")

print("Testing installing packages from CRAN")
packagelist <- c("audio","bdoc","diagram","fgui")

for (pkg in packagelist)
{
	if(!require(pkg))
	{
		print(paste("Attempting to install ",pkg))
		install.packages(pkg)
	}
}

library("audio")
library("bdoc")
library("diagram")
library("fgui")
print("Done testing R")

```
