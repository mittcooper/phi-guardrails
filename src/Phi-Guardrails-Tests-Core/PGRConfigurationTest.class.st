"
Mirror test for PGRConfiguration. Carries the canonical green artifact (validArtifactString) reused by every later E03 chunk, plus one-line mutation helpers for the defect arms. testUnknownKeySignals is the named test of property P-CFG-STRICT.
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
PGRConfigurationTest >> artifactWithout: aKey [
	| map |
	map := self artifactMap.
	map removeKey: aKey.
	^ STON toString: map
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
PGRConfigurationTest >> testNonMapTopLevelSignals [
	"The envelope is one map with Symbol keys - a non-map top level and a String-keyed map are both refused."
	self should: [ PGRConfiguration fromString: '[ 1 ]' ] raise: PGRConfigurationError.
	self should: [ PGRConfiguration fromString: '{ ''schemaVersion'' : 2 }' ] raise: PGRConfigurationError
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
PGRConfigurationTest >> testUnknownKeySignals [
	"P-CFG-STRICT: an unknown top-level key is a configuration error naming the key (D-51)."
	self
		should: [ PGRConfiguration fromString: (self artifactWith: #extra value: 1) ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error | self assert: (error messageText includesSubstring: 'extra') ]
]

{ #category : 'tests' }
PGRConfigurationTest >> testValidArtifactParses [
	| configuration |
	configuration := PGRConfiguration fromString: self validArtifactString.
	self assert: configuration project equals: 'Scratch'.
	self assert: configuration kitBlocks size equals: 1.
	self assert: (configuration kitBlocks first at: #kit) equals: 'PGRScratchKit'
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
