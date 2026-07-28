# E12-C01 · The toy mini app and its groupless baseline  [depends: — · parallel: yes]

GOAL      Fill the E01 `Toy-Core`/`Toy-UI`/`Toy-Persistence` package stubs with a small,
real, cleanly-layered three-class app and give the toy its own `BaselineOfToy` — defined
inside `Toy-Core`, declaring the five `Toy-*` packages and **no groups at all** — so the
toy models an adopter whose baseline needed zero changes for adoption (R-47).

TRACE     R-32 (fixture half — the toy client exists) · R-36 (Toy family naming) ·
R-05 (the stand-in client the framework never names) · R-47 (adoption changed nothing
in the adopted baseline — demonstrated by the no-groups form) · spec ch. 8 §8.2 (the
toy's shape and its in-package baseline) · ch. 1 §1.1 (inventory from the baseline) ·
D-12 (a) (in-repo toy) · D-58 (`BaselineOfToy` collision-probed clean; re-confirmed at
this cut, probes.md P16).

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**What the toy is (spec ch. 8 §8.2, condensed).** The toy is the framework's
living-documentation client: a mini layered app over three runtime packages —
`Toy-UI` (mini UI layer), `Toy-Core` (mini domain logic), `Toy-Persistence` (mini
persistence layer) — plus `Toy-Rules` (the extension package, E12-C02's) and
`Toy-Tests` (the toy's tests-role suite, filled by C02/C03). It models a real adopter:
**no framework prefix** — classes are `Toy*` (R-36 as amended by D-56); nothing in it
references any `Phi-Guardrails-*` or `Phi-Coding-Kit-*` class (it is the *subject* of
the gate, never a framework component — R-05/P7; the accepted `PGRArchSelfTest` client
wall enforces the reverse direction). This chunk delivers the app **clean**: the six
planted violations are E12-C03's one concern — nothing here may contain
`isNil ifTrue:`, `isNil ifFalse:`, `Transcript`, or a UI→Persistence reference.

**The layering the code must respect** (the toy's own declared map, committed at
E12-C04; its semantics are the accepted D-79 law — internal client→client references
judged, one-way, non-transitive):
- layers: `'ui'` = `Toy-UI` · `'domain'` = `Toy-Core` · `'persistence'` =
  `Toy-Persistence`; `Toy-Rules` unlayered.
- allowed: ui → domain, domain → persistence. **Clean code therefore means:**
  `Toy-UI` classes may reference `Toy-Core` classes only; `Toy-Core` classes may
  reference `Toy-Persistence` classes only (this chunk's domain does not need to);
  `Toy-Persistence` references no sibling toy package.

**`BaselineOfToy` (spec ch. 8 §8.2, condensed).** Defined *inside* `Toy-Core` — a
baseline class needs its own package only when Metacello loads it from disk by name;
the toy baseline is **introspected, never Metacello-loaded in v1** (the accepted
`BaselineOfPCKFixture` precedent, same trick). Under D-45 it declares **no role
groups** — the toy's artifact (E12-C04) assigns roles by matcher, which is exactly how
the toy demonstrates R-47: adoption changed nothing in the adopted project's baseline.
Declare the five packages, no `group:` sends at all. Live-probed precedent: a
groupless baseline introspects fine (`version packages` answers the list,
`version groups` answers empty — probes.md P8, the accepted `BaselineOfPGRScratchPlain`
as stand-in). Shape to copy (the accepted in-package baseline, adapted):

```smalltalk
Class {
    #name : 'BaselineOfToy',
    #superclass : 'BaselineOf',
    #category : 'Toy-Core',
    #package : 'Toy-Core'
}

BaselineOfToy >> baseline: spec [
    <baseline>
    spec for: #common do: [
        spec package: 'Toy-Core'; package: 'Toy-UI'; package: 'Toy-Persistence';
            package: 'Toy-Rules'; package: 'Toy-Tests' ]
]
```

**Baseline-introspection spellings (D-25.a-verified, used verbatim by the accepted
`PGRToySweepExemptionTest` in this same package):**
`(Smalltalk globals at: #BaselineOfToy) project version` → a version object answering
`packages` (collection whose elements answer `name`) and `groups`.

**The mini app (design freedom within the shape below — the spec fixes the packages
and layer roles, not the domain; keep it honest, tiny, and executable).** Prescribed
classes and the contract the C03 plants and witnesses build on (**the class and
selector names below are load-bearing for C03/C04 — keep them exactly**):

- `ToyOrder` (package `Toy-Core`, superclass `Object`) — instVar `items` (an
  `OrderedCollection` of price Numbers, initialized in `initialize`). Class-side named
  constructor `empty` (`^ self new` is acceptable inside it; the *published* way in is
  the named constructor — constitution: class-side named constructors over
  `new`+setters). Instance: `addItemPriced: aNumber` (appends), `itemCount`
  (`^ items size`), `total` (sum of `items`, 0 when empty).
- `ToyOrderStore` (package `Toy-Persistence`, superclass `Object`) — instVar `orders`
  (an `OrderedCollection`, initialized in `initialize`). Class-side named constructor
  `empty`. Instance: `save: anOrder` (appends), `count` (`^ orders size`).
  References no other toy class.
- `ToyOrderView` (package `Toy-UI`, superclass `Object`) — instVar `order`. Class-side
  named constructor `on: aToyOrder`. Instance: `render` — answers a String naming the
  item count and total (e.g. `'Order: 2 items, total 15'`) built with ordinary string
  concatenation/`printString`; references `ToyOrder` instances only (ui → domain).

**Where this chunk's tests live.** `Toy-Tests` is deliberately outside both verify
patterns (the committed-red discipline, D-57 — the accepted
`PGRToySweepExemptionTest>>testToyTestsPackageMatchesNeitherTestsFamilyPattern` pins
it), so a swept test cannot live there. The framework-side pin tests for toy ground
live in **`Phi-Guardrails-Tests-Toy`** (swept by the verify command and by the
framework's own gate as a tests-role package) — the accepted home of
`PGRToySweepExemptionTest`. Test classes there are framework tests and carry the `PGR`
prefix (R-36).

**Constitution rules that bite here:** class-side named constructors over
`new`+setters · `ifNil:`/`ifNotNil:` over `isNil ifTrue:` — and this chunk commits
**no plant of any kind** (plants are C03's, D-26-sanctioned there) · no
`skip`/`expectedFailures` in `Phi-Guardrails-Tests-Toy` (tests-role, machine-caught) ·
comments state constraints the code cannot show · touching any file outside the
manifest is a review rejection · no dependency additions.

**Regression guard riding every E12 chunk (owner ground):** the framework's own
committed artifact `guardrails.ston` is **untouched** — the toy has its OWN artifact
(E12-C04, class-side text); the self-hosted gate leg must still answer its 12
registrations unchanged.

DELIVERABLES

Files (Tonel):
- **create** `src/Toy-Core/ToyOrder.class.st`
- **create** `src/Toy-Core/BaselineOfToy.class.st`
- **create** `src/Toy-Persistence/ToyOrderStore.class.st`
- **create** `src/Toy-UI/ToyOrderView.class.st`
- **create** `src/Phi-Guardrails-Tests-Toy/PGRToyBaselineTest.class.st`

Classes/methods: exactly the four product classes with the signatures in the digest,
plus the test class below. The five `package.st` stubs, `BaselineOfPhiGuardrails`, and
`guardrails.ston` are **not** in this manifest.

LOC budget: target ~110 · ceiling 300.

TESTS FIRST  (`PGRToyBaselineTest`, package `Phi-Guardrails-Tests-Toy`, superclass
`TestCase`)

- `testBaselineDeclaresTheFivePackagesAndNoGroups` *(R-47's demonstration pin)* —
  given the loaded `BaselineOfToy`; when its `project version` is introspected; then
  `(version packages collect: [:each | each name]) asSortedCollection asArray` equals
  `#('Toy-Core' 'Toy-Persistence' 'Toy-Rules' 'Toy-Tests' 'Toy-UI')` **and**
  `version groups isEmpty` — the adopted baseline carries no role group, no
  convenience group, nothing.
- `testToyDomainBehaves` *(the app is real code, not stubs — R-32's honest fixture)* —
  given `ToyOrder empty` with items priced 5 and 10 saved into `ToyOrderStore empty`;
  when totals and counts are read and `ToyOrderView on:` renders; then `total` is 15,
  `itemCount` is 2, the store's `count` is 1, and `render` answers a String containing
  both `'2'` and `'15'`.

Fixtures: none beyond the classes this chunk creates (the baseline is introspected in
the verify image, where the `CI` group loads all `Toy-*` packages — the accepted E01
baseline ground).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, 0 failures / 0 errors; both `PGRToyBaselineTest` cases
          listed by name, every previously accepted suite green — ≥252 run when this
          chunk lands first (250 accepted at cut + these 2); membership + floor, never
          an exact ceiling ([P] sibling E12-C02 adds no swept test — its suite is
          unswept by design — so the floor holds either way).
          **Plus the self-hosted regression leg:**
          `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston`
          → exit 0, **12 registrations unchanged**, `GATE: GREEN` (E12 adds nothing to
          the framework's artifact).

OUT OF SCOPE
- Any planted violation (all six are E12-C03's one concern; this chunk's code is
  clean by contract).
- `BaselineOfToy class>>guardrailsSTON` (E12-C04) and `ToyNoIsNilIfFalseRule` +
  `Toy-Tests` content (E12-C02/C03).
- Any edit to `BaselineOfPhiGuardrails` (frozen E01 group tree), `guardrails.ston`,
  `.smalltalk.ston`, or any accepted test file.
- Metacello-loading `BaselineOfToy` (introspected only in v1, §8.2).
- A `ToyDemoTest` or any gate run over toy configuration (E14's ground — do not
  pre-build).

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67). Postcondition:
one commit `E12-C01: the toy mini app and its groupless baseline`, nothing
uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output (verify sweep +
  gate leg) · deviations (each one-line justified) · new questions for the decision
  sheet.
