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
PCKLayerMapTest >> testEmptyUnlayeredWithTotalLayersConstructsCleanly [
	"Production fully partitioned by layers, no #unlayered: constructs clean, #unlayered empty."
	| layersDict map |
	layersDict := Dictionary new
		at: 'ui' put: #( 'A-Ui' );
		at: 'domain' put: #( 'A-Domain' );
		yourself.
	map := PCKLayerMap
		fromLayerMap: (self layerMapWithLayers: layersDict allowed: #() unlayered: nil)
		productionPackages: #( 'A-Ui' 'A-Domain' ).
	self assert: map unlayered isEmpty
]

{ #category : 'tests' }
PCKLayerMapTest >> testFullyCoveringMapConstructsCleanly [
	"Layers cover A-Ui/A-Domain and #unlayered covers A-Glue: the map covers the production
	role exactly once, so construction succeeds."
	| layersDict map |
	layersDict := Dictionary new
		at: 'ui' put: #( 'A-Ui' );
		at: 'domain' put: #( 'A-Domain' );
		yourself.
	map := PCKLayerMap
		fromLayerMap: (self layerMapWithLayers: layersDict allowed: #() unlayered: #( 'A-Glue' ))
		productionPackages: #( 'A-Ui' 'A-Domain' 'A-Glue' ).
	self assert: (map layerOfPackageNamed: 'A-Ui') equals: 'ui'.
	self assert: (map unlayered includes: 'A-Glue')
]

{ #category : 'tests' }
PCKLayerMapTest >> testLayerNamesNonProductionPackageSignals [
	"Fault 4: a layer naming a package outside the production role signals, naming it (D-25)."
	| layersDict sub error |
	layersDict := Dictionary new
		at: 'ui' put: #( 'A-Foreign' );
		at: 'domain' put: #( 'A-Domain' );
		yourself.
	sub := self layerMapWithLayers: layersDict allowed: #() unlayered: #().
	error := nil.
	[ PCKLayerMap fromLayerMap: sub productionPackages: #( 'A-Domain' ) ]
		on: PGRConfigurationError do: [ :e | error := e ].
	self assert: error notNil.
	self assert: (error messageText includesSubstring: 'A-Foreign')
]

{ #category : 'tests' }
PCKLayerMapTest >> testLayeredAndUnlayeredOverlapSignals [
	"Fault 3 (P-LAYERMAP-TOTAL): a package both layered and in #unlayered signals, naming it."
	| layersDict sub error |
	layersDict := Dictionary new
		at: 'domain' put: #( 'A-Domain' );
		yourself.
	sub := self layerMapWithLayers: layersDict allowed: #() unlayered: #( 'A-Domain' ).
	error := nil.
	[ PCKLayerMap fromLayerMap: sub productionPackages: #( 'A-Domain' ) ]
		on: PGRConfigurationError do: [ :e | error := e ].
	self assert: error notNil.
	self assert: (error messageText includesSubstring: 'A-Domain')
]

{ #category : 'tests' }
PCKLayerMapTest >> testPackageInTwoLayersSignals [
	"Fault 2: a package declared in two layers breaks pairwise disjointness; the error names it."
	| layersDict sub error |
	layersDict := Dictionary new
		at: 'ui' put: #( 'A-Ui' );
		at: 'domain' put: #( 'A-Ui' );
		yourself.
	sub := self layerMapWithLayers: layersDict allowed: #() unlayered: #().
	error := nil.
	[ PCKLayerMap fromLayerMap: sub productionPackages: #( 'A-Ui' ) ]
		on: PGRConfigurationError do: [ :e | error := e ].
	self assert: error notNil.
	self assert: (error messageText includesSubstring: 'A-Ui')
]

{ #category : 'tests' }
PCKLayerMapTest >> testUnassignedProductionPackageSignals [
	"Fault 1 (P-LAYERMAP-TOTAL): a production package in no layer and not in #unlayered signals,
	naming it — the D-79 ruling-3 hole is loud, never invisibly ignored."
	| layersDict sub error |
	layersDict := Dictionary new
		at: 'ui' put: #( 'A-Ui' );
		at: 'domain' put: #( 'A-Domain' );
		yourself.
	sub := self layerMapWithLayers: layersDict allowed: #() unlayered: #().
	error := nil.
	[ PCKLayerMap fromLayerMap: sub productionPackages: #( 'A-Ui' 'A-Domain' 'A-Orphan' ) ]
		on: PGRConfigurationError do: [ :e | error := e ].
	self assert: error notNil.
	self assert: (error messageText includesSubstring: 'A-Orphan')
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

{ #category : 'tests' }
PCKLayerMapTest >> testUnlayeredNamesNonProductionSignals [
	"Fault 5 (P-LAYERMAP-TOTAL): an #unlayered entry outside the production role signals, naming it."
	| layersDict sub error |
	layersDict := Dictionary new
		at: 'ui' put: #( 'A-Ui' );
		yourself.
	sub := self layerMapWithLayers: layersDict allowed: #() unlayered: #( 'A-NotProduction' ).
	error := nil.
	[ PCKLayerMap fromLayerMap: sub productionPackages: #( 'A-Ui' ) ]
		on: PGRConfigurationError do: [ :e | error := e ].
	self assert: error notNil.
	self assert: (error messageText includesSubstring: 'A-NotProduction')
]
