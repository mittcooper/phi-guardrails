# 03 · Spec defects — roadmap stage

*Prompt 3's defect channel: anything the roadmap could not derive from
`plan/02-spec/` + the decision log without returning to the source corpus, or any
contradiction found while decomposing. Recorded per the stage instructions; the
roadmap works around nothing silently.*

**No defects.** The full corpus read (all ten chapters, glossary, coverage,
architecture, quickstarts) supported the decomposition without consulting
`sources/`; no contradiction with the decision log survived to this stage.

Two near-findings, recorded as consequences rather than defects:

1. **Behavioral enforcement is a prerequisite of the first self-hosted run** — the
   mandatory `#tests` role (ch. 1 §1.1) × unconditional suite derivation (ch. 5
   §5.1) × "self-hosted from M1" (constitution §3, R-38) jointly force the
   pack-M3 content into M1. The spec is internally consistent about this; only the
   pack's non-binding milestone sketch missed it. Handled in the roadmap (§0
   point 1, epic E07); no spec text needs amending.
2. **The §7.5 artifact is a final state, not an M1 state** — the constitution's
   "each registers as it lands (M1–M4)" licenses the growing artifact; the roadmap
   names the M1 form explicitly (E09) and the completion point (E11). Consistent;
   no amendment needed.
