"
Mirror test for PGRConfiguration. Carries the canonical green artifact (validArtifactString) reused by every later E03 chunk, plus one-line mutation helpers for the defect arms. testUnknownKeySignals is the named test of property P-CFG-STRICT; testRolesByPatternWithoutBaselineGroups is the named test of P-ROLES-FROM-CONFIG (first half).
"
Class {
	#name : 'PGRConfigurationTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-Core',
	#package : 'Phi-Guardrails-Tests-Core'
}

{ #category : 'fixtures' }
PGRConfigurationTest >> artifactMap [
	"The parsed valid artifact, for one-line mutations in the defect-arm tests."
	^ STON fromString: self validArtifactString
]

{ #category : 'fixtures' }
PGRConfigurationTest >> artifactWith: aKey value: aValue [
	| map |
	map := self artifactMap.
	map at: aKey put: aValue.
	^ STON toString: map
]

{ #category : 'fixtures' }
PGRConfigurationTest >> artifactWithExempt: matcherArray [
	"The valid artifact with #exempt replaced - the stage-5 mutation point shared by the matcher-arm tests."
	| map |
	map := self artifactMap.
	(map at: #roles) at: #exempt put: matcherArray.
	^ STON toString: map
]

{ #category : 'fixtures' }
PGRConfigurationTest >> artifactWithout: aKey [
	| map |
	map := self artifactMap.
	map removeKey: aKey.
	^ STON toString: map
]

{ #category : 'tests' }
PGRConfigurationTest >> testEmptyGroupMatcherIsLegal [
	"An empty group is a legal baseline fact (D-25.a addendum): the group arm matches and contributes nothing."
	| configuration |
	configuration := PGRConfiguration fromString: (self artifactWithExempt: #( 'scratch-ghost' 'scratch-empty' )).
	self assert: configuration exemptPackageNames equals: #( 'PGR-Scratch-Ghost' )
]

{ #category : 'tests' }
PGRConfigurationTest >> testGroupMatcherExpandsToRoleReaders [
	"Stage 5, the group arm: each role's group matcher expands to the group's transitive package names, in baseline declaration order."
	| configuration |
	configuration := PGRConfiguration fromString: self validArtifactString.
	self assert: configuration productionPackageNames equals: #( 'Phi-Guardrails-SDK' 'Phi-Guardrails-Core' ).
	self assert: configuration testsPackageNames equals: #( 'Phi-Guardrails-Tests-SDK' ).
	self assert: configuration exemptPackageNames equals: #( 'PGR-Scratch-Ghost' )
]

{ #category : 'tests' }
PGRConfigurationTest >> testInvalidPatternMatcherSignals [
	"A matcher the regex engine rejects is a loud configuration error naming it - no engine exception escapes fromString: (family 7)."
	self
		should: [ PGRConfiguration fromString: (self artifactWithExempt: #( 'Toy-(' )) ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error | self assert: (error messageText includesSubstring: 'Toy-(') ]
]

{ #category : 'tests' }
PGRConfigurationTest >> testKitsBlockShapeSignals [
	"Kits must be a non-empty list of blocks each carrying #kit - the rest of a block is opaque (D-51)."
	self
		should: [ PGRConfiguration fromString: (self artifactWith: #kits value: #(  )) ]
		raise: PGRConfigurationError.
	self
		should: [ PGRConfiguration fromString: (self artifactWith: #kits value: (Array with: (Dictionary with: #notKit -> 'X'))) ]
		raise: PGRConfigurationError
]

{ #category : 'tests' }
PGRConfigurationTest >> testMalformedStonSignals [
	"STONReaderError never escapes fromString: - it is re-signalled as a configuration error (D-49)."
	self should: [ PGRConfiguration fromString: '{ #a : ' ] raise: PGRConfigurationError
]

{ #category : 'tests' }
PGRConfigurationTest >> testMissingCoreKeySignals [
	self
		should: [ PGRConfiguration fromString: (self artifactWithout: #roles) ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error | self assert: (error messageText includesSubstring: 'roles') ]
]

{ #category : 'tests' }
PGRConfigurationTest >> testNeverShippedVersionOneSignals [
	"P-SCHEMA-REFUSAL: version 1 is the never-shipped pre-D-51 draft - unknown, not parsed (D-51 detail 4); the refusal names both versions."
	self
		should: [ PGRConfiguration fromString: (self artifactWith: #schemaVersion value: 1) ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: '1').
			self assert: (error messageText includesSubstring: '2') ]
]

{ #category : 'tests' }
PGRConfigurationTest >> testNewerSchemaVersionSignals [
	"P-SCHEMA-REFUSAL: a newer schema version is refused outright, never misread; the refusal names both versions, the artifact's and the gate's own (D-45 ruling 3)."
	self
		should: [ PGRConfiguration fromString: (self artifactWith: #schemaVersion value: 3) ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: '3').
			self assert: (error messageText includesSubstring: '2') ]
]

{ #category : 'tests' }
PGRConfigurationTest >> testNonBaselineClassSignals [
	"A loaded class outside the BaselineOf hierarchy is refused as the baseline, naming it (D-25.a)."
	self
		should: [ PGRConfiguration fromString: (self artifactWith: #baseline value: 'PGRFinding') ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error | self assert: (error messageText includesSubstring: 'PGRFinding') ]
]

{ #category : 'tests' }
PGRConfigurationTest >> testNonKitClassSignals [
	"A loaded class answering neither kit-protocol selector is refused, naming the class and the missing selector (the D-53 error style); PGRFinding is the loaded non-kit."
	self
		should: [ PGRConfiguration fromString: (self artifactWith: #kits value: (Array with: (Dictionary with: #kit -> 'PGRFinding'))) ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'PGRFinding').
			self assert: (error messageText includesSubstring: 'registrationsFrom:productionPackages:testsPackages:') ]
]

{ #category : 'tests' }
PGRConfigurationTest >> testNonMapTopLevelSignals [
	"The envelope is one map with Symbol keys - a non-map top level and a String-keyed map are both refused."
	self should: [ PGRConfiguration fromString: '[ 1 ]' ] raise: PGRConfigurationError.
	self should: [ PGRConfiguration fromString: '{ ''schemaVersion'' : 2 }' ] raise: PGRConfigurationError
]

{ #category : 'tests' }
PGRConfigurationTest >> testResolvedKitAndBaselineReaders [
	"Kit resolution answers the class itself via the conformance path - PGRScratchKit is duck-typed, no PGRKit ancestry (D-53); the baseline resolves to the loaded BaselineOf subclass."
	| configuration |
	configuration := PGRConfiguration fromString: self validArtifactString.
	self assert: configuration kitClasses asArray equals: { PGRScratchKit }.
	self assert: configuration baselineClass equals: BaselineOfPGRScratchGrouped
]

{ #category : 'tests' }
PGRConfigurationTest >> testRolesByPatternWithoutBaselineGroups [
	"P-ROLES-FROM-CONFIG (first half): assignment comes from the configuration, inventory from the baseline (D-45) - a baseline with no role groups needs none; pattern and exact-package-name matchers carry the roles."
	| map configuration |
	map := self artifactMap.
	map at: #baseline put: 'BaselineOfPGRScratchPlain'.
	(map at: #roles)
		at: #production put: #( 'Phi-Guardrails-(SDK|Core)' );
		at: #tests put: #( 'Phi-Guardrails-Tests-SDK' );
		removeKey: #exempt.
	configuration := PGRConfiguration fromString: (STON toString: map).
	self assert: configuration productionPackageNames equals: #( 'Phi-Guardrails-SDK' 'Phi-Guardrails-Core' ).
	self assert: configuration testsPackageNames equals: #( 'Phi-Guardrails-Tests-SDK' ).
	self assertEmpty: configuration exemptPackageNames
]

{ #category : 'tests' }
PGRConfigurationTest >> testRolesShapeSignals [
	"Roles carry exactly a subset of #production/#tests/#exempt, the first two mandatory."
	| map |
	map := self artifactMap.
	(map at: #roles) removeKey: #tests.
	self should: [ PGRConfiguration fromString: (STON toString: map) ] raise: PGRConfigurationError.
	map := self artifactMap.
	(map at: #roles) at: #extraRole put: #(  ).
	self
		should: [ PGRConfiguration fromString: (STON toString: map) ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error | self assert: (error messageText includesSubstring: 'extraRole') ]
]

{ #category : 'tests' }
PGRConfigurationTest >> testSubstringMatchDoesNotCount [
	"D-15 witnessed: 'Guardrails-Tests-SDK' substring-matches Phi-Guardrails-Tests-SDK but does not full-match, so it adds nothing."
	| configuration |
	configuration := PGRConfiguration fromString: (self artifactWithExempt: #( 'scratch-ghost' 'Guardrails-Tests-SDK' )).
	self assert: configuration exemptPackageNames equals: #( 'PGR-Scratch-Ghost' )
]

{ #category : 'tests' }
PGRConfigurationTest >> testUnknownBaselineSignals [
	"A baseline name resolving to no loaded class is a configuration error naming it."
	self
		should: [ PGRConfiguration fromString: (self artifactWith: #baseline value: 'BaselineOfPGRNoSuch') ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error | self assert: (error messageText includesSubstring: 'BaselineOfPGRNoSuch') ]
]

{ #category : 'tests' }
PGRConfigurationTest >> testUnknownKeySignals [
	"P-CFG-STRICT: an unknown top-level key is a configuration error naming the key (D-51)."
	self
		should: [ PGRConfiguration fromString: (self artifactWith: #extra value: 1) ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error | self assert: (error messageText includesSubstring: 'extra') ]
]

{ #category : 'tests' }
PGRConfigurationTest >> testUnknownKitClassSignals [
	"P-CFG-STRICT, unknown-kit arm: a kit name resolving to no loaded class is a configuration error naming the kit name."
	self
		should: [ PGRConfiguration fromString: (self artifactWith: #kits value: (Array with: (Dictionary with: #kit -> 'PGRNoSuchKit'))) ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error | self assert: (error messageText includesSubstring: 'PGRNoSuchKit') ]
]

{ #category : 'tests' }
PGRConfigurationTest >> testValidArtifactParses [
	| configuration |
	configuration := PGRConfiguration fromString: self validArtifactString.
	self assert: configuration project equals: 'Scratch'.
	self assert: configuration kitBlocks size equals: 1.
	self assert: (configuration kitBlocks first at: #kit) equals: 'PGRScratchKit'
]

{ #category : 'tests' }
PGRConfigurationTest >> testVersionTwoParses [
	"The green arm: schema version 2 - the gate's own - parses; guards against an over-eager refusal."
	self assert: (PGRConfiguration fromString: self validArtifactString) class equals: PGRConfiguration
]

{ #category : 'tests' }
PGRConfigurationTest >> testZeroMatchMatcherIsLegal [
	"D-47: a matcher expanding to zero packages is not itself an error - its consequences are what the later machinery catches."
	| configuration |
	configuration := PGRConfiguration fromString: (self artifactWithExempt: #( 'scratch-ghost' 'PGR-Nothing-.*' )).
	self assert: configuration exemptPackageNames equals: #( 'PGR-Scratch-Ghost' )
]

{ #category : 'fixtures' }
PGRConfigurationTest >> validArtifactString [
	"The canonical green artifact: its names are written against the C20 scratch fixtures so the artifact keeps resolving as validation tightens through C27."
	^ '{
		#schemaVersion : 2,
		#project : ''Scratch'',
		#baseline : ''BaselineOfPGRScratchGrouped'',
		#roles : {
			#production : [ ''scratch-prod'' ],
			#tests : [ ''scratch-tst'' ],
			#exempt : [ ''scratch-ghost'' ] },
		#kits : [ { #kit : ''PGRScratchKit'' } ]
	}'
]
