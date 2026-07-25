"
Test fixture for C15's advisory arm (never registered, hence inert - spec ch. 2 par. 2.1: loaded-but-unregistered never blocks): the same rewrite pattern as the catalog rule but at class-side severity #warning, so PCKLintRuleCheck must map its critiques to advisories on a green verdict (D-03 two-tier severity).
"
Class {
	#name : 'PCKWarningSeverityStubRule',
	#superclass : 'ReNodeRewriteRule',
	#category : 'Phi-Coding-Kit-Tests-Rules',
	#package : 'Phi-Coding-Kit-Tests-Rules'
}

{ #category : 'accessing' }
PCKWarningSeverityStubRule class >> rationale [
	^ 'Test fixture rationale: a sub-#error rule''s critiques must arrive as advisories, never findings (D-03).'
]

{ #category : 'accessing' }
PCKWarningSeverityStubRule class >> ruleName [
	^ 'warning-severity stub'
]

{ #category : 'accessing' }
PCKWarningSeverityStubRule class >> severity [
	^ #warning
]

{ #category : 'initialization' }
PCKWarningSeverityStubRule >> initialize [
	super initialize.
	self replace: '`@x isNil ifTrue: [`.@block]' with: '`@x ifNil: [`.@block]'
]
