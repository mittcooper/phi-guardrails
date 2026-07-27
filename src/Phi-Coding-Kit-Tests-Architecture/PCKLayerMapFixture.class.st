"
A test-support builder that installs a three-package scratch mini-fixture for the
architecture layer-map check (C04/C05) and tears it down completely. Ui / domain /
persistence scratch packages hold four scratch classes with six planted references, one of
them the forbidden ui -> persistence reach the check must catch (D-22/D-26: planted
violations exist to be caught, compiled at runtime into scratch packages, never committed
sends). A plain Object subclass, not a TestCase, so no behavioral run sweeps it (ch. 9
9.3); scratch classes and packages are created and torn down within a test's own control.

The scratch package names PCKScratchArch-* match no swept test pattern, so the runner never
adopts them. install creates all four classes first, then compiles the six planted methods,
so each reference resolves to a real class binding rather than an undeclared variable.
remove is guarded so a missing class or package never raises - callers invoke it from an
ensure: block, and double or partial removal is a no-op. No class-side state persists (R-35:
no global state); teardown looks classes and packages up by name.
"
Class {
	#name : 'PCKLayerMapFixture',
	#superclass : 'Object',
	#category : 'Phi-Coding-Kit-Tests-Architecture',
	#package : 'Phi-Coding-Kit-Tests-Architecture'
}

{ #category : 'accessing' }
PCKLayerMapFixture class >> classNames [
	"The four scratch class names, looked up by symbol for teardown (they cannot appear as
	literals here - the classes exist only between install and remove)."
	^ #( #PCKScratchUiView #PCKScratchUiWidget #PCKScratchDomainModel #PCKScratchPersistenceStore )
]

{ #category : 'accessing' }
PCKLayerMapFixture class >> domainPackageName [
	^ 'PCKScratchArch-Domain'
]

{ #category : 'building' }
PCKLayerMapFixture class >> install [
	"Create the four scratch classes in their three packages, then compile the six planted
	methods. Answers self. The planted method sources are fixture data: each `^ SomeClass new`
	send is the referencedClasses entry the layer-map walk reads."
	| ui domain |
	ui := Object << #PCKScratchUiView package: self uiPackageName; install.
	Object << #PCKScratchUiWidget package: self uiPackageName; install.
	domain := Object << #PCKScratchDomainModel package: self domainPackageName; install.
	Object << #PCKScratchPersistenceStore package: self persistencePackageName; install.
	ui compile: 'usesDomain ^ PCKScratchDomainModel new' classified: 'fixture'.
	ui compile: 'usesPersistence ^ PCKScratchPersistenceStore new' classified: 'fixture'.
	ui compile: 'usesSibling ^ PCKScratchUiWidget new' classified: 'fixture'.
	ui compile: 'usesExternal ^ OrderedCollection new' classified: 'fixture'.
	domain compile: 'usesPersistence ^ PCKScratchPersistenceStore new' classified: 'fixture'.
	domain compile: 'usesUi ^ PCKScratchUiWidget new' classified: 'fixture'.
	^ self
]

{ #category : 'accessing' }
PCKLayerMapFixture class >> packageNames [
	^ { self uiPackageName. self domainPackageName. self persistencePackageName }
]

{ #category : 'accessing' }
PCKLayerMapFixture class >> persistencePackageName [
	^ 'PCKScratchArch-Persistence'
]

{ #category : 'building' }
PCKLayerMapFixture class >> remove [
	"Tear down all four scratch classes then all three scratch packages. Guarded so a missing
	class or package - partial install, or a second remove - never raises. Callers invoke this
	from an ensure: block."
	self classNames do: [ :className |
		(Smalltalk globals at: className ifAbsent: [ nil ])
			ifNotNil: [ :cls | cls removeFromSystem ] ].
	self packageNames do: [ :name |
		(PackageOrganizer default packageNamed: name ifAbsent: [ nil ])
			ifNotNil: [ :pkg | pkg removeFromSystem ] ]
]

{ #category : 'accessing' }
PCKLayerMapFixture class >> uiPackageName [
	^ 'PCKScratchArch-Ui'
]
