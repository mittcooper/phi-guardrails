"
Pins the E05-C02 PGRReport value and rendering contract: isClean/exitCode over P6's four
verdict statuses (only #green is clean; #red/#missing/#skipped all block - silence never
passes), blockingVerdicts is exactly the non-green verdicts in order, advisories aggregate
across verdicts and never block (D-03), verdicts answers a fresh Array copy per send
(R-35), and printOn: renders the §7.2 header/verdict-lines/summary shape (substrings only -
the format is explicitly not an API).
"
Class {
	#name : 'PGRReportTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-Gate',
	#package : 'Phi-Guardrails-Tests-Gate'
}

{ #category : 'tests' }
PGRReportTest >> testAdvisoriesAggregateAcrossVerdictsAndNeverBlock [
	| first second report |
	first := PGRVerdict greenAdvisories: { PGRFinding target: 'A>>#m' message: 'first advisory' }.
	second := PGRVerdict greenAdvisories: { PGRFinding target: 'B>>#n' message: 'second advisory' }.
	report := PGRReport project: 'Scratch' verdicts: { first. second }.
	self assert: report advisories equals: (first advisories , second advisories).
	self assert: report isClean.
	self assert: report exitCode equals: 0
]

{ #category : 'tests' }
PGRReportTest >> testAnyNonGreenVerdictAnswersExitOne [
	| report |
	report := PGRReport project: 'Scratch' verdicts: { PGRVerdict green. PGRVerdict redFindings: #() }.
	self deny: report isClean.
	self assert: report exitCode equals: 1
]

{ #category : 'tests' }
PGRReportTest >> testBlockingVerdictsAreExactlyNonGreenInOrder [
	| green1 red missing green2 report |
	green1 := PGRVerdict green registrationName: 'lint/A'; yourself.
	red := (PGRVerdict redFindings: #()) registrationName: 'lint/B'; yourself.
	missing := (PGRVerdict missingReason: 'no tests') registrationName: 'behavioral/C'; yourself.
	green2 := PGRVerdict green registrationName: 'lint/D'; yourself.
	report := PGRReport project: 'Scratch' verdicts: { green1. red. missing. green2 }.
	self assert: (report blockingVerdicts collect: [ :v | v registrationName ])
		equals: { 'lint/B'. 'behavioral/C' }
]

{ #category : 'tests' }
PGRReportTest >> testCleanReportAnswersExitZero [
	| report |
	report := PGRReport project: 'Scratch' verdicts: { PGRVerdict green. PGRVerdict green }.
	self assert: report isClean.
	self assert: report exitCode equals: 0.
	self assert: report blockingVerdicts isEmpty
]

{ #category : 'tests' }
PGRReportTest >> testMissingVerdictBlocks [
	| missing report |
	missing := PGRVerdict missingReason: 'tests-role package contains no tests'.
	missing registrationName: 'behavioral/Toy-Tests'.
	report := PGRReport project: 'Scratch' verdicts: { PGRVerdict green. missing }.
	self deny: report isClean.
	self assert: report exitCode equals: 1.
	self assert: (report blockingVerdicts includes: missing)
]

{ #category : 'tests' }
PGRReportTest >> testPrintOnRendersHeaderVerdictLinesAndSummary [
	| green red missing finding report rendered |
	green := PGRVerdict green.
	green registrationName: 'lint/PCKNoIsNilIfTrueRule'; kind: #lint; durationMillis: 34.
	finding := PGRFinding target: 'ToyWidget>>#render' message: 'references ToyDatabase' rationale: 'layers must not cross'.
	red := PGRVerdict redFindings: { finding }.
	red registrationName: 'architecture/PCKLayerMapCheck'; kind: #architecture; durationMillis: 12.
	missing := PGRVerdict missingReason: 'tests-role package contains no tests'.
	missing registrationName: 'behavioral/Toy-Tests'; kind: #behavioral.
	report := PGRReport project: 'Scratch' verdicts: { green. red. missing }.
	rendered := report printString.
	self assert: (rendered includesSubstring: 'PGR gate').
	self assert: (rendered includesSubstring: 'Scratch').
	self assert: (rendered includesSubstring: '3 registrations').
	self assert: (rendered includesSubstring: '[ GREEN ]').
	self assert: (rendered includesSubstring: '[ RED').
	self assert: (rendered includesSubstring: '[MISSING]').
	self assert: (rendered includesSubstring: 'lint/PCKNoIsNilIfTrueRule').
	self assert: (rendered includesSubstring: 'architecture/PCKLayerMapCheck').
	self assert: (rendered includesSubstring: 'behavioral/Toy-Tests').
	self assert: (rendered includesSubstring: 'ToyWidget>>#render').
	self assert: (rendered includesSubstring: 'references ToyDatabase').
	self assert: (rendered includesSubstring: 'rationale:').
	self assert: (rendered includesSubstring: 'layers must not cross').
	self assert: (rendered includesSubstring: 'tests-role package contains no tests').
	self assert: (rendered includesSubstring: 'GATE:').
	self assert: (rendered includesSubstring: '2 blocking').
	self assert: (rendered includesSubstring: 'exit 1')
]

{ #category : 'tests' }
PGRReportTest >> testVerdictsAnswersFreshCopyPerSend [
	| v1 v2 report first second |
	v1 := PGRVerdict green.
	v2 := PGRVerdict green.
	report := PGRReport project: 'Scratch' verdicts: { v1. v2 }.
	first := report verdicts.
	second := report verdicts.
	self deny: first == second.
	self assert: first first == second first.
	self assert: first second == second second
]
