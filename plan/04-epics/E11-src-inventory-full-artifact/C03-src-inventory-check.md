# E11-C03 · `PCKSrcInventoryCheck` — the dead-source read-only walk  [depends: — · parallel: yes]

GOAL      Deliver the coding kit's second architecture check: a read-only walk of a declared source root that reds — one finding per offender — on every directory that neither names a package in the handed inventory nor is the package of a loaded `BaselineOf` subclass, green on a clean root, with scratch-root fixtures built and deleted by the test.

TRACE     R-38 (self-hosting; the dead-code guard) · R-12 (checks never mutate — read-only walk) · R-20 (precise findings) · spec ch. 7 §7.5 (the check's whole contract) · §7.6 (this walk + the artifact read are the gate's only two file accesses) · ch. 9 P-NO-DEAD-SRC (the fires/silent legs land here; the missing leg is E11-C04's) · D-25 residual 2 + D-25.a (verified spellings) · D-45 (the declared root; existence judged by the walk at run time).

CONTEXT DIGEST

*Self-contained; do not read other documents.*

**The check's contract (spec §7.5, condensed).** `PCKSrcInventoryCheck` is kind
`#architecture`. Its `run` is a **read-only walk** of the declared source root: red,
with **one finding per offender**, when a directory under the root neither names a
package in the handed inventory **nor is the package of a loaded `BaselineOf`
subclass**; else green. The baseline clause is forced, not convenient: the root
baseline must sit in its own `src/` directory for Metacello to find it, and no
baseline declares its own package — without the clause the check reds itself on day
one. Code is therefore either in the baseline (and so in a role, and so guarded), a
baseline package itself, or flagged as dead; there is no fourth state.

**What "the handed inventory" is.** The check receives everything it knows at
construction and pulls nothing (the accepted §4.3 construction law): a source-root
path String and one flat collection of package-name Strings — the caller's resolved
production + tests + exempt role lists concatenated. By the accepted scope law (D-25:
role groups are pairwise disjoint and jointly cover every package the baseline
defines) that concatenation IS the baseline's full package inventory; the check
itself never touches Metacello version objects or the configuration (D-53.5 —
E11-C04 builds the collection from the environment view). The **loaded-baselines
clause** is the one reflective part of the walk: a directory whose basename equals
the package name of any loaded `BaselineOf` subclass is not dead (reflective queries
of the checked image are the checks' subject matter, not state — constitution).

**Verdict shape (frozen E02 SDK, verbatim):**
- `PGRVerdict class >> green` · `PGRVerdict class >> redFindings: aCollection`
- `PGRFinding class >> target: aTargetString message: aMessageString rationale: aRationaleStringOrNil`
- `PGRCheck` (the skeleton this class subclasses, like accepted `PCKLayerMapCheck`):
  instance `run` (override), `kind` (override to `#architecture`), `canFix` (inherited
  false — correct: no safe rewrite deletes directories), class-side `packages:`
  (inherited; unused by the kit path — the kit constructs richer, §4.3).

**Construction (kit-side, richer than the promised `packages:` because the kit owns
this class — the accepted `PCKLayerMapCheck class >> layerMap:` pattern):**

```smalltalk
PCKSrcInventoryCheck class >> srcPath: aPathString packages: packageNameCollection
    "aPathString: the resolved absolute source root; packageNameCollection: the
     caller's full package inventory (production + tests + exempt)."
```

Internal, not a frozen public surface (the contract the engine validates is
`PGRCheck`'s instance protocol, exactly as with `PCKLayerMapCheck layerMap:`).

**The walk (`run`):**
1. `root := srcPath asFileReference.` If `root exists` is false (or it is not a
   directory — `root isDirectory` false), answer red with **one finding** whose
   target is the declared path and whose message says the declared source root does
   not exist. *Why red and not missing or green:* §1.5 reserves **missing** for an
   absent parameter — here `#src` was declared, so the registration resolved; and a
   silent green on a dangling declaration is the silence-as-success shape the ruled
   ground closes loudly everywhere (D-79's "an undeclared dependency is a loud
   finding" at the layer level; D-25's loud scope law at the role level). The
   accepted core comment (D-45 resolution) explicitly defers existence to "the walk
   that consumes it judges that at run time" — a check judges by verdict, and the
   only loud verdict is red.
2. Else, for each entry of `root directories` (immediate subdirectories only —
   §7.5's "one finding per directory under `#src`"): the directory's `basename` is
   an offender iff it is **not** in the handed package-name collection **and** no
   loaded `BaselineOf` subclass has it as its package name.
3. One `PGRFinding` per offender: target = the directory's `basename`; message names
   the full path and states it matches no baseline-defined package and no loaded
   baseline's package; rationale (the finding-level agent guidance the SDK carries)
   states the no-fourth-state law: source on disk must be a baseline package, a
   baseline's own package, or deleted.
4. Findings nonempty → `PGRVerdict redFindings: findings` (in `root directories`
   order); empty → `PGRVerdict green` (no advisories — nothing advisory exists here).

**Read-only is law (R-12/§7.6):** the walk creates, writes, and deletes nothing —
`exists` / `isDirectory` / `directories` / `basename` reads only.

**No file-triad class literal in production code (validator-added constraint):** the
accepted `PGRArchSelfTest` file-triad arm sweeps every production package —
`Phi-Coding-Kit-Architecture` included — for methods referencing `FileSystem` /
`FileReference` / `FileLocator` against a three-entry allowlist that does not (and
this epic does not) include this check. The walk as specified needs none: reach the
root via `srcPath asFileReference` and message sends only (a String-extension send
compiles no triad class literal). If your implementation genuinely needs a triad
class literal, that reds an accepted suite whose fix sits outside this manifest —
**stop and report**, never allowlist-by-silent-edit.

**Loaded-baselines clause spelling:**
`BaselineOf allSubclasses anySatisfy: [ :cls | cls package name = basename ]` —
`inheritsFrom: BaselineOf` / subclass enumeration is the D-25.a-verified family;
`cls package name` on a class is the accepted spelling (`PCKLayerMapCheck`'s walk
uses `targetClass package name`, P5-confirmed at E10-C04). `allSubclasses` itself:
⟨verify-in-image⟩ before relying on it (standard Behavior protocol; confirm and
record in the report, P5).

**Scratch-root fixtures (ch. 9 P-NO-DEAD-SRC, binding):** the tests hand the check
a scratch root **built and deleted by the test — never planted directories in the
real working tree**. Accepted spellings (used verbatim in accepted
`PGRConfigurationTest`/`PGRGateTest`): `FileSystem workingDirectory / 'name'`,
`ensureCreateDirectory`, `ensureDeleteAll`, in `setUp`/`tearDown`.

**Constitution rules that bite:** the fixture-pair law (fires on bad, silent on
good — both named, both asserted); no global state; class-side named constructor;
comments state constraints the code cannot show. Touching any file outside the
manifest is a review rejection.

DELIVERABLES

Files (Tonel):
- **create** `src/Phi-Coding-Kit-Architecture/PCKSrcInventoryCheck.class.st`
- **create** `src/Phi-Coding-Kit-Tests-Architecture/PCKSrcInventoryCheckTest.class.st`

Classes/methods:
- `PCKSrcInventoryCheck` (superclass `PGRCheck`, package
  `Phi-Coding-Kit-Architecture`) — instVars `srcPath`, `packageNames`; class-side
  `srcPath:packages:`; instance `kind` (`#architecture`), `run`, private setter and
  any private walk helpers. Class comment: the §7.5 contract incl. the baseline
  clause's why, R-12 read-only, and the construction law (full inventory handed,
  nothing pulled).
- `PCKSrcInventoryCheckTest` — `setUp`/`tearDown` scratch root + the five skeletons
  below (`testMissingWithoutSrcKey`, the property's third leg, is **E11-C04's** —
  it needs the kit dispatch and is added to this class there).

LOC budget: target ~140 · ceiling 300.

TESTS FIRST  (`PCKSrcInventoryCheckTest`, package `Phi-Coding-Kit-Tests-Architecture`;
scratch root e.g. `FileSystem workingDirectory / 'pck-e11-src-scratch'`)

- `testRedOnStrayDirectory` *(ch.-9-named, P-NO-DEAD-SRC fires leg)* — given a
  scratch root holding directories `Known-Package` and `Dead-Package`, and the check
  constructed with the root's path and packages `#('Known-Package')`; when `run`;
  then the verdict is red with exactly one finding, its target `'Dead-Package'` and
  its message naming the path (the fires half of the fixture pair, R-37).
- `testGreenOnCleanRoot` *(ch.-9-named, P-NO-DEAD-SRC silent leg)* — given a scratch
  root holding only `Known-Package`, and the check constructed with packages
  `#('Known-Package')`; when `run`; then the verdict is green with no findings (the
  silent half).
- `testBaselineDirectoryIsNotDead` *(the forced clause, §7.5)* — given a scratch
  root holding `Known-Package` and `BaselineOfPhiGuardrails` (a directory named
  after a genuinely loaded `BaselineOf` subclass's package), packages
  `#('Known-Package')`; when `run`; then green — the baseline clause absorbs the
  directory the inventory never lists.
- `testOneFindingPerOffender` *(§7.5 arity)* — given a scratch root with two stray
  directories and one known; when `run`; then red with exactly two findings, targets
  the two stray basenames (each offender named, none folded).
- `testNonexistentRootIsRed` *(the D-45 run-time judgment)* — given the check
  constructed with a path inside the scratch root that was never created; when
  `run`; then red with one finding whose message names the declared path (a dangling
  declaration is loud, never silently green).

Fixtures: the scratch root above (setUp creates, tearDown `ensureDeleteAll`s);
`BaselineOfPhiGuardrails` is loaded in the verify image by construction (the image is
built from it).

VERIFY    `bash tools/build-image.sh && bash tools/verify.sh`
          Expected: exit 0, 0 failures / 0 errors; the five `PCKSrcInventoryCheckTest`
          cases listed by name, and every previously accepted suite green — ≥235 run
          when this chunk lands first (230 accepted at cut + these 5); membership +
          floor, never an exact ceiling ([P] sibling E11-C01 may land first and raises
          the floor by its 6).

OUT OF SCOPE
- Kit-side dispatch and the missing-without-`#src` leg (E11-C04).
- Registering the check in the framework's own artifact (E11-C05).
- Recursing below the root's immediate directories, judging loose files, or any
  write/delete/create in `run` (R-12; §7.5 judges directories only).
- Any `canFix`/autofix arm (deleting directories is no safe rewrite; inherited
  false stands).
- Touching `PCKLayerMapCheck`, `PCKLayerMap`, or any E10-frozen file.

COMMIT     Precondition: `bash tools/precheck.sh` exits 0 (D-66/D-67). Postcondition:
one commit `E11-C03: PCKSrcInventoryCheck — the dead-source walk`, nothing
uncommitted.

COMPLETION REPORT (implementer fills in):
  files touched · LOC added/changed · test names + final run output · the
  ⟨verify-in-image⟩ record for `allSubclasses` (and anything else probed, P5) ·
  deviations (each one-line justified) · new questions for the decision sheet.
