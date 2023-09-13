# Ports

This page lists the ports that an institution may need to open to allow users to make use of grid tools.

## Grisu

- direct outgoing TCP connection to port 443 (at least for hosts myproxy.arcs.org.au, grisu.vpac.org, grisu-vpac.arcs.org.au - at best, open it to the world)

## Grix

- direct connection to ports 8443 and 15001 at hosts vomrs.arcs.org.au and voms.arcs.org.au (again, at best, open to the world)

## GridFTP

- IN and OUT TCP and UDP connections to ports 40000-41000 (a range of

1001 ports)
- Outgoing TCP connections to ports 7512, 2811, 2119 (in addition to 443 and 8443)
