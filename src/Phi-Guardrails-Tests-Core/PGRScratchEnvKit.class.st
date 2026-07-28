"
E11-C02 scratch fixture - the environment-handoff witness (D-81 ruling 3). A duck-typed plain Object subclass (D-53), class-side only and stateless, answering the two frozen class-side selectors resolveKitClassNamed: requires (registrationsFrom:productionPackages:testsPackages: and recommendedBlock) plus the opt-in environment form registrationsFrom:environment:. It echoes rather than captures: each registering arm answers one missing spec whose reason encodes, in a fixed assertable format, which path the engine took and what it was handed - the environment form encodes the view's four facts (production, tests, exempt, and srcPath printString); the three-argument fallback encodes the two role lists and marks itself the frozen path. Tests read the handoff off the spec, never off captured state (R-35).
"
Class {
	#name : 'PGRScratchEnvKit',
	#superclass : 'Object',
	#category : 'Phi-Guardrails-Tests-Core',
	#package : 'Phi-Guardrails-Tests-Core'
}

{ #category : 'accessing' }
PGRScratchEnvKit class >> recommendedBlock [
	^ '{ #kit : ''PGRScratchEnvKit'' }'
]

{ #category : 'registering' }
PGRScratchEnvKit class >> registrationsFrom: aBlock environment: anEnvironment [
	"The opt-in environment form (D-81): echo the view's four facts into one missing spec's reason, in a fixed assertable format - the environment-path witness. srcPath printString renders nil as 'nil' and an absolute path as its quoted String, so the srcPath witness reads either off the same reason."
	^ { PGRRegistrationSpec
		missing: 'scratch/env'
		kind: #scratch
		reason: 'environment | production: ' , (', ' join: anEnvironment productionPackages)
			, ' | tests: ' , (', ' join: anEnvironment testsPackages)
			, ' | exempt: ' , (', ' join: anEnvironment exemptPackages)
			, ' | srcPath: ' , anEnvironment srcPath printString }
]

{ #category : 'registering' }
PGRScratchEnvKit class >> registrationsFrom: aBlock productionPackages: productionNames testsPackages: testsNames [
	"The frozen three-argument conformance baseline (D-81) - the fallback detector: the reason marks the frozen path, so a test would see the engine never probed the environment form."
	^ { PGRRegistrationSpec
		missing: 'scratch/env'
		kind: #scratch
		reason: 'three-argument | production: ' , (', ' join: productionNames)
			, ' | tests: ' , (', ' join: testsNames) }
]
