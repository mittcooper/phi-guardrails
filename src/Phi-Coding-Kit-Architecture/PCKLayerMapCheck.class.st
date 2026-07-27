"
The architecture kind's check (spec §4.2): wraps one PCKLayerMap and walks the layered
production packages reflectively, emitting one precise finding per forbidden inter-layer
reference. Red iff any finding, else green; on the clean path, a non-empty #unlayered rides
one advisory naming those packages (P-LAYERMAP-TOTAL run-time arm). Constructed via the
kit-side layerMap: - richer than the promised packages: because the kit owns this class
(as PCKLintRuleCheck carries its rule, §4.3).

The walk (§4.2): for every declared layer L and every class in L's packages, every method
including class-side, collect referencedClasses; normalise each to its instance side; look
up the referenced class's layer M via the map. A finding fires iff M is non-nil (the
referenced class sits in a declared layer - internal client->client, D-79.a) and
(allowsFrom: L to: M) is false. A nil M (external kernel/framework, or an unlayered client
package) is never a finding; self-reference is absorbed because allowsFrom: L to: L is true
(D-79 ruling 1). A finding's target is exactly 'Class>>#selector' (R-20 / P-FINDING-PRECISE).

R-18: reflective queries only, never file parsing - the walk reads, never mutates. A nil
package (unloaded) contributes nothing; loaded-ness -> missing registration is C06's, never
a walk finding.

Filed question (§4.2 step 4 vs frozen PGRVerdict): the unlayered advisory can attach only
to a green verdict, since frozen PGRVerdict has no redFindings:advisories: constructor. The
conservative arm is implemented - advisory-on-green-only; a red verdict carries findings
only. Owner-pre-ruled to implement as written and restate on the decision sheet.
"
Class {
	#name : 'PCKLayerMapCheck',
	#superclass : 'PGRCheck',
	#instVars : [
		'layerMap'
	],
	#category : 'Phi-Coding-Kit-Architecture',
	#package : 'Phi-Coding-Kit-Architecture'
}

{ #category : 'instance creation' }
PCKLayerMapCheck class >> layerMap: aPCKLayerMap [
	"Kit-side constructor (§4.3): this class carries its layer map, richer than the promised
	packages: for classes the kit does not own."
	^ self new
		setLayerMap: aPCKLayerMap;
		yourself
]

{ #category : 'accessing' }
PCKLayerMapCheck >> kind [
	^ #architecture
]

{ #category : 'running' }
PCKLayerMapCheck >> run [
	"The §4.2 walk over the layer map handed at construction, answering a PGRVerdict: red with
	the findings when any forbidden reference exists, else green - carrying the #unlayered
	advisory when #unlayered is non-empty."
	| findings |
	findings := OrderedCollection new.
	layerMap layers keysAndValuesDo: [ :layerName :packageNames |
		packageNames do: [ :packageName |
			(PackageOrganizer default packageNamed: packageName ifAbsent: [ nil ])
				ifNotNil: [ :package |
					package definedClasses do: [ :cls |
						self collectFindingsFor: cls inLayer: layerName into: findings ] ] ] ].
	findings ifNotEmpty: [ ^ PGRVerdict redFindings: findings ].
	layerMap unlayered ifEmpty: [ ^ PGRVerdict green ].
	^ PGRVerdict greenAdvisories: { self unlayeredAdvisory }
]

{ #category : 'private' }
PCKLayerMapCheck >> collectFindingsFor: aClass inLayer: aLayerName into: aCollection [
	"Every method of aClass, instance and class side, contributes its forbidden references."
	aClass methods do: [ :method | self collectFindingsForMethod: method inLayer: aLayerName into: aCollection ].
	aClass class methods do: [ :method | self collectFindingsForMethod: method inLayer: aLayerName into: aCollection ]
]

{ #category : 'private' }
PCKLayerMapCheck >> collectFindingsForMethod: aMethod inLayer: aLayerName into: aCollection [
	"One finding per referenced class whose layer M is non-nil and unreachable from aLayerName.
	referencedClasses entries are normalised to their instance side before the package lookup."
	aMethod referencedClasses do: [ :referenced | | targetClass targetLayer |
		targetClass := referenced instanceSide.
		targetLayer := layerMap layerOfPackageNamed: targetClass package name.
		(targetLayer notNil and: [ (layerMap allowsFrom: aLayerName to: targetLayer) not ])
			ifTrue: [ aCollection add:
				(self findingForMethod: aMethod referenced: targetClass from: aLayerName to: targetLayer) ] ]
]

{ #category : 'private' }
PCKLayerMapCheck >> findingForMethod: aMethod referenced: aReferencedClass from: aFromLayer to: aToLayer [
	"A precise finding (R-20): target exactly 'Class>>#selector', message naming the referenced
	class, both layer names, and the ruling."
	^ PGRFinding
		target: aMethod methodClass name , '>>#' , aMethod selector
		message: 'references ' , aReferencedClass name , ' — layer ''' , aFromLayer , ''' → ''' , aToLayer , ''' is not allowed'
]

{ #category : 'private' }
PCKLayerMapCheck >> setLayerMap: aPCKLayerMap [
	layerMap := aPCKLayerMap
]

{ #category : 'private' }
PCKLayerMapCheck >> unlayeredAdvisory [
	"One advisory (§4.2 step 4) naming the unlayered packages, targeted at a stable sentinel;
	reported, never blocking."
	^ PGRFinding
		target: 'architecture/PCKLayerMapCheck'
		message: 'unlayered packages (unjudged by the layer map): ' , (', ' join: layerMap unlayered)
]
