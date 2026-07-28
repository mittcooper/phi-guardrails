# E11-C02 · Engine probe — the core builds the view and hands it to kits that answer for it  [depends: E11-C01 · parallel: no]

GOAL      Make the core build one `PGRKitEnvironment` per registry construction and, per kit, probe once for `registrationsFrom:environment:` — handing the view to kits that answer it and falling back to the frozen three-argument form otherwise, with zero behavior change for every accepted consumer.

TRACE     D-81 ruling 3 (additive landing: the engine probes each kit once — `respondsTo:`, the established D-53/D-60 reflective-conformance family — and falls back to the frozen form) · D-53.5 (the view, never the configuration object, crosses the kit boundary) · D-45 ruling 2 (`#src` resolution semantics — already implemented in accepted core; this chunk only relays the resolved value) · R-35 (per-run objects, no global state).

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**What lands here (D-81 ruling 3, verbatim ground):** "`registrationsFrom:environment:`
(block + view) lands BESIDE the frozen three-argument message; the engine probes each
kit once (`respondsTo:`, the established D-53/D-60 reflective-conformance family) and
falls back to the frozen form otherwise. Zero accepted consumers change; the
three-argument contract remains complete for kits that consume no envelope fact."

**The accepted engine method you amend (verbatim, current body core —
`PGRRegistry class >> fromConfiguration: aPGRConfiguration`, internal surface, no
frozen caller):**

```smalltalk
| wrapped seenNames |
wrapped := OrderedCollection new.
seenNames := Set new.
aPGRConfiguration kitClasses with: aPGRConfiguration kitBlocks do: [ :kitClass :block |
    (kitClass
        registrationsFrom: block
        productionPackages: aPGRConfiguration productionPackageNames
        testsPackages: aPGRConfiguration testsPackageNames)
        do: [ :spec |
            self validateSpec: spec.
            (seenNames includes: spec name) ifTrue: [
                PGRConfigurationError new signal: 'Duplicate registration name: ' , spec name ].
            seenNames add: spec name.
            wrapped add: (PGRRegistration fromSpec: spec) ] ].
^ self new
    setRegistrations: wrapped asArray;
    yourself
```

**The change:** before the kit loop, build the view once:

```smalltalk
environment := PGRKitEnvironment
    productionPackages: aPGRConfiguration productionPackageNames
    testsPackages: aPGRConfiguration testsPackageNames
    exemptPackages: aPGRConfiguration exemptPackageNames
    srcPath: aPGRConfiguration srcPath.
```

Inside the loop, replace the fixed three-argument send with the probe:

```smalltalk
specs := (kitClass respondsTo: #registrationsFrom:environment:)
    ifTrue: [ kitClass registrationsFrom: block environment: environment ]
    ifFalse: [ kitClass
        registrationsFrom: block
        productionPackages: aPGRConfiguration productionPackageNames
        testsPackages: aPGRConfiguration testsPackageNames ].
```

Everything downstream (per-spec validation, duplicate-name law, wrapping order) is
untouched. One view per registry construction is correct sharing: the view's collection
readers answer a fresh copy per send (E11-C01's law), so no kit can reach another's
lists through it — the same reasoning the accepted comment gives for the role readers.

**Accepted core readers this chunk consumes (all exist, accepted):**
`aPGRConfiguration productionPackageNames` / `testsPackageNames` /
`exemptPackageNames` — resolved role expansions, fresh copy per send; and
`aPGRConfiguration srcPath` — the resolved `#src`: an absolute-path String (relative
`#src` was resolved against the config file's directory at parse, D-45 ruling 2), or
**nil when the artifact declares no `#src`**.

**The E11-C01 view surface (frozen by this epic):**
`PGRKitEnvironment class >> productionPackages:testsPackages:exemptPackages:srcPath:`;
instance readers `productionPackages` · `testsPackages` · `exemptPackages` ·
`srcPath` (nil when no `#src`).

**Kit resolution is NOT touched.** Accepted
`PGRConfiguration class >> resolveKitClassNamed:` still requires every kit class to
answer both frozen class-side selectors
(`registrationsFrom:productionPackages:testsPackages:` and `recommendedBlock`) — the
three-argument form remains the conformance baseline; the environment form is opt-in
on top (D-81: additive). So the new scratch fixture kit below implements all three
class-side messages.

**The accepted scratch-kit fixture pattern you extend (the echo pattern, verbatim
precedent):** `PGRScratchSpecKit` (accepted, `Phi-Guardrails-Tests-Core`) is a plain
`Object` subclass, class-side only, whose `#echoRoles` arm answers "a missing spec
whose reason is the received role lists verbatim — the C03 handoff witness, echoing
instead of capturing state." The new `PGRScratchEnvKit` witnesses the environment
handoff the same way: it answers one missing spec whose reason encodes what the view
answered, so tests read the handoff off the spec, never off captured state.

**The accepted test envelope you reuse (verbatim, from accepted `PGRRegistryTest`):**

```smalltalk
PGRRegistryTest >> artifactWithKitsFragment: aStonKitsArrayString
    ^ '{
    #schemaVersion : 2,
    #project : ''Scratch'',
    #baseline : ''BaselineOfPGRScratchGrouped'',
    #roles : {
        #production : [ ''scratch-prod'' ],
        #tests : [ ''scratch-tst'' ],
        #exempt : [ ''scratch-ghost'' ] },
    #kits : ' , aStonKitsArrayString , '
}'
```

Role expansions against the accepted scratch baseline: production =
`#('Phi-Guardrails-SDK' 'Phi-Guardrails-Core')`, tests =
`#('Phi-Guardrails-Tests-SDK')`, exempt = `#('PGR-Scratch-Ghost')`. For a
`#src`-carrying envelope, add a top-level `#src` with an **absolute** path (an
absolute `#src` is recorded as-is even via `fromString:` — accepted resolution; use a
scratch-directory absolute path built in the test, e.g.
`(FileSystem workingDirectory / 'pgr-e11c02-src') fullName`, no need for the
directory to exist — existence is judged only by the walk that consumes it, which
this chunk never runs). You will need a variant helper that splices `#src` into the
envelope; add it beside `artifactWithKitsFragment:` rather than editing the accepted
helper.

**Constitution rules that bite:** no global state (the view is a per-construction
local — never cached class-side); strict parsing untouched; comments state
constraints code cannot show. Touching any file outside the manifest is a review
rejection.

**Verified spellings (P5):** `respondsTo:` on a class object probes class-side
selectors incl. inherited (the accepted engine and kit code use exactly this probe
family — D-53/D-60); `FileSystem workingDirectory`, `/`, `fullName` (accepted in
`PGRConfigurationTest`/`PGRGateTest`). ⟨verify-in-image⟩ anything beyond these.

── AMENDED-SURFACE NOTE (scripted; behavior-preserving) ──

The amended surface is `PGRRegistry class >> fromConfiguration:` — internal, no frozen
caller (E04 close: "no new frozen exports; the engine is internal"). Committed callers
enumerated by script (`git ls-files 'src/**/*.st' | xargs grep -l "fromConfiguration:"`):
`PGRRegistration` (comment only) · `PGRRegistry` (itself) · `PGRGate` ·
`PGRRegistryTest` · `PGRGateTest` · `PGRQuickstartSamplesTest` ·
`PGRScratchConfigErrorKit` / `PGRScratchThrowingKit` (comments/fixtures). **None is
amended:** every accepted kit class answers only the three-argument form, so the probe
answers false for all of them and each takes the byte-identical fallback path — the
full accepted sweep staying green is the machine witness. Zero accepted test files in
this chunk's manifest change a single accepted method.

DELIVERABLES

Files (Tonel):
- **modify** `src/Phi-Guardrails-Core/PGRRegistry.class.st` — `fromConfiguration:`
  gains the view construction + per-kit probe (class comment updated to state the
  D-81 dispatch: probe once per kit, view built by the core, fallback to the frozen
  form).
- **create** `src/Phi-Guardrails-Tests-Core/PGRScratchEnvKit.class.st` — plain
  `Object` subclass, class-side only: `recommendedBlock` (a one-line stanza);
  `registrationsFrom:productionPackages:testsPackages:` (answers one missing spec
  whose reason says the three-argument path was taken — the fallback detector);
  `registrationsFrom: aBlock environment: anEnvironment` (answers one missing spec,
  kind `#scratch`, whose reason encodes — in a fixed, assertable format — the view's
  `productionPackages`, `testsPackages`, `exemptPackages`, and `srcPath printString`).
- **modify** `src/Phi-Guardrails-Tests-Core/PGRRegistryTest.class.st` — add the
  `#src`-splicing helper + the three tests below; every accepted method stays
  byte-identical.

LOC budget: target ~120 · ceiling 300.

TESTS FIRST  (`PGRRegistryTest` additions)

- `testEnvironmentFormKitReceivesResolvedView` — given the scratch envelope (no
  `#src`) with kits = `[ { #kit : 'PGRScratchEnvKit' } ]`; when the registry is
  built; then the one registration's missing reason encodes production
  `Phi-Guardrails-SDK`/`Phi-Guardrails-Core`, tests `Phi-Guardrails-Tests-SDK`,
  exempt `PGR-Scratch-Ghost`, and srcPath `nil` — the core built the view from the
  resolved configuration and handed it (D-81/D-53.5).
- `testEnvironmentViewCarriesResolvedSrcPath` — given the `#src`-carrying envelope
  (absolute scratch path) with the env kit; when the registry is built; then the
  missing reason encodes exactly that absolute path — `#src` crosses the kit
  boundary through the view and only through it.
- `testKitWithoutEnvironmentFormStillServedByFrozenForm` — given one envelope whose
  kits array holds a `PGRScratchEnvKit` block **and** a `PGRScratchSpecKit` block
  (one spec, distinct name); when the registry is built; then the env kit's reason
  shows the environment path, the spec kit's registration is exactly its accepted
  three-argument result, and order follows the kits array (the probe is per-kit;
  fallback intact, D-81 additive).

Fixtures: the accepted scratch baseline/kits above; the new `PGRScratchEnvKit`.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, 0 failures / 0 errors; the three new `PGRRegistryTest`
          cases listed by name, **every accepted `PGRRegistryTest` case byte-identical
          and green** (the fallback regression witness), and every previously accepted
          suite green — ≥239 run once E11-C01 is in per the listed serial pick order
          (230 + C01's 6 + these 3); membership + floor, never an exact ceiling.

OUT OF SCOPE
- Any `PCKKit` change (E11-C04 gives the coding kit its environment form).
- Any `PGRKit` skeleton change (B-28 (4); the probe folds inheritance — a skeleton
  default would falsely claim the form for every subclass).
- Amending `resolveKitClassNamed:` (the three-argument form stays the conformance
  baseline, D-81).
- Amending any accepted test method (additive only; the amended-surface note above).
- Caching the view anywhere class-side (R-35).

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67). Postcondition:
one commit `E11-C02: engine probe — core builds the kit environment view`, nothing
uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  confirmation every accepted PGRRegistryTest method stayed byte-identical ·
  deviations (each one-line justified) · new questions for the decision sheet.
