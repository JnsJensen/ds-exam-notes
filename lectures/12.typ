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

=== Data Deduplication
- If you already have data stored that 

==== Cost of Data
- File size itself
- Cost of redundancy

*Two Questions*
- Can we reduce storage costs
- Can we reduce the cost of redundancy

==== Example
- Send and email to 100 employees with a 10MB attachment
- What is the cost of sending this email?
- $10"MB" times 100 + 100 times "rest of mail" = 1"GB" + 100 times "rest of mail"$ (without redundancy)
- $10"MB" times 3 times 100 + 100 times "rest of mail" = 3"GB" + 100 times "rest of mail"$ (with redundancy)

*Instead:*
- Store the 10MB attachment once
- $10"MB" + "overhead" + 100 times "rest of mail"$

==== Idea
- Instead of doing deduplication at file level
- Recognise bit-patterns within files and deduplicate at bit-level
- *Or at a _block level_ #sym.arrow.l This is the one used (Fixed size block, variable-sized is very uncommon and difficult)*
- Do this across all files
  - Think of it as lego, going from the finished build to the list of bricks
  - Store the list of bricks and _the instructions_
- The more data you store, the more opportunities for deduplication
- Instruction are typically an index to a table containing a pointer to the data

*Goal:*
- Eliminate storage of data with same content

==== Challenges
- Can we preserve performance?
- Can we support general file system operations?
  - Read, write, modify, delete
- Can we deploy deduplication on low-cost commodity hardware?
  - A few GB of RAM, 32/64-bit CPU, standard OS
  - Maybe a small server
  - Or you want each node to be part of computation

=== Practical Ideas
- *Deduplication in backup systems*
  - Assume no modifications
- *Deduplication file systems*
  - ZFA, OpenDedup SDFS
  - Consumes significant memory
- *VM image storage?*
  - VM images are large and have a lot of common data

==== Compare Blocks
- Don't compare every single block
- Cryptographic hashing
  - MD5, SHA-1
  - Hashing is fast
  - Probability of getting different content with same hash is _very low_
    - Combat by having larger hashes

*How often do I get matches?*
- Birthday paradox
- $N$ people, what is the probability that two people have the same birthday?
- Number of values to test to have a probability of at least one collision greater than 50%
  is $N^(1"/"2)$ for $N$ possible values \
  #ra Block size of $N = 2^n$ \
  #ra Need $2^(n"/"2)$ values to have a 50% chance of a collision \
- Above is _worst case_ with equal probabilities for each block \
  #ra typically there is _more correlation_ in data

==== When to Delete Blocks
- When no file references it
  - This requires exploring/analysing all files to find references

*Instead:*
- Keep count of how many times a block is referenced
- This should be part of the initial processing
- Decrement count for all blocks referenced by a file when it is deleted
- This count gives a notion of _importance_ of a block

==== Where to put index structure
*RAM*
- Hadoop, ZFS
- Fast, but limited by RAM size
- Per 1TB of data, around 4GB of RAM is needed
*Disk*
- Updating each data block moves the disk head
  - Impacts performance #ra Slow
*LiveDFS*
- Partial storage of fingerprints in memory
- Rest on disk
- Balance between RAM and disk
- Per 1TB of data, around 1.6GB of RAM is needed

==== Important Slides
#image("../img/12/dd-ss.png")

=== Generalised View
- Block basis + deviation
- Maximise similarities in data
- Gains start earlier
- Easier to find matches

==== Important Slides
#image("../img/12/dd-gen.png")