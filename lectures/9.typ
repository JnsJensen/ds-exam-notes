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


=== SAN: Sorage Area Networks
- Deliver content

=== NAS: Network Attached Storage
- A lot of file with different users