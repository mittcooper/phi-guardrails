"
The architecture kind's dead-source check (spec §7.5): a read-only walk of a declared
source root. Red, with one finding per offender, when a directory immediately under the
root neither names a package in the handed inventory nor is the package of a loaded
BaselineOf subclass; else green. Judges the root's immediate directories only - never
recurses, never looks at loose files, never writes, creates, or deletes (R-12 / §7.6:
this walk plus the artifact read are the gate's only two file accesses).

The baseline clause is forced, not convenient (§7.5): the root baseline must sit in its
own src/ directory for Metacello to find it, and no baseline declares its own package -
without the clause the check reds itself on day one. Code is therefore either a baseline
package (in a role, and so guarded), a baseline's own package, or flagged dead; there is
no fourth state. The clause is the one reflective part of the walk - a reflective query
of the checked image, the check's subject matter, not state (constitution).

Construction (§4.3 law): the check receives everything it knows and pulls nothing. The
kit-side srcPath:packages: hands the resolved absolute source root and one flat
collection of package-name Strings - the caller's resolved production + tests + exempt
role lists concatenated, which by the D-25 scope law IS the baseline's full package
inventory. The check itself never touches Metacello version objects or the configuration
(E11-C04 builds the collection from the environment view).

A non-existent (or non-directory) root reds with one finding naming the declared path:
#src was declared so the registration resolved (not missing, §1.5), and a silent green on
a dangling declaration is the silence-as-success shape the ruled ground closes loudly (a
check judges by verdict, and the only loud verdict is red; the D-45 core comment defers
existence to 'the walk that consumes it judges that at run time').
"
Class {
	#name : 'PCKSrcInventoryCheck',
	#superclass : 'PGRCheck',
	#instVars : [
		'srcPath',
		'packageNames'
	],
	#category : 'Phi-Coding-Kit-Architecture',
	#package : 'Phi-Coding-Kit-Architecture'
}

{ #category : 'instance creation' }
PCKSrcInventoryCheck class >> srcPath: aPathString packages: packageNameCollection [
	"Kit-side constructor (§4.3): aPathString is the resolved absolute source root;
	packageNameCollection is the caller's full package inventory (production + tests +
	exempt). Richer than the promised packages: because the kit owns this class."
	^ self new
		setSrcPath: aPathString packages: packageNameCollection;
		yourself
]

{ #category : 'accessing' }
PCKSrcInventoryCheck >> kind [
	^ #architecture
]

{ #category : 'running' }
PCKSrcInventoryCheck >> run [
	"The §7.5 read-only walk: red with one finding per dead directory, else green. A
	dangling root declaration reds with one finding naming the declared path."
	| root findings |
	root := srcPath asFileReference.
	(root exists and: [ root isDirectory ])
		ifFalse: [ ^ PGRVerdict redFindings: { self nonexistentRootFinding } ].
	findings := OrderedCollection new.
	root directories do: [ :directory |
		(self isDeadDirectory: directory)
			ifTrue: [ findings add: (self deadFindingFor: directory) ] ].
	findings ifEmpty: [ ^ PGRVerdict green ].
	^ PGRVerdict redFindings: findings
]

{ #category : 'private' }
PCKSrcInventoryCheck >> deadFindingFor: aDirectory [
	"A precise finding (R-20) for one dead directory: target its basename, message names
	the full path, rationale states the no-fourth-state law."
	^ PGRFinding
		target: aDirectory basename
		message: aDirectory fullName , ' matches no baseline-defined package and no loaded baseline''s package'
		rationale: 'source on disk must be a baseline package, a baseline''s own package, or deleted'
]

{ #category : 'private' }
PCKSrcInventoryCheck >> isDeadDirectory: aDirectory [
	"A directory is dead iff its basename names neither a package in the handed inventory
	nor the package of a loaded BaselineOf subclass."
	| basename |
	basename := aDirectory basename.
	^ (packageNames includes: basename) not
		and: [ (self namesLoadedBaseline: basename) not ]
]

{ #category : 'private' }
PCKSrcInventoryCheck >> namesLoadedBaseline: aBasename [
	"The reflective clause (§7.5): does any loaded BaselineOf subclass have aBasename as
	its package name?"
	^ BaselineOf allSubclasses anySatisfy: [ :cls | cls package name = aBasename ]
]

{ #category : 'private' }
PCKSrcInventoryCheck >> nonexistentRootFinding [
	"One finding for a declared-but-absent source root (§7.5 step 1): target and message
	name the declared path; a dangling declaration is loud, never silently green (D-45)."
	^ PGRFinding
		target: srcPath
		message: 'the declared source root ' , srcPath , ' does not exist'
		rationale: 'a declared source root that does not exist is a loud finding, never a silent green'
]

{ #category : 'private' }
PCKSrcInventoryCheck >> setSrcPath: aPathString packages: packageNameCollection [
	srcPath := aPathString.
	packageNames := Array withAll: packageNameCollection
]
