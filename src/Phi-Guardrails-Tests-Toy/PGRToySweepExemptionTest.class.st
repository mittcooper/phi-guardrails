"
Pins the toy family's sweep exemption (D-26/D-57): the guard that lets the toy be committed red at M4 without reddening the verify sweep. The toy's tests-role package name must never match either tests-family pattern (so its future red tests can never enter the sweep), and every toy package must full-match the artifact's 'Toy-.*' exempt pattern (par. 7.5). Baseline-introspection helpers are duplicated locally on purpose — deliberate self-containment, the E05-C03 recorded stance.
"
Class {
	#name : 'PGRToySweepExemptionTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-Toy',
	#package : 'Phi-Guardrails-Tests-Toy'
}

{ #category : 'accessing' }
PGRToySweepExemptionTest >> packageNamesFor: aGroupName [
	"D-25.a trap: an unknown group name answers empty, no error — callers assert exact non-empty sets."
	^ ((self version packagesForSpecNamed: aGroupName) collect: [ :each | each name ]) asSortedCollection asArray
]

{ #category : 'tests' }
PGRToySweepExemptionTest >> testEveryToyPackageMatchesTheExemptNamePattern [
	"The par. 7.5 #exemptNamePatterns fact: every toy package full-matches 'Toy-.*', and the expansion is non-empty."
	| toy |
	toy := self packageNamesFor: 'toy'.
	self deny: toy isEmpty.
	toy do: [ :each |
		self
			assert: (each matchesRegex: 'Toy-.*')
			description: each , ' does not full-match Toy-.*' ]
]

{ #category : 'tests' }
PGRToySweepExemptionTest >> testToyGroupIsTheFiveToyPackages [
	"The frozen E01 inventory pin: the toy group expands to exactly the five Toy-* packages, sorted."
	self assert: (self packageNamesFor: 'toy')
		equals: #( 'Toy-Core' 'Toy-Persistence' 'Toy-Rules' 'Toy-Tests' 'Toy-UI' )
]

{ #category : 'tests' }
PGRToySweepExemptionTest >> testToyTestsPackageMatchesNeitherTestsFamilyPattern [
	"The D-26 committed-red discipline's guard: the toy's tests-role package name full-matches neither tests-family pattern, so the toy's future red tests can never enter the verify sweep."
	self deny: ('Toy-Tests' matchesRegex: 'Phi-Guardrails-Tests-.*').
	self deny: ('Toy-Tests' matchesRegex: 'Phi-Coding-Kit-Tests-.*')
]

{ #category : 'accessing' }
PGRToySweepExemptionTest >> version [
	^ (Smalltalk globals at: #BaselineOfPhiGuardrails) project version
]
