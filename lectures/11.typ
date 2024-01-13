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

=== Basic Compression
- Reduction of the size of the data
- Alias: Source Encoding

==== Idea
- Represent frequent repetitions of information with a shorter representation
- Can think of some information as occurring with some probability

Information of an event given that it has a probability of $p$ is

$ I = log_2 (1/p) = -log_2(p) $
- *Provides nice properties:*
  - Information of independent events is additive, but probabilities are multiplicative
  $ I_A + I_B = -log_2(p_A) - log_2(p_B) = -log_2(p_A p_B) $

==== Shannon Entropy
- Average information of a random variable
$
  E[I] = H(p_1, p_2, ..., p_n) = sum p_i log_2(1/p_i)
$
- *Another way to about it:* \
  #ra Expected uncertainty associated with this set of events
    - $H$ is non-negative
    - $H <= log_2(N)$, where $N$ is the number of events (equality if all events are equally likely)
- Most compression with low entropy (high certainty, highly predictable)

==== Types of Compression
*Lossless:*
- No information is lost
- Can be reversed exactly
- Typically used for text, programs, data
- Achieves lower compression ratios

*Lossy:*
- Some information is lost
- Cannot be reversed exactly
- Typically used for images, audio, video
- Achieves higher compression ratios

==== Entropy
- Expected amount of information in a message
- Lower bound on the amount of information that must be sent
- *Computable*
  - If you know the probability of each symbol

=== Compression Schemes

==== Shannon-Fano & Huffman Coding
#image("../img/9/comp-huff.png")

==== LZW: Lempel-Ziv-Welch
- ZIP based on LZW
- Automatically discovers inter-symbol relations
- Builds the code-book on the fly

#image("../img/9/comp-lzw.png")

==== `JPEG`
- Lossy

==== Repition suppresion
- Counting the number of times a symbol is repeated when repeated

*Application:* 
  - Silence in audio
  - Spaces in text
  - Background in images

==== Run-length Encoding
- Specific version of repetition suppression
- Used in JPEG in some cases
- Encoding would be heavier than original if no repetition

*Example:*
  - Original: `AAAAAABBBBCCCCC`
  - Encoding: `(A, 6), (B, 4), (C, 5)`

=== Delta Encoding
- If you know you get different versions of that the files
- Sequences as compared to previous versions

*Applications:*
  - Version control (`git`)

==== The Problem
- Storing each version independently creates massive unnecessary redundancy
- No inherent way of keeping track of the changes/dependencies

==== Solution
+ Store the first version
+ Store the differences between the first and second version
+ Repeat for each version

*How to access any version:*
+ Start with the first version
+ Apply the differences in order

==== Example
Git/SVN is optimised for text files
- Uses large amounts of RAM for bit files

==== Slides
#image("../img/9/com-delta.png")