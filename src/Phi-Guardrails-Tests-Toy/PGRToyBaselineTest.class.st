"
Framework-side pins for the toy ground delivered by E12-C01. Lives in the swept tests-role package (never in Toy-Tests, which is exempt by design, D-57), so these two facts are enforced by the verify command and the framework's own gate. testBaselineDeclaresTheFivePackagesAndNoGroups is R-47's demonstration: the adopted baseline carries no role group. testToyDomainBehaves witnesses that the toy is real executable code, not stubs (R-32).
"
Class {
	#name : 'PGRToyBaselineTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-Toy',
	#package : 'Phi-Guardrails-Tests-Toy'
}

{ #category : 'tests' }
PGRToyBaselineTest >> testBaselineDeclaresTheFivePackagesAndNoGroups [
	"R-47's pin: BaselineOfToy declares the five Toy-* packages and no group of any kind - adoption changed nothing in the adopted baseline."
	| version |
	version := (Smalltalk globals at: #BaselineOfToy) project version.
	self
		assert: (version packages collect: [ :each | each name ]) asSortedCollection asArray
		equals: #( 'Toy-Core' 'Toy-Persistence' 'Toy-Rules' 'Toy-Tests' 'Toy-UI' ).
	self assert: version groups isEmpty
]

{ #category : 'tests' }
PGRToyBaselineTest >> testToyDomainBehaves [
	"R-32's honest fixture: the toy app runs end to end across its three layers."
	| order store view rendered |
	order := ToyOrder empty.
	order
		addItemPriced: 5;
		addItemPriced: 10.
	store := ToyOrderStore empty.
	store save: order.
	view := ToyOrderView on: order.
	rendered := view render.
	self assert: order total equals: 15.
	self assert: order itemCount equals: 2.
	self assert: store count equals: 1.
	self assert: rendered isString.
	self assert: (rendered includesSubstring: '2').
	self assert: (rendered includesSubstring: '15')
]
