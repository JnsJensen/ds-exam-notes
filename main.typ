#import "lib.typ": *

#show link: it => underline(emph(it))
#set page(numbering: "1 / 1")
#set math.equation(numbering: "(1)")
#set enum(full: true)
#set math.mat(delim: "[")
#set math.vec(delim: "[")

#set list(marker: text(catppuccin.latte.lavender, sym.diamond.filled))
#show heading.where(level: 1): it => text(size: 22pt, it)
#show heading.where(level: 2): it => text(size: 18pt, it)
// #show heading.where(level: 3): it => {
//   text(size: 14pt, mainh, pad(
//     left: -0.4em,
//     gridx(
//       columns: (auto, 1fr),
//       align: center + horizon,
//       gap: 0em,
//       it, rule(stroke: 1pt + mainh)
//     )
//   ))
// }
#show heading.where(level: 4): it => text(size: 12pt, secondh, it)
#show heading.where(level: 5): it => text(size: 12pt, thirdh, it)
#show heading.where(level: 6): it => text(thirdh, it)

#show emph: it => text(accent, it)
#show outline.entry.where(level: 2) : it => text(size: 1em, weight: "bold", it)

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

#text(size: 25pt, weight: 900, [Distributed Storage Exam Notes])
#v(-10pt)#hr

#outline(
  indent: auto,
  depth: 2,
  fill: grid(
    columns: 1,
    block(
        fill: black,
        height: 0.5pt,
        width: 100%,
    ),
    block(
        fill: none,
        height: 0.25em,
        width: 100%,
    ),
  ),
)

#let lecture-topics = (
  "01: Socket Programming",
  "02: Remote Procedure Calls & Network File System",
  "03: Andrew File System & Reliable Storage: Single Server",
  "04: RAID systems",
  "05: Reliable Storage: Finite Fields & Linear Coding",
  "06: Repair Problem & Regenerating Codes",
  "07: Reliable Storage: Regenerating Codes & Local Repairability",
  "08: Hadoop Distributed File System (HDFS)",
  "09: Storage Virtualisation",
  "10: Object Storage",
  "11: Compression & Delta Encoding",
  "12: Data Deduplication",
  "13: Fog/Edge Storage",
  "14: Security in Storage Systems"
)

#{
  for i in range(0, lecture-topics.len()) {
    pagebreak(weak: true)
    [== #lecture-topics.at(i)]
    include "lectures/" + str(i+1) + ".typ"
  }
}


