# EduPerson.schema

``` 

#
# eduPerson Objectclass version 1.6 (2002-10-23)
#
# See http://www.educause.edu/eduperson for background and usage
#
# eduPerson is an effort of Internet2 and EDUCAUSE
#
#
# NOTE TO OpenLDAP DIRECTORY USERS (noted 2002-10-23)
#
#	If you have difficulty using this LDIF then you should try
#	changing the "attributetypes:" to "attributetype" and
#	"objectclasses:" to "objectclass" and retry...
#
#
# When modifying objectclass eduperson -- 
#                we first must delete the objectclass
# and then re-add -- make sure all replicas are functioning.  Try to do this
# during an inactive period of services (if possible).
#
# Modifying schema may only affect the instance being modified -- 
#                     it may NOT replicate!
#
# check your server documentation to verify this.
#
# 1.3.6.1.4.1.5923 is the toplevel OID for this work
#	          .1 = MACE related work
#	          .1.1 = eduPerson
#	          .1.1.1 = attributes
#	          .1.1.2 = objectclass
#	          .1.1.3 = syntax (probably never used)
#	          .1.2 = eduOrg
#	          .1.2.1 = attributes
#	          .1.2.2 = objectclass
#	          .1.2.3 = syntax (probably never used)
#
# CHANGELOG
#
#   Jul 20, 2000	(gettes@georgetown.edu) Original version
#   Aug 17, 2000	(gettes@georgetown.edu) Added EPPNEphemeral
#			also cleanup and initial documentation
#   Jan 22, 2001        (gettes@georgetown.edu) Removed EPPNEphemeral
#                       EPPNephemeral not part of 1.0
#                       moved all OIDs below 5923.1
#   Apr 29, 2002	Added EQUALITY specs for attrs (Rob Banz)
#			(gettes) Added EPEntitlement & EPPrimaryOrgUnitDN
#			(gettes) Expanded OID space to include eduOrg
#   Oct 23, 2002        (gettes) tabs go to spaces
#			Fixed EQUALITY lines with trailing space
#
#
#  USAGE:
#
#	This LDIF file makes modifications to the cn=schema tree
#	which should modify the user portion of the schema of your
#	directory (if that concept exists).  The LDIF is constructed
#	to perform this modification in one update.  Should any portion
#	fail, then the entire update will fail and no change should be
#	made.  The first part of the LDIF is to delete any attributes
#	that may have already been defined so that they can be readded
#	in the next section. Same methodology applies to the objectclasses
#	which follows.
#
#	This file contains lines with trailing spaces so that continuation
#	of lines work properly.  Please make sure this is respected or you
#	may have difficulty in applying the LDIF.
#
dn: cn=schema
changetype: modify
#
# if you need to change the definition of an attribute, 
#            then first delete and re-add in one step
#
# if this is the first time you are adding the eduperson
# objectclass using this LDIF file, then you should comment
# out the delete attributetypes modification since this will
# fail. Alternatively, if your ldapmodify has a switch to continue
# on errors, then just use that switch -- if you're careful
#
#
# "eduPerson" attributes
#
delete: attributetypes
attributetypes: ( 1.3.6.1.4.1.5923.1.1.1.1 NAME 'eduPersonAffiliation' )
attributetypes: ( 1.3.6.1.4.1.5923.1.1.1.2 NAME 'eduPersonNickname' )
attributetypes: ( 1.3.6.1.4.1.5923.1.1.1.3 NAME 'eduPersonOrgDN' )
attributetypes: ( 1.3.6.1.4.1.5923.1.1.1.4 NAME 'eduPersonOrgUnitDN' )
attributetypes: ( 1.3.6.1.4.1.5923.1.1.1.5 NAME 'eduPersonPrimaryAffiliation' )
attributetypes: ( 1.3.6.1.4.1.5923.1.1.1.6 NAME 'eduPersonPrincipalName' )
attributetypes: ( 1.3.6.1.4.1.5923.1.1.1.7 NAME 'eduPersonEntitlement' )
attributetypes: ( 1.3.6.1.4.1.5923.1.1.1.8 NAME 'eduPersonPrimaryOrgUnitDN' )
attributetypes: ( 1.3.6.1.4.1.5923.1.1.1.9 NAME 'eduPersonScopedAffiliation' )
-
#
# re-add the attributes -- in case there is a change of definition
#
#
# "eduPerson" attributes
#
add: attributetypes
attributetypes: ( 1.3.6.1.4.1.5923.1.1.1.1 
 NAME 'eduPersonAffiliation' 
 DESC 'eduPerson per Internet2 and EDUCAUSE' 
 EQUALITY caseIgnoreMatch 
 SYNTAX '1.3.6.1.4.1.1466.115.121.1.15' )
attributetypes: ( 1.3.6.1.4.1.5923.1.1.1.2 
 NAME 'eduPersonNickname' 
 DESC 'eduPerson per Internet2 and EDUCAUSE' 
 EQUALITY caseIgnoreMatch 
 SYNTAX '1.3.6.1.4.1.1466.115.121.1.15' )
attributetypes: ( 1.3.6.1.4.1.5923.1.1.1.3 
 NAME 'eduPersonOrgDN' 
 DESC 'eduPerson per Internet2 and EDUCAUSE' 
 EQUALITY distinguishedNameMatch 
 SYNTAX '1.3.6.1.4.1.1466.115.121.1.12' SINGLE-VALUE )
attributetypes: ( 1.3.6.1.4.1.5923.1.1.1.4 
 NAME 'eduPersonOrgUnitDN' 
 DESC 'eduPerson per Internet2 and EDUCAUSE' 
 EQUALITY distinguishedNameMatch 
 SYNTAX '1.3.6.1.4.1.1466.115.121.1.12' )
attributetypes: ( 1.3.6.1.4.1.5923.1.1.1.5 
 NAME 'eduPersonPrimaryAffiliation' 
 DESC 'eduPerson per Internet2 and EDUCAUSE' 
 EQUALITY caseIgnoreMatch 
 SYNTAX '1.3.6.1.4.1.1466.115.121.1.15' SINGLE-VALUE )
attributetypes: ( 1.3.6.1.4.1.5923.1.1.1.6 
 NAME 'eduPersonPrincipalName' 
 DESC 'eduPerson per Internet2 and EDUCAUSE' 
 EQUALITY caseIgnoreMatch 
 SYNTAX '1.3.6.1.4.1.1466.115.121.1.15' SINGLE-VALUE )
attributetypes: ( 1.3.6.1.4.1.5923.1.1.1.7 
 NAME 'eduPersonEntitlement' 
 DESC 'eduPerson per Internet2 and EDUCAUSE' 
 EQUALITY caseExactIA5Match 
 SYNTAX '1.3.6.1.4.1.1466.115.121.1.26' )
attributetypes: ( 1.3.6.1.4.1.5923.1.1.1.8 
 NAME 'eduPersonPrimaryOrgUnitDN' 
 DESC 'eduPerson per Internet2 and EDUCAUSE' 
 EQUALITY distinguishedNameMatch 
 SYNTAX '1.3.6.1.4.1.1466.115.121.1.12' SINGLE-VALUE)
attributetypes: ( 1.3.6.1.4.1.5923.1.1.1.9 
 NAME 'eduPersonScopedAffiliation' 
 DESC 'eduPerson per Internet2 and EDUCAUSE' 
 EQUALITY caseIgnoreMatch 
 SYNTAX '1.3.6.1.4.1.1466.115.121.1.15' )
-
#
# eduPerson objectclass definition
# can only be done after attributes established
#
# if this is the first time you are adding the eduperson
# objectclass using this LDIF file, then you should comment
# out the delete objectclasses modification since this will
# fail. Alternatively, if your ldapmodify has a switch to continue
# on errors, then just use that switch -- if you're careful
#
delete: objectclasses
objectclasses: ( 1.3.6.1.4.1.5923.1.1.2 
 NAME 'eduPerson' 
 ) 
-
#
# now re-add the objectclass properly defined.
#
add: objectclasses
objectclasses: ( 1.3.6.1.4.1.5923.1.1.2 
 NAME 'eduPerson' 
 AUXILIARY 
 MAY ( eduPersonAffiliation $ eduPersonNickname $ 
 eduPersonOrgDN $ eduPersonOrgUnitDN $ 
 eduPersonPrimaryAffiliation $ eduPersonPrincipalName $ 
 eduPersonEntitlement $ eduPersonPrimaryOrgUnitDN $
 eduPersonScopedAffiliation
 )) 
-
#
# end of LDIF
#


```
