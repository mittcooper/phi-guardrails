# 02 · Decision Sheet — phi-guardrails (specification stage)

*Questions surfaced while writing `plan/02-spec/` and during the Gate-2 review. Same
entry format as sheet 01; rulings become numbered `plan/decision-log.md` entries at
Gate 2 (so far: Q-18 → D-24, Q-22 → D-25). Minor calls already taken by the agent are
**not** here — they are decision-log entries D-16–D-23, each marked agent-decided and
veto-open; vetoing any of them reopens the affected spec section. One item was a carried
veto from Gate 1 (Q-20, since closed as moot by D-25).*

---

**Q-18 · Can a project exclude a global-catalog registration?**
*→ RULED: option (a) — no exclusion mechanism in v1; see `plan/decision-log.md` D-24.*
— D-01/D-07 make the project artifact *extend* the shipped catalog; the spec (ch. 1 §1.2)
therefore ships **no exclusion mechanism**: every global entry runs for every adopter.
That is the strictest reading of P6, but it has a real consequence: a client that cannot
yet satisfy a global check (say, a legacy codebase full of `isNil ifTrue:` it will fix
incrementally) has no legal state except a red gate or not adopting. The alternative — an
explicit, diffable `#exclusions` section — keeps the deselection visible in git (the
agent still can't silently weaken anything; a human reviews the diff), at the cost of a
knob and a social hole (exclude-instead-of-fix).
· **Options:** (a) no exclusions in v1 (as specified); a client in trouble fixes its code
or delays adoption — revisit only on real demand; (b) an `#exclusions` list section at
project scope, each entry requiring a `#reason` string, reported in every gate run as a
standing advisory; (c) per-registration severity override instead of exclusion.
· **Recommendation: (a).** The walking skeleton's global catalog is deliberately small
(one lint rule + no-skips + secrets — all things a new adopter should genuinely pass);
family 5 says no knob before demand, and (b) can be added compatibly at M5 if phi-llm's
onboarding proves the need. (c) is Q-03's rejected option (c) returning in disguise.
· **Blocks:** nothing in the skeleton (spec ch. 1 §1.2 states (a)); a ruling for (b)/(c)
would amend ch. 1 §1.2 and ch. 7 §7.1.

**Q-19 · Where do the framework's own gate-red states live during development?**
*→ RULED: option (a) — toy committed red, exempt-role declared; see `plan/decision-log.md` D-26.*
— Self-hosting (R-38) plus the in-repo toy creates a bootstrap tension the spec resolves
one way and the human should confirm: the toy is committed **red** (planted violations
are real code, ch. 8 §8.2), while the framework's artifact excludes toy packages so the
framework's own gate stays green. Consequence: `Phi-Guardrails-Toy-Tests` contains a
committed failing test and a committed skip — so the *verify command's* pattern
(`Phi-Guardrails-Tests-.*`) must not match toy test packages, which is why the toy's
suite package is named `Phi-Guardrails-Toy-Tests` (Toy- prefix, not Tests- prefix).
· **Options:** (a) as specified — toy committed red, toy tests outside the
`Phi-Guardrails-Tests-.*` namespace, demo test drives red → green in-image and restores;
(b) toy committed green with the demo test *installing* the violations at runtime before
each gate assertion.
· **Recommendation: (a).** The committed red state is the honest fixture — it is what a
real adopter's first gate run looks like, and (b) hides the violations from every reader
and from the fixture-pair discipline. The naming consequence is already in R-36's tree
(`Phi-Guardrails-Toy-*`), so (a) costs nothing new.
· **Amended in remediation (Gate-2 validation finding 1):** the same mechanism now also
covers the kit's own red-test fixtures — they live under `Phi-Guardrails-Fixtures-*`,
outside every registered and swept namespace (D-22, ch. 5 §5.5). A ruling on this
question rules on both applications of the mechanism; choosing (b) here would switch the
behavioral fixtures to dynamically built classes as well.
· **Blocks:** ch. 8 §8.2/§8.3, ch. 5 §5.5, and the M4 demo if overruled.

**Q-20 · (carried veto from Gate 1, D-07) Behavioral registration form: name patterns**
*→ CLOSED AS MOOT by D-25 (Q-22 ruled option (a)): behavioral targets derive from the
baseline's tests-role group; no patterns remain to confirm or veto.*
— D-07 adopted regex **test-package patterns** as the working default and flagged the
form for veto at this gate. The spec commits to it (ch. 5 §5.1) with full-match semantics
and the zero-match-is-missing rule, and the toy uses a literal package name as its
pattern (the degenerate case reads naturally).
· **Options:** (a) confirm patterns (as specified); (b) explicit package enumeration;
(c) patterns + minimum match count.
· **Recommendation: (a)** — unchanged from sheet 01 Q-08; the verified full-match
semantics (D-15) removed the main foot-gun (accidental substring matches).
· **Contingent on Q-22 (rule that first):** under Q-22 (a) with behavioral targets
derived from the baseline's tests-role group, this question is **moot** — no patterns
remain; zero-match-missing becomes empty-group-missing.
· **Blocks:** ch. 5 §5.1 wording only; mechanics identical under (b).

**Q-21 · Where do gate-driving tests live? (applied working default: `Phi-Guardrails-CI-Tests`, D-23)**
*→ RULED: option (a) — D-23 confirmed and ratified; see `plan/decision-log.md` D-27.*
— Validation round 4 found that the CI adapter test (D-10) inside `Phi-Guardrails-Tests-Gate`
makes the self-hosted gate recurse: the framework's `#testPackages` sweeps the package
containing the test that runs the gate. Some placement ruling is unavoidable; the spec
applies a working default and the human may veto.
· **Options:** (a) *(applied, D-23)* a dedicated `Phi-Guardrails-CI-Tests` package outside
every swept namespace, selected explicitly by smalltalkCI — the Q-19/D-22 mechanism a
third time; states a general no-self-sweep rule that also protects clients (§8.1 step 4);
(b) keep the adapter in `Tests-Gate` and carve its name out of the framework's
`#testPackages` pattern — no new package, but the pattern grows a negative lookahead and
each new gate-driving test needs another carve-out; (c) a recursion guard inside the gate
(depth flag) — hides the design smell, leaves the demo test's mid-run source mutation
unsolved, and flirts with global state (R-35).
· **Recommendation: (a).** It is the mechanism this spec already uses twice, it fixes the
client-side reproduction of the bug, and it needs no gate machinery. (b) is fragile
pattern surgery; (c) trades a structural fix for hidden state.
· **Blocks:** ch. 7 §7.4/§7.5, ch. 8 §8.1/§8.3, baseline `CI` group if overruled.

---

**Q-22 · Package scope: Metacello-derived, not artifact opt-in (human's proposal at Gate 2)**
*→ RULED: option (a) with residual remediation in v1 — see `plan/decision-log.md` D-25.
Propagated through spec ch. 1/2/4/5/6/7/8, glossary, ch. 9, coverage, and R-02/R-23/R-24.*
— Raised and refined across the Gate-2 review discussion. History, kept for the record:
(1) the human identified `#packages` opt-in as a silence hole — code never listed is
never examined, with no diff anywhere; (2) a namespace-claim meta-rule was proposed and
rejected — a name pattern is opt-in one level up; (3) a baseline-reconciliation
meta-rule ("every package the baseline loads must be in `#packages`") was proposed and
rejected — two inventories plus a reconciliation check is a design seam, not a fix.
The human's standing proposal: **the baseline is the only package inventory; scope is
derived from it.**
· **Shape:** the artifact drops `#packages` (and possibly `#testPackages`) and names the
baseline instead (`#baseline : 'BaselineOfPhiGuardrails'`). The gate asks Metacello what
the baseline's groups load and derives scope by **group role**: production groups →
lint/architecture/secrets targets; a tests-role group → behavioral suites; exempt-role
groups (Toy, Fixtures, CI-Tests) → unswept. The artifact keeps genuine configuration
(which checks, layer map, secret patterns); the what-code question has one owner — the
file that must already be right for anything to ship, in git, diffable (P6 preserved).
CI is already Metacello-driven (§7.4 `SCIMetacelloLoadSpec`), so the gate reads the same
source of truth CI loads from.
· **What it closes / what remains:** the opt-in gap closes structurally — not in the
baseline means not in the product; in it means in scope. Residuals: misfiling a package
into an exempt group (visible diff in the single authoritative file; a group-role
namespace check can machine-catch it later); a `src/` directory the baseline never
loads (dead unguarded code — one small surviving check); Metacello introspection
spellings are ⟨verify⟩ — a D-15-style probe is prerequisite (P5).
· **Options:** (a) adopt for v1: amend the D-01/D-07 slice and R-02 (targets derive from
the baseline; the artifact still owns check registration), update spec ch. 1/5/7/8
accordingly, run the Metacello probe first; (b) adopt at M5, v1 keeps `#packages` as
ruled; (c) keep `#packages` opt-in permanently and accept review-tier risk.
· **Recommendation: (a).** The seam is cheapest to remove before any code exists; the
probe is small and rides the M0 toolchain; waiting (b) means building `#packages`
handling, its missing-semantics, and its docs, then ripping them out. This amends ruled
ground (D-01/D-07 provisioning slice, R-02), which is exactly why it needs the human's
formal ruling rather than an agent edit.
· **Supported by the agreed three-tier run model (Gate-2 discussion):** tier 1 edit-time
(touched methods, advisory) · tier 2 chunk-time (chunk tests + regression guard; local
checks may scope; advisory) · tier 3 CI (full registry from the committed artifact — the
only authoritative verdict; the source's S5). Under (a), tier 3's input is exactly what
Metacello loaded, group roles name each tier's scope, and agents' scoped scratch
configurations at tiers 1–2 are legitimate precisely because their verdicts don't count.
A Q-22 (a) ruling folds in: D-16 schema amendment (`#packages` → `#baseline`), D-23
restated as an exempt group role, Q-20 mooted, and the tier model written into ch. 7.
· **Blocks:** under (a): ch. 1 §1.1/§1.3/§1.5, ch. 5 §5.1, ch. 7 §7.5, ch. 8 artifacts
and baseline-group table; R-02/R-36 wording; the D-02/D-15 probe list. Under (b)/(c):
nothing now.

*Amendment-time notes (from the passing constitution validation; non-blocking, no ruling
needed): (i) §2 "named constructors over `new`+setters" could gain "for classes we
author" — spec §2.3's Renraku engine API legitimately uses `new`; (ii) the constitution's
"frozen at epic acceptance" and the spec's "frozen at M1" markers are two freeze
vocabularies never formally equated — the roadmap stage (Prompt 3) should map M1's
protocol markers onto its epic boundaries; (iii) the constitution is at exactly 2.0
pages — any amendment must displace text, not add.*

---

# Reopened · post-gate remediation round (2026-07-20)

*The sheet was closed at Gate 2 and is **reopened** by the owner to carry the questions
raised by the chapter-by-chapter spec review. Numbering continues (question IDs are
history, never reused). The first four (Q-23–Q-26) were ruled by the human in the same
message that reopened the sheet; Q-27 and Q-28 were appended by later review rounds and
ruled in turn.*

**Q-23 · A check that crashes: the headless entry must always decide an exit code**
*→ RULED: the review's full three-part recommendation (a)+(b)+(c); see `plan/decision-log.md` D-39.*
— *Partially ruled already:* **D-21** rules the per-registration half — a resolved check
whose `run` signals an unhandled exception yields a **red** verdict carrying the error
description, never a crash and never a pass (ch. 1 §1.4; property P-ERR-IS-RED). Ch. 7
never restated it, which is why the review could not see it. Genuinely **unspecified**:
errors escaping *outside* a registration's `run` — registry construction, report
rendering, the verdict sink, a non-`Error` exception. Then `runHeadless:` never answers,
`Smalltalk exit:` never evaluates, and the process exit code is whatever the headless
image happens to produce: a crashed gate that CI reads as success.
· **Ruled:** (a) per-registration catching with a blocking error verdict — confirmed as
already-specified D-21 ground, now restated in ch. 7; (b) a top-level handler in both
`runHeadless:` forms answering **2** (joining configuration errors as "the run produced
no verdict"); (c) the fixtures that make it testable — a check whose `run` throws and a
kit that throws during registry construction.
· **Blocks:** ch. 7 §7.3 contract and exit-code table; ch. 9 P-EXIT-CODES.

**Q-24 · Why the tests-role suites run twice — safety property or optimize away?**
*→ RULED: option (a); see `plan/decision-log.md` D-40.*
— smalltalkCI runs the tests-role packages *and* the adapter test's gate re-runs the same
suites. Unstated, this invites a future reader to make the gate the sole runner. The
bootstrap argument is decisive: CI loads committed source, so **a change to the gate is
judged by the changed gate**. A gate defect that greens regardless (broken tally, dropped
reds, early return in `run`) is caught by the independent smalltalkCI run and swallowed by
the gate-only arrangement.
· **Ruled (a):** state it in §7.4 as a safety property — the tests-role suites are run
independently by smalltalkCI so that a defect in the gate cannot suppress the tests that
detect it — paired with a "can the judge convict" test on the gate object (deliberately
red registration ⇒ report red, exit 1). Rejected: (b) convenience note only, (c) gate as
sole runner.
· **Accepted cost:** every tests-role suite executes twice per CI run — seconds at v1
size, and the price of the independence.
· **Blocks:** ch. 7 §7.4; one ch. 9 property.

**Q-25 · Must a registered lint rule declare its severity explicitly?**
*→ RULED: explicit severity required, no default; see `plan/decision-log.md` D-41.*
— Ch. 2 §2.2 inherited `#warning` on omission; ch. 7 §7.1 blocks only at `#error`.
Together they failed open: register a rule, forget the severity, and real violations exit
0 — the rule *looks* enforced and is advisory.
· **Ruled:** a registered lint rule whose class does not itself implement class-side
`severity` is a **configuration error**, caught by `forConfiguration:` before anything
runs. **No default** — the inherited `#warning` is no longer a legal state for a
*registered* rule (unregistered rules in the image are unaffected).
· **Accepted consequence:** we do not own `ReAbstractRule`, so a shipped built-in relying
on the inherited default is **unregistrable** — a real, narrow restriction on D-05's
register-by-name mechanism, accepted rather than softened with the reporting-only
fallback (the sheet's option (b)) or a per-registration override (foreclosed by D-24).
v1's own catalog is unaffected: both entries declare `#error` (D-20, D-28).
· **Blocks:** ch. 2 §2.2/§2.4, ch. 1 §1.1 validation list, ch. 9 (new property).

**Q-26 · May the fix command target the framework's own production packages?**
*→ RULED: option (a); see `plan/decision-log.md` D-42.*
— `PGRFixCommand` rewrites code and the spec never said whether it may be pointed at
`Phi-Guardrails-*` production packages; Pharo permits recompiling an executing method.
Two facts bound the risk: the gate **structurally cannot** invoke the fix command (the
framework's layer map forbids `-Gate` → `-Coding-Rules`; P-FIX-GATE-WALL), and an in-image
run is single-threaded, so a gate run and a fix command cannot interleave.
· **Ruled (a):** permitted, with a stated caution in ch. 3 §3.3 — fixing the framework's
own packages is legitimate self-hosting; the invoker must not do it from inside a gate
run, a condition carried structurally by P-FIX-GATE-WALL rather than by any runtime flag.
Rejected: (b) refusal (exempts the framework from its own instrument), (c) a runtime
"gate in progress" guard (exactly the global state R-35 forbids).
· **Blocks:** ch. 3 §3.3.

**Q-27 · The demo test mutates live source — how is the toy's red state protected?**
*→ RULED: option (a), both additions; see `plan/decision-log.md` D-43.*
— `PGRToyDemoTest` (§8.3) rewrites the toy's actual source in the running image (fix
command applied, forbidden reference removed, failing assertion repaired, skip removed)
and restores the saved originals in `tearDown`. Two failure modes: (i) if the body errors
part-way or `tearDown` itself raises, the toy is left **partly fixed** in the image; (ii)
the three tests share one mutable thing — the toy's source — and `testAllFixedThenClean`
deliberately leaves it fully green, so a failed restoration makes whichever test runs next
fail (or, worse in principle, pass) for a reason unrelated to the gate. This matters more
than usual because **the toy's red state is the fixture**: the whole demonstration rests
on it being reliably red at the start of every test.
· **Note — this amends a ruled entry's letter, not its substance:** D-26 ruled the toy
committed red with "the demo test drives red → fixed → green in-image and restores in
`tearDown`". Any option below keeps that; only the restoration mechanism changes.
· **Options:** (a) *(the review's recommendation)* make restoration **exception-safe** —
each mutation wrapped so the restore runs whether the body succeeded or not (`ensure:`),
not left to `tearDown` alone — **plus** a `setUp` precondition asserting the toy is in its
expected planted state before each test, so a leak fails loudly at its cause instead of
surfacing as a confusing failure elsewhere; (b) `ensure:` only (no precondition) — closes
the leak, keeps diagnosis harder; (c) don't mutate the committed toy at all: build scratch
copies of the toy packages per test and mutate those — strongest isolation, but the demo
stops exercising the committed artifact, which is the point of D-26.
· **Recommendation: (a).** Both halves are one line each and they close different holes:
`ensure:` prevents the leak, the precondition detects any leak that still happens (from a
future test, a manual Playground session, an interrupted run). (c) trades away the honesty
D-26 bought.
· **Blocks:** ch. 8 §8.3 wording; ch. 9's demo-test properties (P-GATE-RED) inherit the
guarantee.

**Q-28 · The gate's default Transcript sink vs the registered `Transcript show:` ban**
*→ RULED: no default sink — the gate writes only to what it is given (option (b),
strengthened: streaming is conditional on a supplied sink, and the P5 gap routes to
M1's match-set-pinning fixture); see `plan/decision-log.md` D-55.*
— §7.2 mandates "the default sink writes one line per verdict to the Transcript" (R-45's
in-image half), while the framework's own artifact registers
`ReCodeCruftLeftInMethodsRule` over all production packages — verified to fire on
`Transcript show:` (D-28) — and `Phi-Guardrails-Gate` is production-role, the
constitution bans the idiom, and **D-24 forecloses exclusions**. As specified, the M4
self-hosted gate goes red on its own streaming sink — unless the sink uses a Transcript
spelling the built-in provably does not match, and no probe has verified the rule's
match set beyond `show:` (a P5 gap). D-33's trade covers tests-role fixtures only;
nothing spotlights this production-code seam, and a chunk implementer hits it cold at
M1 (constitution idiom) or M4 (self-hosted gate).
· **Options:** (a) probe the built-in's full match set (D-31.a toolchain) and specify a
verified-non-matching spelling (e.g. `Transcript nextPutAll:` + `cr`) — P5-clean today
but brittle across Pharo upgrades: the D-34 severity-pin logic cuts against resting on
an unverified matcher boundary; (b) **the production sink never names Transcript** —
the default verdict sink writes to an *injected* stream (headless `runHeadless:on:`
already passes one; in-image, the invoker passes `Transcript`, documented as the
Playground idiom in §7.2). R-45's substance (a run is never a black box) is kept,
`Transcript` disappears from production source, the rule cannot fire, and nothing needs
excluding — amends §7.2's letter only; (c) drop the built-in from the framework's *own*
artifact — collides with §7.5's "we eat the explicit-composition rule" and weakens
D-28/R-16's early arrival.
· **Recommendation: (b)** — the structural resolution (make the violation impossible,
not caught: the D-42/D-53 wall pattern), no probe needed, the built-in's registration
untouched.
· **Blocks:** ch. 7 §7.2 wording; M1/M4 implementation.

---

*Sheet status: 5 Gate-2 entries **closed** — Q-18 → D-24 · Q-19 → D-26 · Q-20 closed as
moot (D-25) · Q-21 → D-27 · Q-22 → D-25; plus 6 reopened-round entries **closed** —
Q-23 → D-39 · Q-24 → D-40 · Q-25 → D-41 · Q-26 → D-42 · Q-27 → D-43 · Q-28 → D-55.
**Nothing open.** Agent-decided minor calls
— veto windows now closed by D-28: D-16, D-17, D-18, D-21 ratified; D-22 ratified (also
via D-26); D-23 ratified (also via D-27); D-19 **revised** — the v1 global catalog
registers `ReCodeCruftLeftInMethodsRule` (D-28). D-20 (`#error` severity for
`PGRNoIsNilIfTrueRule`) ratified by D-29. **Nothing on this sheet or in the veto ledger
remains open.** The spec re-validation (D-25/D-28 amendments) passed (round 6) and the
constitution re-validation passed after the D-30 amendments (human-confirmed 2026-07-11;
discharge recorded in D-31) — **Gate 2 is closed.***
