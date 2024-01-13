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
      gap: 0em,
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

=== Andrew File System
- Does have a way to create multiple replicas, and can decide where to place them \
  #ra Mimics more something like _NFSv4.1_

*Server:* Vice \
*Client:* Venus

==== Main Goal
*Scalability*

==== Properties
- Scalable
- _Whole-file_ caching on local disk of client
  - Allow for many modifications at once, only sending large protocol messages
  - Engages the local file system
  - Less messages #ra less protocol overhead

#image("../img/afs-flow.png", width: 80%)
_Note that the local file system has to exist and be engaged._

==== Venus (Client)
#image("../img/afs-venus.png", width: 70%)
- Decisions on caching
  - what to do when cache space has run out.
- Multiple threads

==== Vice (Server)
#image("../img/afs-vice.png", width: 70%)
- Single thread
  - Serving data
  - Storing data

==== Organising Data
*Local volumes:*
- Logical unit corresponding to a directory
- _Difference to NFS:_ Allows operators to deal with logical volumes; replicating, moving, otherwise modifying
- User doesn't need to be aware where the logical volumes point

*Benefits:*
- Load-balancing
  #ra incread availability & performance
- Can be moved easily

==== Callback
*Goal:*
- Ensure cached copies of files are up-to-date when another client closes the same file after updating it.

*Callback promise:*
- Token issued by Vice
- Token stored with the cached files on local client disk
- Token is valid or cancelled \
  #ra *Valid:* Free to modify \
  #ra *Cancelled:* Do not touch #box(emoji.warning, outset: -1pt)

*Implementation:*
- RPC from Vice to Venus
  - Set token to cancelled

==== Consistency Guarantees
Two clients open one file and makes changes. Server will only be updated on close. What happens here? \
#ra Clients need to know when the Vice is updated to know that their copy is _old_ \
#ra Upon close, _promises_ to show updated data to all clients

- Weak
- Practical
- Though with some pitfalls

*Methods to provide this guarantee:*
- *Write-through Cache:* Once modified on client, it will be modified on server (on close) \
- *Callbacks:* Setting other tokens to cancelled, making other clients aware that they have to re-fetch.

#figure(
  image("../img/afs-process.png", width: 80%)
)

==== AFSv2
- Able to support 50 clients per server
- Client-side performance close to local performance - since everything basically happens in local cache

==== AFS vs NFS
#image("../img/afs-nfs.png")

=== Reliable Storage: Single Server
==== Basic Problem
- No corruption
- Minimise loss

Individual servers are unreliable, some redundancy will be needed. \
Start thinking _one machine_ with multiple disks

==== State of The Art: Replication
#image("../img/replication.png", width: 80%)
*Overhead:* 200%

- Make decisions about where to place each chunk/fragment/stripe/slice; impacts reliability
- How many slices to make: \
  #ra defines how much is lost if one fragment is impacted \
  #ra defines how big of an action is needed to recover, like moving 10/20/50 percent of total file.

*Traffic to repair:* 1 unit, 50% of file size

===== Different Options: Vanilla RAID5
#image("../img/vanilla-raid5.png", width: 50%)
- Can lose _any *one* of the shown fragments_, and still recover it.
- Need to move _the equivalent_ of the entire file, no matter how many slices.
#image("../img/vanilla-raid5-2.png", width: 50%)

===== Different Options: Vanilla RAID6
- Sustain _any *two* losses_, while only storing twice the data
- Slicing thinner gives better performance, with further linear combinations of the slices.
#image("../img/vanilla-raid6.png", width: 50%)
