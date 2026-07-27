"
Fixture-pair tests for PCKLayerMapCheck's §4.2 walk (E10-C04). Each test installs the
three-package scratch mini-fixture (C03), builds a PCKLayerMap over the fixture package
names, runs the check, then tears the fixture down inside an ensure: block (ch. 9 §9.3 -
planted violations are built and torn down within the test's own control).

The pair: testFiresOnForbiddenReference plants a forbidden ui->persistence reach and
demands the precise finding (target exactly 'PCKScratchUiView>>#usesPersistence');
testSilentOnConformingMap grants every edge the fixture uses and demands green. The
advisory arm (P-LAYERMAP-TOTAL run-time) is witnessed by testUnlayeredReportedAsAdvisory
(green + advisory names the unlayered package) and its negative
testGreenWithNoUnlayeredHasNoAdvisory. testKindIsArchitecture pins the kind.
"
Class {
	#name : 'PCKLayerMapCheckTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Tests-Architecture',
	#package : 'Phi-Coding-Kit-Tests-Architecture'
}

{ #category : 'fixtures' }
PCKLayerMapCheckTest >> layersUiDomain [
	"Two layers, 'ui' and 'domain', over the fixture ui/domain packages (persistence left
	for #unlayered)."
	^ Dictionary new
		at: 'ui' put: { PCKLayerMapFixture uiPackageName };
		at: 'domain' put: { PCKLayerMapFixture domainPackageName };
		yourself
]

{ #category : 'fixtures' }
PCKLayerMapCheckTest >> layersUiDomainPersistence [
	"Three layers over the three fixture packages."
	^ Dictionary new
		at: 'ui' put: { PCKLayerMapFixture uiPackageName };
		at: 'domain' put: { PCKLayerMapFixture domainPackageName };
		at: 'persistence' put: { PCKLayerMapFixture persistencePackageName };
		yourself
]

{ #category : 'fixtures' }
PCKLayerMapCheckTest >> mapFromLayers: layersDict allowed: allowedArray unlayered: unlayeredArrayOrNil [
	"A PCKLayerMap over the fixture package names, from a sub-map built as STON yields it."
	^ PCKLayerMap
		fromLayerMap: (self subMapLayers: layersDict allowed: allowedArray unlayered: unlayeredArrayOrNil)
		productionPackages: PCKLayerMapFixture packageNames
]

{ #category : 'fixtures' }
PCKLayerMapCheckTest >> subMapLayers: layersDict allowed: allowedArray unlayered: unlayeredArrayOrNil [
	"A #layerMap sub-map as STON parses it - Symbol block keys; #unlayered omitted when nil."
	| map |
	map := Dictionary new.
	map at: #layers put: layersDict.
	map at: #allowed put: allowedArray.
	unlayeredArrayOrNil ifNotNil: [ :u | map at: #unlayered put: u ].
	^ map
]

{ #category : 'tests' }
PCKLayerMapCheckTest >> testFiresOnForbiddenReference [
	"P-CAT-FIXTURES bad / P-FINDING-PRECISE: with ui->persistence not granted (only ui->domain
	and domain->persistence), the walk emits a precise finding for the ui view's persistence
	reach."
	PCKLayerMapFixture install.
	[ | map verdict |
	map := self mapFromLayers: self layersUiDomainPersistence
		allowed: { { 'ui'. 'domain' }. { 'domain'. 'persistence' } }
		unlayered: nil.
	verdict := (PCKLayerMapCheck layerMap: map) run.
	self deny: verdict isGreen.
	self assert: (verdict findings anySatisfy: [ :f |
		f target = 'PCKScratchUiView>>#usesPersistence'
			and: [ (f message includesSubstring: 'PCKScratchPersistenceStore')
			and: [ (f message includesSubstring: 'ui')
			and: [ f message includesSubstring: 'persistence' ] ] ] ]) ]
		ensure: [ PCKLayerMapFixture remove ]
]

{ #category : 'tests' }
PCKLayerMapCheckTest >> testGreenWithNoUnlayeredHasNoAdvisory [
	"A fully-layered conforming map with empty #unlayered is green and carries no advisory."
	PCKLayerMapFixture install.
	[ | map verdict |
	map := self mapFromLayers: self layersUiDomainPersistence
		allowed: { { 'ui'. 'domain' }. { 'ui'. 'persistence' }. { 'domain'. 'persistence' }. { 'domain'. 'ui' } }
		unlayered: nil.
	verdict := (PCKLayerMapCheck layerMap: map) run.
	self assert: verdict isGreen.
	self assert: verdict advisories isEmpty ]
		ensure: [ PCKLayerMapFixture remove ]
]

{ #category : 'tests' }
PCKLayerMapCheckTest >> testKindIsArchitecture [
	"The check's kind is #architecture."
	PCKLayerMapFixture install.
	[ | map |
	map := self mapFromLayers: self layersUiDomainPersistence allowed: #() unlayered: nil.
	self assert: (PCKLayerMapCheck layerMap: map) kind equals: #architecture ]
		ensure: [ PCKLayerMapFixture remove ]
]

{ #category : 'tests' }
PCKLayerMapCheckTest >> testSilentOnConformingMap [
	"P-CAT-FIXTURES good: granting every edge the fixture uses (ui->domain, ui->persistence,
	domain->persistence, domain->ui) yields green with no findings; self-reference and the
	external OrderedCollection never needed a grant."
	PCKLayerMapFixture install.
	[ | map verdict |
	map := self mapFromLayers: self layersUiDomainPersistence
		allowed: { { 'ui'. 'domain' }. { 'ui'. 'persistence' }. { 'domain'. 'persistence' }. { 'domain'. 'ui' } }
		unlayered: nil.
	verdict := (PCKLayerMapCheck layerMap: map) run.
	self assert: verdict isGreen.
	self assert: verdict findings isEmpty ]
		ensure: [ PCKLayerMapFixture remove ]
]

{ #category : 'tests' }
PCKLayerMapCheckTest >> testUnlayeredReportedAsAdvisory [
	"P-LAYERMAP-TOTAL advisory arm: with persistence #unlayered (so no forbidden edge to a
	layered class remains) the verdict is green and an advisory names the persistence package."
	PCKLayerMapFixture install.
	[ | map verdict |
	map := self mapFromLayers: self layersUiDomain
		allowed: { { 'ui'. 'domain' }. { 'domain'. 'ui' } }
		unlayered: { PCKLayerMapFixture persistencePackageName }.
	verdict := (PCKLayerMapCheck layerMap: map) run.
	self assert: verdict isGreen.
	self deny: verdict advisories isEmpty.
	self assert: (verdict advisories anySatisfy: [ :a |
		a message includesSubstring: PCKLayerMapFixture persistencePackageName ]) ]
		ensure: [ PCKLayerMapFixture remove ]
]
