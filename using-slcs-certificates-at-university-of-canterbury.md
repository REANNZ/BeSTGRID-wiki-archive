# Using SLCS certificates at University of Canterbury

SLCS certificates (SLCS for *Short-lived certificate service*) issued based on an Shibboleth assertions can make grid much easier to access - it is no longer necessary to arrange a face-to-face meeting with an RAO, neither to wait for the certificate to be issued.

This page documents the steps necessary to get a SLCS certificate and start using the grid with such a certificate.  The page considers the specifics of the University of Canterbury Shibboleth Identity Provider, but it should reasonably apply to other institutions once they deploy an IdP and configure the SharedToken attribute.

A separate page documents [the task of configuring the IdP for SLCS certificates](configuring-idp-for-slcs-certificates.md) - and this page focuses on the user perspective.

Overall, the user has to:

1. Obtain a certificate, and arrange for membership in the relevant virtual organizations.
2. Use the certificate on the grid, and periodically refresh the certificate - with no need to redo the steps above.

# Configuring the VO membership

## Retrieving your first SLCS certificate

- Make sure you have configured the attribute release as described above.
- Start [http://bestgrid.org/grix](http://bestgrid.org/grix) and select the Institution login tab
- Pick your institutions IdP and enter your home usercode and password.
- Click login -  Grix should now create a grid certificate and a proxy for you.

## Configuring VO membership

- In Grix, go to the VO tab.


>  **Select*ARCS** from the VO list.
>  **Select*ARCS** from the VO list.

- Enter your contact details and click Apply.
- Wait for an email with a confirmation code.  Copy the code into Grix and click Confirm.
- Wait for an email that the selected VOMRS Representative has approved your membership.
- Request membership in the VO groups of choice: select /ARCS/BeSTGRID from the group list and click Apply.
- Again, wait for a confirmation email.

# Running jobs with Grisu

Grisu now offers Shibboleth login.

- Start Grisu from: [http://grisu.arcs.org.au/downloads/webstart/grisu.jnlp](http://grisu.arcs.org.au/downloads/webstart/grisu.jnlp)
- Select your institution from the list, and enter the username and password as you did in Grix.
- Login ... and submit your jobs as if you were using a regular grid certificate.
