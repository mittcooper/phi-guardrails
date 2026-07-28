# E11-C05 · The framework artifact completed to its §7.5 form — self-hosted walls  [depends: E11-C02, E11-C04 · parallel: no]

GOAL      Grow the framework's own `guardrails.ston` to its complete §7.5 form — `#src`, both `#architectureChecks` entries, the §4.4 `#layerMap` — taking the self-hosted gate from 10 to 12 registrations, and execute the scheduled amendment of `PCKArtifactBlockM1FormTest` so the pin witnesses the completed form.

TRACE     R-38 (self-hosting, full form) · spec ch. 7 §7.5 (the artifact's complete declaration) · ch. 4 §4.4 (the layer map: four layers, four allowed edges — D-53) · D-79/D-79.a (map semantics; the four edges are the complete declaration — nothing inferred) · D-45 ruling 2 (`#src : 'src'` relative to the config file's directory) · D-51 (every check named explicitly — the artifact eats our own composition rule) · P-SELF-HOSTED (full form) · P-NO-DEAD-SRC (the live `src/` covered via the self-hosted registration) · the E09 scheduled-ground line ("E11 amends the M1-form assertions by schedule when the artifact grows" — the pin test's own class comment).

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**The committed artifact today (repo root `guardrails.ston`, verbatim):**

```ston
{
	#schemaVersion : 2,
	#project : 'PhiGuardrails',
	#baseline : 'BaselineOfPhiGuardrails',
	#roles : {
		#production : [ 'production' ],
		#tests : [ 'tests' ],
		#exempt : [ 'fixtures', 'toy' ] },
	#exemptNamePatterns : [ 'Phi-Coding-Kit-Fixtures-.*', 'Toy-.*' ],
	#kits : [ {
		#kit : 'PCKKit',
		#lintRules : [ 'PCKNoIsNilIfTrueRule', 'ReCodeCruftLeftInMethodsRule' ],
		#metaRules : [ 'PCKNoSkippedTestsMetaRule' ] } ]
}
```

**The completed §7.5 form (this chunk's target):** add top-level `#src : 'src'`
(after `#project` or `#baseline` — position free, presence law; relative, resolved
against the config file's directory, D-45 ruling 2), and grow the kit block with
`#architectureChecks` and `#layerMap` (canonical key order `#kit` · `#lintRules` ·
`#architectureChecks` · `#layerMap` · `#metaRules`):

```ston
	#kits : [ {
		#kit : 'PCKKit',
		#lintRules : [ 'PCKNoIsNilIfTrueRule', 'ReCodeCruftLeftInMethodsRule' ],
		#architectureChecks : [ 'PCKLayerMapCheck', 'PCKSrcInventoryCheck' ],
		#layerMap : {
			#layers : {
				'sdk' : [ 'Phi-Guardrails-SDK' ],
				'core' : [ 'Phi-Guardrails-Core' ],
				'gate' : [ 'Phi-Guardrails-Gate' ],
				'kit' : [ 'Phi-Coding-Kit', 'Phi-Coding-Kit-Rules',
					'Phi-Coding-Kit-Architecture', 'Phi-Coding-Kit-Behavioral' ] },
			#allowed : [
				[ 'core', 'sdk' ],
				[ 'gate', 'core' ],
				[ 'gate', 'sdk' ],
				[ 'kit', 'sdk' ] ] },
		#metaRules : [ 'PCKNoSkippedTestsMetaRule' ] } ]
```

The map is §4.4 verbatim: layers `sdk`/`core`/`gate`/`kit` over the **seven
production packages**; allowed edges exactly `core→sdk` · `gate→core` · `gate→sdk` ·
`kit→sdk` (D-53). Under D-79 these four directed one-way non-transitive edges are the
**complete** declaration — nothing inferred, self-reference implicit (intra-layer,
incl. kit-package→kit-package, needs no declaration). **No `#unlayered` key**: the
four layers already total over the production role, so the completeness law (layers +
`#unlayered` jointly cover the production role, E10) is satisfied with the optional
key absent. The frozen `#layerMap` format (E10 digest): `#layers` map
layerName-String → package-name-String list (mandatory) · `#allowed` list of
two-element `[from, to]` declared-layer-name lists (mandatory) · `#unlayered`
(optional). STON detail: sub-map keys `#layers`/`#allowed` are Symbols like every
artifact key; layer names and package names are Strings.

**What the gate now runs (12 registrations, canonical four-stage order):**
`lint/PCKNoIsNilIfTrueRule` · `lint/ReCodeCruftLeftInMethodsRule` ·
`architecture/PCKLayerMapCheck` · `architecture/PCKSrcInventoryCheck` · seven
`behavioral/<tests-role package>` suites · `behavioral/PCKNoSkippedTestsMetaRule`.
The M1 count was 10; the two architecture entries make 12.

**The scheduled amendment (the pin test).** Accepted
`PCKArtifactBlockM1FormTest` (package `Phi-Coding-Kit-Tests-Architecture`) reads the
committed artifact off disk and pins its form; its class comment says **"E11 amends
the M1-form assertions by schedule when the artifact grows"** — this chunk is that
schedule. Current accepted shape (verbatim, all three tests + both helpers):

- `artifactMap` — `STON fromString: (self repoRoot / 'guardrails.ston') readStream upToEnd`.
- `codingKitBlock` — `(self artifactMap at: #kits) first`.
- `m1Specs` — `PCKKit registrationsFrom: self codingKitBlock productionPackages:
  #( 'P-One' ) testsPackages: #( 'T-One' )`.
- `repoRoot` — upward walk (≤8 levels) from working and image directories for a
  directory holding `guardrails.ston`; errors loudly if not found. **Keep verbatim.**
- `testCodingKitBlockIsTheM1Form` — asserts one kit block, sorted keys =
  `#( #kit #lintRules #metaRules )`, denies `#architectureChecks` / `#layerMap` /
  top-level `#src`.
- `testEveryNamedCheckResolves` — asserts every `m1Specs` spec's `check` notNil.
- `testM1BlockRegistersLintAndMetaOnly` — asserts spec names =
  `#( 'lint/PCKNoIsNilIfTrueRule' 'lint/ReCodeCruftLeftInMethodsRule'
  'behavioral/T-One' 'behavioral/PCKNoSkippedTestsMetaRule' )`.

Why the helper must change too: with `#layerMap` present, the kit validates it at
block-open against the handed production role — over scratch `#('P-One')` the real
map cannot cover, so the three-argument drive would raise. The amended helper drives
the **environment form** (E11-C04) with the **real seven production packages** (all
loaded in the verify image) and the repo's real `src/`:

```smalltalk
completedSpecs
    ^ PCKKit
        registrationsFrom: self codingKitBlock
        environment: (PGRKitEnvironment
            productionPackages: #( 'Phi-Guardrails-SDK' 'Phi-Guardrails-Core'
                'Phi-Guardrails-Gate' 'Phi-Coding-Kit' 'Phi-Coding-Kit-Rules'
                'Phi-Coding-Kit-Architecture' 'Phi-Coding-Kit-Behavioral' )
            testsPackages: #( 'T-One' )
            exemptPackages: #(  )
            srcPath: (self repoRoot / 'src') fullName)
```

P-SDK-EDGE holds: the class still references only STON, `PCKKit`, and SDK classes
(`PGRKitEnvironment` is SDK) — never `PGRConfiguration`/`PGRRegistry`/any
`-Core`/`-Gate` class. Reading the config (and handing `src/` for the specs'
construction) is file I/O a test may do; it is not invoking the gate (§8.1's
residual caveat bans only that).

**Amended assertions (the completed-form pin):**
- `testCodingKitBlockIsTheCompletedForm` *(replaces `testCodingKitBlockIsTheM1Form`)*
  — one kit block; sorted keys = `#( #architectureChecks #kit #layerMap #lintRules
  #metaRules )`; artifact `#src` = `'src'`; the `#layerMap` sub-map's key set =
  `#( #allowed #layers )` (no `#unlayered` — the four layers are total); the
  `#architectureChecks` value = `#( 'PCKLayerMapCheck' 'PCKSrcInventoryCheck' )`.
- `testBlockRegistersTheCompletedFormSpecs` *(replaces
  `testM1BlockRegistersLintAndMetaOnly`)* — `completedSpecs` names, in canonical
  order: `#( 'lint/PCKNoIsNilIfTrueRule' 'lint/ReCodeCruftLeftInMethodsRule'
  'architecture/PCKLayerMapCheck' 'architecture/PCKSrcInventoryCheck'
  'behavioral/T-One' 'behavioral/PCKNoSkippedTestsMetaRule' )`.
- `testEveryNamedCheckResolves` *(kept, now over `completedSpecs`)* — every spec's
  `check` notNil: both architecture entries resolve live (the map covers the seven
  loaded packages; `#src` is handed) — a missing registration in the self-hosted
  artifact is a red test here before it is a gate failure (P6/R-38).

Class name and `repoRoot` stay; the class comment is rewritten: it pins the
**completed §7.5 form** (the name's "M1" is a historical anchor — the class was born
pinning the M1 form and now pins each scheduled growth; renaming would orphan the
accepted ledger/checkpoint references to it).

── AMENDED-SURFACE TABLE (scripted over committed sources at the cut; the ONLY accepted test file E11 amends) ──

Enumeration script (run against `git ls-files 'src/**/*.st' 'docs/**/*.md'
'tools/*' 'guardrails.sh' '.github/workflows/*' '.smalltalk.ston'` — the committed
code + product-doc + infra scope; 116 files scanned, nonzero asserted;
independently re-confirmed by the validator's full-tree 237-file sweep): every
committed file referencing `guardrails.ston`, asserting artifact keys, or asserting
a 10-registration count.

| Committed consumer | Relation to the artifact's form | Amendment |
|---|---|---|
| `PCKArtifactBlockM1FormTest` (3 tests + `m1Specs` helper + class comment) | reads the committed artifact and pins its M1 form | **amended here** — per the design above (its own comment schedules exactly this) |
| `PGRConfigurationTest` line 139 | writes its **own scratch** `guardrails.ston` in a scratch directory (a `fromFile:` fixture) | none — never reads the committed artifact |
| `PGRGateTest` lines 247–267 | writes a **decoy** `guardrails.ston` in the work image's working directory (P-NO-DEFAULT-PATH), own spliced content | none |
| `PCKNoSkippedTestsMetaRuleTest` class comment | prose mention only | none |
| `docs/quickstarts/01/02/03` | client-sample configs (Acme/DK), prose pointers | none — no fence reads the committed artifact (guide-1 fences are untested until M4, accepted E09 note) |
| 10-registration count in committed code/docs | **zero committed files assert it** (scripted: no hits for `10 registrations`/`equals: 10` over the sweep) — the count lives in the gate's runtime output and frozen plan history only | none |

No other accepted test or guide asserts the artifact's keys or count. The kit- and
engine-side callers of `registrationsFrom:` were enumerated and dispositioned in
C02/C04's notes (delegation/fallback, behavior-preserving, zero amendments).

**Roadmap-budgeted risk (binding conduct):** the first run of the completed artifact
may surface REAL violations in our own code — that is the product working. A genuine
red finding is **fixed** (if it is a true defect within this chunk's power: an
out-of-scope-file fix is a stop-and-report) or **filed as a decision-sheet
question** — the map and the artifact are **never weakened to reach green** (no
edge added, no package unlayered, no check unregistered — P6; constitution forbidden
moves). Expected state from accepted ground: green — E09's `PGRArchSelfTest` already
enforces these walls reflectively and the 21 `src/` directories are the 20
role-covered packages + the baseline's own (absorbed by the baseline clause).

**Constitution rules that bite:** P6 (never weaken a check to pass); the artifact is
pure-data STON (D-16); every check named explicitly (D-51); comments state
constraints code cannot show. Touching any file outside the manifest is a review
rejection.

DELIVERABLES

Files:
- **modify** `guardrails.ston` (repo root) — the completed §7.5 form above.
- **modify** `src/Phi-Coding-Kit-Tests-Architecture/PCKArtifactBlockM1FormTest.class.st`
  — the scheduled amendment (helper + two renamed/reshaped tests + kept third +
  class comment).

LOC budget: target ~90 · ceiling 300 (the artifact's STON is data; the test file is
the code half).

TESTS FIRST

The three amended pin tests above ARE this chunk's tests (given the committed
artifact on disk; when parsed / driven through the kit's environment form; then the
completed form and its live resolution hold). Write them first against the
still-M1 artifact and watch the two form tests fail; complete the artifact; watch
all three go green.

VERIFY    Two instruments, same commit (the epic's — and M2's — both-instruments
          criterion, first proven here):
          1. `bash tools/build-image.sh && bash tools/verify.sh` — exit 0, 0
             failures / 0 errors; the three amended pin tests listed by name; every
             previously accepted suite and every earlier E11 suite green — ≥250 run
             (230 at cut + C01 6 + C02 3 + C03 5 + C04 6 + net 0 here); membership +
             floor, never an exact ceiling.
          2. `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston`
             — exit 0, `PhiGuardrails`, **12 registrations**, `GATE: GREEN` (the
             self-hosted gate now enforcing the walls it previously only
             self-tested).

OUT OF SCOPE
- Renaming `PCKArtifactBlockM1FormTest` (historical anchor; comment carries the
  reading).
- Touching `PGRArchSelfTest` (the reflective walls stay as the map's independent
  witness — two instruments are the point, not redundancy to prune).
- Any `#unlayered` key, any fifth layer, any fifth edge (D-53/D-79: the declaration
  is complete as specified; additions are decision-sheet ground).
- Weakening anything to reach green (the risk clause above).
- `.smalltalk.ston`, `ci.yml`, `guardrails.sh`, `tools/*` (no infra change is
  needed; the gate reads the artifact it is handed).

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67). Postcondition:
one commit `E11-C05: guardrails.ston completed to its §7.5 form`, nothing
uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output · **both
  instrument outputs** (verify sweep tail + the gate's 12-registration GREEN tail) ·
  confirmation the amendment table held (only the pin-test file among accepted tests
  changed) · any real violation surfaced and its disposition (fixed here / filed —
  never weakened) · deviations (each one-line justified) · new questions for the
  decision sheet.
