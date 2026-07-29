"
Mirror test for PGRConfigurationDraft (spec ch. 8 §8.1 step 1). The draft is honest input to
the strict parser, not merely plausible text: testDraftForToyParsesAndValidates hands
draftFor: 'BaselineOfToy' straight to PGRConfiguration fromString: and reads the validated
result. testDraftGuessesRolesBySuffix pins the groupless role guess, testDraftComposesThe-
RecommendedStanza pins the D-54.3 single-source (the kit block IS PCKKit recommendedBlock,
byte-derived), testUnknownBaselineNameRaisesConfigurationError pins the loud-failure arm. This
is a tests-role class - outside every production layer/neutrality wall - so it references
PCKKit and the toy names freely.
"
Class {
	#name : 'PGRConfigurationDraftTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-Core',
	#package : 'Phi-Guardrails-Tests-Core'
}

{ #category : 'fixtures' }
PGRConfigurationDraftTest >> toyConfiguration [
	"The toy draft parsed and validated through the strict parser - the shared subject of the
	introspection and composition assertions."

	^ PGRConfiguration fromString: (PGRConfigurationDraft draftFor: 'BaselineOfToy')
]

{ #category : 'tests' }
PGRConfigurationDraftTest >> testDraftComposesTheRecommendedStanza [
	"D-54.3: the drafted kit block is the published stanza, byte-derived - some block of
	kitBlocks equals STON fromString: PCKKit recommendedBlock (membership, so a future second
	shipped kit extends rather than breaks this)."

	| configuration publishedBlock |
	configuration := self toyConfiguration.
	publishedBlock := STON fromString: PCKKit recommendedBlock.
	self assert: (configuration kitBlocks anySatisfy: [ :block | block = publishedBlock ])
]

{ #category : 'tests' }
PGRConfigurationDraftTest >> testDraftForToyParsesAndValidates [
	"The §8.1 step-1 story end-to-end: draftFor: 'BaselineOfToy' handed to the strict parser
	validates and answers a configuration whose project is 'Toy' and whose baseline is
	BaselineOfToy."

	| configuration |
	configuration := self toyConfiguration.
	self assert: configuration project equals: 'Toy'.
	self assert: configuration baselineClass name asString equals: 'BaselineOfToy'
]

{ #category : 'tests' }
PGRConfigurationDraftTest >> testDraftGuessesRolesBySuffix [
	"Baseline introspection, the groupless case: the suffix guess assigned all five packages
	explicitly - four to production, only Toy-Tests to tests - naming no group (the target
	baseline has none to name)."

	| configuration |
	configuration := self toyConfiguration.
	self
		assert: configuration productionPackageNames asSortedCollection asArray
		equals: #( 'Toy-Core' 'Toy-Persistence' 'Toy-Rules' 'Toy-UI' ).
	self assert: (configuration testsPackageNames includes: 'Toy-Tests').
	self assert: configuration testsPackageNames size equals: 1
]

{ #category : 'tests' }
PGRConfigurationDraftTest >> testUnknownBaselineNameRaisesConfigurationError [
	"Loud failure over inference (family 7): a name that resolves to no loaded BaselineOf
	subclass raises PGRConfigurationError, and its message names the missing baseline."

	| raised |
	raised := false.
	[ PGRConfigurationDraft draftFor: 'BaselineOfNoSuchThing' ]
		on: PGRConfigurationError
		do: [ :error |
			raised := true.
			self assert: (error messageText includesSubstring: 'BaselineOfNoSuchThing') ].
	self assert: raised description: 'draftFor: an unknown baseline must signal PGRConfigurationError'
]
