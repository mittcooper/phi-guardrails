"
Test fixture (ch. 9 par. 9.3: fixture classes beside their tests, inert - a plain PGRCheck subclass, never a TestCase, registered by no production block): the minimal promised-constructor citizen for the #metaRules path - overrides only kind and run, inheriting packages:/packages from the skeleton. PCKKitTest hands its name through the block and asserts the spec shape and the tests role.
"
Class {
	#name : 'PCKMetaStubCheck',
	#superclass : 'PGRCheck',
	#category : 'Phi-Coding-Kit-Tests-Rules',
	#package : 'Phi-Coding-Kit-Tests-Rules'
}

{ #category : 'accessing' }
PCKMetaStubCheck >> kind [
	"The kind the #metaRules block key implies; agreement is the engine's to validate (D-60)."
	^ #behavioral
]

{ #category : 'running' }
PCKMetaStubCheck >> run [
	^ PGRVerdict green
]
