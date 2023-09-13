# Sharing Rocks users with LDAP

1. Log into the head node

2. Install LDAP with:

>   sudo yum install openldap openldap-servers openldap-clients openldap-servers-overlays nss_ldap pam

3. Edit /etc/openldap/slapd.conf and make these changes:

>   backend bdb
>   database bdb
>   suffix "dc=your,dc=domain,dc=com"
>   rootdn "cn=manager,dc=your,dc=domain,dc=com"

4. Create a password with slappasswd and paste it in as a rootpw entry in slapd.conf

5. run slapdtest to check your config with:

>   sudo /usr/sbin/slaptest -u

6. start slapd and configure its start on reboot:

>   sudo chkconfig ldap on
>   sudo /etc/init.d/ldap start

7. Fix permissions

>  chown -R ldap /var/lib/ldap

8. set up migration environment variables with:

>  export LDAPHOST=head.node.external.domain.name
>  export LDAP_BASEDN="dc=your,dc=domain,dc=com"
>  export LDAP_BINDDN="cn=manager,dc=your,dc=domain,dc=com"

9. Migrate users etc. with script:

>    /usr/share/openldap/migration/migrate_all_online.sh

10. change head node authentication method with:

>  authconfig --enableldap --enableldapauth --enablemkhomedir --enablelocauthorize --ldapserver=head.node.external.domain.name --ldapbasedn='dc=your,dc=domain,dc=com' --updateall

11. change compute node authentication with (may give you grief due to quote marks):

>  sudo rocks run host command=" authconfig --enableldap --enableldapauth --enablemkhomedir --enablelocauthorize --ldapserver=head.local --ldapbasedn='dc=your,dc=domain,dc=com' --updateall"

12. edit /export/rocks/install/site-profiles/5.2/nodes/extend-compute.xml and add the command:

>  authconfig --enableldap --enableldapauth --enablemkhomedir --enablelocauthorize --ldapserver=head.local --ldapbasedn='dc=your,dc=domain,dc=com' --updateall

13. Rebuild your distribution, and (eventually) reinstall your nodes.

You will need to create users by porting ldif files into ldapadd or ldapmodify, or create them with adduser and import them into ldap separately. The internet can tell you how.

# Enable Caching (optional)

``` 

/sbin/chkconfig nscd on
/etc/init.d/nscd start
rocks run host command="/sbin/chkconfig nscd on"
rocks run host command="/etc/init.d/nscd start"

```

and add those lines to extend-compute.xml

``` 

/sbin/chkconfig nscd on
/etc/init.d/nscd start

```
