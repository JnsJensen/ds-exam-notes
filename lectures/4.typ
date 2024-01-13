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

=== Proporties
- Reliability
- Increase _speed_ beyond individual disk capabilities
  - Since disk speed growth has plateaued

=== Disks
#image("../img/hdd.png", width: 50%)

$
  "access time" = "seek time" + "latency time" + "transfer time"
$

#image("../img/hdd-os.png", width: 50%)

==== Disk Arm Scheduling Algorithm
1. Seek time - Move to the right cylinder
2. Latency time - Sectors rotate under the head
3. Transfer time - Moving the data to/from memory

*Dominant:* physical seek time and physical rotation

#image("../img/hdd-diag.png", width: 50%)

*FIFO:*
- Sub-optimal
- _Very fair_

*SSTF:* Shortest Service Time First
- Might never finish a specific request
- Or big delays for some requests
- _Not fair_

*SCAN:*
- Always moving arm side to side
- Read whichever request is there no matter when it was given
- Favoring outermost and innermost tracks

*C-SCAN:*
- Best #emoji.face.surprise

=== RAID
*Redundant Array of Inexpensive Disks*

#report-block[
  Didn't use any RAID terminology in report; _make sure to be able to use it at the exam_
]

What is possible with many inexpensive disks?

#image("../img/raid.png", width: 80%)

==== Metrics

- *Space Efficiency:* File size divided by the space used in the system.
- *Storage Capacity:* Amount of data that can be stored in the system given a number of devices.
- *Fault Tolerance:* Number of failed devices, $F$, that results in loss of data.
- *Read Performance:* Given a system read speed of $R_(r,s)$ and a read speed of an individual disk $R_(r,d)$, the read performance is the speed-up: $R_(r,s) "/" R_(r,d)$.
- *Write Performance:* Same as read performance, but with write speed of the system $R_(w,s)$ and of the individual disk $R_(w,d)$: $R_(w,s) "/" R_(w,d)$
- *Minimum Number of Disks Required*

_Note: difficult to work with these metrics if all devices/disks aren't exactly the same._

#report-block[
  Make sure to be able to use the _above metrics_ talking about the report.
]

==== What is RAID
*Redundant Array of Inexpensive Disks* \
*Redundant Array of Independent Disks*

Alternative to SLED: Single Large Expensive Disk


- A RAID box with a RAID controller looks just like a SLED to the system using it

==== Striping
#image("../img/raid-striping.png", width: 80%)

==== `RAID0`
- Non-redundant
- _Striped_ and _chunked_
- Not any more space efficient

#image("../img/raid0.png", width: 50%)
`Sx, Cy = Stripe x, Chunk y`

*Purpose:*
- Increase speed
- Read/write in parallel from multiple devices
- Serve data very quickly

*Disk failure:*
- Results in many stripes affected
- Can't recover at all
- Reliability is worse than SLED

#tablex(
  columns: (auto, auto),
  (), vlinex(),
  thick-rule,
  colspanx(2, cellx(align: center, text(size: 14pt, [*`RAID0`*]))),
  thick-rule,
  [*Metric*], [*Evaluation*],
  ..double-rule(2),
  [*Space Efficiency*], [1],
  trule,
  [*Storage Capacity*], [$N times "C"$, For $N$ equal sized disks with capacity $C$],
  trule,
  [*Fault  Tolerance*], [$F=1$, a single disk causes damage],
  trule,
  [*Read Performance*], [$N$],
  trule,
  [*Write Performance*], [$N$],
  trule,
  [*Min Disks Required*], [2],
  thick-rule,
)

==== `RAID1`
- Meant for _reliability_
- *Key:* $N$ mirrored disks
  - 1 Main disk, $N-1$ mirrors
  - Full file replication
- *Failure:* Use any surviving disk, plug in new disk, copy over
- *Read:* Pick fastest disk, $~2x$ for $N=2$, with a lot of requests, parallel read from several drives for different files.
- *Write:* Single disk speed, no speed-up


#tablex(
  columns: (auto, auto),
  (), vlinex(),
  thick-rule,
  colspanx(2, cellx(align: center, text(size: 14pt, [*`RAID1`*]))),
  thick-rule,
  [*Metric*], [*Evaluation*],
  ..double-rule(2),
  [*Space Efficiency*], [$1"/"N$, very _bad_],
  trule,
  [*Storage Capacity*], [Capacity of _smallest_ single disk],
  trule,
  [*Fault  Tolerance*], [$F=N$, lose all disks],
  trule,
  [*Read Performance*], [$N$, only in high load scenarios],
  trule,
  [*Write Performance*], [$1$, need to write to each disk],
  trule,
  [*Min Disks Required*], [2],
  thick-rule,
)

==== `RAID1 E`
- Merge `RAID1` with ideas of striping & chunking from `RAID0`
  - _Striped_ and _chunked_
- *Read:* Can approach that of `RAID0`
- Typically not interleaved

_Basically `RAID0` with *one* replica of everything_

#image("../img/raid1e.png", width: 70%)
`Sx, Cy = Stripe x, Chunk y`

#tablex(
  columns: (auto, auto),
  (), vlinex(),
  thick-rule,
  colspanx(2, cellx(align: center, text(size: 14pt, [*`RAID1 E`*]))),
  thick-rule,
  [*Metric*], [*Evaluation*],
  ..double-rule(2),
  [*Space Efficiency*], [$1 "/" 2$, typically used with 2 replicas],
  trule,
  [*Storage Capacity*], [$N C "/" 2$, half capacity of $N$ disks],
  trule,
  [*Fault  Tolerance*], [$F=2$, can cause loss in worst case, best case: $F=N "/" 2$],
  trule,
  [*Read Performance*], [$N "/" 2$, light load, up to $N$ under high load],
  trule,
  [*Write Performance*], [$N "/" 2$ (could be higher depending on placement strategy)],
  trule,
  [*Min Disks Required*], [3],
  thick-rule,
)

#report-block[
  The idea that read/write could be higher depending on placement strategy is introduced here the first time, and is likely something like that that would have been nice to see in the project and report.

  However, it does of course require some parallel setup like this, which I didn't have.

  _Refer to this (`RAID1 E`) if asked about that_
]

// ==== RAID2

// #tablex(
//   columns: (auto, auto),
//   (), vlinex(),
//   thick-rule,
//   colspanx(2, cellx(align: center, text(size: 14pt, [*`RAID2`*]))),
//   thick-rule,
//   [*Metric*], [*Evaluation*],
//   ..double-rule(2),
//   [*Space Efficiency*], [],
//   trule,
//   [*Storage Capacity*], [],
//   trule,
//   [*Fault  Tolerance*], [],
//   trule,
//   [*Read Performance*], [],
//   trule,
//   [*Write Performance*], [],
//   trule,
//   [*Min Disks Required*], [],
//   thick-rule,
// )

// ==== RAID3

// #tablex(
//   columns: (auto, auto),
//   (), vlinex(),
//   thick-rule,
//   colspanx(2, cellx(align: center, text(size: 14pt, [*`RAID3`*]))),
//   thick-rule,
//   [*Metric*], [*Evaluation*],
//   ..double-rule(2),
//   [*Space Efficiency*], [],
//   trule,
//   [*Storage Capacity*], [],
//   trule,
//   [*Fault  Tolerance*], [],
//   trule,
//   [*Read Performance*], [],
//   trule,
//   [*Write Performance*], [],
//   trule,
//   [*Min Disks Required*], [],
//   thick-rule,
// )

==== `RAID4`
- {Block/stripe}-level parity with stripes
- *Read:* accesses all the disks
- *Write:* accesses all the disks *and* the parity disk
- _Heavy load on parity disk_

*Like `RAID0` but with parity*

#image("../img/raid4.png", width: 70%)
`Sx, Cy, Pz = Stripe x, Chunk y, Parity z`

*Parity:*
- For each stripe create a parity
- bit-by-bit xor for between chunks for each stripe

#image("../img/raid4-parity.png", width: 70%)

#tablex(
  columns: (auto, auto),
  (), vlinex(),
  thick-rule,
  colspanx(2, cellx(align: center, text(size: 14pt, [*`RAID4`*]))),
  thick-rule,
  [*Metric*], [*Evaluation*],
  ..double-rule(2),
  [*Space Efficiency*], [$1-1"/"N$, taking the parity disk into account, otherwise like `RAID0`],
  trule,
  [*Storage Capacity*], [$(N-1) times C$, for $N$ disks with the same capacity of $C$],
  trule,
  [*Fault  Tolerance*], [$F=2$, of the data disks, as at least two are needed to recover the combination of them],
  trule,
  [*Read Performance*], [$N-1$, taking the parity disk into account, otherwise like `RAID0`],
  trule,
  [*Write Performance*], [$N-1$, taking the parity disk into account, otherwise like `RAID0`],
  trule,
  [*Min Disks Required*], [3, 2 disks for striping and chunking, 1 for parity],
  thick-rule,
)

===== Challenges
- Seperated parity disk to one single disk
- Replaced by `RAID5`

==== `RAID5`
- Block-interleaved parity
- Can activate more disks when needing parity
- *Read:* Better read than `RAID4`
- *Write:* Same write performance as `RAID4`

*`RAID4` but with spread out parity*

#image("../img/raid5.png", width: 70%)
`Sx, Cy, Pz = Stripe x, Chunk y, Parity z`

#tablex(
  columns: (auto, auto),
  (), vlinex(),
  thick-rule,
  colspanx(2, cellx(align: center, text(size: 14pt, [*`RAID5`*]))),
  thick-rule,
  [*Metric*], [*Evaluation*],
  ..double-rule(2),
  [*Space Efficiency*], [$1-1"/"N$, taking the parity disk into account, otherwise like `RAID0`],
  trule,
  [*Storage Capacity*], [$(N-1) times C$, for $N$ disks with the same capacity of $C$, as we're still losing the capacity equal to a whole disk on parity],
  trule,
  [*Fault  Tolerance*], [$F=2$, same as `RAID4`],
  trule,
  [*Read Performance*], [$N$, no longer impaired by the parity disk],
  trule,
  [*Write Performance*], [$N-1$, we still have to write parity each time, same as `RAID4`],
  trule,
  [*Min Disks Required*], [3, same as `RAID4`],
  thick-rule,
)

==== `RAID6`
- *Read:* can outperform `RAID5`, as there are multiple parities to take from
- *Write:* slower than `RAID4`, because we need to perform more parity
- Better _reliability_ than `RAID4`

*Like `RAID5` with an extra parity*

#image("../img/raid6.png", width: 70%)
`Sx, Cy, Pz, Qw = Stripe x, Chunk y, Parity z, Parity 2 (Q) w`

- Linear combination of 2 chunks, in such a way that you dont use more space than any other chunk.
- What is $2 times "bitstring"$?
  - Reed-Solomon Code, _see next section_
  - Possible to extent to protect against _more than 2 losses_, however, with some implications
#image("../img/raid6-parity.png", width: 70%)
#image("../img/raid6-reed.png", width: 60%)
#image("../img/raid6-reed2.png", width: 50%)

#tablex(
  columns: (auto, auto),
  (), vlinex(),
  thick-rule,
  colspanx(2, cellx(align: center, text(size: 14pt, [*`RAID6`*]))),
  thick-rule,
  [*Metric*], [*Evaluation*],
  ..double-rule(2),
  [*Space Efficiency*], [$1 - 2 "/" N$, same as `RAID5` but taking the space of another parity disk into account],
  trule,
  [*Storage Capacity*], [$(N-2) times C$, for $N$ disks of same capacity $C$],
  trule,
  [*Fault  Tolerance*], [$F=3$ because of the extra parity],
  trule,
  [*Read Performance*], [$N$, same as `RAID5`, but can sometimes outperform, if parity can be used from two different disks],
  trule,
  [*Write Performance*], [$N-2$, taking the space of two parity disks into account],
  trule,
  [*Min Disks Required*], [4, 2 for striping and chunking, 2 for parity],
  thick-rule,
)

===== Finite Fields
- Acceleratable with parallel GPU operations
Introduction to next lecture. \
_How to set up that linear combination for extra parity_

*Closure Property*
#image("../img/ff-closure.png", width: 50%)

*Example $"GF"(2^2)$: Addition* \
_Instead of operating on 1 bit, operate on pairs of bits, i.e. numbers 0, 1, 2, 3_ \

XOR bitpair-by-bitpair

#tablex(
  columns: same(auto, 5),
  (), vlinex(), (), (), (), (),
  colspanx(5, cellx(align: center, text(size: 10pt, [*`Addition`*]))),
  thick-rule,
  `+`, `0`, `1`, `2`, `3`,
  trule,
  `0`, `0`, `1`, `2`, `3`,
  `1`, `1`, `0`, `3`, `2`,
  `2`, `2`, `3`, `0`, `1`,
  `3`, `3`, `2`, `1`, `0`
)

*Example $"GF"(2^2)$: Multiplication* \
_Retains some properties like multiplying with 0 always gives 0, with 1 always gives the same (identity)_
#tablex(
  columns: same(auto, 5),
  (), vlinex(), (), (), (), (),
  colspanx(5, cellx(align: center, text(size: 10pt, [*`Multiplication`*]))),
  thick-rule,
  `+`, `0`, `1`, `2`, `3`,
  trule,
  `0`, `0`, `0`, `0`, `0`,
  `1`, `0`, `1`, `2`, `3`,
  `2`, `0`, `2`, `3`, `1`,
  `3`, `0`, `3`, `1`, `2`
)

*So how to do the `a + 2b` for the extra parity* \
_Using the two tables above_

```
a = 10
b = 11

2 * b = 10 * 11 (= 2 * 3)
      = 01 (= 1)

a + 2 * b = 10 + 01
          = 11
```

- _Retains the same bit-length_ which is important
- Can be seen as some polynomial modulus arithmetic

*What happens with more than 3 disks* \
- Go to bigger bit pairs if necessary
#image("../img/ff-more3.png", width: 50%)

=== `RAID` Updating Data

*What happens if you need to modify a file?* \
- Deleting/inserting #ra Messes up striping

_If one were to touch the originally written data, then this might incur massive down-times or system slow-downs_

*Solution:* \
- Changes recorded appending data never modifying the original written data

=== Nested/Hybrid `RAID`
- Combine several `RAID` levels stacked
- Combines the different properties
- Typically uses two levels like `RAID 10`
  - *First level is the lowest:* `RAID1` replication at the bottom
  - *Second is the highest:* Data striping of `RAID0` (carried out first) on top of `RAID1` replication

_*Increases read/write speeds* of `RAID1` by doing the *striping* of `RAID0`_