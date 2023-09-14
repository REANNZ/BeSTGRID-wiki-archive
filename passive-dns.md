# Passive DNS

## Passive DNS

- Project Lead

[Bojan Zdrnja](mailto:b.zdrnja@auckland.ac.nz), ICT Security, ITS
- Usage

1 TB, VM

; Research

Our sensors are deployed at various networks around the world. The sensors passively parse network traffic and collect all authoritative DNS responses. All responses are sent to a central collector which stores them into a database. The information collected include the query, response, resource record type, TTL, timestamp and the sensor that collected this information. The database also stores first seen and last seen time stamps.

This allows us to do various analysis on the collected data. As the database stores all historical information about the seen DNS records, we are working on a reputation based system for certain domains and/or IP addresses, based on their history. Besides this, it is possible to correlate information received from various sensors so we can see geographical spread of DNS responses. 

Collected information can easily identify fast-flux hosts; this can help with analysis of security incidents.

; Technical Description

DNS data is captured passively by sensors at the network edge, using an architecture designed to make implementation of sensors as simple as possible. A sensor is connected to a router SPAN port in order to get complete access to all network traffic. Sensors run tcpdump, configured to write captured packets to a pcap file. Since we are only interested in DNS messages, we used the following tcpdump filter:

>  udp port 53 and ( udp[10](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=10&linkCreation=true&fromPageId=3818228746) & 0x04 != 0 )

Note that our filter only captures UDP DNS replies from authoritative sources, since we filter on their "Authoritative Answer" bit. We ignore TCP (for now) to simplify our parsing code, and because we observe relatively little TCP DNS traffic at the router. Since DNS replies always include the query data (in the Question section), there is little need to also collect DNS queries. Alas, our filter can cause some problems on certain large responses. If the DNS reply is larger than the path MTU, the UDP message will be fragmented. If that occurs, the first fragment usually contains enough information for anomaly detection.

Since our sensor is placed at the network perimeter, we see two types of DNS responses: those destined for the University's local caching resolvers, and responses leaving the University's own authoritative nameservers. The former are most interesting for our purposes here, but we did not attempt to filter out the latter from our database.

The sensors have a cron job that runs every hour. First, a new tcpdump process is launched. Then, the existing tcpdump process is killed. The pcap file containing data from the previous hour is compressed and sent to the collector.

Our database resides on the collector. The database holds only collected DNS data relevant for our research. The relevant data includes:

- Query name (name of the original query)
- Resource Record (RR) type (query type, ie A for address records)
- Resource Record data (answer returned by the authoritative DNS server)
- TTL (Time To Live) - value in seconds, set by the authoritative server, that allows the client DNS server or resolver to cache the answer
- First Seen Timestamp - timestamp showing when the sensor first saw this record
- Last Seen Timestamp - timestamp showing when the sensor last saw this record
- Sensor ID - ID of the sensor showing its geographical location

Rows in the database correspond to resource records in the Answer section of the DNS reply. We do not store records from the Authority or Additional sections. Incoming pcap files are preprocessed by a program that unpacks the DNS messages and removes any duplicate entries. Duplicates typically occur for popular names with short TTLs. Since the only timestamp in our database is the First Seen column, a duplicate answer does not update the database and can be safely discarded. After all the new pcap files have been properly parsed, the program imports the data to the database.
