# Forum Presentations Video Conferencing

_*NOTOC*_

# Introduction

- KAREN Conference Dates

Monday, Tuesday and Wednesday **July 2-4, 2007**

- Important Links

- [Main Site](http://www.karen.net.nz/building-karen-communities-for-collaboration/)
- [Forum Programme](http://www.karen.net.nz/forum-programme/)
- [Main Speakers](http://www.karen.net.nz/speakers/)
- Organiser

Julie Watson: Julie.Watson@reannz.co.nz

- Overall Technical Coordinator - University of Auckland

[Paul Bonnington](http://www.math.auckland.ac.nz/~bonning/) p.bonnington@auckland.ac.nz CellPhone: +64-21-623206 (**Note** that [Paul Bonnington is in Europe June 23rd-June 30th](http://www.math.auckland.ac.nz/~bonning/?p=30) arriving back Sunday July 1 morning 9am)

>  ***Julie Watson** from 23 June to 2 July phone +64 21 674 954 or +64 4 913 1095

# Venue

- Responsibility

**Robert Hamilton** robert.hamilton@auckland.ac.nz 

NOTE: We have access to this venue from 7am on 3&4 July 2007.

Main Venue (CONFIRMED _ UPDATED) is now Conference Centre 423-342, (availible from 4pm on monday)

We have the flat floor catering space adjacent also.

A secondary theatre that easy seats 100 is located near by, (Design) and is also booked for this workshop for side meetings etc.

Break out rooms availible and booked are .. 

>  Room 421E-219 

Room (long name): ALR4 

Room Capacity: 43  

>  Room 421E-212 

Room (long name): ALR3 

Room Capacity: 81  

>  Room 421W-501 

Room (long name): ALR6 

Room Capacity: 42 

- Expected number of participants: 150 - 200. (Updated JW 23/6/07)

# Things that need to be done

## KAREN NETWORK CONNECTIVITY

**MULTICAST is not required**

Back channel has been successfully tested by Graeme, Calit2 will join Access Grid via Hitlabs unicast bridge: Completed

**JUMBO FRAMES**

Jumbo frames enabled if required : Completed

**Direct Peering to San Diego**

Direct peering has been established with Callit2 : Completed

Calit2 routes available through peering

67.58.32.0/19

KAREN routes allowed to uses Calit2 peering

130.216.0.0/16 UofA

202.37.88.0/24 UofA

210.7.40.0/24 REANNNZ

**This connection is now available for testing, please report any problems to clayton.ejiofor@reannz.co.nz**

Brian Dunne (bdunne@soe.ucsd.edu) at San Diego has designated Internal DNS server is: 67.58.44.5 and .6

## UOA NETWORK CONNECTIVITY

The lecture theater "Electurn" network infrastructure will remain as is.

There will be network connectivity provided in to the conference center for the equipment that does not form part of the lecture theater.

This will be provided by installing a 1Gb network switch in to the room.

Theses network ports will be able to access Karen and the production internet networks.

The network connections will be multi cast enabled??

The network connections will be jumbo frame enabled

The 1Gig LAN connection for Larry Smar HD Connection needs to bypass the University Firewall

**Network ports required:**

- 1-Larry Smar HD Decoder Computer [130.216.155.10](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=130.216.155.10&linkCreation=true&fromPageId=3818228801)
	
- (Inbound ports required: 5900/TCP (VNC) and 10000-10004/UDP (Qvidium Streaming viewer) & 26220/UDP (vid unicast), 37800/UDP (audio unicast), 59002/UDP (vid multicast), 59004/UDP (audio multicast) (inbound Access Grid streams))

- 2-Presenters Laptop HP tablet [130.216.155.11](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=130.216.155.11&linkCreation=true&fromPageId=3818228801)
	
- (Inbound ports required: 5900/TCP (VNC))

- 3-Portable Access GRID node [130.216.155.12](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=130.216.155.12&linkCreation=true&fromPageId=3818228801)
	
- (Inbound ports required: 26220/UDP (vid unicast), 37800/UDP (audio unicast), 59002/UDP (vid multicast), 59004/UDP (audio multicast) (inbound Access Grid streams))

- 4-Nathans LifeSize Unit [130.216.155.13](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=130.216.155.13&linkCreation=true&fromPageId=3818228801)
	
- (Inbound ports required: 1720/TCP, 5060/UDP, 60000-64999/TCP&UDP)

- 5-Presenters Laptop [DHCP or 130.216.155.14](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=DHCP%20or%20130.216.155.14&linkCreation=true&fromPageId=3818228801)
	
- Nathan (Inbound ports required: 1720/TCP&UDP, 5000-5020/TCP&UDP, 5090/TCP&UDP)

- 6-AGVCR Access GRID node [130.216.155.15](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=130.216.155.15&linkCreation=true&fromPageId=3818228801)
	
- (Inbound ports required: 5900/TCP (VNC) & 26220/UDP (vid unicast), 37800/UDP (audio unicast), 59002/UDP (vid multicast), 59004/UDP (audio multicast) (inbound Access Grid streams))

- 7-Graeme's laptop (just in case) [130.216.155.16](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=130.216.155.16&linkCreation=true&fromPageId=3818228801)
	
- (Inbound ports required: 10000-10004/UDP (Qvidium Streaming viewer) & 26220/UDP (vid unicast), 37800/UDP (audio unicast), 59002/UDP (vid multicast), 59004/UDP (audio multicast) (inbound Access Grid streams))

- 8-Spare

As well ICMP echo requests need to get through and 233 multicast GLOP addresses.

Engineering VLAN

- 1-Miniature shaking table with a controlling PC for Quincy Ma
- 2-Webcam for shaking table
- 3-Normal UoA network connection for Quincy Ma laptop

**Actions:**

Install 3750 in conference centre next to where the equipment will be placed. JohnD

Connect 3750 Switch in conference center to communications room.JohnD

Connect fiber from 58 Symonds St to conference center communications room.JohnD

Connect fiber to Firewall. JohnD

Connect firewall to BR2.JohnD

**Testing**

Test that the network ports can access the Karen and production

Test that the network ports can access the Intranet.

Confirm that the EVO PANDA server is reachable

Confirm that local resources are available.

## UOA WIRELESS CONNECTIVITY

There will be wireless available in the conference room and also the foyer area in front of the conference room.

User names and passwords will provided for delegates to access the wireless network.

As agreed there is no requirement for wireless in the breakout areas.

**Actions:**

Network team to install and test wireless, confirming all is operational by COB Tuesday 26th. JohnD

Reannz team to provide number of attendees for wireless user names and passwords. JulieW COMPLETED

UoA has supplied REANNZ with guest UIPs and passwords: COMPLETED

Network team to provide wireless instructions by the 29th. COMPLETED

## Backchannel

- Responsibility

**Graeme Glen** g.glen@auckland.ac.nz

**Backchannel will be on Access Grid via Hitlabs unicast bridge: Completed and tested**

Unicast Bridge IP:- 202.36.178.14 video port: 26220 and audio port: 37800

Calit2 IP:-

Analogue line backup - Rob Beattie

Conference room: x82511

Conference room (special): +64 9 3737599 x83507

Calit2 Phone number:-

## Broadcasting Talks on the AccessGRID: We need to obtain the consent from the presenters

- Responsibility

**Julie Watson** Julie.Watson@reannz.co.nz Email sent and responses being filed.

## Broadcasting Talks on the AccessGRID: Need to book the other New Zealand nodes 

- Responsibility

**Sam Searle** sam.searle@mcs.vuw.ac.nz

COMPLETE (19-06-07): Access Grid sessions are booked and all AG node operators have been notified. [these bookings will not show in the public Google Calendar until 20-06-07.](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=Note&title=these%20bookings%20will%20not%20show%20in%20the%20public%20Google%20Calendar%20until%2020-06-07.)

Vicki Lindsay, REANNZ has emailed instructions and additional information to Node operators, plus has advertised AccessGrid option.

## Supply min 2 wireless handheld mics for main theatre (for audience questions), along with Lectern and Clipon mics *Config to change to 4 or more handhelds for panel discussions

Will supply 

- Responsibility

**Robert Hamilton** robert.hamilton@auckland.ac.nz

## Supply full auditorium audio mix to Portable AccessGRID unit (large mono phono jack)

- Responsibility

**Robert Hamilton** robert.hamilton@auckland.ac.nz

## Supply composite video (BNC connector) of presentation laptop to Portable AccessGRID unit

- Responsibility

**Robert Hamilton** robert.hamilton@auckland.ac.nz

## Setup Computers to receive and display HDV or DVCPro-HD video from Larry Smar

- Responsibility

**Graeme Glen** g.glen@auckland.ac.nz

- Workstation computer with Dual-DVI Nvidia Outputs directly to Lecture theatre projectors.
- Sound feed back into the main auditorium sound system
- Funding for new any computers to come from BeSTGRID
- Software codecs required from San Diego

**Completed. Graeme's laptop to be used as backup.**

## Organise Stand and 3 Plasma Screens Front left of main theatre

- Responsibility

**Robert Hamilton** robert.hamilton@auckland.ac.nz
- Responsibility

**Graeme Glen** g.glen@auckland.ac.nz
- Responsibility

**Clayton Ejiofor** clayton.ejiofor@reannz.co.nz

- Required to display remote sites from AccessGRID
- Plasma Screens used for KAREN launch. Held by Graeme Glen
- Stands hired from Future Tech: Clayton to order for Panasonic screens; drop off 4pm Monday 2 July and collect either after 4.30pm Wedensday 4 July or 5 July. Invoice directly to REANNZ

**Stands hired, maps of venue supplied. Future Tech will mount plasmas on stands. - Completed**

# Technical requirements requested by speakers

## Paul Bonnington and Nick Jones

Using BestGRID laptop

## Nathan Gardiner's Presentation Requirements

Nathan will be bring up with him a demo unit of LifeSize Team High Definition system so he can linkup back to HIT Lab at University of Canterbury. Items that are needed to run this are:

- Projector with Component Input or VGA (preferably can handle 720p - if not Nathan can bring one up)
- An audio system to plug the sound into so that people can hear
- Will need to have the LifeSize Phone on or near the lectern when presenting (circular device which comes with LifeSize kit)
- Somewhere to place the LifeSize Camera so it can be pointed at the lectern
- KAREN connection to plug into LifeSize Unit
- KAREN connection to plug into Nathan's laptop

- 
- 
- 
- Also if REANNZ are wanting to keep the High Def feed linked up throughout the conference, after Nathan's presentation we can move it to an area where we could link it up to an LCD TV or Plasma so people can interact with it during breaks etc. We could just keep the connection alive down to the HIT Lab or to the REANNZ office in Wellington etc.

- 
- 
- **This depends on whether all 3 plasms are mounted in auditorium, we will not be able to move a mounted plasma to enable the VC to continue -*Rob to eyeball venue**

In order to do this, we would need

- An LCD TV of Plasma (preferably larger than 40" and with speakers)
- KAREN connection

**Table for monitor, camera and LifeSize phone to sit on - *Rob to look at table real estate issue**

## Nathan Gardiners 9pm Lifesize VC with UK

This will not be allowed to interupt the setting up of the conference venue. **Graeme to confirm / infrom Nathan of this**

## Quincy Ma's demonstration requirements

Quincy would like to show a small scale building model remotely controlled over the internet, so he will require the laptop to have network access. In addition, he’ll provide the other computers required to make it work. Will contact Rob Beattie directly.

Quincy

Lecturer

Dept. of Civil and Environmental Engineering

University of Auckland, New Zealand

q.ma@auckland.ac.nz 

+64 9 373 7599 x 88766

## Daniel Patrick's presentation

Powerpoint only

## Ron Johnson

Ron will be using PowerPoint either directly from his laptop or will transfer the presentation from a USB key.

## George McLaughlin's requirements

- Responsibility

Julie Watson to email George to remind him to provide presentation for testing: 

George wants to show about 3 minutes of a telesurgery training demo during his presentation.  When he tried to do this at GridAsia, he wasn't able to get video from both his Powerpoint presentation, and the streaming video.  

He is not sure if this was the local environment or a conflict in his laptop (it worked fiine until he hooked up the projector>  So might be worth having another machine to run the video, and he'll run the powerpoint from his laptop.  Or test beforehand from the single machine.  

Or he can send both the PPT and the presentation through beforehand and the technical team can work out what's best.

Presentation expected on Wednesay 27 July. Also George will be able to help with testing on Monday 2 July - if necessary.

## Rhys Francis

BestGRID Laptop and USB key

## Paul Arthur

Will use BestGRID laptop

## Rick Stevens

Technical requirements to come

## Donald Clark is Chair on day one

Laptop only

## Jacqueline Brown is Chair on Day Two

Laptop only

## Nick Tate

Wants to connect his own laptop to sound system

# STREAM ONE Bldg 423 Room: Design

## Jim Mullins' presentation 10.15am 4 July

Jim would like to use Keynote 3 instead of powerpoint, so will bring his own MAC laptop

## Chris Brown

Using lecturn laptop

## Robert Moritz

Technical details to come

## Neil Gemmell

Using lecturn laptop

## Keith Crandall tbc

# STREAM TWO Bldg 423 Room 342

## Laurin Herr

Laurin wants to use Powerpoint for his CineGrid presentation, played from his Mac laptop into our projector via VGA connector.

He is also happy to assist in the preparations for Larry Smarr’s HD-over-IP presentation from UCSD/Calit2 since he has worked with him and Tom DeFanti on this sort of thing before. Please let him know if you have any questions before he arrives in Auckland ... Early in the morning of Monday July 2nd.

Email

Laurin Herr [unnamed link](https://reannz.atlassian.net/wiki/404?key%3Dpacific-interface.com%3Bsearch%3Fq%3Dlaurin)

## Panel Discussion

Wireless microphones x4

Seating for five people

## Lunchtime discussions

Nothng extra needed

## Feedback from Discussions

Wireless microphones x2

## Paul Bonnington and Nick Jones

BestGRID laptop

## Ian Foster

BestGRID laptop

# Larry Smarr's Presentation from University of California San Diego

- Responsibility

**Graeme Glen** g.glen@auckland.ac.nz (University of Auckland)
- Responsibility

**Tom DeFanti** tdefanti@ucsd.edu (UCSD)

Given the bandwidth restrictions, we have **two** options for "Larryality" to NZ depending on bandwidth available:

- DVCPro-HD (the Calit2/EVL/Irvine system)

Requires 100Mb/s, Latency to Calit2 is 170-180ms. Resolution (1400x720p) of good conference projectors. Can do software decode on the NZ end, assuming there's a POTS or H.323 link back to Calit2. Use AG for backchannel. (Decoder Software required sourced from Tom DeFanti)

- HDV

Also HD (1400x720) using software, 25Mb/s, (Decoder: Use VLC or other sourced from Tom DeFanti)

- We should attempt to have both of the options available so we have backup. The software can coexist on one computer, but a spare computer should be ready.

## Peering with CAlit2, San Diego

; Responsibility

**Brian Dunne** bdunne@soe.ucsd.edu (UCSD)

- Responsibility

**Clayton Ejiofor** clayton.ejiofor@reannz.co.nz : Completed

**Peering has been established, testing required**

## Decoders

- Responsibility

**Graeme Glen** g.glen@auckland.ac.nz (University of Auckland)
- Responsibility

**Qian Liu** qianliu@soe.ucsd.edu (UCSD)

Qvidium decoder software for both the Sony HDV (25Mb/s) and the Panasonic DVCPro-HD (100Mb/s) camera streams. 

VLC is also a possibility for HDV.

## Local Equipment and Projectors

Graeme Writes: I assume we can just use something like VLC here?  I guess we will need to project for ~100 people, do we have any 720p projectors (if you want wide screen HD)? A couple of machines, one for the HD stream (A/V) and one for backchannel?

## Timing

This has been confirmed for 02:00:00 p.m. Monday July 2, 2007 in US/Pacific which converts to 09:00:00 a.m. Tuesday July 3, 2007 in New Zealand.

Regarding advance tech checks, it kind of depends on the NZ side

schedule (and if UW is bringing equipment).  The hardest part is

getting an end-to-end network connection at the chosen speed that is not

dropping packets due to non-jumbo enabled routers or firewalls or

whatever other gremlins are in the middle. We should start on that NOW,

testing as close to the lecture site in Auckland as possible, extending

to the lecture site as soon as possible.  If you can get into the

lecture site the week ahead, it would be most excellent to rehearse,

say by Saturday June 30 (Friday June 29 here).  Again, we could rehearse on

Sunday/Monday there, but that's cutting it close given that the

engineers in NOCs along the way often aren't available on weekends

much.

I'd prefer to start tech rehearsals even earlier than Saturday June 30

there.  Remember to set up a POTs line (or a cell phone, I suppose

would be fine too).

# Broadcasting the presentations on the AccessGRID

- Responsibility

**Andrey Kharuk** a.kharuk@auckland.ac.nz
- Are these going to be 'recorded'?

Yes, it will be recorded with AGVCR. After conversion we can make streams available on the web. Roger, Graham and Paul to decide who does the recording.

- Is this going to be 'live' or 'delayed'? If live, 'view-only' or are we expecting interaction from the various sites?

Yes, it will be live, and we are expecting interaction from various sites.

- If recorded/delayed, will these be available permanently or only for a limited time?

We will aim to make it available permanently, but only to KAREN members.

## NOTE CONCERNS ABOUT AUDIO QUALITY

Julie is concerned about the management of live interactions with audio quality, availability of node operators and 'unknown' nodes.

Possible soultion could be VIEW ONLY and typing in questions to Auckland-based node operator to pass on to speaker. During break can be set up as an interactive area.

## Presentations

We will offer the presentations simulaneously in three ways:

High quality: VNC will be used to broadcast full-resolution shared desktop of presentations from the presentation laptop in the main lecture room. The IP number and port of this VNC server will be advised shortly. AccessGRID nodes can run a VNC client pointed to presentation laptop, and 'see exactly' what is on the laptop. 

Streamed Video: the presentations will also show up as just another regular video stream on the AccessGRID, and it comes direct from the video-output of the laptop. This is good for any video segments in the presentation. This is not full quality, but requires no additional effort from the node operators.

Camera Feed: the presentations will also be broadcast as a camera feed pointed to the projector screen in the auditorium. This also captures the Speaker 'pointing to' various parts on the slides. This is also good for any video segments in the presentation. 

Remote sites should probably aim to 'project' in their room two or all three of the above presentation formats.

# Capability Build Panel Meeting and Cocktail Party on Monday July 2nd

- We have Room 279 in Blg 303S from 11am - 4pm – demonstrations, lunch and meeting

- And for the cocktail party Room 561 Blg 303S from 4 - 6pm: nice room with great view overlooking Albert Park.

Maps are here:

Building 303S

>  [http://www.cs.auckland.ac.nz/locations/](http://www.cs.auckland.ac.nz/locations/)

# Signage for footpath

Vicki and Julie need to work out some kind of signage to direct people from footpath on Symmonds Street to the Conference Centre.

# Emails for presenters

## From US 

- Jim Mullins jmullins@u.washington.edu [http://ubik.microbiol.washington.edu/People/Mullins.html](http://ubik.microbiol.washington.edu/People/Mullins.html)
- Ian Foster itf@mcs.anl.gov
- Rick Stevens [unnamed link](https://reannz.atlassian.net/wiki/404?key%3Dmcs.anl.gov%3Bsearch%3Fq%3Dstevens) Argonne National Laboratory, [http://www-fp.mcs.anl.gov/~Stevens/](http://www-fp.mcs.anl.gov/~Stevens/)
- Ron Johnson, Vice Provost, Information Systems University of Washington c/-  luler@u.washington.edu
- Laurin Herr, Director CineGRID
- Larry Smarr, Director Calit2 by video conference
- John Silvester, silvester@usc.edu, Professor of Computer Engineering, University of Southern California
- Jacqueline Brown, jbrown@u.washington.edu, Executive Director International Partnerships, Northwest Pacific Gigapop and Univerity of Washington

## From Australia 

- George McLaughlin [unnamed link](https://reannz.atlassian.net/wiki/404?key%3Dmclaughlin.net%3Bsearch%3Fq%3Dgeorge)
- Rhys Francis Rhys.Francis@csiro.au, NCRIS Facilitator for Platforms for Collaboration
- Nick Tate, Director, ITS and AusCERT, The University of Queensland, n.tate@its.uq.edu.au
- Paul Arthur, Curtin University of Technology,[unnamed link](https://reannz.atlassian.net/wiki/404?key%3Dhotmail.com%3Bsearch%3Fq%3Dresearchdevelopment)

## From New Zealand 

- Allen Rodrigo [unnamed link](https://reannz.atlassian.net/wiki/404?key%3Dauckland.ac.nz%3Bsearch%3Fq%3Da.rodrigo)
- John Hine, Professor Computer Science, Victoria, hine@mcs.vuw.ac.nz
- David Thorn, david.thorns@canterbury.ac.nz
- Donald Clark, CEO REANNZ, donald.clark@reannz.co.nz
- Nick Jones, BeSTGRID, n.jones@auckland.ac.nz
- Neil Gemmell, Canterbury University, neil.gemmell@canterbury.ac.nz
- Neil James, Otago University, neil.james@stonebow.otago.ac.nz
- Quincy Ma, Auckland University,q.ma@auckland.ac.nz
- Daniel Patrick, Auckland University,d.patrick@auckland.ac.nz
- Nathan Garinder, HitLab, nathan.gardiner@hitlabnz.org
- Chris Brown, Otago University, Chris Brown [unnamed link](https://reannz.atlassian.net/wiki/404?key%3Dotago.ac.nz%3Bsearch%3Fq%3Dchris.brown)
- Russell Butson, Otago University, russell.butson@otago.ac.nz
