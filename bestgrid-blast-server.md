# BeSTGRID BLAST Server

**[WWW BLAST Server](http://blast.bestgrid.org)**

## Configuration

Standalone BeSTGRID BLAST Server is built on a virtual machine of [the Pleyads Xen Server](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Pleyads_Server&linkCreation=true&fromPageId=3816950642) using CentOS 5.0.

Software has been downloaded from [NCBI BLAST Web Server](http://www.ncbi.nlm.nih.gov/blast/download.shtml) and installed according manuals: [ReadMe One](http://140.109.34.30/blast/readme.html) and [//ftp.ncbi.nih.gov/blast/documents/blast.html ReadMe Two](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=ftp&title=%2F%2Fftp.ncbi.nih.gov%2Fblast%2Fdocuments%2Fblast.html%20ReadMe%20Two).

A location of the GenBank Database is [//biomirror.auckland.ac.nz/genbank-uncompressed New Zealand Biomirror](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=ftp&title=%2F%2Fbiomirror.auckland.ac.nz%2Fgenbank-uncompressed%20New%20Zealand%20Biomirror). Daily script uncompresses the GenBank database and places it into that folder. Then the database is formatted by formatdb utility: 

>  ./formatdb -i rel###.fsa_aa -p T -n fsa_aa_db -o 

where

>  *-i rel###.fsa_aa* - input file with release number ###
>  *-p T* - type of file, **T** for protein
>  *-n fsa_aa_db* - base name for BLAST files
>  *-o* - parse SeqID and create indexes

Resulted BLAST files are copied to db/ sub-folder together with rel###.fsa_aa which is renamed to fsa_aa_db. This folder is a NFS share of the BeSTGRID Data Storage and mounted on [WWW BLAST Server](http://blast.bestgrid.org) on a folder **/var/www/html/db**.

To connect the GenBank database to BLAST several configuration and html files of BLAST installation have been updated:

>  ***blast.rc** and **psiblast.rc**
>  blastn fsa_aa_db
>  blastp fsa_aa_db
>  blastx fsa_aa_db
>  tblastn fsa_aa_db
>  tblastx fsa_aa_db

 ***blast.html**, **blast_cs.html**, **megablast.html**, **megablast_cs.html**, **psiblast.html**, **psiblast_cs.html**

``` 

 <select name = "DATALIB">
    ....
    <option VALUE = "fsa_aa_db"> fsa_aa_db
 </select>

```

Finally a copy of blast.cgi script file has been created with name **Blast.cgi**. That is a requirements of Geneious plug-in.

All updated html and configuration files are placed in [SVN repository](https://svn.csi.ac.nz/svn/bestgrid/themes/collab%20grid/BeSTGrid%20Wiki/blast/).
