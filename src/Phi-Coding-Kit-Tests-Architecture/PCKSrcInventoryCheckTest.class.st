"
Fixture-pair tests for PCKSrcInventoryCheck's §7.5 read-only walk (E11-C03). setUp builds
a scratch source root under the working directory and tearDown deletes it (ch. 9
P-NO-DEAD-SRC binding: the tests hand the check a scratch root built and deleted by the
test, never planted directories in the real working tree).

The pair: testRedOnStrayDirectory plants a Dead-Package directory the inventory never
lists and demands the one precise finding (the fires half, R-37); testGreenOnCleanRoot
holds only a listed package and demands green (the silent half). testBaselineDirectoryIsNotDead
witnesses the forced baseline clause (a directory named after a loaded BaselineOf
subclass's package is absorbed); testOneFindingPerOffender pins the §7.5 arity (two
strays -> two findings, none folded); testNonexistentRootIsRed pins the D-45 run-time
judgment (a dangling root declaration reds loudly). The missing-without-#src leg is
E11-C04's - it needs the kit dispatch.
"
Class {
	#name : 'PCKSrcInventoryCheckTest',
	#superclass : 'TestCase',
	#instVars : [
		'scratchRoot'
	],
	#category : 'Phi-Coding-Kit-Tests-Architecture',
	#package : 'Phi-Coding-Kit-Tests-Architecture'
}

{ #category : 'running' }
PCKSrcInventoryCheckTest >> setUp [
	super setUp.
	scratchRoot := FileSystem workingDirectory / 'pck-e11-src-scratch'.
	scratchRoot ensureCreateDirectory
]

{ #category : 'running' }
PCKSrcInventoryCheckTest >> tearDown [
	scratchRoot ensureDeleteAll.
	super tearDown
]

{ #category : 'tests' }
PCKSrcInventoryCheckTest >> testBaselineDirectoryIsNotDead [
	"The forced baseline clause (§7.5): a directory named after a genuinely loaded
	BaselineOf subclass's package is absorbed even though the inventory never lists it."
	| verdict |
	(scratchRoot / 'Known-Package') ensureCreateDirectory.
	(scratchRoot / 'BaselineOfPhiGuardrails') ensureCreateDirectory.
	verdict := (PCKSrcInventoryCheck srcPath: scratchRoot fullName packages: #( 'Known-Package' )) run.
	self assert: verdict isGreen.
	self assert: verdict findings isEmpty
]

{ #category : 'tests' }
PCKSrcInventoryCheckTest >> testGreenOnCleanRoot [
	"P-NO-DEAD-SRC silent leg: a root holding only a listed package is green with no
	findings (the silent half of the fixture pair)."
	| verdict |
	(scratchRoot / 'Known-Package') ensureCreateDirectory.
	verdict := (PCKSrcInventoryCheck srcPath: scratchRoot fullName packages: #( 'Known-Package' )) run.
	self assert: verdict isGreen.
	self assert: verdict findings isEmpty
]

{ #category : 'tests' }
PCKSrcInventoryCheckTest >> testNonexistentRootIsRed [
	"The D-45 run-time judgment: a check constructed with a never-created path reds with
	one finding whose message names the declared path - a dangling declaration is loud."
	| declaredPath verdict |
	declaredPath := (scratchRoot / 'never-created') fullName.
	verdict := (PCKSrcInventoryCheck srcPath: declaredPath packages: #( 'Known-Package' )) run.
	self deny: verdict isGreen.
	self assert: verdict findings size equals: 1.
	self assert: (verdict findings first message includesSubstring: declaredPath)
]

{ #category : 'tests' }
PCKSrcInventoryCheckTest >> testOneFindingPerOffender [
	"§7.5 arity: two stray directories and one known yield exactly two findings, targeting
	the two stray basenames - each offender named, none folded."
	| verdict targets |
	(scratchRoot / 'Known-Package') ensureCreateDirectory.
	(scratchRoot / 'Dead-One') ensureCreateDirectory.
	(scratchRoot / 'Dead-Two') ensureCreateDirectory.
	verdict := (PCKSrcInventoryCheck srcPath: scratchRoot fullName packages: #( 'Known-Package' )) run.
	self deny: verdict isGreen.
	self assert: verdict findings size equals: 2.
	targets := verdict findings collect: [ :f | f target ].
	self assert: (targets includes: 'Dead-One').
	self assert: (targets includes: 'Dead-Two')
]

{ #category : 'tests' }
PCKSrcInventoryCheckTest >> testRedOnStrayDirectory [
	"P-NO-DEAD-SRC fires leg: a root holding a listed Known-Package and a stray
	Dead-Package reds with exactly one finding, target 'Dead-Package', message naming the
	path (the fires half of the fixture pair, R-37)."
	| verdict finding |
	(scratchRoot / 'Known-Package') ensureCreateDirectory.
	(scratchRoot / 'Dead-Package') ensureCreateDirectory.
	verdict := (PCKSrcInventoryCheck srcPath: scratchRoot fullName packages: #( 'Known-Package' )) run.
	self deny: verdict isGreen.
	self assert: verdict findings size equals: 1.
	finding := verdict findings first.
	self assert: finding target equals: 'Dead-Package'.
	self assert: (finding message includesSubstring: (scratchRoot / 'Dead-Package') fullName)
]
