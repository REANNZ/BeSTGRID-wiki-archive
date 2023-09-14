# JMeter

[Shibboleth](/wiki/spaces/BeSTGRID/pages/3818228969)

# **JMeter** 

There are two types of servers available for Shibboleth Identity Provider (IdP) hosting. It can be hosted either on a single powerful server with multiple virtual machines (VM) or on multiple parallel servers. Therefore it is necessary to carry out a test plan to measure the performances of above options. As the result JMeter has been chosen as the tool of performance measurement.

The latest binary of JMeter can be download from here [http://jakarta.apache.org/site/downloads/downloads_jmeter.cgi](http://jakarta.apache.org/site/downloads/downloads_jmeter.cgi).

Extract it into a directory and double click the jmeter.bat in /bin directory.

Please following the steps below to complete the set-up of this performance measurement.

# General setup for the test plan

1) Add a Thread Group under the root (Test Plan)

![AddAThreadGroup.PNG](./attachments/AddAThreadGroup.PNG)
2) Specifies the variables at the root (Test Plan). 

Note: I specifies the hostname of the IdP as 'yifan-jiang.enarc.auckland.ac.nz'

![TestPlanUserDefinedVariables.PNG](./attachments/TestPlanUserDefinedVariables.PNG)
3) Specifies the load of the test plan by configures the Thread properties

![SpecifyThread.PNG](./attachments/SpecifyThread.PNG)
4) Add a Cookie Manager

![AddCookieManager.PNG](./attachments/AddCookieManager.PNG)
5) Add a Http Authorization Manager if there is a password protection.

![AuthorizationManager.PNG](./attachments/AuthorizationManager.PNG)
# SP to WAYF sub test plan set up

6) Add a HTTP Request Sampler under the Thread Group

![AddHttpRequestSampler.PNG](./attachments/AddHttpRequestSampler.PNG)
7) Specifies the HTTP Request Sampler

![SP2WAYFrequest.PNG](./attachments/SP2WAYFrequest.PNG)
8) Add a Assertion Results Listener after the HTTP Request Sampler

![AddAssertionResultsListener.PNG](./attachments/AddAssertionResultsListener.PNG)
9) Add a 'Save Responses to a file' after the Assertion Results Listener. You can choose either store all the responses or just the failed response only.

![S2w-saveRespnses.PNG](./attachments/S2w-saveRespnses.PNG)
10) It is necessary to extract the responded values from the responded page and then assign these values to their corresponding variables. XPath Extractor would be used for this purpose.

10.1) Extracting 'shire' from the responded page

![ShireExtractor.PNG](./attachments/ShireExtractor.PNG)
10.2) Extracting 'providerId' from the responded page

![ProviderIdExtractor.PNG](./attachments/ProviderIdExtractor.PNG)
10.3) Extracting 'target' from the responded page

![TargetExtractor.PNG](./attachments/TargetExtractor.PNG)
10.4) Extracting 'time' from the responded page

![TimeExtractor.PNG](./attachments/TimeExtractor.PNG)
# WAYF to IdP sub test plan set up

11) Add another HTTP Request Sampler for the steps from WAYF to IdP and specifies them as the following

![Wayf2idpRequest.PNG](./attachments/Wayf2idpRequest.PNG)
12) Add a Respond Assertion to match the responded page

![W2i-response.PNG](./attachments/W2i-response.PNG)
13) Similar to last sub test plan set up, add an 'Assertion Results Listeners' and a 'Save Responses to a file' into this sub test plan as well.

14) Extracting 'SAML' from the responded page

![Idp2spSAMLExtractor.PNG](./attachments/Idp2spSAMLExtractor.PNG)
15) Extracting 'action' from the responded page

![Idp2spActionExtractor.PNG](./attachments/Idp2spActionExtractor.PNG)
16) Extracting 'target' from the responded page

![Idp2spTargetExtractor.PNG](./attachments/Idp2spTargetExtractor.PNG)
# IdP to SP sub test plan set up

17) Add another HTTP Request Sampler for the steps from IdP to SP and specifies them as the following

![Idp2spRequest.PNG](./attachments/Idp2spRequest.PNG)
18) Add a Respond Assertion to match the responded page

![Idp2spResponse.PNG](./attachments/Idp2spResponse.PNG)
19) Add an 'Assertion Results Listeners' and a 'Save Responses to a file' into this sub test plan, similar to previous sub test plan.

# Debugging and Test Results Summary

20) It is helpful to print out the values of the variables during the debugging process. So click here [http://www.beanshell.org/download.html](http://www.beanshell.org/download.html) and download the 'bsh-commands' (e.g. bsh-commands-2.0b4.jar) into JMETER_HOME\lib. Save and restart JMeter, and then add a 'BeanShell PostProcessor' into the test plan. The script show below is an example to print out the values of all variables.

![VariablePrinter.PNG](./attachments/VariablePrinter.PNG)
21) Add a summary page to summarizes the test results

![SummaryReport.PNG](./attachments/SummaryReport.PNG)