"
Fixture-pair-free unit tests for PCKLayerMap: every input is an in-image Dictionary built
exactly as STON yields it (Symbol block keys, String layer names), so no code fixture is
needed to exercise the value (the three-package code fixture is C03). Covers well-formed
parse, the optional-#unlayered default, both lookups, the D-79 self/directed/non-transitive
semantics of allowsFrom:to:, and the two representative shape faults (missing #layers, an
#allowed entry naming an undeclared layer).
"
Class {
	#name : 'PCKLayerMapTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Tests-Architecture',
	#package : 'Phi-Coding-Kit-Tests-Architecture'
}

{ #category : 'fixtures' }
PCKLayerMapTest >> layerMapWithLayers: layersDict allowed: allowedArray unlayered: unlayeredArrayOrNil [
	"A #layerMap sub-map as STON parses it — Symbol block keys; #unlayered omitted when nil."
	| map |
	map := Dictionary new.
	map at: #layers put: layersDict.
	map at: #allowed put: allowedArray.
	unlayeredArrayOrNil ifNotNil: [ :u | map at: #unlayered put: u ].
	^ map
]

{ #category : 'fixtures' }
PCKLayerMapTest >> layersUi [
	"One declared layer 'ui' → #( 'Acme-UI' )."
	^ Dictionary new
		at: 'ui' put: #( 'Acme-UI' );
		yourself
]

{ #category : 'fixtures' }
PCKLayerMapTest >> layersUiDomain [
	"Two declared layers, 'ui' and 'domain'."
	^ Dictionary new
		at: 'ui' put: #( 'Acme-UI' );
		at: 'domain' put: #( 'Acme-Domain' );
		yourself
]

{ #category : 'fixtures' }
PCKLayerMapTest >> layersUiDomainPersistence [
	"Three declared layers, for the non-transitive case."
	^ Dictionary new
		at: 'ui' put: #( 'Acme-UI' );
		at: 'domain' put: #( 'Acme-Domain' );
		at: 'persistence' put: #( 'Acme-Persistence' );
		yourself
]

{ #category : 'tests' }
PCKLayerMapTest >> testAllowedNamingUndeclaredLayerSignals [
	"An #allowed pair naming a layer not in #layers is a shape fault whose message names it."
	| sub error |
	sub := self layerMapWithLayers: self layersUiDomain allowed: { { 'ui'. 'ghost' } } unlayered: nil.
	error := nil.
	[ PCKLayerMap fromLayerMap: sub ] on: PGRConfigurationError do: [ :e | error := e ].
	self assert: error notNil.
	self assert: (error messageText includesSubstring: 'ghost')
]

{ #category : 'tests' }
PCKLayerMapTest >> testAllowsDeclaredDirectedPair [
	| map |
	map := PCKLayerMap fromLayerMap:
		(self layerMapWithLayers: self layersUiDomain allowed: { { 'ui'. 'domain' } } unlayered: nil).
	self assert: (map allowsFrom: 'ui' to: 'domain')
]

{ #category : 'tests' }
PCKLayerMapTest >> testAllowsSelfReferenceWithoutDeclaration [
	"D-79 ruling 1: a layer may always reference itself, with no #allowed entry."
	| map |
	map := PCKLayerMap fromLayerMap:
		(self layerMapWithLayers: self layersUi allowed: #() unlayered: nil).
	self assert: (map allowsFrom: 'ui' to: 'ui')
]

{ #category : 'tests' }
PCKLayerMapTest >> testDoesNotAllowReverseOfDeclaredPair [
	"D-79 ruling 2: 'ui'→'domain' grants only that direction."
	| map |
	map := PCKLayerMap fromLayerMap:
		(self layerMapWithLayers: self layersUiDomain allowed: { { 'ui'. 'domain' } } unlayered: nil).
	self deny: (map allowsFrom: 'domain' to: 'ui')
]

{ #category : 'tests' }
PCKLayerMapTest >> testDoesNotAllowTransitivePair [
	"D-79 ruling 2: allowed is literal, never closed over."
	| map |
	map := PCKLayerMap fromLayerMap:
		(self layerMapWithLayers: self layersUiDomainPersistence
			allowed: { { 'ui'. 'domain' }. { 'domain'. 'persistence' } }
			unlayered: nil).
	self deny: (map allowsFrom: 'ui' to: 'persistence')
]

{ #category : 'tests' }
PCKLayerMapTest >> testLayerOfPackageNamedAnswersNilForUnmapped [
	| map |
	map := PCKLayerMap fromLayerMap:
		(self layerMapWithLayers: self layersUi allowed: #() unlayered: nil).
	self assert: (map layerOfPackageNamed: 'Acme-Nowhere') isNil
]

{ #category : 'tests' }
PCKLayerMapTest >> testLayerOfPackageNamedFindsDeclaringLayer [
	| map |
	map := PCKLayerMap fromLayerMap:
		(self layerMapWithLayers: self layersUi allowed: #() unlayered: nil).
	self assert: (map layerOfPackageNamed: 'Acme-UI') equals: 'ui'
]

{ #category : 'tests' }
PCKLayerMapTest >> testMissingLayersKeySignals [
	"#layers is mandatory; the error names it."
	| sub error |
	sub := Dictionary new.
	sub at: #allowed put: #().
	error := nil.
	[ PCKLayerMap fromLayerMap: sub ] on: PGRConfigurationError do: [ :e | error := e ].
	self assert: error notNil.
	self assert: (error messageText includesSubstring: 'layers')
]

{ #category : 'tests' }
PCKLayerMapTest >> testParsesLayersAllowedAndUnlayered [
	"A well-formed sub-map yields the layers, the one allowed pair, and the one unlayered package."
	| map |
	map := PCKLayerMap fromLayerMap:
		(self layerMapWithLayers: self layersUiDomain
			allowed: { { 'ui'. 'domain' } }
			unlayered: #( 'Acme-Glue' )).
	self assert: (map layers at: 'ui') equals: #( 'Acme-UI' ).
	self assert: (map layers at: 'domain') equals: #( 'Acme-Domain' ).
	self assert: map layers keys asSortedCollection asArray equals: #( 'domain' 'ui' ).
	self assert: map allowed size equals: 1.
	self assert: map allowed first equals: #( 'ui' 'domain' ).
	self assert: map unlayered equals: #( 'Acme-Glue' )
]

{ #category : 'tests' }
PCKLayerMapTest >> testUnlayeredDefaultsToEmptyWhenAbsent [
	"Absent #unlayered reads as empty, never nil."
	| map |
	map := PCKLayerMap fromLayerMap:
		(self layerMapWithLayers: self layersUi allowed: #() unlayered: nil).
	self assert: map unlayered notNil.
	self assert: map unlayered isEmpty
]
