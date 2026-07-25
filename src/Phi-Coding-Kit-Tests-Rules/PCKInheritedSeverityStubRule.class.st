"
Test fixture (never registered outside tests, hence inert): a Renraku rewrite rule that does not itself implement class-side severity, so it inherits #warning - exactly the illegal-when-registered state D-41 names. PCKKitTest hands it to the kit and must see PGRConfigurationError (P-SEVERITY-EXPLICIT).
"
Class {
	#name : 'PCKInheritedSeverityStubRule',
	#superclass : 'ReNodeRewriteRule',
	#category : 'Phi-Coding-Kit-Tests-Rules',
	#package : 'Phi-Coding-Kit-Tests-Rules'
}

{ #category : 'accessing' }
PCKInheritedSeverityStubRule class >> rationale [
	^ 'Test fixture rationale: a rule registered without its own class-side severity must be a configuration error, never a silently-inherited #warning (D-41).'
]

{ #category : 'accessing' }
PCKInheritedSeverityStubRule class >> ruleName [
	^ 'inherited-severity stub'
]

{ #category : 'initialization' }
PCKInheritedSeverityStubRule >> initialize [
	super initialize.
	self replace: '`@x isNil ifTrue: [`.@block]' with: '`@x ifNil: [`.@block]'
]
