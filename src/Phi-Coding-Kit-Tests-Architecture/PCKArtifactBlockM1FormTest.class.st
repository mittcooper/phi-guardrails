"
Pins the coding-kit block of the framework's own committed guardrails.ston to its completed §7.5 form: the top-level #src, both #architectureChecks entries, and the §4.4 #layerMap, with every named check resolving live against the seven loaded production packages. Reads the repo's own config from disk (tests may do file I/O — P-DETERMINISTIC binds production packages only) and drives PCKKit's environment registration surface with the real production packages and the repo's real src/; reading the config is not invoking the gate on it (§8.1's residual caveat bans only the gate invocation). P-SDK-EDGE: this class references STON, PCKKit, and SDK classes only (PGRKitEnvironment is SDK) — never PGRConfiguration, PGRRegistry, or any -Core/-Gate class. The name's 'M1' is a historical anchor: the class was born pinning the M1 form and now pins each scheduled growth of the artifact — E11 amended the M1-form assertions to the completed form when the artifact grew (renaming would orphan the accepted ledger/checkpoint references to it).
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
PCKArtifactBlockM1FormTest >> completedSpecs [
	"The block's registrations over the environment form (E11-C04): the real seven production packages (all loaded in the verify image, so the §4.4 map covers) and the repo's real src/, with one scratch tests package. The #layerMap validates at block-open against the handed production role — the real map cannot cover scratch roles, so the environment form with the real packages is required here."
	^ PCKKit
		registrationsFrom: self codingKitBlock
		environment: (PGRKitEnvironment
			productionPackages: #( 'Phi-Guardrails-SDK' 'Phi-Guardrails-Core'
				'Phi-Guardrails-Gate' 'Phi-Coding-Kit' 'Phi-Coding-Kit-Rules'
				'Phi-Coding-Kit-Architecture' 'Phi-Coding-Kit-Behavioral' )
			testsPackages: #( 'T-One' )
			exemptPackages: #(  )
			srcPath: (self repoRoot / 'src') fullName)
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
PCKArtifactBlockM1FormTest >> testBlockRegistersTheCompletedFormSpecs [
	"The completed block derives the two lint specs, both architecture checks, the one derived behavioral suite, and the meta-rule — in the canonical four-stage order (lint, architecture, behavioral, meta)."
	self assert: (self completedSpecs collect: [ :spec | spec name ]) asArray
		equals: #( 'lint/PCKNoIsNilIfTrueRule' 'lint/ReCodeCruftLeftInMethodsRule' 'architecture/PCKLayerMapCheck' 'architecture/PCKSrcInventoryCheck' 'behavioral/T-One' 'behavioral/PCKNoSkippedTestsMetaRule' )
]

{ #category : 'tests' }
PCKArtifactBlockM1FormTest >> testCodingKitBlockIsTheCompletedForm [
	"The committed artifact carries exactly one kit block in its completed §7.5 form: the five-key set including #architectureChecks and #layerMap, the top-level #src of 'src', and a #layerMap whose four total layers need no #unlayered key."
	| kits block |
	kits := self artifactMap at: #kits.
	self assert: kits size equals: 1.
	block := kits first.
	self assert: block keys asSortedCollection asArray equals: #( #architectureChecks #kit #layerMap #lintRules #metaRules ).
	self assert: (self artifactMap at: #src) equals: 'src'.
	self assert: ((block at: #layerMap) keys asSortedCollection asArray) equals: #( #allowed #layers ).
	self assert: (block at: #architectureChecks) asArray equals: #( 'PCKLayerMapCheck' 'PCKSrcInventoryCheck' )
]

{ #category : 'tests' }
PCKArtifactBlockM1FormTest >> testEveryNamedCheckResolves [
	"The committed artifact names no unloadable check: every spec's check is non-nil (a missing registration in the self-hosted gate is a build failure, P6/R-38). Both architecture entries resolve live — the map covers the seven loaded packages and #src is handed."
	self assert: (self completedSpecs allSatisfy: [ :spec | spec check notNil ])
]
