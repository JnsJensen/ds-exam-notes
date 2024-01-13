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

=== Exact Repair & Regenerating Codes
- Introduction to this from last week

*Functional repair vs exact repair*

==== What
*Exact:* You get exactly what you lost \
- Reed Solomon
- `RAID` systems
*Functional:* Can be used for the same purpose, but aren't exactly the same values (like multiplcations of data?) \
- Regenerating codes (RLNC)

==== How to do Exact Repair with RLNC
_MBR and MSR points are predicated on *functional repair*_ \
RLNC can still be exact repair, but that restricts it in many ways, making it less efficient.
- Fx. E-MBR
  - Duplicate each native block. Native and duplicate blocks are in different disks

#image("../img/7/reg-embr.png", width: 30%)
*If* $D_2$ had was lost, it can be rapaired easily #sym.arrow.t

- Fx. Exact repair with known storage structure (kinda MSR)
#image("../img/7/reg-emsr.png", width: 60%)

=== Local Repairability
- XORBAS
- Locality in terms of within same coding?
- Placement is important
#image("../img/7/lr-theorems.png", width: 45%)

==== Example
We want to have locality
#image("../img/7/lr-ex.png", width: 70%)
- If you keep all involved in one code, $x_1,y_1,S_1$ on the same node, then you will lose that data entirely.
  - Sparse combinations and its parents _have_ to be stored on different nodes
- With simple clever placement, you can avoid this issue
- Can sustain 2 full node losses, without losing data
  - Due to sparse extra combinations

#report-block[
  Require better intuition about MDS codes
]

*How to repair* \
#image("../img/7/lr-ex2.png", width: 70%)
- Achieves the optimal performance from theorem 1 & 2 above #sym.arrow.t

#report-block[
  He likes the problem from the Facebook setup. \
  #ra The _big picture_ view

  #image("../img/facebook.png")
  _Motivation #sym.arrow.t _ #ra Make sure that network traffic doesn't exceed a certain level
]

==== How Good
- *Reed Solomon 10:4:* 3x storage #ra 2.865x storage = 5% improvement
- *XORBAS 10:6:* 3x storage #ra 2.65x storage = 13% improvement (25% erasure coded)
  - Still paying a hefty cost in traffic

#image("../img/7/lr-graph.png", width: 100%)

==== Hybrid Replication & Coding
- Not good from an erasure coding perspective
- Quite restricted
  - Lost 8, 9, 10 #ra doomed
- Not nearly as flexible as RS and MDS
- Compromising structure
- _Not_ erasure coded

#gridx(
  columns: 2,
  image("../img/7/lr-hybrid.png"),
  image("../img/7/lr-hybrid-2.png"),
  image("../img/7/lr-hybrid-3.png"),
  image("../img/7/lr-hybrid-graph.png"),
)