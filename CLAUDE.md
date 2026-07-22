# phi-guardrails

A generic, extensible **guardrails framework** for agentic work in Pharo 13 — one **check
registry** (check kinds × global/project scopes) + a headless **gate** that fails on anything
registered that is missing, skipped, or red. First domain kit: **coding** (lint/AST rules
with autofix, architecture tests, behavioral-test enforcement). The framework knows no
client; clients (first: phi-llm) extend it via configuration and their own extension
packages.

Part of the **Phi** family — AI agents native to the Pharo image ("the agent is the
image"): phi-llm, phi-guardrails, later phi-session, phi-agent-runtime, phi-ui,
phi-coding-agent, phi-examples. Family vision + design principles:
`../phi/phi-overview.md`. Packages `Phi-Guardrails-*`,
class prefix `PG`, `BaselineOfPhiGuardrails`, Tonel under `src/`.

## How this project is built

By the **prompt-suite method**: staged prompts (consolidate → specify → decompose ×2 →
execution loop) with human gates, fresh-session adversarial validators, and 50–150-LOC
verified chunks.

- **`pack.md`** — the project pack: sources, binding principles P1–P6, scope, standards,
  verify command. Prepended as `{{PACK}}` to every method prompt. **Read it first.**
- **Method document** (the prompts to paste): `../phi/method/prompt-suite-method.md`
- `sources/` — the source documents (self-contained copy)
- `plan/` — pipeline artifacts (requirements, decision log, constitution, spec, roadmap,
  epics, ledger)
- `src/` — the code; tests `Phi-Guardrails-Tests-*`

## Standing rules for agents in this repo

- The pack's binding principles are the tie-breakers; the decision log
  (`plan/decision-log.md`) wins on any conflict with older prose.
- Never skip a pipeline stage; artifacts are validated in fresh sessions before human gates.
- Chunks: 50–150 LOC including tests (ceiling 300), tests first, done = verify command
  exits 0. Nothing is "done" by inspection.
- Every unsettled question becomes a numbered decision-sheet entry for the human — agents
  recommend, humans rule.

## Wider layout

Sibling repos under `../`: `../phi` (family repo — the method, the pack template, the
family overview), `../phi-llm` and other components as they start. Legacy design-doc corpus
(phi-llm sources, archive): `/Users/mitt/Downloads/latest_files/`.
