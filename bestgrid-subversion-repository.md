# BeSTGRID SubVersion Repository

um,,uc,,ua,,sc

- note

this repository is integrated with University of Auckland's LDAP server.

For **non University of Auckland users, please apply for guest access** to University services through the [BeSTGRID Project Manager](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=User__nickdjones&linkCreation=true&fromPageId=3816950645).

**INSTALL TORTOISESVN WINDOWS SUBVERSION CLIENT**

Before proceeding, ensure you've [downloaded and installed TortoiseSVN](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=BeSTGRID__TortoiseSVN&linkCreation=true&fromPageId=3816950645)

**SVN CHECKOUTS**

To get the latest version of a document repository perform the following steps:

1. Open Explorer
2. Create new folder in any drive; `bestgrid`.
3. Right click on a folder and select 'SVN Checkout'
4. Select your repository URL as shown below
5. Enter the folder for the checkout destination
6. Leave all options as default and click OK

- Note

The process of copying all the files from the repository takes a while.
- Icons

A green overlay icon with a tick represents that the file/all the files inside the folder are consistent with those in the repository. A red overlay icon with an exclamation mark represents that the local copy is currently inconsistent, implying that it needs to be 'Committed'. It must be noted that icons do not always accurately describe the state of the file/folder in question.

# Repository Details

- bestgrid all documents

BeSTGRID documentation repository [https://support.csi.ac.nz/svn/bestgrid/](https://support.csi.ac.nz/svn/bestgrid/)

No log message or JIRA issue ticket required

- bestgrid graphic design

BeSTGRID design sub section of the main bestgrid repository. If you're working on graphic design for bestgrid, this is probably where you need to connect to [https://support.csi.ac.nz/svn/bestgrid/communications/design/](https://support.csi.ac.nz/svn/bestgrid/communications/design/)

No log message or JIRA issue ticket required

# Synchronization

## Updating files from the repository

1. Right click on a file/folder to update
2. Click 'SVN Update'

- Note

Any changes to text based (excluding binary) files in the server repository are merged with the local copy. Any (potentially) conflicting change or error is reported.

***Commiting the changes you've made***

1. Right click on a file/folder to commit
2. Click 'SVN Commit'
3. Add in a log message including the Jira issue number if required by repository
