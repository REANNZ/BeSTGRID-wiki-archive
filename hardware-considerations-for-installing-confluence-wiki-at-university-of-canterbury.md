# Hardware considerations for installing Confluence wiki at University of Canterbury

# Hardware Considerations

Looking at [http://confluence.atlassian.com/display/DOC/System+Requirements](http://confluence.atlassian.com/display/DOC/System+Requirements)

Server specs:

>   "Over 25 concurrent users" 512MB+ RAM, Dual 2.4GHz Xeon
>   "Over 100 concurrent users" 4GB RAM, Dual 2.4GHz Xeon

I think I'd go for 1GB, 2 virtual CPUs .... and expand if needed.

Looking at the "typical hardware" listed at [http://confluence.atlassian.com/pages/viewpage.action?pageId=76840961](http://confluence.atlassian.com/pages/viewpage.action?pageId=76840961)

I think that should be fine - and that we could also go with the default 16GB drive, even if we store the data locally.

# Database considerations

Databases supported:

>   PostgreSQL 8.1, 8.2
>   Oracle 10.1, 10.2
>   MySQL 50.0.28 and above
>   DB2 8.2
>   SQL Server 2005

Database gotchas: strongly recommended to use UTF-8 character encoding all the way through to the database: [http://confluence.atlassian.com/display/DOC/Configuring+Encoding](http://confluence.atlassian.com/display/DOC/Configuring+Encoding)

Confluence documentation links:

- [Database Configuration](http://confluence.atlassian.com/display/DOC/Database+Configuration)
- [SQL Server 2005 configuration](http://confluence.atlassian.com/display/DOC/Database+Setup+for+SQL+Server)
- [Known issues for SQL Server](http://confluence.atlassian.com/display/DOC/Known+Issues+For+SQL+Server)
- [jTDS driver FAQ](http://jtds.sourceforge.net/faq.html)

# Load balancing

Loadbalancing: Confluence supports Cluster installation but needs a cluster license to do it.  I think we won't have to do it for quite some time....
[http://confluence.atlassian.com/display/DOC/Confluence+Cluster+Installation](http://confluence.atlassian.com/display/DOC/Confluence+Cluster+Installation)

# Backups

- Confluence can be doing automatic backups, but that can eat up space and cause delays when accessing the wiki during a backup.

- See the discussion on manual backups vs. Automatic minus attachs vs. Automatic XML backups at: [http://confluence.atlassian.com/display/DOC/Site+Backup+and+Restore](http://confluence.atlassian.com/display/DOC/Site+Backup+and+Restore)

- Big decision to make: should attachments be on filesystem or in Database?

# Shibboleth login

Documented at [http://confluence.atlassian.com/display/CONFEXT/Shibboleth+Authenticator+for+Confluence](http://confluence.atlassian.com/display/CONFEXT/Shibboleth+Authenticator+for+Confluence)

- Further details at [http://confluence.atlassian.com/display/CONFEXT/How+to+Shibbolize+Confluence](http://confluence.atlassian.com/display/CONFEXT/How+to+Shibbolize+Confluence)
- Might co-exist with local accounts and LDAP.
- Should support dynamic groups in a similar way as LDAP-Dynamic-Groups

- Note: this extension is community supported, not Confluence supported.
- Confluence has their own SSO solution, [Crowd](http://www.atlassian.com/software/crowd/) - which is however based on OpenID.
