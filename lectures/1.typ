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

=== Data Storage
==== Basic Problem
- Persistent storage
- Reliable storage: no corruption, minimise loss
- Cope with large amounts of data

==== Discs
- Exponential growth in capacity
- Linear growth in read/write speeds

Thus simply getting larger discs might not helpt, and will inversely effectively slow down the overall system - especially for HDDs where random access is slow, and having to get more data from a single drive simply overburdens it.

==== Distributed System
- Single machine won't be enough
- Interface with multiple machine
  - Coordination (Interesting challenge)
  - Programming is more complex
  - Synchronise and manage
  - Network limitations
- More points of failure
- Limitation of components
- Expect continuous failure

NFS bad quote: _"still in use, sometimes I wonder why"_ #emoji.face.rofl

#report-block[
  Was I supposed to do replication with erasure codes??
]

==== HDFS
- Get data quickly
- Analyse quickly

#report-block[
  Not expected to do low level socket programming, expected to use ZMQ or Flask or such.
]

#report-block[
  Definitely supposed to have done parallelism

  #set enum(numbering: bold-enum)
  1. *Main thread to accept connections* \
     #ra Make a new socket to handle each connection on a different socket.
  2. *Event-based reaction* \
     #ra Decent, but different \
     Wouldn't do this in Python
]