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

=== General
- Use ideas from previous weeks

==== Purpose
- Process _big data_ with reasonable _cost and time_
- Large scale processing on data not stored on a single computer

==== Idea
- Distribute the data as it is initially stored.
- _Each node_ can then perform computation on the data it stores without mocing the data for the intial processing.
- *Don't* move data to the computation
- *Do* move the computation to where the data is

==== Examples
- Google File System
- MapReduce: Simplified Data Processing on Large Clusters

==== History
Used to be #ra is like this now
- Low data volume #ra High data volume
- Big complex computations #ra Many simpler computations

_Improvements to the individual machine #ra able to perform the processing itself._
- Moore's law

=== Hadoop File system
- Storing data on the cluster
- For _large_ files
- Files _split into blocks_ of certain size #ra distribute across nodes in cluster
  - Similar concept as we saw in `RAID`
- Each _block is replicated_ multiple times
- Main goal to _optimise for speed_
- Has some _reliability_, but not a main goal

- Unlikely to be built with SSDs #ra too expensive

#report-block[
  OH?! The storage system I have implemented is a simple HDFS??
]

==== NFS vs HDFS
NFS < v4.1 - before multiple servers
#image("../img/8/hdfs-vs-nfs.png", width: 70%)

==== Basic concepts
- Redundant storage for MASSIVE amounts of data
- HDFS works best with a _small number_ of _large files_
  - Millions as opposed to billions of iles
  - Typically 100MB or more per file
  - Terabytes or Petabytes of data
- Files in HDFS are write once!
- Optimised for streaming reads of large files and not random reads
  #ra operate disks at absolute top speed

*More*
- _Very large_ distributed file system
  - 10k nodes, 100 million files, 10PB
- Don't assume _specific_ hardware: Assumes commodity hardware
  - Files are _replicated_ to handle hardware failure
- *Optimised for batch processing*
  - Data locations exposed so that _computations can move to where data resides_
  - Provides very _high aggregate bandwidth_

*More more*
- Tolerate node failure without data loss
  - _Detect failures and recover from them_
- Data coherency
  - Write-once #ra read-many access model
  - Client can _only_ append to existing files
- _Computation is near the data_
- Portability; built using Java

*Summary*
#image("../img/8/hdfs-basics.png", width: 50%)
- Built for large scale processing, not quick access
#image("../img/8/hdfs-diag.png", width: 60%)

==== Blocks
*Large blocks*
- Size of either 64MB or 128MB
- Minimise seek costs
- *Benefit:* can take advantage of any disks in the cluster
- Simplified the storage subsystem: amount of metadata storage per file is reduced
- Good for replication schemes

==== Master/worker pattern
*Name/Coordinator Node*
- Manage filesystem metadata
- Where are chunks corresponding to a file
- Configuration
- Replication engine

*Data/Worker nodes:*
- Workhorse of the file system: store and retrieve
- Stores metadata of a block (e.g. CRC checksums)
- Serves data and metadata to clients

*Data/Worker nodes:*
- Two files:
  + Data
  + Metadata: checksums, generation stamp (timestamp?)
- Startup handshake
- After handshake

*Namenode metadata* \
_In memory_
- List of files
- List of blocks for each file
- List of datanodes for each block
- File attributes, e.g. creation time, replication factor
- Transaction log

#report-block[
  Well it looks like it is a very very abstract and simple implementation of HDFS if anything.

  Some things line up:
  - Replication schemes
  - Master/worker pattern
  - Coordinator keeps track of metadata
]

==== Resiliancy
Have secondary coordinator/name-node

==== HDFS Client
- Code library that exports the HDFS interface
- Allows user application to access the file system
- *Intelligent client*
  - Client can find location of blocks
  - Client accesses data directly from worker/data-nodes

==== Read Operation
#image("../img/8/hdfs-read.png",  width: 70%)

#report-block[
  *Difference to my implementation:* \
  _Clearly_ my client does not simply use the Name/coordinator-node to access metadata and then connect to data/worker-nodes itself.

  
  Make sure to understand whether what I have done is _RPCs_ or not \
  #ra Maybe it's a simplified custom way of doing RPCs

  *Remember:* \
  It said nowhere on the project description that it should be a HDFS implementation
]

==== Write Operation
- Once written, cannot be altered, _only append_
- HDFS Client: lease for the file
  - Renewal of lease
  - Lease: _soft_ limit or _hard_ limit
- Single-writer, multiple-reader model

#image("../img/8/hdfs-write.png", width: 70%)
- Bring traffic down by letting the nodes talk to each other
- Circumvents network limitation on client side, as instead of talking to multiple nodes, it just sends once, thus _handing off_ the network load to the nodes

#report-block[
  My data nodes do not talk to each other at all \
  #ra All happens from the coordinator to the data nodes
]

==== Replication
- Multiple nodes for reliability
  - Aditionally, data transfer brandwidth is multiplied
- Computation is near data
- Replication factor, default: $k=3$

*Block placement:*
- After placement you have a certain structure, and knowdledge thereof
- Place intentionally to be robust and reliable
  - Spread across multiple racks
  - Nodes of rack share switch
- Balance with speed

*Balancer:*
- Balasnce disk space usage
- Optimise by minimising inter-rack copying

*Strategy:*
- *Current Strategy*
  - One replica on local node
  - Second replica on remote rack
  - Third replica on same remote rack
  - Additional replicas are randomly placed
- Clients read from nearest replicas
- Would like to make this policy _pluggable_?
  - Something you can edit and change.

==== Data Pipelining
- Client retrieves list of data/worker-nodes on which to place replicas of a block
- Client writes block to the first data/worker-node
  - This node handles handing over to the next node
- When all replicas are written, the client moves on to write the next block in file

==== Balancer
*Goal:*
- Percentage full on data/worker-nodes should be _balanced_

*Interesting when:*
- New nodes are added
- Rebalancing? Maybe when new nodes are added or simply slowly balance by using that node more.
- Rebalancer gets throttles when more network bandwidth is needed elsewhere
- Typically a command line tool run by and operator

==== Block Scanner
- Periodically scan and verify checksums
- *Check for:*
  - Verfication succeeded?
  - Corrupt block?
- Verfication of data correctness

*Checksums*
- Computs CRC32 for ever 512 bytes
- Make sure nothing is missing
- Data/worker nodes store checksums
- *File Access:*
  - Client retrieves the data and checksums from the data/worker-node
  - If _validation fails_ #ra client tries other replicas

#report-block[
  No checksums, data correctness is in my system
]

==== Heartbeat
- Data/worker-nodes sends heartbeat to name/coordinator-node
  - once every 3 seconds
- Name/coordinator-node uses heartbets to detect whether a node has failure

==== Beyond One Node Failure
*A lot of failures:*
- Full racks
- Fire
- Power outages

_{HDFS, GFS, Windows Azure, RAMCloud} uses random placement_ \
#ra Random not so good no no no

=== Copysets & Random Replica Placement
#report-block[
  Yay finally something in the report, I must already know this.

  But here are notes on what I missed or maybe _misinterpreted_ from the slides:
]

==== 1% of nodes fail concurrently:
- Chance of data loss doens't mean that percentage of data is lost
- It is a percentage of the probability of data loss, so at least 1 chunk lost
#gridx(
  columns: 2,
  image("../img/8/t-trade.png"),
  image("../img/8/g-recov-buddy.png"),
  image("../img/8/g-buddy.png")
)
==== Random
- Basically every failure is a loss
Probability of a given chunk is lost:
$
  mat(delim: "(", F; R) / mat(delim: "(", N; R)
$
Where $F$ nodes out of $N$ have been lost, with replication factor $R$

==== Minimum Copysets
- Only loss if all nodes in specific copyset dies
- Once you lose something, you will lose _a lot_ \
  #ra Less nodes left to recover (only the last nodes left in the copyset, instead of from many random nodes) \
  #ra Thus much longer recovery time
#report-block[
  Scatter-width? \
  #ra Daniel didn't mention in the lecture
]

==== Buddy
- Combining random with the idea of creating separate groups
  - Isolated random replication groups
  - A copyset is always within one buddy group
  - However, placed randomly within the group


=== MapReduce
- Fast overview

==== Overview
- Distribute computation across nodes

==== Features
- Automatic parallelisation and distribution \
  #ra Bad for little data, good for massive data
- Provides a clean abstraction for programmers to use
  
*Fault Tolerance:*
- System detects laggard tasks
- Speculatively executes parallel tasks on the same slice of data

==== Phases
+ Map
+ (Shuffle & Sort)
+ Reduce

*Mapper:*
+ *Input:* Data _key/value pairs_
  - The key is often discarded
+ *Outputs:* _zero or more_ key/value pairs
  - For every key identify what the value is

*Shuffle & Sort:*
+ Output from the mapper is _sorted by key_

_All values with the *same key* are guaranteed to go to the *same machine*_ \
#ra Hadoop overhead here?

*Reduce:*
+ Called once for each unique key
+ *Input:* List of all values associated with a key
+ *Outputs:* Zero or more final key/value pairs
  - Usually reduced to 1 output per unique key input

*Example:*  Count words of same type
#image("../img/8/map-reduce.png")
- Already at the splitting stage when stuff has been chunked and split into nodes.
- What the mapping and reduction does is defined base on what function you want to compute.
- In this case the mapping could actually also reduce the data by counting each value up, if a key is repeated.

Steps:
+ *Mapping:* Take each word and write it's value of 1 such that you can count them in reduction stage.
+ *Shuffle:* Move data around such that data for a single key is in a single node.
+ *Reduction:* Here reduce over each key bu summing values.

#report-block[
  This definitely looks like something I should have thought about in the report:

  #image("../img/8/compute-time.png")
]