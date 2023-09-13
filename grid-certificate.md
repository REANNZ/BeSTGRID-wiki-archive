# Grid certificate


## Table of Contents 
 - [Introduction](#introduction)
- [Grid Certificate Policies](#grid-certificate-policies)
- [Prerequisites](#prerequisites)
- [Getting a Grid Certificate](#getting-a-grid-certificate)
- [Grid Certificate request procedure](#grid-certificate-request-procedure)
-- [Request Grid Certificate with Grix](#request-grid-certificate-with-grix)
--- [Organisation Unit Definitions for BeSTGRID](#organisation-unit-definitions-for-bestgrid)
-- [Verify Grid User's Identity](#verify-grid-user's-identity)
-- [Retrieving and Installing the Grid Certificate](#retrieving-and-installing-the-grid-certificate)
- [Renewing a Grid Certificate](#renewing-a-grid-certificate)
- [Revoking a Grid Certificate](#revoking-a-grid-certificate)
# Introduction

In order to use any of the [BeSTGRID](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=BeSTGRID&linkCreation=true&fromPageId=3816950618) [Computational Grid](/wiki/spaces/BeSTGRID/pages/3816950992) services a [Grid User](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Grid%20User&linkCreation=true&fromPageId=3816950618) is required to identify themselves with either a University or CRI [Identity Provider](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Identity%20Provider&linkCreation=true&fromPageId=3816950618) or by obtaining a [Grid Certificate](/wiki/spaces/BeSTGRID/pages/3816950618). BeSTGRID Grid Certificates are provided by the [APACGrid Certificate Authority](https://ca.apac.edu.au/pub) and are used by a variety of applications, such as web browsers and [Grid Tools](/wiki/spaces/BeSTGRID/pages/3816950787), to allow access to sites and services provided by [BeSTGRID](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=BeSTGRID&linkCreation=true&fromPageId=3816950618) and its partners such as [ARCS](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=ARCS&linkCreation=true&fromPageId=3816950618). This document will provide an overview on how a [Grid User](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Grid%20User&linkCreation=true&fromPageId=3816950618) obtains, uses, and maintains their [Grid Certificate](/wiki/spaces/BeSTGRID/pages/3816950618).

# Grid Certificate Policies

- A Grid Certificate expires 1 calendar year after issue and must be renewed annually.


>  **A Grid Certificate*must not** be shared; Grid Users **must** have their own Grid Certificate. Shared Grid Certificates will be revoked without warning.
>  **A Grid Certificate*must not** be shared; Grid Users **must** have their own Grid Certificate. Shared Grid Certificates will be revoked without warning.

# Prerequisites

- [Java](http://www.java.com/en/) will need to be installed and updated to the latest version
- The APAC Certificate Authority Server certificate will needed to be [downloaded and installed](https://ca.apac.edu.au/cgi-bin/pub/pki?cmd=getStaticPage&name=index)
- The [Grix](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Grix&linkCreation=true&fromPageId=3816950618) grid tool ...
	
- will need to be downloaded and installed (see [Grix](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Grix&linkCreation=true&fromPageId=3816950618)),
- or started using [this Java Web Start link](http://ngportal.canterbury.ac.nz/grid/grix-jdk5-bestgrid.jnlp)
- that there is no HTTP proxy or firewall blocking access to the Grix servers ([listed here](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Grix&linkCreation=true&fromPageId=3816950618))

# Getting a Grid Certificate

The recommended method of obtaining a Grid Cerificate is with the [Grix](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Grix&linkCreation=true&fromPageId=3816950618) grid tool, though it may be requested directly from the [APACGrid Certificate Authority](https://ca.apac.edu.au/pub).

# Grid Certificate request procedure

This procedure is written for [Grix](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Grix&linkCreation=true&fromPageId=3816950618) v1.2.2, it has three main phases, requesting the Grid Certificate, verifying the Grid User's identity, and retrieving & installing the Grid Certificate once it has been issued. Requesting the certificate and verifying the Grid User's identity do not have to happen in any specific order, and identity verification can be done well in advance of a certificate request provided the [Registry Authority Operator](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Registry%20Authority%20Operator&linkCreation=true&fromPageId=3816950618) (RAO) can recall the identity verification. However, the Grid Certificate Request will not be approved until the Grid User

s identity is confirmed.

## Request Grid Certificate with Grix

1. Open the [Grix](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Grix&linkCreation=true&fromPageId=3816950618) application
2. Select the **Certificate** tab
3. Enter the following details in the request form fields
4. ***Country:** `NZ`
5. ***Organisation:** `BeSTGRID`
6. ***Organisation Unit:** Use the full name of the organisation as indicated in the [Organisation Unit Definition table](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Grid_certificate&linkCreation=true&fromPageId=3816950618) below.
7. ***Name:** The name of the Grid User (at least first name and surname)
8. ***Email:** The email address of the Grid User (should be an email address hosted by the Grid User's parent organisation)
9. Click on the **Request** button to submit the Grid Certificate request

### Organisation Unit Definitions for BeSTGRID

Using consistent names in the Organisation Unit (OU) field of Grid Certificates ensures that Grid Users from the same organisation or institution can be quickly found and easily managed.

|  Organisation                       |  OU text                            |
| ----------------------------------- | ----------------------------------- |
|  University of Auckland             |  The University of Auckland         |
|  University of Canterbury           |  University of Canterbury           |
|  Victoria University of Wellington  |  Victoria University of Wellington  |
|  Massey University                  |  Massey University                  |
|  Landcare Research                  |  Landcare Research NZ ltd           |
|  Lincoln University                 |  Lincoln University                 |

## Verify Grid User's Identity

The Grid User will need to choose a [Registry Authority Operator](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Registry%20Authority%20Operator&linkCreation=true&fromPageId=3816950618) (RAO) from the [list of approved ARCS RAOs](http://wiki.arcs.org.au/bin/view/Main/RaoList#NZ_BeSTGRID), there may be an RAO within the Grid User's organisation but it may be more convenient to see the closest RAO. There may be a stronger burden of proof required when meeting an RAO outside the Grid User's organisation.

The Grid User will need to provide proof of identity, preferably some form of Photo ID, such as a drivers license or student ID card, when they meet the RAO. The RAO will not approve requests on behalf of other Grid Users. The Grid User and RAO must physically meet, proof of identity can not be confirmed by email, fax, telephone, or any other communications media.

Once proof of identity has been established, the RAO may be happy to renew Grid Certificates when they expire without re-presenting proof of identity. It is recommended that proof of identity be re-established if the Grid User's circumstances change, e.g. working for a new organisation.

1. Choose an RAO from the [list of approved ARCS RAOs](http://wiki.arcs.org.au/bin/view/Main/RaoList)
2. Contact the RAO to see if they are available, and make arrangements to meet the RAO
3. The Grid User presents their photo ID when they meet the RAO
4. If the RAO is satisfied with the Grid User's proof of identity, they will then approve the Grid Certificate request and contact a Certificate Authority Operator (CAO) to issue the Grid Certificate

## Retrieving and Installing the Grid Certificate

1. The Grid User should recieve an automated email from the ARCS Certificate Authority Server when the Certificate Authority Operator (CAO) issues the Grid Certificate
2. The Grid User can then do either or both of:
	
- follow the link in the email to retrieve the Grid Certificate as a downloadable file
		
1. Click on the link in the Grid Certificate issue notification email
2. Check that the certificate details are correct
3. Select **CER** format from the **Certificate** drop down menu at the bottom of the page
4. Click on the **Download** button and save the certificate in a safe and secure location
5. Locate the certificate file, right click on it and select **Install**
6. ***NOTE:** This should work for Windows 2k/XP/Vista/7, some other installation process may be required for other operating systems.
- use [Grix](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Grix&linkCreation=true&fromPageId=3816950618) to retrieve the Grid Certificate (recommended)
		
1. Open the [Grix](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Grix&linkCreation=true&fromPageId=3816950618) application
2. Select the **Certificate** tab
3. If the **Retrieve** button is active, click on it to retrieve the Grid Certificate
4. Once Grix has retrieved the certificate, click on **Export for Browser**
5. Enter the Grid Certificates passphrase when prompted
6. Locate the certificate file, right click on it and select **Install**
7. ***NOTE:** This should work for Windows 2k/XP/Vista/7, some other installation process may be required for other operating systems.

**WHAT TO DO NEXT**

Once a Grid User has been issued with a Grid Certificate they will need to use [Grix](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Grix&linkCreation=true&fromPageId=3816950618) to [apply for BeSTGRID Virtual Organisation membership](/wiki/spaces/BeSTGRID/pages/3816950526)

# Renewing a Grid Certificate

A Grid Certificate is only valid for the calender year after it is issued, and will need to be renewed near it's expiry date. A Grid User will not normally have to go through the whole Grid Certificate Request process in order to renew their certificate.

*This process has not yet been documented*

# Revoking a Grid Certificate

If a Grid User leaves a organisation that is a BeSTGRID member, even if it is to move to another member organisation, their Grid Certificate should be revoked. If a Grid Certificate and its passphrase is stolen or otherwise compromised, it must be revoked.

Grid Users may have to request a new Grid Certificate from scratch if their Grid Certificate is revoked.

*This process has not yet been documented*'


---
