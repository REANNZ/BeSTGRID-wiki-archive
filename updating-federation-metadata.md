# Updating Federation Metadata

Each member of a Shibboleth federation needs to have up-to-date metadata, fetched in a reliable and trustworthy manner.  In particular, it is important to make sure that an interrupted transfer won't result into consistent metadata used by the host - but it is also essential to employ security mechanisms that would prevent any wilful tampering with the metadata.

The MAMS testbed federation provides tools to securely [update the metadata](http://www.federation.org.au/twiki/bin/view/Federation/UpdateMetadata) on an IdP and SP; these tools rely on XML signatures included in the document.  For the BeSTGRID federation where no XML signature is employed, we use a two-phase approach where we first download the metadata with `wget` from an https location (verifying authenticity against a known CA), and then use the MAMS tools to check the metadata for consistency (at least at syntactic level avoid incomplete transfer corruption) and move the metadata to the target location.

I have put together a collection of scripts that do the updates, for all combinations of server type (IdP/SP) and federations (AAF L1, AAF L2, BeSTGRID, BeSTGRID Test).  The scripts are available at [http://ngportal.canterbury.ac.nz/fedid/metadata/](http://ngportal.canterbury.ac.nz/fedid/metadata/).  The sections below elaborate on the specifics of updating the metadata in each of the situations.

# Updating metadata for AAF Federations

The metadata is signed with the host certificate of www.federation.org.au.  It is sufficient to use just the MAMS tools (siterefresh/metadatatool) to download the metadata from a plain HTTP URL and put them into the right place - these tools will check both authenticity and consistency of the metadata.  Detailed instructions, as well as links to the certificate keystore, are at the [MAMS metadata updating wiki page](http://www.federation.org.au/twiki/bin/view/Federation/UpdateMetadata). This applies both to AAF L1 and L2 federations.

# Updating metadata for the BeSTGRID federations

The metadata is not signed, and must be separately downloaded with `wget` from an HTTPS URL at the federations WAYF server (checking the authenticity against the root certificate of the certification authority issuing the server's SSL certificate), and then moved to the correct location with the MAMS tools (checking for consistency).

The essence of this solution is represented by the following two lines (replacing the single invocation of the `metadatatool`/`siterefresh`). 

>  wget --quiet --ca-certificate=/etc/certs/IPS-IPSCABUNDLE.crt [https://wayf.bestgrid.org/metadata/bestgrid-metadata.xml](https://wayf.bestgrid.org/metadata/bestgrid-metadata.xml) -O /usr/local/shibboleth-idp/etc/bestgrid-metadata-download.xml
>  IDP_HOME=$SHIB_HOME   $SHIB_HOME/bin/metadatatool -i [file:///usr/local/shibboleth-idp/etc/bestgrid-metadata-download.xml](file:///usr/local/shibboleth-idp/etc/bestgrid-metadata-download.xml) -N -o /usr/local/shibboleth-idp/etc/bestgrid-metadata.xml

or

>  wget --quiet --ca-certificate=/etc/certs/apacgrid.pem [https://wayf.bestgrid.org/metadata/bestgrid-metadata.xml](https://wayf.bestgrid.org/metadata/bestgrid-metadata.xml) -O /usr/local/shibboleth-sp/etc/shibboleth/bestgrid-metadata-download.xml
>  $SP_HOME/sbin/siterefresh --url [file:///usr/local/shibboleth-sp/etc/shibboleth/bestgrid-metadata-download.xml](file:///usr/local/shibboleth-sp/etc/shibboleth/bestgrid-metadata-download.xml) --out /usr/local/shibboleth-sp/etc/shibboleth/bestgrid-metadata.xml --noverify 

The URL for the [BeSTGRID Federation](/wiki/spaces/BeSTGRID/pages/3818228616) is [https://wayf.bestgrid.org/metadata/bestgrid-metadata.xml](https://wayf.bestgrid.org/metadata/bestgrid-metadata.xml) and the server's SSL certificate is issued by ipsCA (root certificate available at [IPS-IPSCABUNDLE.crt](http://certs.ipsca.com/companyIPSipsCA/IPS-IPSCABUNDLE.crt).

The URL for the [BeSTGRID Test Federation](/wiki/spaces/BeSTGRID/pages/3818228710) is [https://wayf.test.bestgrid.org/metadata/bestgrid-test-metadata.xml](https://wayf.test.bestgrid.org/metadata/bestgrid-test-metadata.xml), and the server'S SSL certificate is issued by the BeSTGRID CA (root certificate [local copy](http://ngportal.canterbury.ac.nz/fedid/bestgridca.pem)

For more detail, see the discussion at [University of Canterbury IdP metadata updates](shibboleth-idp-installation-at-the-university-of-canterbury.md).

You may also download a script suitable as a cron job for updating the BeSTGRID federation metadata: [idp-bestgrid-metadata](attachments/Idp-bestgrid-metadata.txt)

# Updating metadata for on an IdP

On an IdP, the MAMS `metadatatool` should be used, following the instructions posted at the [MAMS metadata updating wiki page](http://www.federation.org.au/twiki/bin/view/Federation/UpdateMetadata)

After setting the proper variables (as done by the scripts), the key command is:

>   $IDP_HOME/bin/metadatatool -i $METADATA_URL \
>        -k /etc/cron.hourly/testfed-keystore.jks -a www.federation.org.au -p testfed \
>        -o $OUTPUT_FILE

# Updating metadata on a SP 

On an SP, the MAMS `siterefresh` should be used, following the instructions posted at the [MAMS metadata updating wiki page](http://www.federation.org.au/twiki/bin/view/Federation/UpdateMetadata)

After setting the proper variables (as done by the scripts), the key command is:

>  $SP_HOME/sbin/siterefresh --url $METADATA_URL --cert /etc/shibboleth/www.federation.org.au.pem \
>         --out $OUTPUT_FILE

# Updating metadata on a WAYF

Updating metadata on a WAYF server introduces one additional piece of complexity - as it is neither an IdP, nor a SP, neither of the tools (metadatatool, siterefresh) is available.

An easy solution is to install the java libraries necessary for running the metadatatool on the WAYF server.  A tar archive with these libraries is available at [http://ngportal.canterbury.ac.nz/fedid/shibboleth-idp-metadatatool.tar.gz](http://ngportal.canterbury.ac.nz/fedid/shibboleth-idp-metadatatool.tar.gz) - it contains directories `bin`, `endorsed` and `lib`, without the MAMS extensions (`mams-*.jar`).

To install this on the WAYF server, just CD to a temporary directory and run

>  wget [http://ngportal.canterbury.ac.nz/fedid/shibboleth-idp-metadatatool.tar.gz](http://ngportal.canterbury.ac.nz/fedid/shibboleth-idp-metadatatool.tar.gz)
>  tar xzf shibboleth-idp-metadatatool.tar.gz -C /usr/local/

This creates `/usr/local/shibboleth-idp-metadatatool/` which can be used as IDP_HOME in the above scripts for running metadatatool (and proceed as if the server was an IdP).  Fresh metadata should go into `/usr/local/shibboleth-wayf/`

Download the keystore or certificates into `/usr/local/shibboleth-idp-metadatatool/certs` and edit the update scripts as necessary.
