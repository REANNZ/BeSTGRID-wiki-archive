# Getting started on the Computational Grid

To get started using the computational grid using Grisu, one only needs to:

1. Get a grid identity (an X509 certificate or a SLCS certificate)
2. Register in a Virtual Organization (such as /nz/bestgrid) to get access to Resources
3. Start Grisu

# Get a Grid Identity

If you have an account at an institution who is a member of Tuakiri (see the [Tuakiri Subscriber List](https://tuakiri.ac.nz/confluence/display/Tuakiri/Subscriber+List)), just login to: [https://slcs1.nesi.org.nz/SLCS/login](https://slcs1.nesi.org.nz/SLCS/login) and confirm any attribute release if asked to do so.

After logging in, you should see an XML response where the second line says:

``` 
<Status>Success</Status>
```

If your institution is not Tuakiri member, you may still be able to access the computational grid by [Getting an ASGCCA grid certificate](getting-an-asgcca-grid-certificate.md)

# Register for the Grid BeSTGRID VO

Register by going to [http://bestgrid.org/join](http://bestgrid.org/join)

# Start Grisu

- Install Grisu as part of the NeSI tools as documented on the [Grid Tools page Grisu section](grid-tools.md#GridTools-Grisu)
- Start Grisu from the installed icon
- Login with either your Tuakiri login or your grid certificate
- Submit your first computational job...
