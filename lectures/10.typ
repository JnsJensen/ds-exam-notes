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

=== General about Object Storage
- More recent
- Not Hierarchical inherently
  - Can mimic hierarchy with how you name objects
  - Backups can take advantage of the mimicked hierarchy
- Quite a saturated market already
  - Amazon S3
  - Microsoft Azure 
  - HP Cloud Object Storage
  - etc.
- Open Source Solutions
  - OpenStack Swift (Python)
  - Ceph
  - Riak CS
  - etc.

=== Before
- Relational databases (SQL)
- NoSQL databases
- Block Storage
  - SAN
  - Oldest and simplest
  - Fixed-sized chunks
  - Block is a portion of data
  - Address: identify part of block
    - No block metadata
    - Limits scalability
  - Good performance with local app and storage
    - More latency the further apart
- File Storage
  - NAS
  - Hierarchical file system
  - Works well with _smaller files_
  - Issues when retrieving large amounts of data
    - Not scalable
  - Unique address #ra finite number of files can be stored

#report-block[
  Make sure to understand the difference between block and file storage
]

=== What is an Object
- File + Metadata

==== Example
#gridx(
  columns: 2,
  image("../img/9/os-ex.png"),
)

=== What Object Storage
- Collection of _a lot_ of objects
- Enables metadata search (kinda similar capability to a database)

=== Why Object Storage
Enables loading large amounts of data

*Benefits:*
- Big data
- Capacity
- Scalability
- Cheap

#gridx(
  columns: 2,
  image("../img/9/os-why.png"),
  image("../img/9/os-comp.png"),
)

=== What is Object Storage NOT
#gridx(
  columns: 2,
  image("../img/9/os-not.png"),
)

=== OpenStack Swift
- Can do some erasure coding #ra think about it as systematic Reed Solomon
- No master/slave coordinator/worker architecture
- One extra level: Container (bucket)
  - Container is a collection of objects
  - Container can have metadata
- Replica management similar to Hadoop
  - With a crawler/scanner that checks for consistency
  - Takes action if inconsistency is found
- Scales linearly

#gridx(
  columns: 2,
  image("../img/9/os-swift.png"),
  image("../img/9/os-swift2.png"),
  image("../img/9/os-interaction.png"),
  image("../img/9/os-objects.png"),
  image("../img/9/os-swift-arch.png"),
  image("../img/9/os-swift-arch2.png"),
  image("../img/9/os-swift-arch3.png"),
  image("../img/9/os-swift-arch4.png"),
  image("../img/9/os-swift-arch5.png"),
  image("../img/9/os-swift-arch6.png"),
)

==== Regions and Zones
- Enables handling of very different data-center topologies

*Regions:*
- Separate physical locations
- Minimum of 1 regions (~1 data center)
- A region can be defined within data centers, but is typically not used

*Zones:*
- Independent failure domains
- Minimum of 1 zone per region
- Zones are typically divisions within a data center
- Failure domains
  - Maybe physical fire walls
  - Maybe different power sources
  - Maybe different network switches
  - Maybe different racks

*Cluster:*
- A collection of regions
- Make these global for optimal reliability
- Specific regions
  - Can have different policies
  - Like different replication policies
  - Different erasure coding policies

*Differences between Hadoop and Swift:*
- Hadoop verified to the client right after receiving the data
  - Fast!
- Swift only tells client stuff is done after complete storage is finished
  - Slow!
  - But more reliable
- Hadoop only spread on two racks
  - Two racks fail #ra data is lost
  - Faster! (Than Swift)
- Swift object clusters
  - 1 replica on 3 different racks in different zones in different regions
  - Slower! (Than Hadoop)
  - Highly reliable
  - Spread out as much as possible

#gridx(
  columns: 2,
  image("../img/9/os-regions.png"),
  image("../img/9/os-zones.png"),
  image("../img/9/os-cluster.png"),
  image("../img/9/os-policies.png"),
)

=== When to use what
- Hybrid options are best!

#gridx(
  columns: 2,
  image("../img/9/os-comp-full.png"),
)

#report-block[
  Replication placement strategies still apply to object storage \
  #ra Doesn't depend on the type of storage \
  #ra Simply just strategies for how to place replicas
] 

