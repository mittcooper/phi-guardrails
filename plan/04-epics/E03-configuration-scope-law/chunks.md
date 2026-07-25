# E03 · Configuration and the scope law — chunk index (M1)

*Produced by Prompt 4 (fourth run, 2026-07-25). Entry check: roadmap approved and
frozen (D-62); E03's only dependency E02 is `accepted` in `plan/ledger.md`
(2026-07-24) with its interface digest frozen on head `5f2fc60`
(`plan/04-epics/E02-sdk-vocabulary/chunks.md` — the SDK vocabulary, the check
protocol, the two-message kit protocol). Owner notes honored: every COMMIT
section cites `bash tools/precheck.sh` as its precondition (D-66/D-67 delivered
in E02). Numbering note: this epic's chunks are **C20–C27** — a concurrent
Prompt-4 run cut E06 the same day and claimed C12–C18 first (its papers were on
disk before this cut closed); chunk IDs are corpus-global and never collide or
reuse (the stable-ID convention), so this cut ceded the range rather than edit
another run's artifacts. The near-miss itself is reported to the owner in this
run's summary.*

| ID | Title | Depends | [P] | LOC est. | Acceptance (one line) |
|---|---|---|---|---|---|
| C20 | Scratch client fixtures | — | no | ~90 | two scratch baselines (grouped + plain) and the duck-typed `PGRScratchKit` land in `Phi-Guardrails-Tests-Core`; `PGRScratchFixturesTest` (7) pins the D-25.a expansion behavior on this image |
| C21 | Envelope parse and shape | C20 | no | ~140 | `fromString:` strict-parses pure-data STON and enforces the whole envelope shape (required keys, unknown-key refusal, per-key shapes, blocks opaque past `#kit`); `project`/`kitBlocks` readers; **P-CFG-STRICT**'s named test green (7 tests) |
| C22 | Schema-version law | C21 | no | ~50 | parse set exactly {2}; newer and never-shipped-1 refused naming both versions; **P-SCHEMA-REFUSAL** (both named tests) green (3 tests) |
| C23 | Kit and baseline resolution | C22 | no | ~100 | `#kit` → loaded class conforming class-side to the two-message protocol (duck-type witnessed); `#baseline` → loaded `BaselineOf` subclass; `kitClasses`/`baselineClass` readers (5 tests) |
| C24 | Role-matcher expansion | C23 | no | ~130 | matchers resolve group-name-first (membership pre-checked), else package name, else full-match pattern; zero-match legal; three role readers; **P-ROLES-FROM-CONFIG** first named test green (6 tests) |
| C25 | The scope law and loadedness | C24 | no | ~140 | disjoint + total over `version packages` + production/tests loaded, exempt exempt; **P-SCOPE-TOTAL** (all three named tests) and **P-ROLES-FROM-CONFIG** second named test green (6 tests) |
| C26 | Exempt-name patterns | C25 | no | ~70 | `#exemptNamePatterns` enforced both directions, full-match; **P-ROLE-MISFILE**'s named test green (3 tests) |
| C27 | fromFile: and the #src anchor | C26 | no | ~110 | `fromFile:` (missing file → configuration error) anchors relative `#src` to the config's directory; directory-less relative `#src` errors naming the fix (D-47); internal `srcPath` (5 tests) |

Total ~830 LOC across 8 chunks (= the sum of the work-order targets). The frozen
roadmap row estimated ~7 chunks; the eighth is C22, split out of C21 so the
schema-version law (P-SCHEMA-REFUSAL) is its own reviewable diff — a size-shaped
split under constitution §3, not new scope. C22 (~50) sits at the band floor
deliberately (the E02 C05/C06 precedent for ruled single-purpose chunks).

**No `[P]` anywhere, deliberately:** C21–C27 all modify the same two files
(`PGRConfiguration.class.st` + `PGRConfigurationTest.class.st`) — the pipeline is
built up stage by stage in one class, so the chain is strictly linear; C20 is the
fixture root everything depends on. Manifest disjointness, the [P] precondition,
is structurally absent (the E02 note in reverse).

**P-CFG-STRICT's arms, placed:** the property's named test
(`testUnknownKeySignals`) plus its malformed-block and unknown-kit arms land in
E03 (C21, C23). Its **duplicate-name arm cannot exist at parse time** —
registration names are built at registry construction, and the frozen roadmap
gives duplicate-name rejection to E04 explicitly — so that arm is discharged by
E04's registry tests. Recorded here so the property's cross-epic split is a
statement, not a drift.

## Probe record (this cut, 2026-07-25 — D-31.a work image `.build/work/phi.image`, task-writer-run; R-39/P5)

Spellings E03's orders rely on, each executed live (scripts:
`probe-e03*.st`, session scratchpad):

- `Smalltalk classNamed: 'PGRVerdict'` → the class; unknown name → **nil** (the
  resolution spelling, C23).
- `STON fromString:` on a pure-data map → `Dictionary`, keys `ByteSymbol`
  (Symbols), lists → `Array`; malformed text signals **`STONReaderError`**
  (an `Error` subclass) — wrapped, never escaping (C21).
- **Class-tagged STON parses silently** (`'OrderedCollection [ 1 ]'` → an
  `OrderedCollection`, no signal): "pure-data" is enforced by our shape checks,
  not by the reader (C21's design premise).
- `PGRKit respondsTo: #recommendedBlock` → true (class-side conformance
  spelling, C23).
- Fluid class builder `BaselineOf << #Name … install` works; the legacy
  `subclass:instanceVariableNames:…` message is **gone** in Pharo 13 (C20
  authoring).
- A scratch baseline may declare an **unloaded** package (listed in `version
  packages`; `PackageOrganizer default packageNamed:ifAbsent:` answers nil) and
  an **empty** group; `packagesForSpecNamed:` expands composites transitively —
  D-25.a re-verified on this repo's image (C20/C24/C25).
- **Metacello refuses a group named like a declared package** — building
  `project version` raises "incompatible specs (MetacelloGroupSpec /
  MetacelloPackageSpec)". Consequence: §1.1's matcher-ambiguity error arm is
  unconstructible from a real baseline → **Q-31** (decision sheet), C24 written
  to its recommendation.
- `FileReference`: `asFileReference`, `contents` (missing file →
  `FileDoesNotExistException`), `parent`, `parent / 'sub'`, `fullName`,
  `isAbsolute` (true for `/tmp/x`, false for `src`) — the C27 spellings.

## Agent calls recorded (veto-open, D-16 precedent; closing at acceptance unless vetoed)

- **Conformance-not-ancestry kit resolution (C23):** §1.1's "loaded `PGRKit`
  subclass" is implemented as *class-side conformance to the two-message
  protocol* — D-53's law, `PGRKit`'s frozen class comment ("a duck-typed plain
  class implementing the pair registers fine"), and E04's ruled duck-typed
  scratch-kit tests (which an ancestry check would reject at parse) all bind the
  same way; the decision log wins over older spec prose (constitution preamble).
- **Matcher-ambiguity arm not implemented (C24)** — per the Q-31 recommendation
  (unconstructible, probe-backed); a veto returns it as an amendment chunk.
- **Regex failures are configuration errors (C24/C26):** a matcher or
  exempt-name pattern the regex engine rejects signals `PGRConfigurationError`
  naming the string (family 7: loud, and no engine exception escapes
  `fromString:`).
- **`currentSchemaVersion` (C22):** the gate's own version, 2, stated in one
  class-side internal method.
- **Internal reader `srcPath` (C27):** absolute String when anchored/absolute,
  nil when absent — not on any frozen surface; E11's `PCKSrcInventoryCheck`
  wiring is its consumer.
- **Role readers answer ordered, deduped `Array`s (C24)** — handed collections
  copied (the E02 R-35 convention); expansion order: matcher order, then
  baseline declaration order.
- **Test-helper shape (C21):** `validArtifactString` + a mutation helper live on
  `PGRConfigurationTest`, written against the C20 fixtures so every green case
  stays green as C22–C27 tighten validation.
- **Descriptive fixture-suite name `PGRScratchFixturesTest` (C20)** — the E01/E02
  `PGRBaselineSmokeTest`/`PGRSdkErrorsTest` precedent.

## Exit checkpoint (freezes E03's interfaces)

E03 is provable by, on one head commit:

1. **Named suite:** `PGRScratchFixturesTest` (7) + `PGRConfigurationTest` (35) —
   42 tests — green under `bash tools/build-image.sh && bash tools/verify.sh`,
   with the 19 accepted E02 SDK tests and the 5 `PGRBaselineSmokeTest` smoke
   tests still green (66 run, 0 failures, 0 errors — plus whatever accepted
   parallel-track E06 suites the sweep also matches by then; the E03 claim is
   the 42 + 24, all green). Named properties
   discharged by their ch.-9-named tests: **P-CFG-STRICT** (envelope arms; the
   duplicate-name arm is E04's, recorded above) · **P-SCHEMA-REFUSAL** ·
   **P-SCOPE-TOTAL** · **P-ROLE-MISFILE** · **P-ROLES-FROM-CONFIG**.
2. **Infra leg:** `bash tools/precheck.sh` green at every chunk pick (D-67
   standing discipline).
3. **CI leg:** the committed `.github/workflows/ci.yml` (step 1) green on an
   actual CI run of the same commit — the new tests ride the existing
   smalltalkCI sweep.

**Frozen at acceptance (E03's interface digest — later epics build on these;
amendments need a decision-sheet entry):**

- **Caller surface:** `PGRConfiguration class>>fromString:` ·
  `PGRConfiguration class>>fromFile:` — both signalling `PGRConfigurationError`
  on every defect of the §1.1 strict list; nothing else on the caller surface.
- **The artifact schema, version 2** (config-author surface): the §1.1 envelope
  exactly — `#schemaVersion` (= 2) · `#project` · `#kits` (ordered blocks, `#kit`
  the only common field) · `#baseline` · `#roles`
  (`#production`/`#tests`[/`#exempt`], matchers group-name-first / package-name /
  full-match pattern) · optional `#src` (anchor rules per D-45/D-47) · optional
  `#exemptNamePatterns` (full-match, both directions).
- **Specified-but-internal readers E04 consumes** (changeable only via
  decision-sheet entry while E04 is in flight): `project` · `kitBlocks`
  (ordered, verbatim) · `kitClasses` (ordered, parallel) · `baselineClass` ·
  `productionPackageNames` · `testsPackageNames` · `exemptPackageNames` ·
  `srcPath`.

Checkpoint result (filled at acceptance): —
