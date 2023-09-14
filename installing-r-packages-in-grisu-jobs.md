# Installing R packages in Grisu jobs

# Introduction

[R](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=R&linkCreation=true&fromPageId=3818228816) can dynamically install packages from [CRAN](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=CRAN&linkCreation=true&fromPageId=3818228816). It is recommended that the [CRAN repository at Auckland University](http://cran.stat.auckland.ac.nz) is used as it is available via [KAREN](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=KAREN&linkCreation=true&fromPageId=3818228816). Some packages are pre-installed by the cluster administrators, particularly those that have external dependencies, or required to meet BeSTGRID's standard application deployment, so the installation process ought to check that each package has not previously been installed. Packages installed by grid users will not be persistent, and will need to be reinstalled every time a script is run.

# Requirements

R scripts that need to install packages should meet the following requirements:

- Use the Auckland University CRAN repository
- Check that a package isn't already installed
- Install the packages every time the script is executed
- Check for HTTP Proxy settings

These requirements will apply for both serial (R) and parallel ([R_mpi_SNOW](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=R_mpi_SNOW&linkCreation=true&fromPageId=3818228816)) R jobs.

# Example

``` 

# Add TMP as library path
# if TMP is not set, try using /tmp
Sys.getenv("TMP")
libloc=Sys.getenv("TMP")
.libPaths(libloc)
# Check HTTP proxy settings
Sys.getenv("http_proxy")
# Select mirror for CRAN repository, Auckland is on KAREN - very fast!
options(repos="http://cran.stat.auckland.ac.nz")

print("Testing installing packages from CRAN")
# Create a list of required packages, these examples are unlikely to be installed by default
packagelist <- c("audio","bdoc","diagram","fgui")

for (pkg in packagelist)
{
	if(!require(pkg))
	{
		print(paste("Attempting to install ",pkg))
		install.packages(pkg)
	} else {
                print (paste(pkg," is already installed"))
        }
        if(!require(pkg))
        {
                print(paste("INFO: Installation of ",pkg," has succeeded."))
        } else {
                print(paste("WARNING: Installation of ",pkg," has failed!"))
                # halt or throw an exception here?
        }
}

# library(pkg) doesn't seem to work, if this could be resolved then the library
# call could be incorporated into the loop above.
library("audio")
library("bdoc")
library("diagram")
library("fgui")
print("Packages installed and loaded.")
# Output a list of all installed packages and versions NOTE: Long but important if you need to recreate a job
# ...there should be a way of formatting this in a nice table.
installed.packages()

```
