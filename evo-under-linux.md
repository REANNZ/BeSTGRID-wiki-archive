# EVO Under Linux

# WinXP Virtualised Approach

We have managed to get some configurations of Evo operate under Linux, although we have had significant problems with some cameras and also with USB audio devices.

The performance of Evo under Linux in its current implementation is highly unstable and unreliable compared to the 32-bit Windows implementation.

The most reliable method for running Evo on a Linux platform is to run it from within a 32-bit Windows virtual machine. We have effectively used the free [VMWare Player](http://www.vmware.com) software, available in most Linux repositories, to run a 32-bit Windows XP client machine for Evo, which is more stable than native Linux Evo, and is able to interface with all of our hardware.

# Required Software for Native Linux Evo

- 32-bit Sun Java 1.5 JDK
- Any web browser (32-bit browsers will launch Java Web Start)
- Supporting C libraries
- Video for Linux 2 drivers for camera

EVO is primarily built on the Java 1.5 JDK, so requires that software.

Note that you must have the 32-bit Sun Java version, as the 64-bit versions are not packaged with Java Web Start, which is required to launch the program.

Any web browser that can access the Caltech EVO website [will do, however a 32-bit browser should have some integration with Java Web Start, although this is not a major issue.

EVO is not entirely built on Java. EVO is a front end for the ViEvo and RAT programs, which are C programs with distributions for different operating systems (Java Web Start will grab the appropriate version for your machine automatically). These programs are installed on your machine by the EVO software, and some Linux distributions require some additional C libraries before the video and audio client windows will pop-up during EVO sessions.

- In order to find out which C libraries are missing, run ViEvo from the command line (EVO should install the binaries in a directory embedded in ~/.Koala/plugins/ViEVO... Run the binaries from the directory containing them).

Unlike [AccessGrid Under Linux](http://nextgen-caltech.cern.ch/evoGate/)], which uses an older version of the video client software, EVO will properly interface with v4linux2 drivers, which support most modern video capture hardware.

# JAVA Web Start

It is true that for Linux is always challenging since there is so many possible configurations. The 2 main ones are the following:

- Java SUN is not installed. While a java software is usually installed by default, it is not the SUN version (this may change with the move from SUN to have Java open source). So, the user will need to download the SUN JVM (www.java.com)

- Some browser/system are sensible on the way the Java web start is configured. By default, when a file extension .jnlp is downloaded, the SUN javaws (java web start) should be used to read the file. If not, then it should be configured. The following link can help:


>  [http://evo.vrvs.org/evoGate/FAQ/#linux01](http://evo.vrvs.org/evoGate/FAQ/#linux01)
>  [http://evo.vrvs.org/evoGate/FAQ/#linux01](http://evo.vrvs.org/evoGate/FAQ/#linux01)

- Starting from the Web Start Viewer ('javaws -viewer') is a bit funny: if you start it then exit and attempt to restart it will silently fail just after the splash screen. If you exit the WS viewer and the associated java control panal, then restart them, its OK.

# Hardware Known to Work with EVO and Linux

## Audio Devices

- ClearOne 50 USB Microphone/speaker
- Any device connected to on-board audio. (i.e. Logitech headset w/microphone)

## Cameras

- Sony EVI D100P

# Hardware Known Not to Work with EVO and Linux

- Logitech Quick Cam IM
