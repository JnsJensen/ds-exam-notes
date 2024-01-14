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

=== Definition of Secure
- CIA

==== CIA(A)
- *Confidentiality* \
  #ra Protect against eavesdropping (Encryption)
- *Integrity* \
  #ra Protect against tampering
- *Availability* \
  #ra Protect against denial of service
- *Authenticity* \
  #ra Protect against impersonation

=== How to make it Secure
- Security engineering
- Each system has its own security threats and thus requirements
- Identify the threats and requirements
- Design the system to meet the requirements
- Arms race

==== Swiss cheese problem
*Each layer has holes*
- Holes are not aligned
- Holes are not the same size
*Add more layers*
- Some threats are covered by many layers
- Some threats are covered by only a few layers

=== Summary
- Security has to be tailored to the concrete system
- Identify threats and associated risks before thinking of countermeasures
- Learn and use best practices
- Do not invent new cryptography
- Make sure that different security techniques are not working against each other
- Consider data lifecycle and keep backwards-compatibility open

==== Accountability
- Actions of an entity can be traced uniquely to that entity
- *Why is it important?*
  - Important nodes may be vulnerable to other attacks if discovered
  - Maybe the attacker has identified the _most important_ node