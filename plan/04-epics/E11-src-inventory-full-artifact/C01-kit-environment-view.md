# E11-C01 · `PGRKitEnvironment` — the published kit environment view  [depends: — · parallel: yes]

GOAL      Deliver D-81's ruled SDK value object: a read-only environment view with exactly four named readers — `productionPackages` · `testsPackages` · `exemptPackages` · `srcPath` — built by the core (E11-C02), read by kits (E11-C04), carrying every resolved fact the core publishes to kits, with no generic key lookup.

TRACE     D-81 (Q-38 ruled: kits query a published environment view — the defined API) · D-53.5 (kits never receive the configuration object; the view is a curated projection) · R-35 (no global state; explicit objects) · E02 frozen digest as amended by the D-81 erratum (the optional engine-probed message; the view is its argument) · ch. 0 §0.3 spirit (audience surfaces are deliberate and enumerable).

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**The ruling this chunk executes (D-81, owner-ruled 2026-07-27).** The frozen
three-argument kit contract (`registrationsFrom:productionPackages:testsPackages:`)
cannot carry `#src` or the exempt inventory to kits. The owner vetoed a five-keyword
extended message ("changing api every time something needs something") and ruled a
**curated read-only view with named readers** — "option #2 exposes a defined api, that
is the right approach. approved." Ruling terms binding on this chunk:

1. A new **SDK value object** — working name `PGRKitEnvironment` (refinable, veto-open;
   if you refine it, say so in the completion report) — read-only, built by the core,
   carrying every resolved fact the core publishes to kits:
   `productionPackages` · `testsPackages` · `exemptPackages` · `srcPath` (**nil** when
   the configuration declares no `#src`).
2. **Named readers only — no generic key lookup** (`at:`-style access is expressly out):
   the published set is deliberate and enumerable in one class; a misquery fails loudly
   (an unimplemented selector is a `doesNotUnderstand`, which is exactly the loud
   failure the ruling wants).
3. **Growth path:** a future published fact = **one new reader** on this class — after
   E11 freezes it, a decision-sheet-recorded amendment — never a new kit-protocol
   selector.

**Placement.** The view is SDK vocabulary: package `Phi-Guardrails-SDK`, prefix `PGR`.
Kits read it (`kit → sdk` is an allowed layer edge, D-53); the core constructs it
(`core → sdk` allowed). The view itself references nothing outside the kernel — it is
pure data, like the accepted `PGRRegistrationSpec`.

**House constructor/reader idiom (the accepted SDK pattern you mirror —
`PGRRegistrationSpec` verbatim):** class-side named constructor calling a private
`set...` on `self new` with `yourself`; readers answer stored values. The accepted
role-list precedent: `PGRConfiguration`'s role readers answer **a fresh copy per
send** ("so no kit can reach another's" — the D-53.5 handoff comment in accepted
`PGRRegistry`). The view's three collection readers do the same: answer a fresh
`Array` copy per send. `srcPath` answers the stored String (or nil) as-is — Strings
handed here are path values; the core resolved them already (E11-C02 hands
`PGRConfiguration srcPath`, which is absolute-or-nil by the accepted resolution).

**Signatures this chunk freezes (E11 acceptance freezes them; amendments need a
decision-sheet entry):**

```smalltalk
PGRKitEnvironment class >> productionPackages: prodNames testsPackages: testsNames exemptPackages: exemptNames srcPath: aStringOrNil
PGRKitEnvironment >> productionPackages   "fresh Array copy per send"
PGRKitEnvironment >> testsPackages        "fresh Array copy per send"
PGRKitEnvironment >> exemptPackages       "fresh Array copy per send"
PGRKitEnvironment >> srcPath              "String (absolute path) or nil"
```

**Constitution rules that bite:** class-side named constructors over `new`+setters;
no global state (no class-side variables, no caches — R-35); comments state
constraints the code cannot show; glossary terms exact (these are *packages* lists —
package-name Strings, the resolved role expansions). Touching any file outside the
manifest below is a review rejection.

**Not this chunk (standing exclusions, cite them if tempted):** the engine building
or handing the view (E11-C02); any `PCKKit` change (E11-C04); **any `PGRKit` change**
— the optional skeleton must NOT gain `registrationsFrom:environment:`: the engine's
probe is `respondsTo:`, which folds inheritance, so a skeleton default would make
every `PGRKit` subclass falsely claim the environment form (skeleton support is
B-28 (4), carried post-v1 under D-81); any `PGRSurfaceConformanceTest` growth — the
ch. 0 §0.3 roster and its manifest mirror grow together at the owner's doc pass
(D-81 consequences; the view's freeze is red-test-enforced by this chunk's own suite).

**Verified spellings (P5):** `copy` on Array answers a fresh collection (accepted
`PGRRegistry >> registrations` uses exactly this for the same defensive purpose);
`yourself` cascade (accepted constructors throughout). Nothing else exotic is needed;
⟨verify-in-image⟩ anything you add beyond these and record it in the report.

DELIVERABLES

Files (Tonel):
- **create** `src/Phi-Guardrails-SDK/PGRKitEnvironment.class.st`
- **create** `src/Phi-Guardrails-Tests-SDK/PGRKitEnvironmentTest.class.st`

Classes/methods:
- `PGRKitEnvironment` — instVars `productionPackages`, `testsPackages`,
  `exemptPackages`, `srcPath`; the class-side constructor, the four readers, one
  private `set...` method. Class comment states the D-81 contract: read-only curated
  view, built by the core, named readers only, growth = one new reader via
  decision-sheet amendment, kits still never receive the configuration object
  (D-53.5).
- `PGRKitEnvironmentTest` — the six skeletons below.

LOC budget: target ~100 · ceiling 300.

TESTS FIRST  (`PGRKitEnvironmentTest`, package `Phi-Guardrails-Tests-SDK`)

- `testReadersAnswerConstructedValues` — given the constructor with three distinct
  name lists and an absolute path String; when each reader is sent; then each answers
  a collection equal to its handed list and `srcPath` equals the handed String.
- `testSrcPathNilWhenNoSrcDeclared` — given the constructor with `srcPath: nil`;
  when `srcPath` is sent; then it answers nil (the declares-no-`#src` state, D-81),
  and the three list readers still answer their lists.
- `testCollectionReadersAnswerFreshCopies` — given a constructed view; when the
  collection answered by `productionPackages` is mutated (e.g. `at:put:` on the
  answered Array); then a second `productionPackages` send answers the original
  values unchanged (same law asserted for `testsPackages` and `exemptPackages`).
- `testConstructionDoesNotAliasCallerCollections` — given a caller-side
  `OrderedCollection` handed to the constructor; when the caller adds to its own
  collection afterwards; then the view's reader still answers only the
  construction-time values (the view is a value, not a window).
- `testEmptyExemptListIsLegal` — given the constructor with `exemptPackages: #()`;
  then `exemptPackages` answers an empty collection, no error (the degenerate view
  E11-C04's three-argument delegation builds).
- `testViewAnswersNoGenericLookup` — given a constructed view; then
  `(view respondsTo: #at:)` and `(view respondsTo: #at:ifAbsent:)` are both false
  (D-81: named readers only; the deliberate absence is the contract, so its loss —
  someone adding generic lookup — must be a red test).

Fixtures: none beyond inline literals.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, 0 failures / 0 errors; the six `PGRKitEnvironmentTest`
          cases listed by name, and every previously accepted suite green — ≥236 run
          when this chunk lands first (230 accepted at cut + these 6); membership +
          floor, never an exact ceiling ([P] sibling E11-C03 may land first and
          raises the floor by its 5).

OUT OF SCOPE
- `PGRRegistry` / engine changes (E11-C02).
- `PCKKit` / kit-side changes (E11-C04).
- `PGRKit` skeleton support for the environment form (B-28 (4), post-v1 — the
  inheritance-folding probe hazard above).
- `PGRSurfaceConformanceTest` / ch. 0 §0.3 roster growth (owner's doc pass).
- Any generic key-value access on the view (vetoed shape, D-81).

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67). Postcondition:
one commit `E11-C01: PGRKitEnvironment — the kit environment view`, nothing
uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  name kept or refined (veto-open per D-81) · deviations (each one-line justified) ·
  new questions for the decision sheet.
