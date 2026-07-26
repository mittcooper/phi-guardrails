"
Pins the coding-kit block of the framework's own committed guardrails.ston to its M1 form: no architecture entries yet, and everything the block does name resolves to a loaded check. Reads the repo's own config from disk (tests may do file I/O — P-DETERMINISTIC binds production packages only) and drives only PCKKit's registration surface with scratch role lists; reading the config is not invoking the gate on it (§8.1's residual caveat bans only the gate invocation). P-SDK-EDGE: this class references STON, PCKKit, and SDK classes only — never PGRConfiguration, PGRRegistry, or any -Core/-Gate class. E11 amends the M1-form assertions by schedule when the artifact grows.
"
Class {
	#name : 'PCKArtifactBlockM1FormTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Tests-Architecture',
	#package : 'Phi-Coding-Kit-Tests-Architecture'
}

{ #category : 'accessing' }
PCKArtifactBlockM1FormTest >> artifactMap [
	"The committed guardrails.ston parsed as pure-data STON (D-16)."
	^ STON fromString: (self repoRoot / 'guardrails.ston') readStream upToEnd
]

{ #category : 'accessing' }
PCKArtifactBlockM1FormTest >> codingKitBlock [
	^ (self artifactMap at: #kits) first
]

{ #category : 'accessing' }
PCKArtifactBlockM1FormTest >> m1Specs [
	"The block's registrations over scratch role lists — one production, one tests package."
	^ PCKKit
		registrationsFrom: self codingKitBlock
		productionPackages: #( 'P-One' )
		testsPackages: #( 'T-One' )
]

{ #category : 'accessing' }
PCKArtifactBlockM1FormTest >> repoRoot [
	"Walk upward (≤ 8 levels) from the working directory, then from the image directory, for a directory holding guardrails.ston. Local runs launch from the repo root; the work image sits two levels under it. None found → error loudly, never skip."
	{ FileSystem workingDirectory. FileLocator imageDirectory }
		do: [ :start |
			| dir |
			dir := start.
			1 to: 8 do: [ :level |
				(dir / 'guardrails.ston') exists ifTrue: [ ^ dir ].
				dir := dir parent ] ].
	self error: 'guardrails.ston not found walking up from the working or image directory'
]

{ #category : 'tests' }
PCKArtifactBlockM1FormTest >> testCodingKitBlockIsTheM1Form [
	"The committed artifact carries exactly one kit block whose keys are the M1 set — no architecture, no layer map — and the artifact map carries no #src key."
	| kits block |
	kits := self artifactMap at: #kits.
	self assert: kits size equals: 1.
	block := kits first.
	self assert: block keys asSortedCollection asArray equals: #( #kit #lintRules #metaRules ).
	self deny: (block includesKey: #architectureChecks).
	self deny: (block includesKey: #layerMap).
	self deny: (self artifactMap includesKey: #src)
]

{ #category : 'tests' }
PCKArtifactBlockM1FormTest >> testEveryNamedCheckResolves [
	"The committed artifact names no unloadable check: every spec's check is non-nil (a missing registration in the self-hosted gate is a build failure, P6/R-38)."
	self assert: (self m1Specs allSatisfy: [ :spec | spec check notNil ])
]

{ #category : 'tests' }
PCKArtifactBlockM1FormTest >> testM1BlockRegistersLintAndMetaOnly [
	"The M1 block derives exactly the two lint specs, the one derived behavioral suite, and the meta-rule — in the canonical four-stage order, no architecture/ name."
	self assert: (self m1Specs collect: [ :spec | spec name ]) asArray
		equals: #( 'lint/PCKNoIsNilIfTrueRule' 'lint/ReCodeCruftLeftInMethodsRule' 'behavioral/T-One' 'behavioral/PCKNoSkippedTestsMetaRule' )
]
