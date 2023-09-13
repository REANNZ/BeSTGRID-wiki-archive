# Getting an ASGCCA grid certificate

`Getting Started Roadmap`

Following the winding down of the ARCS project (as of June 2012), the APACGrid CA is no longer issuing certificates to the NZ research community.

We have negotiated a partnership with the Academia Sinica Grid Computing Certificatino Authority (ASGCCA) to issue certificates for the NZ research community.

Also, with the wider availability of Tuakiri, it is much easier for users to use the short-lived (SLCS) certificates issued by the SLCS server based on a Tuakiri login.

This guide applies both to users who have been using APACGrid certificates and to new users who want to get started on the grid.

## Table of Contents 
 - [Determining which certificate to use](#determining-which-certificate-to-use)
- [Obtaining ASGCCA certificate](#obtaining-asgcca-certificate)
- [Registering for using the grid with an ASGCCA certificate](#registering-for-using-the-grid-with-an-asgcca-certificate)
# Determining which certificate to use

Requesting and maintaining a regular long-lived grid certificate may be unnecessary overhead for most users - when they have easier options available - SLCS certificates via Tuakiri.

- Determine whether you can use Tuakiri certificates
	
- Is your institution part of Tuakiri?  Try accessing the following link, and if your institution is on the list and you can log in (and get a "Success" message at the end), just use Tuakiri: [https://slcs1.nesi.org.nz/SLCS/login](https://slcs1.nesi.org.nz/SLCS/login)

- Institution not listed?  Or do you have any of these special requirements:
	
- Use international collaboration on the computational grid (use your certificate with international grids)?
- Need an IGTF-accredited certificate for other purposes?
- Need a long-lived certificate for specialized tools you use?
- In this case, proceed below with [#Obtaining ASGCCA certificate](#GettinganASGCCAgridcertificate-ObtainingASGCCAcertificate)

- Otherwise, if SLCS-Tuakiri certificates work for you well, you don't need to do anything else to get a certificate - just:
	
- Register for the grid services at [http://bestgrid.org/join](http://bestgrid.org/join)
- Start Grisu from [http://bestgrid.org/jobs](http://bestgrid.org/jobs)

# Obtaining ASGCCA certificate

Follow the instructions at [http://ca.grid.sinica.edu.tw/certificate/request/request_user_cert.html](http://ca.grid.sinica.edu.tw/certificate/request/request_user_cert.html)

**Note:** This certification authority is operated by the Academia Sinica in Taiwan. They are providing grid certification services for New Zealand universities.

**Note**: you need Sun/Oracle Java for running the tools (applets) used by the ASGCCA website.  OpenJDK will not work.  Also, as the applets are not signed and recent versions of Oracle Java reject to run applets without a valid signature (without even prompting the user), you may have to first add the CA website into your list of exceptions:

- Launch the Java Control Panel (either from your desktop's Control Panel, or running ControlPanel from the Java bin directory, or running "javaws -viewer")
- On the Security tab, add [https://canew.twgrid.org/](https://canew.twgrid.org/) to the list of Exceptions.


>  **Please note this is done*instead** of doing the step recommended by the ASGCCA website to change the security level to Medium (which is not sufficient).
>  **Please note this is done*instead** of doing the step recommended by the ASGCCA website to change the security level to Medium (which is not sufficient).

The steps are (combining administrative approval and technical steps):

1. To request a new certificate, fill in the form at [https://canew.twgrid.org/request/new/request-new.php](https://canew.twgrid.org/request/new/request-new.php)
	
- You will need to upload your ID documents with the certificate request.
- You will be asked to select your Organization.  This determines which RA would be approving your application.  Please select an entry that matches a person you can actually reach - even if you are not directly linked with the Organization / Department listed.
1. Save your private key as `$HOME/.globus/userkey.pem`
- Note: if you already have an existing certificate and need to renew it, instead go to [https://canew.twgrid.org/request/rekey/request-rekey.php](https://canew.twgrid.org/request/rekey/request-rekey.php)
2. If requesting a new certificate, arrange a meeting with an RA to get your request approved.
	
- Bring your Official form of Identification (Driver's license or Passport are most suitable) and your Work ID card (where applicable) to the meeting.
- The RA then electronically approves your request at [https://canew.twgrid.org/manage/manage-user.php?status=Request](https://canew.twgrid.org/manage/manage-user.php?status=Request)
- This step is skipped when just renewing a certificate.
3. We recommend at this point emailing asgcca@grid.sinica.edu.tw and:
	
- Informing them you have requested the certificate
- Asking for the certificate to be issued as SHA-1.
		
- Otherwise, the certificate would be issued as SHA-256, which is not compatible with some of the tools used on the BeSTGRID/NeSI infrastructure.
4. Wait for your certificate to be issued - this may take a few days.  You should receive a confirmation email when your certificate is issued - and you can also find the certificate listed at [http://ca.grid.sinica.edu.tw/publication/newCRT/newcerts/crt.php](http://ca.grid.sinica.edu.tw/publication/newCRT/newcerts/crt.php)
5. Follow the download link in the confirmation email to download your certificate.
6. Download the certificate as `$HOME/.globus/usercert.pem`
7. To import your certificate into the browser, use the applet at [https://canew.twgrid.org/publish/combinekey.php](https://canew.twgrid.org/publish/combinekey.php) to combine the PEM public and private key into a single PKCS12 file that can be imported into a browser.
8. Import the certificate into your browser from the PKCS12 file (this would be needed for authenticating to the ASGCCA website - e.g., to request host certificates or renew your user certificate).

# Registering for using the grid with an ASGCCA certificate

- Request registration by going to the BeSTGRID-NZ virtual organization server at [https://voms.bestgrid.org:8443/voms/nz/](https://voms.bestgrid.org:8443/voms/nz/)
- Authenticate to the server with your grid certificate - this is easily done if you use the same browser you used for getting the certificate - the certificate is already loaded in the browser.
- Register into the VO server.
- Request membership in relevant groups.
