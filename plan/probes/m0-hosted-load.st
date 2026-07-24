"M0 hosted-load probe (D-60.a hosted form, E01/C04) — in a FRESH pristine image
 (never the work image; tools copy it to .build/scratch/), run spec §7.3 recipe
 step 2 with the D-64 ruled coordinates, then assert in the same session that the
 baseline class arrived and the smoke suite passes (the suite asserts the 20
 packages and the group tree exactly). Exit 0 = load green + suite green; exit 1 =
 suite red; any load failure signals and exits nonzero on its own. Results:
 decision-log D-63."
| result |
Metacello new
    baseline: 'PhiGuardrails';
    repository: 'github://mittcooper/phi-guardrails:main/src';
    load: 'CI'.
(Smalltalk globals includesKey: #BaselineOfPhiGuardrails)
    ifFalse: [ Stdio stdout nextPutAll: 'HOSTED-LOAD: no BaselineOfPhiGuardrails'; lf.
        Smalltalk exit: 1 ].
result := (Smalltalk globals at: #PGRBaselineSmokeTest) buildSuite run.
Stdio stdout nextPutAll: 'HOSTED-LOAD: '; nextPutAll: result printString; lf.
Smalltalk exit: (result hasPassed ifTrue: [ 0 ] ifFalse: [ 1 ])
