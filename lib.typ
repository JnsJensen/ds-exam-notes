#import "catppuccin.typ": *
#import "@preview/gentle-clues:0.1.0": info, success, warning, error, abstract, attention, caution, done, failure, idea, note, remember, question, quote, hint
#import "@preview/tablex:0.0.7": *

#let maccent = math.accent

#let accent = catppuccin.latte.lavender
#let mainh = catppuccin.latte.maroon
#let secondh = catppuccin.latte.green
#let thirdh = catppuccin.latte.lavender

#let rule = line.with(length: 100%)
#let hr = rule()
#let ivan = text(catppuccin.latte.mauve, link("https://pure.au.dk/portal/da/persons/ivan%40cs.au.dk",[Ivan Damsgaard]))
#let srikanth = text(catppuccin.latte.yellow, link("https://pure.au.dk/portal/en/persons/srikanth%40cs.au.dk", [Srikanth Srinivasan]))

#let precision(f, n) = {
  let as-str = str(f)
  if str(f).contains(".") {
    let fract = str(calc.fract(f)).slice(2) // remove leading "0."
    let integral = calc.trunc(f)
    if n > fract.len() {
      panic("n is larger than the number of decimals in f")
    }
    [#integral.#fract.slice(0, n)]
  } else {
    f
  }
}

/// @param x integer|float
/// @param n integer
#let round(x, n) = {
  if type(x) == "integer" {
    return x
  }
  
  assert(type(x) == "float", message: "round(x, n) x is not of type `float`, but has type: " + type(x))
  assert(type(n) == "integer", message: "n must have type `integer`, but has type: " + type(n))
  assert(0 <= n, message: "0 <= n must hold, but n = " + str(n))

  // @type integer|none
  let period-index = str(x).position(".")
  if period-index == none {
    // x is something like `3.` or `3.00`
    return x
  }
  // @type integer[]
  let fractional-part = str(x).slice(period-index + 1).split("").filter(it => it != "").map(int)
  // @type string
  let integer-part = str(x).slice(0, period-index)
  if n == fractional-part.len() {
    // nothing to round off
    return x
  }
  if n > fractional-part.len() {
    // append zeros, to have the fractional-part have n integers
    let appended-zeros = range(n - fractional-part.len()).map(it => 0)
    return float(integer-part + "." + (fractional-part + appended-zeros).map(str).join(""))
  }

  // typst uses 0-indexing for arrays, so .at(n) is the index we need to look at, that is to the right of the rounding boundary.
  if fractional-part.at(n) >= 5 {
    fractional-part.at(n - 1) = fractional-part.at(n - 1) + 1
  }

  float(integer-part + "." + fractional-part.slice(0, n).map(str).join(""))
}


#let bra(..args) = {
  let left = [⟨] // U+27E8
  let bar = [|]
  if args.pos().len() == 1 {
    let var = args.pos().at(0)
    $#left#var#bar$
  } else {    
    let coeffs = $italic(#args.pos().slice(0, -1).join(""))$
    let var = args.pos().last()
    [#coeffs$#left#var|$]
  }
}


#let ket(..args) = {
  let right = [⟩] // U+27E9
  if args.pos().len() == 1 {
    let var = args.pos().first()
    $|#var#right$
  } else {    
    let coeffs = $italic(#args.pos().slice(0, -1).join(""))$
    let var = args.pos().last()
    [#coeffs$|#var#right$]
  }
}


#let to-content(it) = [#it]


#let braket(..args) = {
  let left = [⟨] // U+27E8
  let right = [⟩] // U+27E9
  let bar = [|]
  let vars = args.pos()
  if vars.len() < 2 {
    panic("At least 2 arguments must be given")
  } else if vars.len() == 2 {
    let l = vars.first()
    let r = vars.last()
    [$#left#l#bar#r#right$]
  } else {
    let l = vars.first()
    let r = vars.last()
    let projections = vars.slice(1, -1).map(to-content).join(bar)
    [$#left#l#bar#projections#bar#r#right$]
  }
}


#let state = (
  plus: $ket(#h(-0.1mm)#sym.plus)$,
  minus: $ket(#h(-0.1mm)#sym.minus)$,
  zero: $ket(0)$,
  one: $ket(1)$,
  epr: $(ket("00") + ket("11")) / sqrt(2)$, // Einstein Podolski Rosen
  pf: (
    plus: $ket(#h(-0.5pt)+#h(0pt)++)$,
    minus: $ket(#h(-0.5pt)-#h(0pt)--)$
  )
)


#let q = "quantum"
#let l-- = line(length: 100%)
#let l- = line(length: 50%)


#let title-case(s) = upper(s.first()) + s.slice(1)

#let os12 = $1/sqrt(2)$
#let tp = $times.circle$ // tensor product
#let xor = $plus.circle$ // binary XOR

#let squared-enum(..numbers, color: none, fill: none) = move(
  dy: -2pt,
  box(
    // stroke: 0.65pt + color,
    fill: fill,
    radius: 20%,
    height: 1em,
    inset: (x: 3pt, y: 1.5pt)
  )[
    #text(
      color,
      weight: 900,
      {
        numbers.pos().map(str).join(".")
      }
    )
  ]
)

#let sparkle(content) = [#box(rotate(10deg, scale(x: -100%, emoji.sparkles)))#text(rgb("#ffac33"), style: "italic", content)#h(1.25pt)#box(rotate(10deg, emoji.sparkles))]

#let boxed(
  content,
  color: accent.lighten(0%),
  fill: accent.lighten(80%),
  weight: 400
  // block: false
) = box(
  fill: fill,
  radius: 3pt,
  inset: (x: 2pt),
  outset: (y: 2pt),
  text(
    color,
    weight: weight,
    content
  ) 
)

#let bold-first(..numbers, color: none) = [
  #if numbers.pos().len() == 1 {
    if color != none {
      text(fill: color, weight: "bold", numbers.pos().map(str).join(".") + ".")
    } else {
      text(weight: "bold", numbers.pos().map(str).join(".") + ".")
    }
  } else {
    numbers.pos().map(str).join(".") + "."
  }
]

#let std-block = block.with(
  fill: catppuccin.latte.base,
  radius: 1em,
  inset: 1em,
  stroke: catppuccin.latte.crust,
  width: 100%,
  breakable: true,
)

#let suggested-topics-for-question(content) = {
  std-block(content)
}

#let agenda-block(content) = {
  std-block(
    fill: catppuccin.latte.base,
    [
      #text(size: 13pt, catppuccin.latte.text, weight: "bold", "Agenda")
      #v(-4pt)
      #move(
        dx: -1em,
        rule(
          length: 100% + 2em,
          stroke: 1pt + catppuccin.latte.crust
        )
      )
      #v(-4pt)
      #text(catppuccin.latte.text, content)
    ]
  )
}

#let report-block(content) = {
  std-block(
    fill: catppuccin.latte.base,
    [
      #text(size: 13pt, catppuccin.latte.text, weight: "bold", [#emoji.excl#h(4pt) Possible Report Weakness])
      #v(-4pt)
      #move(
        dx: -1em,
        rule(
          length: 100% + 2em,
          stroke: 1pt + catppuccin.latte.crust
        )
      )
      #v(-4pt)
      #text(catppuccin.latte.text, content)
    ]
  )
}

#let quest-block(content) = {
  std-block(
    fill: catppuccin.latte.base,
    [
      #text(size: 13pt, catppuccin.latte.text, weight: "bold", [#emoji.quest#h(4pt) Question])
      #v(-4pt)
      #move(
        dx: -1em,
        rule(
          length: 100% + 2em,
          stroke: 1pt + catppuccin.latte.crust
        )
      )
      #v(-4pt)
      #text(catppuccin.latte.text, content)
    ]
  )
}

#let tp = $times.circle$

//EPR = 1/sqrt(2) * (ket00 + ket11)

#let EPR = $1/sqrt(2)(ket(00) + ket(11))$

#let gates = (
  X: $mat(delim: "[", 0, 1; 1, 0)$,
  Y: $mat(delim: "[", 0, i; -i, 0)$,
  Z: $mat(delim: "[", 1, 0; 0, -1)$,
  I: $mat(delim: "[", 1, 0; 0, 1)$,
  H: $1/sqrt(2) mat(delim: "[", 1, 1; 1, -1)$,
  S: $mat(delim: "[", 1, 0; 0, i)$, // Phase gate
  T: $mat(delim: "[", 1, 0; 0, e^(i pi"/"4))$,
  SWAP: $mat(delim: "[", 1, 0, 0, 0; 0, 0, 1, 0; 0, 1, 0, 0; 0, 0, 0, 1)$,
  CNOT: $mat(delim: "[", 1, 0, 0, 0; 0, 1 ,0, 0; 0, 0, 0, 1; 0,0,1,0)$,
  CZ: $mat(delim: "[", 1,0,0,0; 0, 1, 0, 0; 0 ,0, 1, 0; 0, 0, 0, -1)$,
  TOFFOLI: $mat(delim: "[",
    1, 0, 0, 0, 0, 0, 0, 0;
    0, 1, 0, 0, 0, 0, 0, 0;
    0, 0, 1, 0, 0, 0, 0, 0;
    0, 0, 0, 1, 0, 0, 0, 0;
    0, 0, 0, 0, 1, 0, 0, 0;
    0, 0, 0, 0, 0, 1, 0, 0;
    0, 0, 0, 0, 0, 0, 0, 1;
    0, 0, 0, 0, 0, 0, 1, 0;
  )$,
)

// S = [1 0; 0 im] # Phase gate
// T = [1 0; 0 exp(im*pi/4)] # T gate (pi/8 gate)
// TOFFOLI = [
//     1 0 0 0 0 0 0 0;
//     0 1 0 0 0 0 0 0;
//     0 0 1 0 0 0 0 0;
//     0 0 0 1 0 0 0 0;
//     0 0 0 0 1 0 0 0;
//     0 0 0 0 0 1 0 0;
//     0 0 0 0 0 0 0 1;
//     0 0 0 0 0 0 1 0;
// ]

// SWAP = [
//     1 0 0 0;
//     0 0 1 0;
//     0 1 0 0;
//     0 0 0 1;
// ]

// CNOT = [1 0 0 0; 0 1 0 0; 0 0 0 1; 0 0 1 0]
// CZ = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 -1]

#let km = $ket(#h(-0.025em)minus)$

#let nameref(
  label,
  name,
  supplement: none,
) = {
  show link : it => text(accent, it)
  link(
    label,
    [#ref(label, supplement: supplement). #name]
  )
}

#let numref(label) = ref(label, supplement: none)
#let ra = text(catppuccin.latte.maroon, sym.arrow.r)
#let pm = $plus.minus$

#let tablex = tablex.with(stroke: 0.25pt, auto-lines: false, inset: 0.5em)

#let trule = hlinex(stroke: 0.25pt)
#let thick-rule = hlinex(stroke: 0.75pt)
#let double-rule(cols) = (
    hlinex(),
    colspanx(cols)[#v(-0.75em)],
    hlinex(),
)

#let N2(exponent) = {
  if exponent == [1] {
    $sqrt(N) / sqrt(2)$
  } else {
    $sqrt(N) / sqrt(2^exponent)$
  }
}


#let comma-separate(xs) = xs.map(str).join(", ")

#let as-vec(xs, delim: "(") = {
  let elements = comma-separate(xs)
  // let expr = "$ vec(" + elements + ", delim: \"" + delim + "\") $"
  let expr = "$ vec(" + elements + ") $"
  set math.vec(delim: delim)
  eval(expr)
}

#let as-mat(M, delim: "(") = {
  let elements = M.map(comma-separate).join("; ")
  let expr = "$ mat(" + elements + ") $"
  set math.mat(delim: delim)
  eval(expr)
}

// #as-vec(range(10), delim: "[")

// #let M = (
//   (1, 2, 3),
//   (4, 5, 6),
//   (7, 8, 9),
//   (10, 11, 12),
//   ("a", "b", "c"),
//   ("cos(x)", "1/2", "x^2"),
// //  (1.2, $a$, $b$)
// )

// #as-mat(M, delim: "{")


#let roots-of-unity-matrix(N) = {
  let M = ()
  for i in range(N) {
    let row = ()
    for j in range(N) {
      let exponent = i * j
      if exponent == 0 {
        row.push(1)
      } else {
        row.push("omega^" + str(exponent))
      }
    }
    M.push(row)
  }
  M
}

#let H(bits) = $H^(tp bits)$



#let swatch(color, content: none, s: 6pt) = {
    if content != none {
        content
        // h(0.1em)
    }
    h(1pt, weak: true)
    box(
        height: s,
        width: s,
        fill: color,
        // stroke: 1pt + color,
        radius: s/2,
        baseline: (s - 0.5em) / 2,
    )
}

#let sr = swatch(red)
#let sb = swatch(blue)

#let prot-title(content) = align(center, text(size: 16pt, content))
#let prot-block = std-block.with(
  fill: accent.lighten(95%),
  stroke: (paint: accent.lighten(20%))
)

#let a = text(catppuccin.latte.yellow, weight: "bold", "Alice")
#let b = text(catppuccin.latte.blue, weight: "bold", "Bob")
#let e = text(catppuccin.latte.maroon, weight: "bold", "Eve")

#let bold-enum = (..numbers) => text(weight: 900, numbers.pos().map(str).join(".") + ".")

#let same(item, amount) = for i in range(amount) {
    (item,)
}