# E12-C05 · `PGRConfigurationDraft` and the scheduled §0.3 mirror amendment  [depends: E12-C01 · parallel: yes (disjoint from C02/C03/C04; picked last in the listed order)]

GOAL      Deliver the init tool — `PGRConfigurationDraft class>>draftFor:` in
`Phi-Guardrails-Core`: baseline introspection + stanza composition → draft STON text
for human review, draft-only semantics — and land the accepted conformance manifest's
scheduled amendment (the config-author audience with `draftFor:`, plus the D-82
kit-environment reader triples).

TRACE     R-31 (draft half; the adoption half is code-free post-D-45) · spec ch. 8
§8.1 step 1 (the init command's whole contract) · ch. 1 §1.3 (the
`PGRConfigurationDraft` row: class `draftFor:` (a baseline name) → draft STON text
composing the kits' published stanzas; `-Core`; config-author surface) · ch. 0 §0.3
(config-author surface; the D-82 erratum scheduling the view's readers into the
conformance mirror) · D-49 (draft-only semantics) · D-53.6 (dedicated authoring-time
class, homed in `-Core`) · D-54.3 (the stanza is single-sourced on the kit class —
the init tool composes from it) · D-45 ruling 4 ("generation may guess, the run-time
gate may never infer").

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**The contract (spec ch. 8 §8.1 step 1, condensed):** one class-side message,
`PGRConfigurationDraft class>>draftFor:` (a baseline name String) → **draft STON
text** — a dedicated authoring-time class on the config-author surface
(`PGRConfiguration` is purely run-time, D-53). **Draft-only semantics (D-49):** it
inspects the loaded baseline, composes the kits' published stanzas, and proposes a
`guardrails.ston` for human review; generation may guess, the run-time gate may never
infer (D-45 ruling 4). Nothing at run time invokes it. It answers text and **writes
no file** (the caller pastes/saves; the accepted mutation boundary and the accepted
`PGRArchSelfTest` file-triad arm both stand).

**Home and walls (accepted, machine-enforced — the self-hosted gate at 12
registrations and the accepted `PGRArchSelfTest` run on every chunk):**
`Phi-Guardrails-Core`. The framework's own layer map allows **core → sdk only**, so
this class may compile literals of SDK classes (`PGRKit`,
`PGRConfigurationError`) and kernel/system classes — and **must not compile a literal
of `PCKKit` or any kit/toy/`-Gate` class** (a `PCKKit` literal in `-Core` reds
`architecture/PCKLayerMapCheck` on our own gate). The accepted core-neutrality wall
additionally bans SUnit/Renraku/AST-Core/Refactoring references from `-Core`, the
Transcript wall bans `Transcript`, and the file-triad/network arm bans
`FileReference`/`FileSystem`/`FileLocator`/Zinc references outside three ruled sites
this class is not among. Kit discovery is therefore **reflective**, anchored on the
SDK skeleton (below).

**Kit discovery (the composition population).** The spec says the draft "composes the
kits' published stanzas" and fixes the one-argument signature — which kits is the
tool's own guess (D-45 ruling 4 grants generation the guess; state it in the class
comment). Cut-time probe over the work image (probes.md P4/P6): image-wide
protocol-conformance discovery is **polluted** — five accepted duck-typed scratch
kits in a tests-role package implement the kit messages — while the SDK-skeleton
anchor is clean: `PGRKit allSubclasses` = `{PCKKit}` exactly. Prescribed guess,
exactly:

> discovered kits = `PGRKit allSubclasses` whose **class side**
> `includesSelector: #recommendedBlock` (the stanza is what the draft consumes; the
> per-class `includesSelector:` probe is the canonical guard shape, D-82, and never
> answers true for a subclass that merely inherits the skeleton's hook), sorted by
> class name for determinism.

A duck-typed kit (registration needs conformance, not ancestry — D-53) is simply not
*discovered*; its author composes its stanza by hand (§1.2 — composition is ordinary
authoring). The class comment states this boundary as the guess it is.

**The draft text to compose** (envelope keys per the frozen version-2 schema —
`#schemaVersion` · `#project` · `#baseline` · `#roles` · `#kits`; no `#src`, no
`#exemptNamePatterns` — the tool cannot know either):
- `#schemaVersion : 2` (the schema the accepted parser reads).
- `#project :` the baseline name minus a leading `'BaselineOf'` prefix (guess;
  `'BaselineOfToy'` → `'Toy'`).
- `#baseline :` the handed name.
- `#roles :` the **role guess by package-name shape**: introspect the loaded
  baseline (`(Smalltalk globals at: name asSymbol) project version packages`, names
  via `name` — the D-25.a spellings, groupless-safe per probes.md P8);
  a package whose name full-matches `'.*-Tests(-.*)?'` (D-15 `matchesRegex:`
  semantics; live-probed P9) goes to `#tests`, every other to `#production` — each
  role listing its package **names explicitly** (a guess should be literally
  reviewable; no patterns, no group names — the drafted file works for a baseline
  with no groups at all, the D-45 point).
- `#kits : [` each discovered kit's `recommendedBlock` text, spliced verbatim `]`
  (D-54.3: single-sourced on the kit class; the accepted `PCKKit recommendedBlock`
  answers pure-data STON text, probed parseable P7).
- Strict-input arm: a name that does not resolve to a loaded `BaselineOf` subclass
  raises `PGRConfigurationError` naming it (the SDK error the config-author already
  catches by class; malformed or unknown input raises a configuration error, never a
  silent default — constitution, family 7). `inheritsFrom: BaselineOf` is the
  subclass probe (the accepted `PCKSrcInventoryCheck` family).

The composed text must be **valid STON that the accepted parser accepts** for a
loadable target: for `'BaselineOfToy'` in the verify image the draft parses AND
validates via `PGRConfiguration fromString:` (all five toy packages loaded, roles
disjoint-and-total by construction, `PCKKit` and every stanza-named class loaded —
the P-STANZA-VALID accepted fact). Note what the draft is NOT: it is not the toy's
committed artifact (C04) — no `ToyNoIsNilIfFalseRule`, no `#layerMap` (the human
adds those; §8.1: "Add `#architectureChecks` + `#layerMap` when the project has
layers to declare").

**Surfaces the tests may use (probed at cut, probes.md P10/P7):** frozen caller
surface `PGRConfiguration class>>fromString:`; the specified-but-internal instance
readers the accepted suites already use in tests — `project`, `baselineClass`,
`productionPackageNames`, `testsPackageNames`, and `kitBlocks` (the ordered, verbatim
block maps — the stanza-equality assertion reads it); `STON class>>fromString:` (the
accepted pure-data STON entry, used by the parser itself) for turning the published
stanza text into a comparable map. The test class lives in a tests-role package —
outside every production wall — so it may reference `PCKKit` and toy names freely.

**The scheduled amendment — `PGRSurfaceConformanceTest` (accepted file, amended BY
SCHEDULE, never silently):** two schedule sources, both already in ruled/accepted
text: (1) the accepted test's own class comment and
`testManifestSpansTheFourCodeSurfacesAtM1` comment — "the config-author audience has
no code member at M1 (`PGRConfigurationDraft` is E12)" / "E12's `draftFor:` cut
amends this by schedule"; (2) the D-82 doc pass's ch. 0 §0.3 erratum — the
`PGRKitEnvironment` view's readers "join this roster's conformance-test mirror at the
next test-touching chunk" (this is that chunk; spec and mirror move together). The
amendment, exactly:

1. `kitAuthorSurface` gains four instance-side triples:
   `{ 'PGRKitEnvironment'. #instance. #productionPackages }`, `… #testsPackages`,
   `… #exemptPackages`, `… #srcPath` (the frozen E11 readers, re-probed P12). The
   optional `registrationsFrom:environment:` message joins **no** roster — it is
   per-kit optional with an engine probe and the `PGRKit` skeleton deliberately does
   not implement it (accepted E11 ground), so an implements-or-inherits triple on
   `PGRKit` would be false by design.
2. A new manifest audience `'config-author'` with the single triple
   `{ 'PGRConfigurationDraft'. #class. #draftFor: }` (ch. 0 §0.3: the init tool is
   the config-author surface's one code member).
3. `testManifestSpansTheFourCodeSurfacesAtM1` is **renamed**
   `testManifestSpansTheFiveAudiences` and amended: the audience set is now the five
   names including `'config-author'`, each non-empty; the `deny:` of
   `'config-author'` is removed (its schedule is discharged). Comment updated to
   state the E12-form pin.
4. The class comment's "config-author audience has no code member at M1
   (`PGRConfigurationDraft` is E12)" sentence updated to record the landing.
   `testEverySurfaceSelectorExistsWithRightArity`'s `>= 40` floor stays valid (41
   triples grow to 46) and is not edited; `testErrorSurfaceClassesAreCatchableByClass`
   untouched.

**Amendment table (scripted at cut over `git ls-files 'src/**/*.st'` — 110 files
scanned, probes.md P29):** consumers of the manifest surface = exactly one file, the
amended `PGRSurfaceConformanceTest.class.st` itself (manifest methods and their only
readers are one class). No other accepted file references the manifest, the audience
method names, or `PGRConfigurationDraft`. Every other accepted test file in this
epic's manifests: none — this is E12's only accepted-file amendment.

**Constitution rules that bite here:** no global state (compose fresh per call — no
class-side caching of discovery or text) · class-side named constructors n/a (pure
class-side function) · strict parsing — loud error, never a silent default ·
comments state constraints the code cannot show (the guess boundaries ARE such
constraints — state them) · touching any file outside the manifest is a review
rejection.

DELIVERABLES

Files (Tonel):
- **create** `src/Phi-Guardrails-Core/PGRConfigurationDraft.class.st`
- **create** `src/Phi-Guardrails-Tests-Core/PGRConfigurationDraftTest.class.st`
- **modify** `src/Phi-Guardrails-Tests-SDK/PGRSurfaceConformanceTest.class.st`
  (exactly the four amendment points above; every other method byte-identical)

Classes/methods:
- `PGRConfigurationDraft` (superclass `Object`, package `Phi-Guardrails-Core`) —
  class-side `draftFor: aBaselineName` plus private class-side helpers as needed
  (discovery, role guess, text assembly). Class comment: authoring-time only,
  draft-only semantics (D-49), the discovery and role-guess boundaries as guesses
  (D-45 ruling 4), answers text / writes nothing.
- `PGRConfigurationDraftTest` (superclass `TestCase`, package
  `Phi-Guardrails-Tests-Core`) — the four skeletons below.

LOC budget: target ~170 · ceiling 300.

TESTS FIRST  (`PGRConfigurationDraftTest`, package `Phi-Guardrails-Tests-Core`)

- `testDraftForToyParsesAndValidates` *(the §8.1 step-1 story end-to-end)* — given
  `PGRConfigurationDraft draftFor: 'BaselineOfToy'`; when the answered text is handed
  to `PGRConfiguration fromString:`; then it validates and answers a configuration
  with `project` = `'Toy'` and `baselineClass` name = `#BaselineOfToy` (the draft is
  honest input to the strict parser, not just plausible text).
- `testDraftGuessesRolesBySuffix` *(baseline introspection, the groupless case)* —
  given the same parsed draft; then `productionPackageNames asSortedCollection
  asArray` = `#('Toy-Core' 'Toy-Persistence' 'Toy-Rules' 'Toy-UI')` and
  `testsPackageNames` contains exactly `'Toy-Tests'` — the suffix guess assigned all
  five explicitly, with no group named (the target baseline has none to name).
- `testDraftComposesTheRecommendedStanza` *(D-54.3: composed from the message, not
  hand-maintained)* — given the same parsed draft; then some block of its `kitBlocks`
  equals `STON fromString: PCKKit recommendedBlock` (map equality — the drafted kit
  block IS the published stanza, byte-derived; membership, not an exact block count,
  so a future second shipped kit extends rather than breaks this).
- `testUnknownBaselineNameRaisesConfigurationError` *(loud failure over inference)* —
  given `draftFor: 'BaselineOfNoSuchThing'`; then `PGRConfigurationError` is
  signalled and its message names the missing baseline.

Fixtures: C01's `BaselineOfToy` (the introspection subject); the loaded `PCKKit`
(accepted ground). The test class references `PCKKit` and toy names freely — it is a
tests-role class, outside every layer/neutrality wall (the walls sweep production
packages only).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, 0 failures / 0 errors; the four `PGRConfigurationDraftTest`
          cases listed by name, `PGRSurfaceConformanceTest` green in its amended form
          (renamed `testManifestSpansTheFiveAudiences` listed; every other accepted
          method byte-identical), every previously accepted suite green — ≥256 run
          once E12-C01 is in per the listed serial pick order (250 + C01's 2 + these
          4; net 0 from the rename); ≥263 once C02/C03/C04 are in (their +7 swept);
          membership + floor, never an exact ceiling.
          **Plus the self-hosted regression leg:**
          `PHARO_VM=.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo IMAGE=.build/work/phi.image ./guardrails.sh guardrails.ston`
          → exit 0, **12 registrations unchanged**, `GATE: GREEN` — in particular
          `architecture/PCKLayerMapCheck` stays green over the grown `-Core` (the
          no-kit-literal law held) and `lint/…` stay green over the new production
          class.

OUT OF SCOPE
- Writing any file from `draftFor:` (text out only), any run-time invocation path,
  or wiring the draft into `PGRConfiguration`/`PGRGate` (D-49: the gate never
  infers).
- Discovery beyond the prescribed anchor (no image-wide protocol scan — probes.md P4
  shows it drafts scratch-kit stanzas; a future widening is a decision-sheet entry).
- Guessing `#src`, `#exempt`/`#exemptNamePatterns`, `#layerMap`, or any kit-block
  edit beyond verbatim stanza splicing (the human's ground, §8.1).
- Touching guide 1 (`docs/quickstarts/01-adopt-and-run.md` quotes `draftFor:`; its
  executable-sample witness is E15's scheduled `testAdoptAndRunSamples` — frozen
  roadmap; no doc edit here).
- Any manifest change beyond the four scheduled points (in particular: no
  `registrationsFrom:environment:` triple — see digest; no floor edit).

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67). Postcondition:
one commit `E12-C05: PGRConfigurationDraft + the scheduled conformance-mirror
amendment`, nothing uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output (sweep + gate
  leg) · the byte-identity check for the unamended `PGRSurfaceConformanceTest`
  methods · deviations (each one-line justified) · new questions for the decision
  sheet.
