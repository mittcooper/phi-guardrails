## Validator report — E10 (layer-map check), M2

**Verdict: PASS** (zero BLOCKING findings). Two MINOR punch-list items and two advisories ride the report; the producer sweeps them in one batch without re-validation.

Scanned-file counts (all sweeps ran on absolute paths, all asserted nonzero): 7 epic docs (6 work orders + `chunks.md`); 78 committed `.class.st` files.

### Checklist results

**1 · Mechanical (scriptable) — clean.**
- Every `depends-on` chunk exists: C01(—), C02(C01), C03(—), C04(C01,C03), C05(C03,C04), C06(C02,C04) — all referents are E10-C01…C06.
- `[P]`: only C03 is `[P]`; its manifest (`PCKLayerMapFixture{,Test}`) is disjoint from C01/C02 (`PCKLayerMap`/`PCKLayerMapTest`). `chunks.md` supplies an explicit per-file disjointness cross-check that holds.
- LOC targets (110/120/110/150/100/130 = 720) match the `chunks.md` table row-for-row; 6 chunks = roadmap's "~6"; every chunk ≤150 target, none near the 300 ceiling.
- Every work order carries exactly one `VERIFY` block.
- Ledger rows ↔ work-order files are one-to-one (6↔6) and the ledger's depends-on column matches every work-order header verbatim.

**2 · Self-containment (judgment) — one MINOR.** Sampled C04 (the walk, most complex) and C06 (kit dispatch). Both inline every signature they use (PGRCheck/PGRVerdict/PGRFinding rows, PCKLayerMap readers+lookups, the verbatim current `registrationsFrom:` body in C06, PackageOrganizer spellings). No "see other document" pointers; each work order asserts "do not read other documents." See MINOR-1 for the one dependency-annotation gap.

**3 · Tests are real — clean.** Every skeleton is given/when/then with load-bearing assertions (e.g. `testFiresOnForbiddenReference` asserts `target` is exactly `'PCKScratchUiView>>#usesPersistence'` and the message names both layers; C05's absence-tests deliberately add a would-fire edge so they cannot pass vacuously). No existence-only tests.

**4 · Epic coverage — clean (one MINOR on arithmetic).** Roadmap assigns E10 "ch. 4 (all)": §4.1 structure→C01, §4.1 completeness law→C02, §4.1 erratum→C05, §4.2 walk→C04, §4.2 registration name & §4.3 generic path→C06, §4.4 fixture pair→C03/C04. §4.4 self-hosting is correctly deferred to E11 (matches the roadmap E11 row and the M1 artifact freeze at E09). The exit checkpoint's named suites (`PCKLayerMapTest` 17 · `PCKLayerMapFixtureTest` 4 · `PCKLayerMapCheckTest` 9 · `PCKKitTest` +5/1-amended) include every chunk's tests. See MINOR-2 for the run-count figure.

**5 · Amended-surface completeness (scriptable) — clean, diff empty.** The cut claims exactly one amended accepted test. My script over `src/` found exactly one accepted test presenting `#layerMap` to `registrationsFrom:` (`PCKKitTest>>testLayerMapKeyProducesNoRegistrationsAndNoError`, line 69) and **zero** accepted tests registering `PCKLayerMapCheck` through a kit block. The other `#architectureChecks` tests name `PCKArchStubCheck`/`PGRFinding`/`PCKNoSuchCheck` (untouched generic path); `PGRReportTest`'s `PCKLayerMapCheck` is a rendering-fixture string; `PCKArtifactBlockM1FormTest` asserts the artifact omits `#layerMap` and C06 does not touch `guardrails.ston`. Diff against C06's amendment table is empty. C06 is the only chunk touching an accepted file (`PCKKit`/`PCKKitTest`), and E06's freeze pre-authorized the `#layerMap` consumer as scheduled ground — the frozen `registrationsFrom:` signature and four-stage order are preserved.

**6 · Intent attribution (scriptable + judgment) — clean.** The 65 normative-phrase hits all trace to sources: the D-79 semantics (self-reference always allowed / directed one-way / non-transitive / external out-of-scope) are cited to D-79 rulings 1–2 and D-79.a, which I read in full (`decision-log.md:2669–2720`) and confirmed match the chunks' behavior byte-for-intent; "never a silent default" traces to constitution strict-parsing/family-7; the completeness law traces to D-35/§4.1. The one spec-vs-frozen-surface conflict (§4.2's "every report" advisory vs `PGRVerdict` having no red+advisories constructor) is correctly filed as a decision-sheet **question**, not asserted as fact. The `instanceSide` spelling is flagged ⟨verify-in-image, P5⟩ and delegated, not asserted. No producer-invented intent.

### Findings

**MINOR-1 · item 2 · dependency annotation.** `C04-layer-map-check-walk.md` and `C05-layermap-semantics-witnesses.md` both direct the implementer to build test maps with `PCKLayerMap fromLayerMap: … productionPackages: …` — the selector introduced by **C02** — yet their `depends-on` (and the matching ledger rows) declare only {C01,C03} and {C03,C04}. C04's own CONTEXT DIGEST says "Builds on (accepted): **C01/C02**", contradicting its header. Under the documented serial in-ledger-row pick order (C01→C02→C03→C04→C05→C06) C02 always lands before C04, so this never bites in practice — hence MINOR, not BLOCKING. Remedy: add `E10-C02` to the C04 and C05 depends-on (headers + `ledger.md` rows + `chunks.md`'s "C04 consumes C01+C03" narrative), or switch those tests to C01's shape-only `fromLayerMap:`.
Location: `C04-layer-map-check-walk.md:1,17,122`; `C05-layermap-semantics-witnesses.md:1,44,63`; `ledger.md:73–74`.

**MINOR-2 · item 4 · arithmetic.** `chunks.md` exit checkpoint states "≥225 run — 195 accepted at cut + **30** net new". The epic adds **35** net-new test methods (10+7+4+5+4+5), for an exact total of 230. The `≥225` floor still holds (floors are lower bounds, "never an exact ceiling"), but the "30 net new" figure is off by 5 and should read 35 (→ ≥230). Descriptive only; nothing downstream acts on it wrongly.
Location: `chunks.md:120–121`.

### Advisories (recorded, not acted on)
- **ADV-1.** C04 correctly flags `referenced instanceSide` as ⟨verify-in-image, P5⟩ with a record-in-report duty rather than asserting it — good P5 discipline.
- **ADV-2.** The E10-C04 filed question (advisory-on-green-only vs amending frozen `PGRVerdict`) is well-formed and owner-pending; the conservative arm is implemented with no frozen surface amended. Worth the owner's attention at acceptance alongside the veto-open agent calls (sub-map format, constructor pair, `== PCKLayerMapCheck` identity special-case).

### Relevant paths
- Epic: `/Users/mitt/dev/projects/phi-guardrails/plan/04-epics/E10-layer-map-check/` (C01–C06 + `chunks.md`)
- Ledger: `/Users/mitt/dev/projects/phi-guardrails/plan/ledger.md:70–75,135–140,532–564`
- Ruled ground: `/Users/mitt/dev/projects/phi-guardrails/plan/decision-log.md:2669–2720` (D-79, D-79.a)
- Spec: `/Users/mitt/dev/projects/phi-guardrails/plan/02-spec/04-architecture-kit.md`
- Amended surface: `/Users/mitt/dev/projects/phi-guardrails/src/Phi-Coding-Kit-Tests-Rules/PCKKitTest.class.st:64–77`
