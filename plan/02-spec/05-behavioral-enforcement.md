# Spec ch. 5 — Behavioral enforcement

*Satisfies: R-23, R-24, R-25, R-44 · D-08, D-15, D-25 (suites derive from the tests
role; D-07's `#testPackages` section is superseded). Package
`Phi-Coding-Kit-Behavioral`. All SUnit result-object spellings verified live
(D-15), including the two semantic traps: skipped tests are not in `runCount`, and an
expected failure counts as passed while appearing in `expectedDefects`.*

## 5.1 Registration: derived from the tests role (R-23 as amended by D-25)

Behavioral suites have **no block key of their own**. The kit derives them from
the **configuration's tests role** (§1.1, D-25 as amended by D-45 — assignment lives in
the config's `#roles` matchers; the baseline supplies only the inventory): **one
registration per tests-role package**, kind `#behavioral`, name
`behavioral/<package name>` (derived entries come from the project's
own baseline and roles — there is no artifact line to collide with; the former `scope`
field left with the two-scope model, D-51). Adding a test package to
the baseline puts it in the inventory, and the scope law forces the config to assign it
a role — so a new test package cannot be silently forgotten: either a matcher catches it
or the run fails as a configuration error.

**Missing closes the silence hole (R-24):** the tests role is mandatory at validation
(§1.1), its groups must exist in the baseline, and an unknown group name is caught before
expansion (D-25.a trap). What remains detectable at run time: a tests-role expansion that
is **empty** yields one missing registration `behavioral/tests-role` — the stock runner
would silently pass here (verified: `test --fail-on-failure` with nothing to run exits 0,
D-15). Silence is never a pass.

## 5.2 Running a suite registration

`PCKTestSuiteCheck` (kind `#behavioral`) holds one tests-role package name. `run`:

1. Test classes = classes defined in the package that inherit from `TestCase` and answer
   `isAbstract` false; build each class's suite (`buildSuite`) and run it once,
   collecting the package's `TestResult` — through the run-scoped result cache (§5.4).
2. Findings: one per failure and per error, target `Class>>#testSelector` (from the
   result's `failures` and `errors`), message `'failed'` / `'errored'`.
3. Verdict: red iff any failure or error, else green. A package containing **zero test
   classes** is missing ('tests-role package contains no tests'), not green, for the
   same R-24 reason.

## 5.3 The no-skips meta-rule (R-25, D-08)

`PCKNoSkippedTestsMetaRule` (kind `#behavioral`), registered in the kit block's
`#metaRules` — the recommended coding-kit block includes it, so every init-drafted
config carries it from birth (D-51; an adopter keeps it by keeping the line).
Registration name:
`behavioral/PCKNoSkippedTestsMetaRule`. It reads **the same result objects** the suite
registrations use — through the run cache (§5.4), **pulled per package, never by run
order** (D-36); no second run, no static heuristics (D-08):

- For every tests-role package name of the configuration (the same derived list §5.1
  builds suite registrations from), ask the cache `resultsForPackage:`. The lazy cache
  runs any suite not yet run, so the meta-rule sees every package's results even when it
  runs first or alone — a narrowed advisory-tier run cannot fail open — while in a full
  run every result is already cached and nothing runs twice.
- For each `TestResult`: `skippedCount > 0` or `expectedDefectCount > 0` ⇒ findings —
  one per test in `skipped` (message `'skipped'`) and per test in `expectedDefects`
  (message `'expected failure'`), target `Class>>#testSelector`.
- Verdict: red iff any finding. (Vacuity is covered one level up: an empty tests-role
  expansion already yields the missing registration `behavioral/tests-role`, §5.1 — the
  meta-rule iterates exactly that same derived list.)

Rationale (carried on the check and emitted with findings): a skipped or expected-failure
test is a disabled check — P6 makes disabling a build failure; re-enable the test or
delete it via a reviewed diff.

The suspicious-shapes check (empty test methods, never-run test classes) is deliberately
**not** part of this rule — it is a separate widened meta-rule at M5 (D-08), so this
rule's zero-false-positive precision stays intact.

## 5.4 The run-scoped result cache (single-run guarantee)

Suites run **once per gate run** even though two registration families read them. The
coding kit's `registrationsFrom:productionPackages:testsPackages:` builds one
`PCKSuiteRunCache` — a plain object created
per registry construction, closed over by the behavioral registrations of that run, and
discarded with them (this is run-scoped sharing, not global state; R-35 holds: no
class-side variables, no lookup by name). Protocol: **one message**,
`resultsForPackage:` — lazily runs §5.2 step 1 on first request per package and answers
the cached `TestResult` thereafter. Correctness rests on the cache alone (D-36): suite
registrations and the meta-rule both pull by package name, so no reader depends on what
another has already run. Registry order (suites before `#metaRules` entries, §1.4)
remains normative as a nicety, not a guarantee: in a full run every suite has already run
when the meta-rule reads the cache, which keeps suite wall time attributed to suite
verdicts and reports reading suites-then-meta.

## 5.5 Demonstration (R-44) and fixtures

Behavioral fixtures are the one fixture family that must contain red, skipped, and
expected-failure **tests** — so they must live where no swept role and no verify sweep
can reach them. They go in **`Phi-Coding-Kit-Fixtures-Behavioral`** (D-22): a member of
the framework baseline's **exempt-role** `fixtures` group (D-25 — the escape is now a
declared, validated group fact, not just a name), whose name also does not full-match
either tests family (`(Phi-Guardrails|Phi-Coding-Kit)-Tests-.*` — the verify command's
regex and smalltalkCI's `#testing` list, D-57), and
which is loaded by the `Tests` baseline group so the tests below can use it. This is
Q-19's toy mechanism applied to the kit's own fixtures.

Fixture pair for the meta-rule (R-37): `Phi-Coding-Kit-Fixtures-Behavioral` holds a
fixture test class with one `skip:` call and one `expectedFailures` entry —
`PCKNoSkippedTestsMetaRuleTest>>#testFiresOnSkipAndExpectedFailure` (in
`Phi-Coding-Kit-Tests-Behavioral`) builds a scratch configuration whose baseline
is **`BaselineOfPCKFixture`** — a tiny `BaselineOf` in the fixtures package declaring an
**empty `production` group** (§1.1 makes `#production` mandatory; an empty group is
declared, listed, and expands to nothing — verified, D-25.a) and the fixture package
under a `tests` role group (baseline introspection needs no load, D-25.a) — and asserts
both findings by name; `>>#testSilentOnCleanSuite` asserts green
over the clean fixture class; `>>#testFiresInIsolationWithoutPriorSuiteRuns` (same
scratch shape, fresh cache, no suite registration executed) asserts the same findings —
the meta-rule cannot fail open (D-36). The suite check's own pair, same scratch-configuration
shape: `PCKTestSuiteCheckTest>>#testRedOnFailingSuite` (a fixture class with one failing
test) / `>>#testGreenOnPassingSuite`, plus `>>#testMissingOnEmptyTestsRole` for §5.1.

End-to-end (R-44): the toy's tests-role group loads `Toy-Tests`, which plants one
red test and one skipped test; chapter 8's demo test asserts the suite registration goes
red on the former and the meta-rule goes red on the latter, and that both turn green when
the plants are fixed in-image.

**Widened meta-rules (M5 — recorded only):** mirror test packages exist per
registered production package (R-26) · the regression set stays green (R-26) · **every
registered check is tested** — for each registered check class defined in one of this
project's **own baseline packages** (external kits' classes exempt — provenance
re-anchoring, D-52, after D-51 removed scope), a
class `FooTest` exists in a tests-role package (`PCKCheckFixturePairMetaRule`, R-46,
D-44: the client fixture-pair discipline of §8.1 step 3 made machine-checkable) ·
coverage floors per registration (R-27, values ruled at M5 per D-07).
