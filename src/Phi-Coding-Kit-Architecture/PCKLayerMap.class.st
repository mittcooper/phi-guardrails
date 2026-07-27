"
The layer-map value: a well-formed #layerMap sub-map read into layers / allowed-pairs /
unlayered, answering the two lookups the layer-map check's walk needs (E10). Construction
copies its input (Array withAll: on every list) so a caller mutating the source map cannot
reach in; the value is ordinary — build it, read it, discard it (no global state).

Scope is C01: turn a well-formed sub-map into a usable value and answer lookups. Parsing is
strict — a shape fault raises PGRConfigurationError rather than defaulting silently. The
shape faults judged here are exactly: a non-map value; a missing / non-map / empty #layers;
a #layers entry that is not a list of Strings; a missing / non-list #allowed, or an entry
that is not a two-element list of Strings, or one naming a layer absent from #layers; and a
present-but-non-list-of-Strings #unlayered. The completeness law — coverage over the
production role, cross-layer disjointness, layer∩unlayered overlap, production-role
membership, unknown/unloaded packages — is C02, not here.

allowsFrom:to: bakes in D-79: a layer always references itself (ruling 1), and allowed
pairs are literal, directed, one-way, and never transitively closed (ruling 2).
"
Class {
	#name : 'PCKLayerMap',
	#superclass : 'Object',
	#instVars : [
		'layers',
		'allowed',
		'unlayered'
	],
	#category : 'Phi-Coding-Kit-Architecture',
	#package : 'Phi-Coding-Kit-Architecture'
}

{ #category : 'instance creation' }
PCKLayerMap class >> fromLayerMap: aLayerMapSubMap [
	"Answer the value read from a well-formed #layerMap sub-map, or signal PGRConfigurationError
	on one of the C01 shape faults. Reads #layers (mandatory) and #allowed (mandatory), then
	#unlayered (optional, absent → empty)."
	| declaredLayers |
	aLayerMapSubMap isDictionary ifFalse: [
		PGRConfigurationError signal: '#layerMap value must be a map' ].
	declaredLayers := self validatedLayersFrom: aLayerMapSubMap.
	^ self new
		setLayers: declaredLayers
			allowed: (self validatedAllowedFrom: aLayerMapSubMap declaredLayers: declaredLayers)
			unlayered: (self validatedUnlayeredFrom: aLayerMapSubMap)
]

{ #category : 'instance creation' }
PCKLayerMap class >> fromLayerMap: aLayerMapSubMap productionPackages: aCollectionOfProductionNames [
	"Answer the value read from a well-formed #layerMap sub-map that also satisfies the
	completeness law (spec §4.1 / D-35) over the production role, or signal
	PGRConfigurationError on the first fault. Shape-parses via fromLayerMap: (C01 faults
	unchanged), then requires the layers and #unlayered to jointly cover every production-role
	package exactly once: a package in two layers, a layered or #unlayered package outside the
	production role, a package both layered and #unlayered, or an uncovered production package
	each raises, naming the offender. Internal-only by D-79.a — external references are B-02's
	ground, not judged here."
	| map |
	map := self fromLayerMap: aLayerMapSubMap.
	self validate: map coversExactly: aCollectionOfProductionNames.
	^ map
]

{ #category : 'validating' }
PCKLayerMap class >> isStringList: anObject [
	^ anObject isArray and: [ anObject allSatisfy: [ :each | each isString ] ]
]

{ #category : 'validating' }
PCKLayerMap class >> validate: aLayerMap coversExactly: aCollectionOfProductionNames [
	"Enforce the completeness law of aLayerMap over the production-role names (D-35): the
	layers and #unlayered jointly cover every production package exactly once. Raises the
	first fault found, naming the offending package (and the conflict for the disjointness /
	overlap faults). Faults, in check order: a package in more than one layer; a layered
	package outside the production role; an #unlayered package outside the production role; a
	package both layered and #unlayered; and, last, a production package covered nowhere."
	| productionSet layerCounts unlayeredNames |
	productionSet := aCollectionOfProductionNames asSet.
	layerCounts := Dictionary new.
	aLayerMap layers valuesDo: [ :packageNames |
		packageNames do: [ :name |
			layerCounts at: name put: (layerCounts at: name ifAbsent: [ 0 ]) + 1 ] ].
	layerCounts keysAndValuesDo: [ :name :count |
		count > 1 ifTrue: [
			PGRConfigurationError signal: 'Package ' , name printString , ' is declared in more than one layer' ] ].
	layerCounts keysDo: [ :name |
		(productionSet includes: name) ifFalse: [
			PGRConfigurationError signal: 'Layer names non-production-role package ' , name printString ] ].
	unlayeredNames := aLayerMap unlayered.
	unlayeredNames do: [ :name |
		(productionSet includes: name) ifFalse: [
			PGRConfigurationError signal: '#unlayered names non-production-role package ' , name printString ] ].
	unlayeredNames do: [ :name |
		(layerCounts includesKey: name) ifTrue: [
			PGRConfigurationError signal: 'Package ' , name printString , ' is both layered and in #unlayered' ] ].
	aCollectionOfProductionNames do: [ :name |
		((layerCounts includesKey: name) or: [ unlayeredNames includes: name ]) ifFalse: [
			PGRConfigurationError signal: 'Production-role package ' , name printString , ' is in no layer and not in #unlayered' ] ]
]

{ #category : 'validating' }
PCKLayerMap class >> validatedAllowedFrom: aMap declaredLayers: aLayersDictionary [
	"#allowed is a mandatory list of two-element [from, to] String lists; every named layer
	must be declared in #layers (either element). Stored as fresh two-element Arrays."
	| raw copy |
	raw := aMap at: #allowed ifAbsent: [
		PGRConfigurationError signal: '#allowed is mandatory in a #layerMap' ].
	raw isArray ifFalse: [
		PGRConfigurationError signal: '#allowed must be a list of two-element [from, to] lists' ].
	copy := OrderedCollection new.
	raw do: [ :pair |
		(pair isArray and: [ pair size = 2 and: [ pair allSatisfy: [ :each | each isString ] ] ]) ifFalse: [
			PGRConfigurationError signal: 'Each #allowed entry must be a two-element list of layer-name Strings' ].
		pair do: [ :layerName |
			(aLayersDictionary includesKey: layerName) ifFalse: [
				PGRConfigurationError signal: '#allowed names undeclared layer ' , layerName printString ] ].
		copy add: (Array withAll: pair) ].
	^ copy asArray
]

{ #category : 'validating' }
PCKLayerMap class >> validatedLayersFrom: aMap [
	"#layers is a mandatory, non-empty map of layer name → list of package-name Strings.
	Stored as a fresh Dictionary of fresh Arrays."
	| raw copy |
	raw := aMap at: #layers ifAbsent: [
		PGRConfigurationError signal: '#layers is mandatory in a #layerMap' ].
	raw isDictionary ifFalse: [
		PGRConfigurationError signal: '#layers must be a map of layer name to package list' ].
	raw isEmpty ifTrue: [
		PGRConfigurationError signal: '#layers must declare at least one layer' ].
	copy := Dictionary new.
	raw keysAndValuesDo: [ :layerName :packageNames |
		(self isStringList: packageNames) ifFalse: [
			PGRConfigurationError signal: 'Layer ' , layerName printString , ' must map to a list of package-name Strings' ].
		copy at: layerName put: (Array withAll: packageNames) ].
	^ copy
]

{ #category : 'validating' }
PCKLayerMap class >> validatedUnlayeredFrom: aMap [
	"#unlayered is optional; absent reads as empty. Present, it must be a list of Strings."
	| raw |
	raw := aMap at: #unlayered ifAbsent: [ ^ Array new ].
	(self isStringList: raw) ifFalse: [
		PGRConfigurationError signal: '#unlayered must be a list of package-name Strings' ].
	^ Array withAll: raw
]

{ #category : 'accessing' }
PCKLayerMap >> allowed [
	"The stored Array of two-element [from, to] layer-name Arrays."
	^ allowed
]

{ #category : 'querying' }
PCKLayerMap >> allowsFrom: aFromLayerName to: aToLayerName [
	"true iff the from and to layers are the same (D-79 ruling 1: self-reference is always
	allowed) or the directed pair is literally among #allowed (D-79 ruling 2: one-way, never
	transitively closed)."
	aFromLayerName = aToLayerName ifTrue: [ ^ true ].
	^ allowed includes: (Array with: aFromLayerName with: aToLayerName)
]

{ #category : 'accessing' }
PCKLayerMap >> layers [
	"The stored Dictionary of layer name → package-name Array."
	^ layers
]

{ #category : 'querying' }
PCKLayerMap >> layerOfPackageNamed: aPackageName [
	"The declared layer whose package list includes aPackageName, or nil when no declared
	layer contains it (unlayered or unknown → nil — distinguishing those is C02's concern)."
	layers keysAndValuesDo: [ :layerName :packageNames |
		(packageNames includes: aPackageName) ifTrue: [ ^ layerName ] ].
	^ nil
]

{ #category : 'initialization' }
PCKLayerMap >> setLayers: aLayersDictionary allowed: anAllowedArray unlayered: anUnlayeredArray [
	layers := aLayersDictionary.
	allowed := anAllowedArray.
	unlayered := anUnlayeredArray
]

{ #category : 'accessing' }
PCKLayerMap >> unlayered [
	"The stored Array of unlayered package-name Strings; empty when #unlayered was absent."
	^ unlayered
]
