# Spec ch. 6 — Secrets-leak check — WITHDRAWN (D-37)

*This file is retained as a numbered placeholder so chapters 7–9 keep their numbers. The
check it specified was withdrawn from scope at the Gate-2 human review; the ruling is
`plan/decision-log.md` **D-37**, which supersedes R-28 and D-09.*

The pattern-based secrets-leak check was withdrawn because pattern matching against
well-known key formats is brittle, costly to maintain, and — decisively — **false
security**: it catches only formats it already knows, so a new provider's token format
passes silently while a green verdict is read as "no secrets." A guard that silently ages
into blindness while reporting success is worse than no guard. An agentic (LLM-based)
in-gate redesign was assessed and rejected: it would break the gate's deterministic
contract (same code → same verdict, offline), break fixture discipline (R-37), and invert
the dependency (the framework would need an LLM client — and an API key in CI).

**Where the concern now lives** (neither relocation is this repository's task, D-37):

- **Detection** → the method layer (`../phi/method/`): an agentic review instruction in
  the chunk-reviewer/integrator prompts — judgment-tier (family §3.1), advisory,
  format-agnostic; may be seeded with the known regexes as hints and improves through the
  method's eval/correction cycle. It makes no deterministic-gate promise.
- **Prevention** → phi-llm's constitution (credentials only via a provider abstraction,
  never literals) — phi-llm's decision, not this framework's.

With the withdrawal, the coding kit's check kinds are `#lint`, `#architecture`, and
`#behavioral`; D-37's consequences list names every knock-on amendment across chapters
1–9, the glossary, and the coverage table.
