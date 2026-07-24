# Ledger — chunk state (the orchestrator's only mutable state)

*Created by Prompt 4's first run (E01). One row per chunk: status ∈
`todo / in-progress / review / accepted`. Everything else in `plan/` is
append-or-frozen.*

| ID | Epic | Status | Depends-on | Assignee | Verify command |
|---|---|---|---|---|---|
| C01 | E01 | todo | — | — | `bash tools/install.sh && bash tools/probe-m0.sh` (exit 0; install run twice) |
| C02 | E01 | todo | C01 | — | `bash tools/build-image.sh && bash tools/verify.sh` (exit 0, 5 tests run) |
| C03 | E01 | todo | C02 (Q-29 ruled — D-64) | — | `gh run list --workflow=ci.yml --limit 1` → `completed success`; `tools/verify.sh` and `tools/probe-m0.sh` green on same commit |
| C04 | E01 | todo | C03 | — | on one commit: `bash tools/build-image.sh && bash tools/verify.sh` (exit 0, 5 tests) · `bash tools/probe-m0.sh` exit 0 · `gh run list --workflow=ci.yml --limit 1` → `completed success` · D-63 answers all four probe bullets |

**Epic acceptance:** E01 `accepted` when all four rows are `accepted` and the exit
checkpoint in `plan/04-epics/E01-build-test-harness/chunks.md` is filled in — at
which point E01's interface digest (the naming tree) freezes and E02's entry check
can pass.
