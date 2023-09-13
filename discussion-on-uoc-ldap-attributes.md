# Discussion on UoC LDAP attributes

# Summary: changes we'd need in the LDAP server

- Crucial:
	
- `givenName` (needed by Wikis, used in Shibboleth)

- Would be good to have:
	
- `displayName` ... so far, I can provision displayName from cn - see discussion below.
- auEduPersonLegalName
- eduPersonAffiliation: I can synthesize the value for "student", "staff", "alum", "member", "affiliate", but I can't tell "staff" from "faculty" (academic staff).  No hard use case for that yet, but could come later.  Any chance to include the "contract code" attribute in the LDAP - I could synthesize the value from that.

- Optional: these are in AD/HR system but are not badly needed:
	
- mobile
- postalAddress
- preferredLanguage
- telephoneNumber
- schacGender
- schacPersonalTitle (Ms/Dr/Prof/Rev/Sr)
- schacPersonalUniqueCode (Student# or Employee# ...)

- Let's keep an eye on these:
	
- schacUserPresenceID (Instant messaging ids,...)
- userCertificate
- userSMIMECertificate

# Core attributes

## So far NOT provided by LDAP

- displayName: See discussion below.  We badly need givenName to be added. I can provision displayName from cn (it has the right value).
- eduPersonAffiliation: I can synthesize the value for "student", "staff", "alum", "member", "affiliate", but I can't tell "staff" from "faculty" (academic staff).  No hard use case for that yet, but could come later.  Any chance to include the "contract code" attribute in the LDAP - I could synthesize the value from that.

## Provided by LDAP

- mail

## Provided at the IdP side

- auEduPersonSharedToken
- eduPersonAffiliation
- eduPersonScopedAffiliation
	
- no internal scopes defined yet, using `"@canterbury.ac.nz"`
- eduPersonTargetedID

## To be provided

- eduPersonEntitlement - can be a fs-based database.  Could be in LDAP.  No values defined yet.

# Recommended attributes

## Provided by LDAP

- cn - "An individual's common name, typically their full name"
- sn

## So far NOT provided by LDAP

- givenName
- mobile
- postalAddress
- preferredLanguage
- telephoneNumber

- schacGender
- schacPersonalTitle (Ms/Dr/Prof/Rev/Sr)
- schacPersonalUniqueCode (Student# or Employee# ...)
- schacUserPresenceID (Instant messaging ids,...)

Not likely to be used:

- userCertificate
- userSMIMECertificate

## Provided at IdP side

- eduPersonPrimaryAffiliation
- eduPersonPrincipalName
- o (Organisation, statically "University of Canterbury")

## Not yet provided

- auEduPersonAffiliation: not enough information to synthesize value
- auEduPersonIdentityLOA: good question for IdMS: how sure we are about user's identity.
- auEduPersonAuthenticationLOA: How strong password/policy.
- auEduPersonLegalName: must be somewhere in HR system

# Discussion on CN/givenName

These two may be complex for users with preferred name different from their legal name.  For Tony Dale, AD says: 

>     displayName: Tony Dale
>     cn: ajd41
>     sn: Dale
>     givenName: Anthony James Eric

I.e.,

- `cn` is the usercode (... weird, uid in LDAP)
- `displayName` is preferred name (correct)
- `givenName + sn` is legal name (though it won't work for Asian cultures)

In LDAP, cn is "Tony Dale" - i.e., the preferred name.  It officially should be the legal name, but let's leave it - and maybe just add displayNAme with the same value.  Maybe just leave it as it is, and provide the `givenName` attribute

# References

See Attribute Recommendations for AAF Participants, v1.4 at [http://www.aaf.edu.au/documentation](http://www.aaf.edu.au/documentation)
