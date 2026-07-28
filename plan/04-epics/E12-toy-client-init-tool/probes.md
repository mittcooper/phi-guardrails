# E12 · Cut-time probe record (D-82/Q-39 obligation)

*Every skeleton assertion in this cut that names a reflective predicate or a
frozen-surface selector/constructor was executed against the work image — or checked
against the frozen digest — before the cut was committed. Work image: rebuilt at HEAD
`bca7c9b` by `bash tools/build-image.sh` on 2026-07-28 (group `CI` from
`tonel://<repo>/src`), probed headless with the D-31.a VM
(`.build/pharo/vm/Pharo.app/Contents/MacOS/Pharo … eval`). Transcripts verbatim below;
digest-checked rows cite their frozen table instead of a transcript. This file is part
of the epic's validation record (the validator spot-checks ≥3 probes live).*

## Live probe transcripts

**P1 — the flag-only rule base and its declaration spellings (E12-C02):**

```
P1 ReNodeMatchRule exists: true
P1 ReNodeMatchRule canUnderstand matches: true
P1 ReNodeMatchRule canUnderstand addMatchingExpression: true
P1 ReNodeMatchRule inheritsFrom ReAbstractRule: true
```

**P2 — the `isNil ifFalse:` match pattern fires/stays silent, end-to-end (E12-C02/C03):**
a scratch `ReNodeMatchRule` subclass declaring
`self matches: '`@x isNil ifFalse: [`.@block]'`, run via the D-15 checker recipe
(`ReSmalllintChecker new rule: {…}; environment: (RBPackageEnvironment packageName: …);
run`) over a scratch package holding one bad method
(`^ x isNil ifFalse: [ x printString ]`) and one clean twin (`ifNotNil:`):

```
P2 critiques total: 1
P2 bad-plant critiques: 1
P2 good-fixture critiques: 0
```

**P3 — SUnit result counting protocol for the planted-suite witnesses (E12-C03):**

```
P3 skip-suite result class: TestResult
P3 result canUnderstand #runCount: true
P3 result canUnderstand #passedCount: true
P3 result canUnderstand #failureCount: true
P3 result canUnderstand #errorCount: true
P3 result canUnderstand #skippedCount: true
P3 skip-suite skippedCount: 1            (PCKSkippingFixtureTest suite run)
P3 fail-suite failureCount: 1 errorCount: 1 runCount: 2   (PCKFailingFixtureTest suite run)
```

**P4/P5/P6 — kit discovery for the draft tool (E12-C05):** image-wide protocol
discovery is polluted; the `PGRKit`-subclass anchor is clean:

```
P4 PCKKit class includesSelector recommendedBlock: true
P4 PGRKit class includesSelector recommendedBlock: true
P4 class-side recommendedBlock implementors: #(#PCKKit #PGRKit #PGRScratchConfigErrorKit
    #PGRScratchEnvKit #PGRScratchKit #PGRScratchSpecKit #PGRScratchThrowingKit)
P5 allClassesAndTraits works, size: 10720
P6 PGRScratchKit/-EnvKit/-SpecKit/-ConfigErrorKit/-ThrowingKit superclass: Object (all five)
P6 PCKKit superclass: PGRKit
P6 PGRKit allSubclasses: #(#PCKKit)
P6 discovery(PGRKit allSubclasses + class-side recommendedBlock): #(#PCKKit)
```

**P7 — the published stanza parses (E12-C05):**

```
P7 stanza parses to: Dictionary keys: #(#kit #lintRules #metaRules)
```

**P8 — groupless-baseline introspection (E12-C01/C05; the accepted E03 scratch
fixture as the live stand-in for the not-yet-existing `BaselineOfToy`):**

```
P8 scratch-plain baseline packages: #('Phi-Guardrails-Core' 'Phi-Guardrails-SDK' 'Phi-Guardrails-Tests-SDK')
P8 scratch-plain baseline groups size: 0
```

**P9 — the §1.1 matchers and the C05 role-guess regex, live in the D-15 dialect:**

```
P9 Toy-Core vs production pattern: true       ('Toy-Core' matchesRegex: 'Toy-(Core|UI|Persistence|Rules)')
P9 Toy-Tests vs production pattern: false
P9 Toy-Tests suffix guess -Tests: true        ('Toy-Tests' matchesRegex: '.*-Tests(-.*)?')
P9 Phi-Guardrails-Tests-Core suffix guess: true
```

**P10–P12, P18, P24–P28 — frozen/tabled surface spellings named by skeletons:**

```
P10 fromString exists: true                    (PGRConfiguration class)
P10 PGRConfiguration canUnderstand: #project #kitClasses #kitBlocks #baselineClass
    #productionPackageNames #testsPackageNames #exemptPackageNames #srcPath — all true
P11 PGRRegistry class fromConfiguration: true; instance #registrations #size — true
P11 PGRRegistration canUnderstand: #name #kind #isResolved #run — all true
P12 PGRKitEnvironment canUnderstand: #productionPackages #testsPackages
    #exemptPackages #srcPath — all true
P18 PCKLintRuleCheck class rule:packages: true
P24 PGRVerdict class-side #green #greenAdvisories: #redFindings: #missingReason: — true
P24 PGRVerdict instance #status #isGreen #registrationName #kind #findings #advisories — true
P24 PGRFinding instance #target #message #rationale — true
P25 ReCodeCruftLeftInMethodsRule class-side severity itself: true
P26 PGRConfigurationError exists: true
P27 TestCase canUnderstand skip: true
P28 PCKKit class includesSelector registrationsFrom:environment: true
```

**P13 — the registered built-in catches the `Transcript show:` plant form (E12-C03):**
a scratch class compiling `noisy Transcript show: 'hi'. ^ 42`, checker recipe:

```
P13 code-cruft critiques on Transcript show: plant: 1
```

**P14 — ground-fact correction 3 re-confirmed (D-80): no red-with-advisories constructor:**

```
P14 PGRVerdict class includesSelector redFindings:advisories: false
```

**P16 — `BaselineOfToy` collision state (D-58 re-confirmed at cut):**

```
P16 BaselineOfToy already bound: false
P16 BaselineOf exists: true
```

**P33 — the §1.1 toy artifact text (comments stripped) is well-formed STON with the
expected structure (E12-C04):** the exact text prescribed in C04, parsed raw:

```
P33 artifact parses to: Dictionary keys: #(#baseline #kits #project #roles #schemaVersion)
P33 kit block keys: #(#architectureChecks #kit #layerMap #lintRules #metaRules)
P33 lintRules: #('PCKNoIsNilIfTrueRule' 'ReCodeCruftLeftInMethodsRule' 'ToyNoIsNilIfFalseRule')
P33 layerMap layers keys: #('domain' 'persistence' 'ui')
P33 unlayered: #('Toy-Rules')
```

**P15 — the accepted sweep at cut time (both instruments):**

```
250 run, 250 passes, 0 failures, 0 errors.
VERIFY PASS: exit 0, 250 run, all 5 smoke tests present
GATE: GREEN           0 blocking of 12 · exit 0    (./guardrails.sh guardrails.ston)
```

## Digest-checked rows (Q-39's frozen-digest arm — no live transcript needed)

- **`PCKKit class>>registrationsFrom:productionPackages:testsPackages:`** (named by
  E12-C03's architecture witness) — digest-exact in the frozen E02 kit-protocol table
  and the frozen E07 digest's completed order law; additionally live-confirmed
  incidentally by P28's sibling probe and by the accepted `PCKKitTest` suite green in
  the P15 sweep.
- **`PGRRegistrationSpec` instance readers `name` · `kind` · `check` ·
  `missingReason`** (named by E12-C03's spec filtering) — digest-exact in the frozen
  E02 SDK table (ch. 1 §1.3's `PGRRegistrationSpec` row); exercised by the accepted
  `PGRRegistrationSpecTest`/`PGRRegistryTest` green in the P15 sweep.
- *(Validator round 1 re-probed both live against the work image: both true.)*

## Scripted consumer sweeps (amended-surface law; absolute-path grep over committed src/)

**P29 — the one amended accepted file's consumer table (E12-C05):** grep over
`git ls-files 'src/**/*.st'` (**110 files scanned — nonzero asserted**) for
`PGRSurfaceConformanceTest`, `kitAuthorSurface`, `gateCallerSurface`,
`checkAuthorSurface`, `fixInvokerSurface`, `configAuthorSurface`:
exactly **one** referencing file — `src/Phi-Guardrails-Tests-SDK/PGRSurfaceConformanceTest.class.st`
(the manifest and its consumers are one class; no other accepted test reads it).

**P30 — no accepted test asserts the toy packages are classless/empty:** grep `Toy`
over the same 110 files; every hit inspected: `PGRToySweepExemptionTest` (name/group
facts only — package *lists*, not contents), `PGRBaselineSmokeTest` (frozen group
memberships — unchanged by adding classes to packages), `PGRArchSelfTest` (string-level
witness `'Toy-Core' beginsWith: 'Toy-'` + an M1-era comment, no classless assertion),
`PGRConfigurationTest` / `PGRReportTest` (string literals in scratch artifacts and
renderings), the five `Toy-*/package.st` stubs, `BaselineOfPhiGuardrails` (group tree,
untouched). **Zero committed files assert a toy package has no classes.**

**P31 — `draftFor:`/`PGRConfigurationDraft` committed references:** the accepted
`PGRSurfaceConformanceTest` class comment + the amended pin's own comment (both
schedule this cut), and `docs/quickstarts/01-adopt-and-run.md:59` (guide 1 — its
executable-sample witness is E15's `testAdoptAndRunSamples` by the frozen roadmap;
E12 touches no doc).

**P32 — zero committed files assert a 10- or 12-registration count** outside the
E11-amended pin test's own scheduled form (grep `12 registrations|registrationNames`
over the 110 files: no hits).
