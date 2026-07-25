# C20 · Scratch client fixtures        [E03 · depends: — · parallel: no]

GOAL      Land the three scratch fixture classes every E03 test builds on — two
          scratch baselines and one duck-typed kit — plus a sanity suite that pins
          their D-25.a behavior on this repo's own image.

TRACE     spec ch. 1 §1.1 (baseline as inventory; D-25.a expansion API) · ch. 9
          §9.3 (fixtures without red tests sit beside their tests, inert) ·
          D-25/D-25.a (verified Metacello spellings; empty-group addendum) ·
          D-53 (conformance, not ancestry — the duck-typed kit witnesses it) ·
          R-02 (client-declared target), R-05 (scratch client, never a real one).

## CONTEXT DIGEST

**What exists (frozen ground):** `src/Phi-Guardrails-Tests-Core/` is a package stub
from E01's frozen 21-directory inventory, already holding `PGRBaselineSmokeTest`;
the baseline is **not** edited (adding classes to an existing package touches no
`package.st` and no baseline group). E02 froze the kit protocol at exactly two
class-side messages (digest, `plan/04-epics/E02-sdk-vocabulary/chunks.md` —
reproduced here in full):

- `registrationsFrom: aBlock productionPackages: productionNames testsPackages: testsNames`
  → ordered collection of `PGRRegistrationSpec`s
- `recommendedBlock` → STON text (a String)

Conformance, not ancestry, is what registration requires (D-53); `PGRKit`'s frozen
class comment states "a duck-typed plain class implementing the pair registers
fine". This chunk's kit fixture is therefore **deliberately a plain `Object`
subclass**, not a `PGRKit` subclass — E03's resolution chunk (C23) and E04's
registry both lean on that witness.

**Verified spellings this chunk uses (probed 2026-07-25 in the D-31.a work image;
record: E03 chunks.md §probes; P5):**

- Class creation for fixtures follows the E01 authoring rule (in-image, Tonel
  export) — the fluid builder `BaselineOf << #Name` works and answers a
  `BaselineOf` subclass; the legacy
  `subclass:instanceVariableNames:classVariableNames:package:` is **gone** in
  Pharo 13.
- `<baseline>` pragma method with `spec for: #common do: [...]`, `spec package:`,
  `spec group:with:` — a baseline may declare a package that is **not loaded**
  (`'PGR-Scratch-Ghost'` lists in `version packages`, and
  `PackageOrganizer default packageNamed: 'PGR-Scratch-Ghost' ifAbsent: [nil]`
  answers nil) and a group that is **empty** (`group: 'x' with: #()` is declared,
  listed, expands to `#()` — D-25.a addendum).
- Expansion API (D-25.a, re-verified): `cls project version` → `version packages`
  (specs; `name`), `version groups` (specs; `name`), transitive
  `version packagesForSpecNamed: 'group'` (composite groups expand correctly).
- **Metacello refuses a group named like a declared package** ("incompatible
  specs" at version build) — do not declare one; the consequence for matcher
  resolution is Q-31 (C24's ground, not this chunk's).
- `PGRKit respondsTo: #recommendedBlock` — class-side `respondsTo:` works for
  conformance checks.

**The three fixture classes, all in `Phi-Guardrails-Tests-Core`:**

1. `BaselineOfPGRScratchGrouped` (superclass `BaselineOf`; the `BaselineOf*`
   naming exception applies — constitution §2). Its one method:

   ```smalltalk
   baseline: spec
       <baseline>
       spec for: #common do: [
           spec
               package: 'Phi-Guardrails-SDK';
               package: 'Phi-Guardrails-Core';
               package: 'Phi-Guardrails-Tests-SDK';
               package: 'PGR-Scratch-Ghost'.
           spec
               group: 'scratch-prod' with: #('Phi-Guardrails-SDK' 'Phi-Guardrails-Core');
               group: 'scratch-tst' with: #('Phi-Guardrails-Tests-SDK');
               group: 'scratch-ghost' with: #('PGR-Scratch-Ghost');
               group: 'scratch-overlap' with: #('Phi-Guardrails-SDK');
               group: 'scratch-empty' with: #();
               group: 'scratch-both' with: #('scratch-prod' 'scratch-ghost') ]
   ```

   Three real, loaded packages + one ghost; role-shaped groups, an overlap group
   (shares `Phi-Guardrails-SDK` with `scratch-prod`), an empty group, a composite
   group. Later chunks' configurations cite these names verbatim — the tree is
   part of the fixture contract.

2. `BaselineOfPGRScratchPlain` (superclass `BaselineOf`) — same three real
   packages (`Phi-Guardrails-SDK`, `Phi-Guardrails-Core`,
   `Phi-Guardrails-Tests-SDK`), **no groups at all** (P-ROLES-FROM-CONFIG's
   subject: role groups in a client's baseline are optional, never required).

3. `PGRScratchKit` (superclass `Object`) — class-side only, stateless:
   `registrationsFrom: aBlock productionPackages: productionNames testsPackages:
   testsNames` answers `OrderedCollection new`;
   `recommendedBlock` answers the String `'{ #kit : ''PGRScratchKit'' }'`.

**Constitution rules that bite here:** glossary exactly (these are *fixtures* for
the configuration's tests — inert, no `TestCase` among them except the sanity
suite); no global state (baselines and the kit are pure declarations); a test that
cannot fail is a defect — every sanity test below asserts introspected behavior,
not existence; no `skip`/`expectedFailures`.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export to
`src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present, D-15);
hand-writing class files is not allowed — the committed form must be what the
tooling emits (see `src/Phi-Guardrails-Tests-Core/PGRBaselineSmokeTest.class.st`).
After export, a fresh `tools/build-image.sh` load from the committed `src/` is the
proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against it
and asserts run count plus the 5 smoke tests.

## DELIVERABLES

- `src/Phi-Guardrails-Tests-Core/BaselineOfPGRScratchGrouped.class.st`
- `src/Phi-Guardrails-Tests-Core/BaselineOfPGRScratchPlain.class.st`
- `src/Phi-Guardrails-Tests-Core/PGRScratchKit.class.st`
- `src/Phi-Guardrails-Tests-Core/PGRScratchFixturesTest.class.st`
- LOC budget: target 90 / ceiling 160 (the two baseline methods and the kit's two
  one-line methods are fixture matter; the sanity suite is the code that counts).

## TESTS FIRST

Test methods on `PGRScratchFixturesTest`:

- `testGroupedBaselineDeclaresItsTree` — given `BaselineOfPGRScratchGrouped
  project version` / when collecting `packages` and `groups` names / then packages
  = the four declared names and groups = the six declared names (exact sets).
- `testGroupExpansionMatchesDeclaration` — when expanding
  `packagesForSpecNamed: 'scratch-prod'` / then exactly
  `#('Phi-Guardrails-SDK' 'Phi-Guardrails-Core')`.
- `testEmptyGroupExpandsEmpty` — when expanding `'scratch-empty'` / then empty
  (the D-25.a addendum, pinned on this image).
- `testCompositeGroupExpandsTransitively` — when expanding `'scratch-both'` / then
  exactly the three packages of its two member groups.
- `testGhostPackageDeclaredButUnloaded` — then `version packages` includes
  `'PGR-Scratch-Ghost'` **and** `PackageOrganizer default packageNamed:
  'PGR-Scratch-Ghost' ifAbsent: [nil]` answers nil (declaration is inventory, not
  loadedness).
- `testPlainBaselineHasNoGroups` — given `BaselineOfPGRScratchPlain project
  version` / then `groups` is empty and `packages` names exactly the three real
  packages.
- `testScratchKitConformsClassSide` — then `PGRScratchKit` class-side responds to
  both kit-protocol selectors, `registrationsFrom: Dictionary new
  productionPackages: #() testsPackages: #()` answers an empty collection, and
  `recommendedBlock` is a String — while `PGRScratchKit inheritsFrom: PGRKit` is
  **false** (the duck-type witness, D-53).

Fixtures: this chunk *is* the fixture chunk; nothing external.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 7 `PGRScratchFixturesTest`
          methods, the 19 accepted E02 SDK tests, and the 5 `PGRBaselineSmokeTest`
          methods (regression guard).

OUT OF SCOPE
- `PGRConfiguration` itself — C21 onward.
- Loading either scratch baseline via Metacello (they are introspection data,
  never loaded), editing `BaselineOfPhiGuardrails`, any `package.st`, or anything
  outside the manifest.
- Declaring a group named like a declared package (Metacello refuses it — Q-31).

COMMIT    Precondition: clean working tree modulo `plan/ledger.md` —
          `bash tools/precheck.sh` (D-67).
          Postcondition: exactly the manifest files, one commit
          `C20: scratch client fixtures` before reporting for review; nothing
          left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
