# C18 · recommendedBlock: the published stanza (M1-partial)      [E06 · depends: C17 · parallel: no]

GOAL      `PCKKit class>>recommendedBlock` answers the coding kit's published
          stanza as STON text — the two catalog lint rules — proven parseable
          and cleanly registering; the meta-rule line and P-STANZA-VALID land
          at E07.

TRACE     ch. 1 §1.3 `PGRKit` row (`recommendedBlock` → STON text, D-54/D-60) ·
          §1.2 (a recommended block is a documented template, composed at
          authoring time — never run-time machinery) · ch. 2 §2.4 (exactly one
          built-in in the recommended block, D-28) · ch. 3 §3.2/§3.2b (both
          catalog entries are in the recommended block, D-51) · roadmap E06
          goal + E07 ("stanza completion (meta-rule line) + P-STANZA-VALID").

## CONTEXT DIGEST

**What exists when this chunk starts:** C16/C17 accepted — `PCKKit` (package
`Phi-Coding-Kit`) with complete block dispatch: five keys recognized, lint
pipeline live, generic architecture/meta paths live. C13's
`PCKNoIsNilIfTrueRule` (severity `#error`). The built-in
`ReCodeCruftLeftInMethodsRule` ships with Pharo (severity `#error`, D-28).
`PCKKitTest` in `Phi-Coding-Kit-Tests-Rules`. Frozen inherited marker being
overridden (E02 digest, verbatim):

```smalltalk
PGRKit class >> recommendedBlock
    "The published stanza, single-sourced on the kit class, answered as STON text
    (a String, D-60); the init tool composes it into drafts and docs quote it."
    ^ self subclassResponsibility
```

**The stanza.** Single-sourced on the class; a String of pure-data STON (Symbol
keys, string values — D-16's artifact dialect). The E06 form names the two
catalog lint rules, catalog order (§3.2 then §3.2b):

```smalltalk
PCKKit class >> recommendedBlock
    ^ '{
	#kit : ''PCKKit'',
	#lintRules : [ ''PCKNoIsNilIfTrueRule'', ''ReCodeCruftLeftInMethodsRule'' ]
}'
```

- **No STON comments in the stanza** — STON's comment support is unverified and
  nothing may depend on it (P5; ch. 1 §1.1 states this for the artifact).
- The method comment must state: this is the M1-partial form; **E07 appends the
  `#metaRules` line** (`'PCKNoSkippedTestsMetaRule'`) so the recommended set is
  complete from M1's checkpoint — the roadmap rules that completion (E07's
  "stanza completion"), so the later edit is scheduled ground, not a
  frozen-surface amendment.
- P-STANZA-VALID (the full parse-resolve-conform property through registry
  construction) is **E07's** — this chunk proves the two E06-checkable halves:
  the text parses as a kit block, and the kit itself registers it cleanly.

**STON reading** (verified present with round-trip, D-15): `STON fromString:
aString` — the stanza must parse to a `Dictionary` with Symbol keys.

**Constitution rules that bite here:** the file (and by extension the stanza a
client composes into it) is the complete statement of what runs — nothing
arrives by default (P3/D-51; the stanza is a *template*, drafted into adopters'
files by the init command at authoring time); glossary — *recommended block* /
*stanza*; comments state constraints the code cannot show; no
`skip`/`expectedFailures`; a test that cannot fail is a defect.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export
to `src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present,
D-15); hand-writing class files is not allowed — the committed form must be what
the tooling emits. After export, a fresh `bash tools/build-image.sh` load from
committed `src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image
from committed `src/`; `bash tools/verify.sh` runs the pack's verify command
against it.

## DELIVERABLES

- `src/Phi-Coding-Kit/PCKKit.class.st` (modify — the one class-side method)
- `src/Phi-Coding-Kit-Tests-Rules/PCKKitTest.class.st` (modify — two methods
  added)
- LOC budget: target 60 / ceiling 150.

## TESTS FIRST

Test methods added to `PCKKitTest`:

- `testRecommendedBlockParsesAsKitBlock` — given `PCKKit recommendedBlock` /
  when `STON fromString:` / then a `Dictionary` whose `#kit` is `'PCKKit'` and
  whose `#lintRules` equals the ordered pair `('PCKNoIsNilIfTrueRule'
  'ReCodeCruftLeftInMethodsRule')` — catalog order, both entries, nothing else
  in the map beyond the two keys.
- `testRecommendedBlockRegistersCleanly` — given the parsed dictionary / when
  handed to `PCKKit registrationsFrom:` it `productionPackages:
  #('Phi-Guardrails-SDK') testsPackages: #()` / then exactly 2 specs, both
  resolved (`check` not nil, `missingReason` nil), named
  `'lint/PCKNoIsNilIfTrueRule'` and `'lint/ReCodeCruftLeftInMethodsRule'` —
  the stanza can never name something that does not resolve and register (the
  E06-form forerunner of P-STANZA-VALID; the full property arrives with E07's
  completion).

Fixtures: none new — the stanza and the accepted catalog rules are the subject.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0,
          0 failures, 0 errors; output lists the 2 new `PCKKitTest` methods
          plus every previously accepted suite — the 24 E01/E02 tests (19 SDK
          + 5 smoke), all accepted E06 siblings, and any accepted
          parallel-track (E03) suites (regression guard; membership + floor,
          never an exact ceiling). This is the epic's closing chunk: the full
          E06 named suite (22 kit tests) must be green — the exit checkpoint's
          leg 1 (≥46 run; exactly 46 only if no E03 suite has landed yet).

OUT OF SCOPE
- The `#metaRules` stanza line (E07) and P-STANZA-VALID's registry-construction
  arm (E07).
- The init tool / draft composition (`PGRConfigurationDraft`, E12).
- Quoting the stanza in docs (guides are E09's execution subject).
- Touching `package.st` files, the baseline, or anything outside the manifest.

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
          `plan/ledger.md`, D-67). Postcondition: exactly the manifest files,
          one commit `C18: PCKKit recommendedBlock stanza` before reporting for
          review; nothing left uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) · new
  questions for the decision sheet.
