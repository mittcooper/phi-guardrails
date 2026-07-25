# E07-C06 · Stanza completion and P-STANZA-VALID      [E07 · depends: E07-C05 · parallel: no]

GOAL      `PCKKit recommendedBlock` reaches its complete M1 form — the `#metaRules`
          line joins the two catalog lint rules — and P-STANZA-VALID lands: the
          published stanza parses, every check it names resolves and registers
          through the kit's own dispatch, and every registered check conforms to
          the frozen check protocol.

TRACE     R-25 (the recommended set carries the meta-rule from birth, D-51) · spec
          ch. 5 §5.3 ("registered in the kit block's `#metaRules` — the recommended
          coding-kit block includes it, so every init-drafted config carries it
          from birth") · ch. 1 §1.3 `PGRKit` row (`recommendedBlock` → STON text,
          D-54/D-60) · ch. 9 **P-STANZA-VALID** · roadmap E07 ("stanza completion
          (meta-rule line) + P-STANZA-VALID") · E06 digest ("`recommendedBlock` in
          its M1-partial two-rule form (completed at E07 by roadmap schedule)").

## CONTEXT DIGEST

**What exists when this chunk starts:** E07-C05 accepted — the kit's dispatch is
complete for the behavioral kind (derivation, cache, own-meta-rule special case,
four-stage order). `recommendedBlock` still answers the E06 M1-partial two-key
stanza; `PCKKitTest>>testRecommendedBlockParsesAsKitBlock` pins that partial shape
(2 keys) and `>>testRecommendedBlockRegistersCleanly` (as amended by C05) hands the
fixture package and expects 3 resolved specs. Both amendments below are the
completion the E06 papers scheduled — not frozen-surface edits.

**The completed stanza** (single-sourced on the class; pure-data STON, Symbol keys,
string values — D-16's dialect; **no STON comments** — their support is unverified
and nothing may depend on it, P5):

```smalltalk
PCKKit class >> recommendedBlock
    ^ '{
	#kit : ''PCKKit'',
	#lintRules : [ ''PCKNoIsNilIfTrueRule'', ''ReCodeCruftLeftInMethodsRule'' ],
	#metaRules : [ ''PCKNoSkippedTestsMetaRule'' ]
}'
```

Update the method comment: this is the **complete M1 recommended set** (the two
catalog lint rules + the no-skips meta-rule); behavioral suites need no stanza line
— they derive from the adopter's tests role (§5.1); later milestones' checks join
by their own scheduled edits. An adopter keeps the meta-rule by keeping the line —
composition over defaults (D-51).

**P-STANZA-VALID (ch. 9, verbatim decidable assertion):** "each shipped kit's
`recommendedBlock` answers STON text (D-60) that parses cleanly as a kit block, and
every check it names resolves, registers, and conforms to its protocol — the stanza
the init tool composes from can never drift from the code it describes."
**Conformance is asserted directly at the kit boundary** (agent call, recorded in
`chunks.md`): E04's engine-side validation is not yet accepted ground this round,
and the property's letter needs no engine — the test asserts each registered
check's protocol itself.

**The frozen check protocol a conforming instance answers (E02 digest):** `run` ·
`kind` · `canFix` · `packages` (instance side). Kind agreement (D-60's engine fact,
asserted directly here): each resolved spec's `kind` equals its check's own `kind`.

**Signatures used (verbatim):**

```smalltalk
STON fromString: aString      "→ Dictionary with Symbol keys (D-15/D-16)"
PCKKit class >> recommendedBlock            "→ STON text (String)"
PCKKit class >> registrationsFrom: aBlock productionPackages: p testsPackages: t
"spec readers: name · kind · check · missingReason"
```

**Expected registration of the completed stanza** — parsed and handed to the kit
with production `#('Phi-Guardrails-SDK')`, tests
`#('Phi-Coding-Kit-Fixtures-Behavioral')` — exactly 4 specs, in the frozen order:

1. `'lint/PCKNoIsNilIfTrueRule'` (#lint)
2. `'lint/ReCodeCruftLeftInMethodsRule'` (#lint)
3. `'behavioral/Phi-Coding-Kit-Fixtures-Behavioral'` (#behavioral — derived suite)
4. `'behavioral/PCKNoSkippedTestsMetaRule'` (#behavioral — the own-class cache path)

**Constitution rules that bite here:** the file is the complete statement of what
runs — the stanza is a documented template composed at authoring time, never
run-time machinery (P3/D-51); glossary — *recommended block* / *stanza*; comments
state constraints the code cannot show; a test that cannot fail is a defect.

**Authoring rule (E01 precedent, verbatim):** author classes in-image and export to
`src/` with the image's Tonel tooling (`TonelWriter` / Iceberg — present, D-15);
hand-writing class files is not allowed — the committed form must be what the
tooling emits. After export, a fresh `bash tools/build-image.sh` load from committed
`src/` is the proof the round trip holds.

**Build/verify workflow:** `bash tools/build-image.sh` builds the work image from
committed `src/`; `bash tools/verify.sh` runs the pack's verify command against it.

## DELIVERABLES

- `src/Phi-Coding-Kit/PCKKit.class.st` (modify — `recommendedBlock` only)
- `src/Phi-Coding-Kit-Tests-Rules/PCKKitTest.class.st` (modify — 1 method added,
  2 amended)
- LOC budget: target 70 / ceiling 150.

## TESTS FIRST

Amendments to `PCKKitTest` (2 — the scheduled completion of the C18 pins):

- `testRecommendedBlockParsesAsKitBlock` — now: the parsed `Dictionary` has exactly
  **3** keys; `#kit` = `'PCKKit'`; `#lintRules` = the ordered catalog pair;
  `#metaRules` = `#('PCKNoSkippedTestsMetaRule')`; comment updated (complete M1
  form).
- `testRecommendedBlockRegistersCleanly` — now: **4** specs, the name array exactly
  the four names in the order above, every `check` non-nil, every `missingReason`
  nil.

New method on `PCKKitTest` (1):

- `testRecommendedBlockParsesAndConforms` — **P-STANZA-VALID** (ch. 9 name): given
  `PCKKit recommendedBlock` / when parsed and handed to
  `registrationsFrom:productionPackages:testsPackages:` (the inputs above) / then
  every spec is resolved, and each spec's check answers the frozen protocol —
  responds to `run`, `kind`, `canFix`, and `packages` — with the spec's `kind`
  equal to the check's own `kind` (the D-60 agreement fact, asserted directly): the
  stanza can never drift from the code it describes.

Fixtures: none new — the stanza, the two catalog rules, and E07-C01…C05's accepted
deliverables are the subject.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh` — exit 0, 0 failures,
          0 errors; output lists the new `testRecommendedBlockParsesAndConforms`
          and both amended stanza tests, plus every previously accepted suite —
          the 88 accepted E01/E02/E03/E06 tests (in their C05-amended form), the
          19 accepted E07-C01…C05 tests, and any accepted parallel-track
          (E04/E05/E08) suites (membership + floor ≥108, never an exact ceiling).
          This is the epic's closing chunk: the full E07 named suite must be green
          — the exit checkpoint's leg 1 (see `chunks.md`).

OUT OF SCOPE
- Any dispatch change (`registrationsFrom:` is C05-complete); any new block key.
- Architecture stanza lines (`#architectureChecks`/`#layerMap` enter the
  recommended block only if a later epic's scheduled ground says so — not implied
  here).
- The init tool / draft composition (`PGRConfigurationDraft`, E12); quoting the
  stanza in docs (E09's execution subject).
- Touching `Phi-Coding-Kit-Rules`, any other `-Tests-Rules` file, `package.st`
  files, or the baseline.

COMMIT    Precondition: `bash tools/precheck.sh` exits 0 (clean tree modulo
          `plan/ledger.md`, D-67). Postcondition: exactly the manifest files, one
          commit `E07-C06: recommendedBlock completion and P-STANZA-VALID`
          (epic-qualified ID, D-73) before reporting for review; nothing left
          uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output · deviations
  from the work order (each with one-line justification) · new questions for the
  decision sheet.
