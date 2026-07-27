# E10-C03 · The three-package architecture mini-fixture (scratch builder + self-test)  [depends: — · parallel: yes]

GOAL      A test-support builder that installs a three-package scratch mini-fixture — ui / domain / persistence packages with one planted forbidden cross-layer reference and the sibling/self and external references the check tests need — and tears it down completely, with a self-test proving the fixture is real.

TRACE     R-37 (the fixture pair every shipped check needs) · R-43 (arch check support) · spec ch. 4 §4.4 (a three-package mini-fixture in `Phi-Coding-Kit-Tests-Architecture` with one planted forbidden reference) · D-22/D-26 (planted violations exist to be caught; they are compiled at runtime into scratch packages, never committed sends) · ch. 9 §9.3 (fixture classes never sit in production-role packages; scratch classes built and torn down by the test).

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**Why a scratch builder, not committed fixture packages.** The layer-map walk (C04)
distinguishes classes **by their defining Pharo package**, so the mini-fixture needs
classes in ≥3 distinct package **names**. The baseline package tree froze at E01 (adding a
package is a decision-sheet-only edit), so the three fixture packages are **scratch
packages built in the test and removed in teardown** — the exact pattern accepted code
already uses (E08 `PCKLintRuleCheckTest>>#testTraitProvidedMethodLintedAtUsingClassPackage`
and E09 `PGRQuickstartSampleHarness`). This chunk delivers that builder as a reusable
support class so C04 and C05 do not each re-author it.

**Verified Pharo 13 spellings (P5 — copied from accepted repo code; cite, do not
re-probe):**
- Create a scratch class in a scratch package (the fluid cascade, E08/E09):
  `Object << #PCKScratchUiView package: 'PCKScratchArch-Ui'; install` — answers the
  installed class and **creates the package** if absent.
- Compile a method carrying a planted reference:
  `installedClass compile: 'usesPersistence ^ PCKScratchPersistenceStore new' classified:
  'fixture'` — the `flag:`/plant style of the accepted D-72 test (a send compiled at
  runtime, never a committed send).
- Look a scratch class up for teardown: `Smalltalk globals at: #PCKScratchUiView ifAbsent:
  [ nil ]`.
- Tear a class down: `aClass removeFromSystem`. Tear a package down (guarded):
  `(PackageOrganizer default packageNamed: aName ifAbsent: [ nil ]) ifNotNil: [ :pkg |
  pkg removeFromSystem ]` — and `PackageOrganizer default hasPackage: aName` /
  `packageNamed:ifAbsent:` for the guard (E09 `PGRQuickstartSampleHarness` precedent:
  guard so double-removal cannot raise).
- Read a class's package name: `aClass package name` (E09 `PGRArchSelfTest` precedent).
- A method's referenced classes: `aCompiledMethod referencedClasses` (answers behaviors),
  used by the self-test to prove the plant is present (E09 precedent).

**Constitution rules that bite here (inline):** the scratch classes/packages are created
and deleted **within the test's own control** (the sanctioned analog of scratch files a
test creates/deletes — ch. 9 §9.3); nothing is committed into a production-role or
tests-role package as a real send. Teardown must run even when an assertion fails — callers
invoke `remove` from an `ensure:` block, and `remove` is guarded so partial or double
removal never raises. No global state persists after teardown. Glossary: these are
**fixtures** / **planted violations**.

**The fixture's shape (the contract C04/C05 rely on — implement exactly).** Three scratch
packages, each name a class-side accessor so tests never hard-code strings:
- `PCKScratchArch-Ui` — classes `PCKScratchUiView`, `PCKScratchUiWidget`.
- `PCKScratchArch-Domain` — class `PCKScratchDomainModel`.
- `PCKScratchArch-Persistence` — class `PCKScratchPersistenceStore`.

Planted references (each a one-line method compiled at `install`; the reference is the
`referencedClasses` entry that matters):

| method | references | intended edge |
|---|---|---|
| `PCKScratchUiView>>usesDomain`      | `PCKScratchDomainModel`      | ui → domain |
| `PCKScratchUiView>>usesPersistence` | `PCKScratchPersistenceStore` | ui → persistence (**the plant**) |
| `PCKScratchUiView>>usesSibling`     | `PCKScratchUiWidget`         | ui → ui (self) |
| `PCKScratchUiView>>usesExternal`    | `OrderedCollection`          | ui → external (kernel) |
| `PCKScratchDomainModel>>usesPersistence` | `PCKScratchPersistenceStore` | domain → persistence |
| `PCKScratchDomainModel>>usesUi`     | `PCKScratchUiWidget`         | domain → ui |

(Bodies may be `^ TheReferencedClass new` — the send is what the walk sees. `usesExternal`
references a kernel class so C05 can prove external references are out of scope, D-79.a.)

DELIVERABLES

Files (Tonel):
- **create** `src/Phi-Coding-Kit-Tests-Architecture/PCKLayerMapFixture.class.st`
- **create** `src/Phi-Coding-Kit-Tests-Architecture/PCKLayerMapFixtureTest.class.st`

`PCKLayerMapFixture` (package `Phi-Coding-Kit-Tests-Architecture`, superclass `Object`;
a plain support object, **not** a `TestCase` — inert under behavioral runs, ch. 9 §9.3):
- class-side accessors returning the scratch package names:
  `uiPackageName` → `'PCKScratchArch-Ui'`, `domainPackageName` → `'PCKScratchArch-Domain'`,
  `persistencePackageName` → `'PCKScratchArch-Persistence'`.
- class-side `packageNames` → `{ self uiPackageName. self domainPackageName.
  self persistencePackageName }`.
- class-side `install` — creates the four classes in their three packages and compiles the
  six planted methods above. Idempotent-safe on a clean image; answers `self` (or the
  builder). May be class-side stateless (look classes up by name for teardown) — no
  class-side variables (constitution: no global state).
- class-side `remove` — tears down all four classes then all three packages, **guarded** so
  a missing class/package never raises (for use in an `ensure:` block).

`PCKLayerMapFixtureTest` (superclass `TestCase`) — the self-test proving the fixture is
real and self-cleaning. Each test wraps `PCKLayerMapFixture install` … assertions … in
`[ ... ] ensure: [ PCKLayerMapFixture remove ]`.

LOC budget: target ~110 · ceiling 300 (the planted method source strings are fixture data,
outside the budget).

TESTS FIRST  (`PCKLayerMapFixtureTest`)

- `testInstallCreatesThreeDistinctPackages` — given a clean image; when `install`; then
  each of the three package names resolves to a loaded package via
  `PackageOrganizer default packageNamed: name ifAbsent: [nil]` (all non-nil, three
  distinct), and the four scratch classes are present in the system.
- `testPlantedForbiddenReferenceIsPresent` — after `install`; then
  `PCKScratchUiView>>#usesPersistence`'s `referencedClasses` (normalized to instance side)
  includes `PCKScratchPersistenceStore` — the plant the check must catch is genuinely in
  the fixture, so a green result later cannot be vacuous.
- `testEachPlantedClassReportsItsOwnPackage` — after `install`;
  `PCKScratchUiView package name` = `uiPackageName`,
  `PCKScratchDomainModel package name` = `domainPackageName`,
  `PCKScratchPersistenceStore package name` = `persistencePackageName` (the walk's
  by-defining-package attribution will be honest).
- `testRemoveLeavesNoResidue` — given `install` then `remove`; then none of the three
  package names resolves to a loaded package and none of the four class names is in
  `Smalltalk globals` — and calling `remove` a second time raises nothing (guarded).

Fixtures: this chunk *is* the fixture; it needs none of its own.

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, 0 failures / 0 errors; `PCKLayerMapFixtureTest` (4 tests) run by
          name; `PCKLayerMapFixture` (the support class) appears in **no** test-run line (it
          is not a `TestCase`); every previously accepted suite still green. Assert
          named-suite membership plus a floor of **≥199 run** (195 + 4), never an exact
          ceiling. Regression guard: no accepted suite changes count except by sibling E10
          chunks.

OUT OF SCOPE
- `PCKLayerMap` / `PCKLayerMapCheck` — C01/C02/C04 own them; this chunk references neither.
- Building any layer-map value or running any check — the fixture only supplies the scratch
  code; C04/C05 build the maps over `PCKLayerMapFixture packageNames` and run the check.
- Editing the baseline, `guardrails.ston`, or `PCKKit`.

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67). Postcondition: one
commit `E10-C03: architecture scratch mini-fixture`, nothing uncommitted. Note: a red or
errored run of a fixture-installing test can leave `*.fuel` debris at the repo root (B-17,
gitignored per D-78) — the precheck must still be clean before the pick.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output ·
  deviations (each one-line justified) · new questions for the decision sheet.
