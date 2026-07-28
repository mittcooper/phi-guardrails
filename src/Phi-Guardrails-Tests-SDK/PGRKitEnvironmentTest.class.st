"
Pins the D-81 PGRKitEnvironment contract: the four named readers answer exactly what the core constructed the view with, srcPath is nil when the configuration declares no #src, the three collection readers answer a fresh copy per send (a value, not a window) and construction does not alias caller collections, an empty exempt list is legal, and the view exposes no generic key lookup (at:/at:ifAbsent: are deliberately absent - their loss must be a red test).
"
Class {
	#name : 'PGRKitEnvironmentTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-SDK',
	#package : 'Phi-Guardrails-Tests-SDK'
}

{ #category : 'tests' }
PGRKitEnvironmentTest >> testCollectionReadersAnswerFreshCopies [
	| view |
	view := PGRKitEnvironment
		productionPackages: #('Prod-A' 'Prod-B')
		testsPackages: #('Tests-A')
		exemptPackages: #('Exempt-A')
		srcPath: '/repo/src'.
	(view productionPackages) at: 1 put: 'mutated'.
	self assert: view productionPackages equals: #('Prod-A' 'Prod-B').
	(view testsPackages) at: 1 put: 'mutated'.
	self assert: view testsPackages equals: #('Tests-A').
	(view exemptPackages) at: 1 put: 'mutated'.
	self assert: view exemptPackages equals: #('Exempt-A')
]

{ #category : 'tests' }
PGRKitEnvironmentTest >> testConstructionDoesNotAliasCallerCollections [
	"The law holds for both input types (D-81 value semantics): an OrderedCollection the caller grows, and a mutable Array the caller overwrites in place - Array>>asArray is identity in Pharo 13, so the store must copy defensively (Array withAll:)."
	| callerOC callerArray ocView arrayView |
	callerOC := OrderedCollection withAll: #('Prod-A' 'Prod-B').
	ocView := PGRKitEnvironment
		productionPackages: callerOC
		testsPackages: #('Tests-A')
		exemptPackages: #('Exempt-A')
		srcPath: '/repo/src'.
	callerOC add: 'Prod-C'.
	self assert: ocView productionPackages equals: #('Prod-A' 'Prod-B').
	callerArray := Array withAll: #('Prod-A' 'Prod-B').
	arrayView := PGRKitEnvironment
		productionPackages: callerArray
		testsPackages: #('Tests-A')
		exemptPackages: #('Exempt-A')
		srcPath: '/repo/src'.
	callerArray at: 1 put: 'mutated'.
	self assert: arrayView productionPackages equals: #('Prod-A' 'Prod-B')
]

{ #category : 'tests' }
PGRKitEnvironmentTest >> testEmptyExemptListIsLegal [
	| view |
	view := PGRKitEnvironment
		productionPackages: #('Prod-A')
		testsPackages: #('Tests-A')
		exemptPackages: #()
		srcPath: '/repo/src'.
	self assert: view exemptPackages isEmpty
]

{ #category : 'tests' }
PGRKitEnvironmentTest >> testReadersAnswerConstructedValues [
	| view |
	view := PGRKitEnvironment
		productionPackages: #('Prod-A' 'Prod-B')
		testsPackages: #('Tests-A')
		exemptPackages: #('Exempt-A' 'Exempt-B')
		srcPath: '/repo/src'.
	self assert: view productionPackages equals: #('Prod-A' 'Prod-B').
	self assert: view testsPackages equals: #('Tests-A').
	self assert: view exemptPackages equals: #('Exempt-A' 'Exempt-B').
	self assert: view srcPath equals: '/repo/src'
]

{ #category : 'tests' }
PGRKitEnvironmentTest >> testSrcPathNilWhenNoSrcDeclared [
	| view |
	view := PGRKitEnvironment
		productionPackages: #('Prod-A')
		testsPackages: #('Tests-A')
		exemptPackages: #('Exempt-A')
		srcPath: nil.
	self assert: view srcPath isNil.
	self assert: view productionPackages equals: #('Prod-A').
	self assert: view testsPackages equals: #('Tests-A').
	self assert: view exemptPackages equals: #('Exempt-A')
]

{ #category : 'tests' }
PGRKitEnvironmentTest >> testViewAnswersNoGenericLookup [
	"D-81: named readers only; generic key lookup is expressly out, and its deliberate absence is the contract - someone adding at:-style access must turn this red. The guard is includesSelector: (methods defined on the view itself), not respondsTo:: every Object inherits Object>>at: (the indexable primitive verified in-image, P5), so respondsTo: #at: is true universally and cannot express the absence - see completion report deviation."
	self deny: (PGRKitEnvironment includesSelector: #at:).
	self deny: (PGRKitEnvironment includesSelector: #at:ifAbsent:)
]
