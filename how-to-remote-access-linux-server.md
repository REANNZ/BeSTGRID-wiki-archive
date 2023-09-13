# How to remote access linux server

# Introduction

This article introduce user how to remotely access linux server on a Microsoft Windows machine.

# Download SSH Secure File Transfer

- SSH Secure File Transfer is a program that allows user to remotely access a Linux server with Graphical User Interface (GUI)
- Download the program from [ftp://ftp.wiretapped.net/pub/security/cryptography/apps/ssh/SSH/SSHSecureShellClient-3.2.9.exe](ftp://ftp.wiretapped.net/pub/security/cryptography/apps/ssh/SSH/SSHSecureShellClient-3.2.9.exe)
- Double click to install

# How to use SSH Secure File Transfer

- I will use wiki.test.bestgrid.org as an example.

- It will look like this after the installation:


![Ssh_after_installation.PNG](./attachments/Ssh_after_installation.PNG)
- Add profile


![Ssh_add_profile_1.PNG](./attachments/Ssh_add_profile_1.PNG)
- Type a name testWikiBestgrid in the text box, and then press the "Add to Profiels" button


![Ssh_add_profile_2.PNG](./attachments/Ssh_add_profile_2.PNG)
- Edit profile


![Ssh_edit_profile_1.PNG](./attachments/Ssh_edit_profile_1.PNG)
- Insert details as the following and then press "OK" button


![Ssh_edit_profile_2.PNG](./attachments/Ssh_edit_profile_2.PNG)
Note: Host name is the name of the server, e.g wiki.test.bestgrid.org or wayf.test.bestgrid.org etc...

- Open a connection


![Ssh_open_connection.PNG](./attachments/Ssh_open_connection.PNG)
- Enter password


![Ssh_enter_password.PNG](./attachments/Ssh_enter_password.PNG)
- The left window represents YOUR desktop file system while the right window represents the remote linux server file system


![Ssh_access_wiki.PNG](./attachments/Ssh_access_wiki.PNG)
- Go into the "wiki" directory at right window, and that is the place that you can upload your file.

- You can use drag and drop to upload your file.
