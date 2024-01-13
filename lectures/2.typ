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


#figure(
  image("../img/basic-system.png", width: 80%)
)

Abstract away the remote file system as if it were local

=== Remote Procedure Calls
- NFS os defined as a set of RPCs
- Almost 1-to-1 match with local file system commands
- RPCs are synchronous

==== Performance
- Limited by RPC overhead
  - Small packets #ra overhead dominates
  - Large packets #ra transmission time dominates

==== Characteristics
- Nearly stateless
  - Need to retry if fail #box(emoji.warning, inset: -1pt)
- *Things that are not stateless:*
  - Keeps some RPC reply cache
  - Certain file locking
  - _File handle_ - reference to the file that an action is to be applied on

=== Network File System

- _Continuous changes_ over network \
  #ra Opposite from AFS, which only applies changes once the user finishes a modification
- OS _independence_
- Simple _crash recovery_ for clients and servers
- _Transparent_ acces (abstract away that anything is remote)
- Maintain _local file system semantics_
- Reasonable _performance_

==== File Handle `fhandle`
- *`file handle`:* reference to file to act on
- *`offset`:* where to start in the file
- *`count`:* how many bytes to read
  #image("../img/file-handle-1.png")
  #image("../img/file-handle-2.png")
  #image("../img/file-handle-3.png")

More than the above.
- *`MOUNT`:* protocol takes a directory pathname and returns an `fhandle`
- UNIX-style permission checks, where this information goes through the RPC
  - Root-acces on client give root access on server? NO smh #emoji.person.facepalm

==== Idempotency
Property of certain poperations where even if applied multiple times, the end result will be the same, as if it were _only ever applied once_.
- This means you can always _retry_ without any issues.

- *`mkdir`:* not idempotent
  
==== Request-Reply
#image("../img/req-rep.png", width: 30%)

==== Client-side Caching
- Caching and write buffering to improve performance
  - *Why:* Sending command at each `ctrl+s` from the user is extreme protocol overhead. The _network_ speed shouldn't be relied on and taken for granted in that way.
  - *What:* \
    #ra _1 user:_ Temporary local buffer is good, but this fails with 2 users modifying the same file, or just one of them looking at it, the changes won't be applied. \
    #ra Once buffer is closed #ra client flushes data #ra other users can see it.
  - *Problem; stale cache* #ra this can be mitigated somewhat by sending a GETATTR to see when the file has been modified last.

==== NFS Versions
Later versions build upon *NFSv2* \
*NFSv4.1* first version to have _multiple servers_

#report-block[
  Should have used some RPC implementation. `tinyrpc`?

  I suppose I did this somewhat by sending JSON messages with message `type` and thus the _storage nodes_ were able to know how to handle and respond to each message.
]