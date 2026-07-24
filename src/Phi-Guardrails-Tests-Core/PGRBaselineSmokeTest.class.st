"
Freeze witness for E01's export — the 20-package naming tree and the ch. 8 par. 8.1 baseline group tree. A regrouping or renaming in BaselineOfPhiGuardrails must turn a test here red, never drift silently.
"
Class {
	#name : 'PGRBaselineSmokeTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-Core',
	#package : 'Phi-Guardrails-Tests-Core'
}

{ #category : 'accessing' }
PGRBaselineSmokeTest >> frozenFixturePackages [
	"E01 frozen inventory: the fixtures role (D-22 — unswept)."
	^ #( 'Phi-Coding-Kit-Fixtures-Behavioral' )
]

{ #category : 'accessing' }
PGRBaselineSmokeTest >> frozenInventory [
	"The complete frozen inventory: 20 packages (the baseline package is not declared inside itself, par. 7.5)."
	^ self frozenProductionPackages , self frozenTestPackages , self frozenFixturePackages , self frozenToyPackages
]

{ #category : 'accessing' }
PGRBaselineSmokeTest >> frozenProductionPackages [
	"E01 frozen inventory: the 7 production packages."
	^ #( 'Phi-Guardrails-SDK' 'Phi-Guardrails-Core' 'Phi-Guardrails-Gate' 'Phi-Coding-Kit' 'Phi-Coding-Kit-Rules' 'Phi-Coding-Kit-Architecture' 'Phi-Coding-Kit-Behavioral' )
]

{ #category : 'accessing' }
PGRBaselineSmokeTest >> frozenTestPackages [
	"E01 frozen inventory: the 7 test packages — both families (D-57: the tests role covers Phi-Guardrails-Tests-* and Phi-Coding-Kit-Tests-*)."
	^ #( 'Phi-Guardrails-Tests-SDK' 'Phi-Guardrails-Tests-Core' 'Phi-Guardrails-Tests-Gate' 'Phi-Guardrails-Tests-Toy' 'Phi-Coding-Kit-Tests-Rules' 'Phi-Coding-Kit-Tests-Architecture' 'Phi-Coding-Kit-Tests-Behavioral' )
]

{ #category : 'accessing' }
PGRBaselineSmokeTest >> frozenToyPackages [
	"E01 frozen inventory: the 5 toy packages (D-46 — stubs until E12)."
	^ #( 'Toy-Core' 'Toy-UI' 'Toy-Persistence' 'Toy-Rules' 'Toy-Tests' )
]

{ #category : 'accessing' }
PGRBaselineSmokeTest >> packageNamesFor: aGroupName [
	"D-25.a trap: an unknown group name answers empty, no error — callers assert exact non-empty sets."
	^ ((self version packagesForSpecNamed: aGroupName) collect: [ :each | each name ]) asSortedCollection asArray
]

{ #category : 'tests' }
PGRBaselineSmokeTest >> testBaselineClassIsLoadable [
	self assert: (Smalltalk globals includesKey: #BaselineOfPhiGuardrails).
	self assert: ((Smalltalk globals at: #BaselineOfPhiGuardrails) inheritsFrom: BaselineOf)
]

{ #category : 'tests' }
PGRBaselineSmokeTest >> testCICompositeCoversEverything [
	self assert: (self packageNamesFor: 'CI') equals: self frozenInventory sorted
]

{ #category : 'tests' }
PGRBaselineSmokeTest >> testCompositeGroupsExpandExactly [
	self assert: (self packageNamesFor: 'Core')
		equals: #( 'Phi-Guardrails-Core' 'Phi-Guardrails-Gate' ) sorted.
	self assert: (self packageNamesFor: 'Coding') equals: self frozenProductionPackages sorted.
	self assert: (self packageNamesFor: 'default') equals: self frozenProductionPackages sorted.
	self assert: (self packageNamesFor: 'Toy')
		equals: (self frozenProductionPackages , self frozenToyPackages) sorted.
	self assert: (self packageNamesFor: 'Tests') equals: self frozenInventory sorted
]

{ #category : 'tests' }
PGRBaselineSmokeTest >> testGroupTreeMatchesSpec [
	| groupNames |
	groupNames := (self version groups collect: [ :each | each name ]) asSet.
	#( 'production' 'tests' 'fixtures' 'toy' 'Core' 'Coding' 'Tests' 'Toy' 'CI' 'default' )
		do: [ :name | self assert: (groupNames includes: name) description: name , ' missing from group tree' ]
]

{ #category : 'tests' }
PGRBaselineSmokeTest >> testRoleGroupsExpandExactlyAndDisjointly [
	| flattened |
	self assert: (self packageNamesFor: 'production') equals: self frozenProductionPackages sorted.
	self assert: (self packageNamesFor: 'tests') equals: self frozenTestPackages sorted.
	self assert: (self packageNamesFor: 'fixtures') equals: self frozenFixturePackages sorted.
	self assert: (self packageNamesFor: 'toy') equals: self frozenToyPackages sorted.
	flattened := #( 'production' 'tests' 'fixtures' 'toy' )
		inject: #(  )
		into: [ :acc :each | acc , (self packageNamesFor: each) ].
	self assert: flattened size equals: 20.
	self assert: flattened asSet equals: self frozenInventory asSet
]

{ #category : 'accessing' }
PGRBaselineSmokeTest >> version [
	^ (Smalltalk globals at: #BaselineOfPhiGuardrails) project version
]
