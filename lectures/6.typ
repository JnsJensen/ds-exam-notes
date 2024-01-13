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

=== Repair Problem
- See intro from last week, in terms of why and trade-offs
- Last week talked aabout erasure codes; striping with redundancy, e.g. `RAID`-like, array codes
- This week will be a bout _regenerating codes_, optimised for repair; decoding and minimising network traffic

#report-block[
  Did I say that the loss-quantification ping/pong was implemented in the Lead Node, without actually having it implemented there?
]

=== Regenerating Codes
- Stripe data with redundancy and reduce the repair bandwidth
- Minimise repair traffic with same fault tolerance as Reed Solomon

*Benefits:*
- Faster repair
- Inherent trade-off of storage and traffic-cost
- *Network coding is key:* Recoding needed at the nodes/racks before sending

_Don't need to become expert in network coding_ \
*#ra Just know:* Network itself can provide re-combinations of the coded data

==== Repair Degree
Repair degree $d$
- That is, from how many disks $d$ data is needed to repair.

==== More General Reed Solomon
#image("../img/6/reed-general.png", width: 50%)

==== Example
*Generate:*
#image("../img/6/reg-example.png", width: 50%)

*Recover:*
- Only had to move 1.5 units instead of 2
#image("../img/6/reg-example-recov.png", width: 50%)

==== How
- as $n$ and $k$ refer to internal units here and not specific nodes you can determine how thinly to slice/stripe for optimal beahviour
#image("../img/6/reg-how.png", width: 50%)

==== Graph
- Multicast flow problem
- Each node stores $alpha$ bits
- Original file has $B$ bits
- Spread is $alpha = B"/"k$ bits
#image("../img/6/reg-g1.png", width: 15%)

- Transmit $beta$ bits from each surviving node ($d$ surviving nodes)
- Total bandwith of $gamma = d beta$
- As long as there is a linear combination that brings the _correct_ properties, it is solvable
- Maintain MDS conditions
#image("../img/6/reg-g2.png", width: 50%)

#report-block[
  Kinda have to do well to make up for report weaknesses it seems like
]

*Full theorem:*
- Clear connection between the degree $d$ and other parameters
#image("../img/6/reg-full.png")
- Hard limit at some point \
  #ra $alpha approx 0.258$ for minimum bandwidth \
  #ra $alpha 0.2$ for minimum storage
#gridx(
  columns: 2,
  image("../img/6/reg-min.png"),
  image("../img/6/reg-mbr-msr.png")
)
- Assuming granularity at bit-level, that you can slice anywhere at bit-level, which might not be possible. \
  #ra Can't get exactly MBS or MSR in these cases

==== Beyond Full Node Loss
- What happens if we only lose one or several disks on a node, instead of all of it

#report-block[
  Not a weakness but the report doesn't talk about node vs inter-node disk loss
]

==== RS vs RLNC
*Example:* Reed Solomon \
Collect 15 chunks #ra decode #ra re-encode \
Centralised processing at one node
#image("../img/6/reg-ex-reed.png", width: 60%)

*Example:* Random Linear Network Co \de
Distributing the processing between nodes
#image("../img/6/reg-ex-rlnc.png")

*Benefits:*
- Less memory consumption furing recovery process
- Workload can be _distributed_ during recovery process (across racks/nodes), while *Reed Solomon* will have large workload on a single rack/node at the end
- Less delay after last packet arrives for *Random Linear Network Codes*

#image("../img/6/reg-rsvsrlnc.png")

#report-block[
  I don't fully understand how RLNC is able to cut down traffic so much? \
  #ra does it mean something about doing it in the network instead of on the nodes?

  *Answer:* \
  - Combine multiple packets of data into a single coded packet of the same size.
  - Coded packets are not useful without the coding coefficients
]

#image("../img/6/reg-benefits.png", width: 30%)
#image("../img/6/reg-comp.png", width: 80%)

==== Exact Repair
*E-MBR (Minimum bandwidth regenerating codes)* with exact repair:
- Minimise repair bandwidth while maintingin MDS property

*Idea:*
- Assume $d = n - 1$ (repair data from $n-1$ survival disks during a single-node failure)
- Make a duplicate copy for each native/code block
- To repair a failed disk, download _exactly one block per segment_ from each survival disk

*Feasibility:*
- Achieving exact repair comes at a cost
- Not really feasible
- Requires more control with a specific structure

_Needs something close to the *Genie* policy_

#report-block[
  Gives no perspective to repairability at all! \

  In general a lack of giving _perspectives_ to the rest of the course topics
]