# Distributing the MATLAB Runtime to Rocks Compute nodes

# Introduction

MATLAB's compiled runtime environment allows compiled MATLAB scripts be executed on a Rocks cluster without the purchase of additional MATLAB licenses. The MATLAB runtime installer can be installed on Rocks using a modified version of [Distributing binary installers to Rocks compute nodes](/wiki/spaces/BeSTGRID/pages/3818228438).

# Procedure

# Distribute binary and options file

- Download the MATLAB Compilier Runtime from [MathWorks](http://www.mathworks.com/downloads/web_downloads/) (Registration Required)
- Set it up as per [Distributing the binary](distributing-binary-installers-to-rocks-compute-nodes.md).
- Create or modify `opts.txt` with the following declaration:

``` 

-P installLocation="/opt/MATLAB/MATLAB_Compiler_Runtime"

```
- Set up `opts.txt` as per [Distributing the binary](distributing-binary-installers-to-rocks-compute-nodes.md).
- Create torrents for both files & rebuild the Rocks distribution.

# Integrate installation onto the compute nodes at reinstall

- Edit `/export/rocks/install/site-profiles/5.2/nodes/extend-compute.xml` and add the following lines to the  block:

``` 

wget -q http://127.0.0.1/install/contrib/extra/install/MCRInstaller.bin
wget -q http://127.0.0.1/install/contrib/extra/install/opts.txt
chmod +x /install/contrib/extra/install/MCRInstaller.bin
/install/contrib/extra/install/MCRInstaller.bin -silent -P /installLocation="/opt/MATLAB/MATLAB_Compiler_Runtime"

```
