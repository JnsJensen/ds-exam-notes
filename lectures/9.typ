#import "../lib.typ": *

#show link: it => underline(emph(it))
#set math.equation(numbering: "(1)")
#set enum(full: true)
#set math.mat(delim: "[")
#set math.vec(delim: "[")

#set list(marker: text(catppuccin.latte.lavender, sym.diamond.filled))
#show heading.where(level: 1): it => text(size: 22pt, it)
#show heading.where(level: 2): it => text(size: 18pt, it)
#show heading.where(level: 3): it => {
  text(size: 14pt, mainh, pad(
    left: -0.4em,
    gridx(
      columns: (auto, 1fr),
      align: center + horizon,
      it, rule(stroke: 1pt + mainh)
    )
  ))
}
#show heading.where(level: 4): it => text(size: 12pt, secondh, it)
#show heading.where(level: 5): it => text(size: 12pt, thirdh, it)
#show heading.where(level: 6): it => text(thirdh, it)

#show emph: it => text(accent, it)

#show ref: it => {
  //let sup = it.supplement
  let el = it.element

  if el == none {
      it.citation
  }
  else {
    let eq = math.equation
    // let sup = el.supplement
    
    if el != none and el.func() == eq {
      // The reference is an equation
      let sup = if it.fields().at("supplement", default: "none") == "none" {
        [Equation]
      } else { [] }
      // [#it.has("supplement")]
      show regex("\d+"): set text(accent)
      let n = numbering(el.numbering, ..counter(eq).at(el.location()))
      [#sup #n]
    }
    else if it.citation.has("supplement") {
      if el != none and el.func() == eq {
        show regex("\d+"): set text(accent)
        let n = numbering(el.numbering, ..counter(eq).at(el.location()))
        [#el.supplement #n]
      }
      else {
        text(accent)[#it]
      }
    }
  }
}


#report-block[
  Explore allocation problems! \
  #ra Which I have done \
  #ra How the system responds to node losses \
  #ra Which I have also done
]

=== Storage Virtualisation

#image("../img/9/sv-stack.png", width: 90%)

==== Hypervisor
Enables the capability of manipulating and running several OS on the same hardware.

#gridx(
  columns: 2,
  image("../img/9/sv-without.png"),
  image("../img/9/sv-with.png")
)

==== Virtualisation Solves
- Scalability: Rapidly growing data volume
- Connectivity: Distributed data sharing
- 24/7 Availability: No single point of failure
- High Performance
- Easy Management

#gridx(
  columns: 2,
  image("../img/9/sv-virt.png")
)
- Virtualisation simplifies the management of storage resources

==== Benefits
- Hides physical storage from applications on host systems
- Presents a simplified, logical, view of storage resources to the applications
- Allows the application to reference the storage resource by its _common name_
- Actual storage could be on complex, multilayered, multipath, storage networks
- `RAID` is an early example of storage virtualisation

==== Types
*Host-Based:*
- On the host
- Through Logical Volume Manager (LVM)
- Provides a logical view of physical storage on the host

*Switch-Based:*
- Implemented on the SAN switches
- Each server is assigned a Logical Unit Number (LUN) to access storage resources
- Newer powerful switches can operate on the data themselves
- *Pros:*
  - Ease of configuration
  - Ease of management
  - Redundancy/high availability
- *Cons:*
  - Potential performance bottleneck on switch
  - Higher cost

#gridx(
  columns: 2,
  image("../img/9/sv-host-switch.png")
)
- Similar in _topology_
- Question of where the logic is implemented


=== DAS: Direct Access Storage
- Directly attached to the host
- No smarts
- Manual management
- Good enough, but not for _large scale_ systems

==== What
- Simplest scenario: one host
- `RAID` controller
  - Smarts
- Host Bus Adapter
  - Not smart
  - Translate to `RAID` controller

#image("../img/9/sv-das.png")

=== SAN: Storage Area Networks
- Deliver content
- Server access, not client access

==== What
- Specialised high speed network
- _Large_ amount of storage
- Separate storage from processing
- High capacity, availability, scalability, ease of configuration, ease of reconfiguration
- Can be _fibre based_, but now also other channels

==== Fibre Channel
- Underlying architecture of SAN
- Needs specialised hardware
- Serial interface
- Data transferred across _single piece_ of medium at _high speeds_
- No complex signaling
- SCSI over Fibre Channel (FCP)
- Immediate OS support
- _Hot pluggable:_ devices can be added or removed at will with no ill effects
- Privdes data link layer above physical layer; analogous to Ethernet
- Sophisticated error detection at frame level
- Data is checked and resent if necessary
- Up to 127 devices (vs 15 for SCSI)
- Up to 10 km of cabling (vs 3-15 ft for SCSI)
- *Combines:*
  - Networks (large address space, scalability)
  - IO channels (high speed, low latency, hardware error detection)

*Original:*
- Originally developed for fibre optics
- Copper cabling support: not renamed

*Layers:*
+ 0-2: Physical 
  - Carry physical attributes of network and transport
  - Created by higher level protocols; SCSI, TCP/IP, FICON, etc.

*Hardware:*
- Switches
- Host Bus Adapters (HBA)
- `RAID` controllers
- Cables

==== Benefits
*Scalability:*
- Fibre Channel networks allow for number of nodes to increase without loss of performance
- Simply add more switches to grow capacity
*High Performance:*
- Fibre Channel fabrics provide a switched 100 MB/s full duplex interconnect
*Storage Management:*
- SAN-attached storage allows uniform management of storage resources
*Decoupling Servers and Storage:*
- Servers can be added or removed without affecting storage
- Servers can be upgraded without affecting storage
- Storage can be upgraded without affecting servers
- Maintenance can be performed without affecting the other part

==== SAN Topologies
- Fibre Channel:
  - Point-to-point
  - Arbitrated loop; shared medium
  - Switched fabric

*Point-to-point:*
#image("../img/9/sv-fc-ptp.png", width: 60%)

*Arbitrated loop:*
#image("../img/9/sv-fc-loop.png", width: 60%)

*Switched fabric:*
- This is the most common and _"good"_ one
- Ways to combine with NAS
#image("../img/9/sv-fc-switched.png")

=== NAS: Network Attached Storage
- A lot of files with different users
- NFS, AFS fall here

==== What
- A dedicated storage device/server
- Operates in a client/server mode
- NAS is connected to the file server via LAN

#image("../img/9/sv-nas.png")

*Protocol:*
- NFS: Network File System - UNIX/Linux
- CIFS: Common Internet File System - Windows
  - Mounted on local system as a drive
- SAMBA: SMB server for UNIX/Linux
  - Essentially makes a Linux box a Windows file server

*Drawbacks:*
- Slow speed
- High latency

*Benefits:*
- *Scalability:* Good
- *Availability:* Good - Predicated on the LAN and NAS device working
- *Performance:* Poor - Limited by speed of LAN, traffic conflicts, inefficient protocols
- *Management:* Decent - Centralised management of storage resources
- *Connection:* Homogeneous vs Heterogeneous - Can be either

==== Alternative Form: iSCSI
- Internet Small Computer System Interface
- Alternate form of NAS
- Uses TCP/IP to connect to storage device
- Encapsulates native SCSI commands in TCP/IP packets
- Windows 2003 Server and Linux
- TCP/IP Offload Engine (TOE) on NICs to speed up packet encapsulation
- Cisco and IBM co-authored the standard
- Maintained by IETF
  - IP Storage (IPS) Working Group
  - RFC 3720

=== Comparison
#gridx(
  columns: 2,
  image("../img/9/sv-comp.png"),
  image("../img/9/sv-comp2.png"),
)
- FC: Fibre Channel

==== NAS vs SAN
*Traditionally:*
- NAS is used for _low volume_ access to large amount of storage by _many users_
- SAN solution for _high volume_ access to large amount of storage, serving data as streaming (typically media like audio/video)
  - Users are not editing or modifying the data

*Blurred Lines:*
- Kinda need both
- Complement each other