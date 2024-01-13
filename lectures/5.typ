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

=== Leading up to Finite Fields
- Used fx. in `RAID6`, see previous sections
- Any operation on one or more elements from within a set of finite elements always yields an element in that set
- Any operation should always be reversible

#image("../img/ff-defs.png", width: 70%)

==== Groups
#image("../img/ff-group.png", width: 70%)

==== Abelian Group
- *Group* with _commutativity_

==== Rings
#pad(top: -2em, image("../img/ff-rings.png"))

==== Commutative Ring
- *Ring* that satisfies _commutativity of multiplication_ $a b = b a in RR$ 

==== Integral Domain
- *Commutative ring* that also satisfies
  - _Multiplicative identity_ e.g. $1 a = a 1 = a$
  - _No zero divisors_ i.e. if $a b = 0 arrow.r.double a=0 or b=0 $

==== Field
- *Integral domain* that also satisfies
  - _Multiplicative inverse_ i.e. for each $forall a in F : a != 0 arrow.r.double exists a^(-1) : a(a^(-1)) = (a^(-1))a = 1$

=== Finite Fields
#image("../img/ff.png", width: 70%)
- $"GF"(2^n)$ is very useful for binary in computer science
  - Thus works  well with binary and can be _executed fast on computer_
- Much of the time _modular arithmetic_ can be used to create _finite fields_
  - Because of the nature of this, $p$ has to be a prime, if not it is no longer a finite field
  - #image("../img/ff-not-prime.png", width: 25%)
    Where you can't undo, you don't know whether 1 came from $1 times 1$ or $3 times 3$, similar case with 3.

*$G(2^n)$* is _not prime_, thus we use _polynomial arithmetic_ instead
#image("../img/ff-polynomial.png", width: 50%)
- Product breaks the finite fields guarantees
  - #image("../img/ff-polynomial-2.png", width: 80%)
  - Divide by some irreducible polynomial (of order $n$?)
- #image("../img/ff-polynomial-3.png", width: 30%)


_Usually you have LUT for these finite fields in an implementation, which accelerates it immensely, instead of computing these polynomials in real time_
- Sometimes tables become very big like $"GF"(2^8)$, where you might _need_ to compute
#image("../img/ff-implementation.png", width: 50%)
#image("../img/ff-implementation-2.png", width: 40%)

=== Linear Coding
- Generating a linear coded fragment/stripe $C$

$
  C_i = sum a_(i j) P_j
$

#image("../img/ff-lc-1.png", width: 50%)
_Take the original fragments $P_j$, and make a *linear combination* of them, reaulting in the encoded fragments $C_i$_ \
How you pick the coefficients determines properties and performance of the system

*`RAID6`*
#image("../img/ff-raid6.png", width: 50%)

==== How to Decode (`RAID6`)
- You have some subset of the coded fragments, and you want to recover

*Example:*
- Lost 5 and 6
#image("../img/ff-raid6-decode.png", width: 50%)

Something something linear system of equations \
#ra _qaussian elimination_


==== Codes
- MDS: Maximum Distance Separable
#image("../img/ff-mds.png", width: 50%)
- Reed Solomon Vandermonde: Not systematic (and MDS code)
#image("../img/ff-reed.png", width: 60%)
- Reed Solomon Cauchy: Systematic and very constructive (designed for specific purposes)
  - Many Cauchy alternatives
  - #image("../img/ff-cauchy.png", width: 60%)

=== Reliable Multi-server
- Numoerous disk _failures per day_
- Failures are the _norm_
- Redundancy is _necessary_
- Replication or erasure coding

#quest-block[
  Are `RAID` schemes like `RAID5` and `RAID6` a form of _erasure coding_?
]

#report-block[
  *Erasure coding* and *replication* are two _distinct_ methods of redundancy, there are trade-offs for each.

  With *erasure coding* you tupically have to do _more work_ to recover. \
  #ra a lot of network traffic for repair \
  Where with simple *striped replication* you might only have to move 1/10 a file. \
  #ra little network traffic for repair \

  Apparently _regenerating codes_ are codes that keep the MDS properties and reduce repair traffic.
]

#report-block[
  I was _definitely_ supposed to use `PyErasure` for the final project, which I didn't \
  #ra look at Lab Week 5
]

