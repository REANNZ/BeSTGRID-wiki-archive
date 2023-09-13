# Hacking VIC to Use Video4Linux2

It is necessary to make some changes to the source code of vic, in order for it to use the video4linux2 drivers.

These guidelines are loosely based on those from the University of Queensland. Unfortunately the UoQ code does not work with the latest AccessGrid, but we can follow their process.

University College London (UCL) had been building a new, open-source media toolkit, which includes a modified version of vic.

Unfortunately none of the University College solutions compile from source, but their latest source includes an upgraded video4linux2 interface, which supercedes the UoQ code.

# Download UCL code

You can find the latest UCL source here: [Vic Download from UCL Media Toolkit](http://mediatools.cs.ucl.ac.uk/mbone/mmedia/wiki/VicDownload)

We only need the 'vic' component of the toolkit, but it is necessary to compile the entire kit to build vic.

Note that in the included source are outdated versions of some common libaries (e.g. TCL), which will work more effictively if built from official repositories.

# Modification 1: Removing Pointer to Integer Casts

The UCL vic source requires a clean-up, in order to compile properly.

There are multiple unnecessary pointer to integer casts. These seem only to be part of a debugging hack, so can simply be commented out.

# Modification 2: Switching from video4linux1

The video4linux1 interface is being built into vic as default in the UCL code.

We can now follow the University of Queensland guide [(except using our UCL source code), and modify all of the Makefiles to point to *v4l2* instead of *video4linux.*

Removing the video4linux.cpp file altogether will ensure that the build is using the video4linux2.cpp code.

# Modification 3: Fixing the video4linux2.cpp file

The code will still not compile correctly, as some minor adaptations to video4linux2.cpp are necessary.

The compiler error output from video4linux2 indicates where these adaptations are required.

# Useful Links

[http://antongrid.blogspot.com/search?q=vic Vic topic on Anton Gerdelan's blog.](http://www.itee.uq.edu.au/%7Egrangenet/vic_v4l2/)]

[Video4Linux2 modification for Vic at University of Queensland](http://www.itee.uq.edu.au/%7Egrangenet/vic_v4l2/)

[UCL Media Toolkit](http://mediatools.cs.ucl.ac.uk/mbone/mmedia/)
