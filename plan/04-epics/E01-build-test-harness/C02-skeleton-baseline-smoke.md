# C02 · Tonel skeleton, baseline group tree, smoke suite    [E01 · depends: C01 · parallel: no]

GOAL      Commit the complete `src/` package-stub tree and `BaselineOfPhiGuardrails`
          with the full ch. 8 §8.1 group tree, prove it Metacello-loads into a fresh
          image from local Tonel, and land the smoke suite
          (`PGRBaselineSmokeTest`, `Phi-Guardrails-Tests-Core`) green under the pack's
          verify command run from a script — freezing E01's export: the naming tree.

TRACE     R-36 (framework + kit families; Toy contents are E12's — stubs only here) ·
          spec ch. 8 §8.1 (group table) · ch. 9 §9.3 (verify command) · D-11/D-56/D-57
          (naming) · D-25.a (Metacello spellings) · D-60/D-60.a (load expression,
          local form — this chunk records it) · D-22/D-46 (fixtures/toy placement).

## CONTEXT DIGEST

**What exists:** C01's toolchain at `.build/pharo/` with scripts under `tools/`;
`src/` is empty; decision-log entry D-63 is open with a stub line for this chunk's
load-expression row.

**Constitution rules that bite here:**
- *Naming:* framework classes (`-SDK`, `-Core`, `-Gate`) are prefixed `PGR`; kit
  classes `PCK`; toy classes unprefixed `Toy*`; `BaselineOf*` excepted from prefix
  law (Metacello convention). Test classes live in their subject family's `-Tests-*`
  package. Glossary terms exactly — gate-runnable things are "checks", not "tests".
- *Tests:* SUnit; a test that cannot fail is a defect (no `self assert: true`
  smoke test — the smoke suite asserts the real group tree). No
  `skip`/`expectedFailures` anywhere in tests-role packages.
- *On disk:* Tonel under `src/`, loaded by `BaselineOfPhiGuardrails`.
- *State:* no global state, no class-side caches.

**The frozen package inventory — 20 packages + the baseline package (21 `src/`
directories).** This list IS E01's frozen export; every later epic fills stubs, never
adds or renames packages:

| Family | Packages |
|---|---|
| framework production (3) | `Phi-Guardrails-SDK` · `Phi-Guardrails-Core` · `Phi-Guardrails-Gate` |
| kit production (4) | `Phi-Coding-Kit` · `Phi-Coding-Kit-Rules` · `Phi-Coding-Kit-Architecture` · `Phi-Coding-Kit-Behavioral` |
| framework tests (4) | `Phi-Guardrails-Tests-SDK` · `Phi-Guardrails-Tests-Core` · `Phi-Guardrails-Tests-Gate` · `Phi-Guardrails-Tests-Toy` |
| kit tests (3) | `Phi-Coding-Kit-Tests-Rules` · `Phi-Coding-Kit-Tests-Architecture` · `Phi-Coding-Kit-Tests-Behavioral` |
| kit fixtures (1) | `Phi-Coding-Kit-Fixtures-Behavioral` |
| toy (5) | `Toy-Core` · `Toy-UI` · `Toy-Persistence` · `Toy-Rules` · `Toy-Tests` |
| baseline | `BaselineOfPhiGuardrails` (its own `src/` directory — Metacello loads the root baseline from disk by name; it is **not** declared as a package inside itself, matching §7.5's baseline clause) |

Framework-tests split rationale (agent call, veto-open at spot-check): the spec fixes
`-Tests-Core` (smoke home, roadmap M0) and `-Tests-Toy` (D-46) and says "mirroring
`Phi-Guardrails-Tests-*`"; `-Tests-SDK` and `-Tests-Gate` complete the mirror of the
three production packages (`PGRCheckSkeletonTest` → SDK's mirror,
`PGRGateTest` → Gate's, per ch. 9's class roster).

**The baseline group tree (ch. 8 §8.1, normative), all in `#common`:**

| Group | Kind | `with:` (exact) |
|---|---|---|
| `production` | role | the 7 production packages above |
| `tests` | role | the 7 test packages above — **both families**. §8.1's row says "every `Phi-Guardrails-Tests-*`" but §7.5 + D-57 state the tests role covers `Phi-Guardrails-Tests-*` **and** `Phi-Coding-Kit-Tests-*`, and the scope law (each package in exactly one role) forces kit tests into this group — the decision log wins; note it in the completion report |
| `fixtures` | role (exempt) | `Phi-Coding-Kit-Fixtures-Behavioral` |
| `toy` | role (exempt) | the 5 `Toy-*` packages |
| `Core` | composite | packages `Phi-Guardrails-Core`, `Phi-Guardrails-Gate` |
| `Coding` | composite | group `production` |
| `Tests` | composite | groups `production` + `tests` + `fixtures` + `toy` |
| `Toy` | composite | groups `production` + `toy` |
| `CI` | composite | group `Tests` |
| `default` | composite | group `production` |

Declare no `#requires:` between stubs — group membership, not dependency order, is
what freezes here. Baseline method shape: `baseline: spec` with `<baseline>` pragma,
`spec for: #common do: [ … package: …; group: … with: … ]`.

**Verified Metacello spellings (D-25.a — use these, no re-probing):**
`BaselineOfPhiGuardrails project version` → `MetacelloVersion` · own packages:
`version packages` (specs; `name`) · groups: `version groups` (specs; `name`) ·
transitive expansion: `version packagesForSpecNamed: 'group'` (composites expand
correctly; **trap:** an unknown group name answers empty, no error) ·
`cls inheritsFrom: BaselineOf`.

**Loading (the D-60.a local form — this chunk's probe row):** build a work image by
copying the pristine C01 image (+ its `.changes`) to `.build/work/`, then loading:

```smalltalk
Metacello new
    baseline: 'PhiGuardrails';
    repository: 'tonel://<absolute-repo-path>/src';
    load: 'CI'.
```

then saving the image. The `tonel://` scheme and the `load: 'CI'` form are exactly
what D-63's local-load row records (spelling as executed, including how the image was
saved from the script — e.g. an `eval --save` flag or an explicit snapshot
expression; record what worked). Append that row to D-63.

**Authoring rule:** author classes in-image and export to `src/` with the image's
Tonel tooling (`TonelWriter` / Iceberg — present, D-15); hand-writing `package.st`
stubs (`Package { #name : #'…' }`) is fine, hand-writing class files is not — the
committed form must be what the tooling emits, so later epics' exports don't churn
formatting. After export, a **fresh** image load from the committed `src/` is the
proof the round trip holds.

**The verify command (pack §6 / ch. 9 §9.3), run from a script:**

```
<pharo-vm> <work-image> test --fail-on-failure "(Phi-Guardrails|Phi-Coding-Kit)-Tests-.*"
```

Known trap (D-15): a regex matching zero packages exits 0 — so the script must also
assert the smoke suite actually ran (grep the runner output for its test count; pin
the exact output format you observe and record it in the completion report). C01's
probe already confirmed the alternation dialect on scratch packages; this chunk's run
is its confirmation on the real families (C04 records that row in D-63).

## DELIVERABLES

- `src/BaselineOfPhiGuardrails/BaselineOfPhiGuardrails.class.st` + `package.st` —
  the baseline class exactly as tabled above.
- `src/<each of the 20 packages>/package.st` — empty package stubs.
- `src/Phi-Guardrails-Tests-Core/PGRBaselineSmokeTest.class.st` — the smoke suite
  (subclass of `TestCase`), five test methods below, no fixtures needed.
- `tools/build-image.sh` — new; pristine-copy + Metacello local-Tonel load
  of group `'CI'` + save, producing `.build/work/phi.image`.
- `tools/verify.sh` — new; runs the verify command against the work image,
  asserts exit 0 **and** a nonzero run count containing the 5 smoke tests.
- `plan/decision-log.md` — append the D-63 local-load row only.
- LOC budget: target 180 / ceiling 300 (≈70 baseline · ≈40 stubs · ≈70 test).
  Above the 150 target band, knowingly: the 21 `package.st` stubs (~40 LOC) are
  pure manifest boilerplate — data-shaped, adjacent to the constitution's
  fixture carve-out — and the chunk does not split because its one concern is the
  frozen naming tree: the stubs, the baseline that groups them, and the suite that
  witnesses them are meaningless apart.

## TESTS FIRST

Test methods on `PGRBaselineSmokeTest` (fill skeletons in, watch them fail — before
the baseline exists, run them in a scratch image where only the test class is
compiled — then implement to green):

- `testBaselineClassIsLoadable` — given the work image built by loading group `CI`
  from local Tonel / when looking up `#BaselineOfPhiGuardrails` in `Smalltalk
  globals` / then it exists and `inheritsFrom: BaselineOf`.
- `testGroupTreeMatchesSpec` — given `project version groups` / when collecting
  group names / then all ten §8.1 names are present (`production tests fixtures toy
  Core Coding Tests Toy CI default`; assert superset — Metacello-implicit groups are
  tolerated but recorded in the completion report if any appear).
- `testRoleGroupsExpandExactlyAndDisjointly` — given `packagesForSpecNamed:` for
  each of the four role groups / then each answers exactly its frozen package list,
  the four are pairwise disjoint, and their union is exactly the 20 packages.
- `testCICompositeCoversEverything` — given `packagesForSpecNamed: 'CI'` / then it
  answers exactly the 20 packages (transitive composite expansion).
- `testCompositeGroupsExpandExactly` — given `packagesForSpecNamed:` for each of
  the five remaining composites / then `Core` answers exactly
  {`Phi-Guardrails-Core`, `Phi-Guardrails-Gate`}, `Coding` and `default` each
  exactly the 7 production packages, `Toy` exactly production + toy (12), and
  `Tests` exactly the 20 — a later regrouping of any composite is a red test, not
  a silent drift (the freeze witness covers all ten groups).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          exits 0, output showing 5 tests run, 0 failures, 0 errors — from a fresh
          work image built off the committed `src/`. Regression guard:
          `bash tools/probe-m0.sh` stays green.

OUT OF SCOPE
- Any class beyond the baseline and the smoke test — every other package ships as an
  empty stub (contents belong to E02–E12). No `PGR*`/`PCK*`/`Toy*` production class,
  no `BaselineOfToy`, no `BaselineOfPCKFixture`.
- `#requires:` dependency edges, role validation logic (E03's scope law), any
  `.smalltalk.ston`/workflow file (C03).
- Renaming or adding packages — the inventory above is frozen; a package the later
  epics turn out to need is a decision-sheet entry, not an edit here.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations from the work order (each with one-line justification) ·
  new questions for the decision sheet.
