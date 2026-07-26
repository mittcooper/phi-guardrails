"
E09-C04 · the quickstart sample-execution harness (ch. 9 P-GUIDE-EXEC, harness half; D-59
home). Not a TestCase - a plain support class the guide-sample tests (C05/C06) drive. Three
jobs: extract the fenced smalltalk/ston samples from a committed guide (samplesIn:), read a
guide through the repo-root locator (guideNamed:), and compile a Smalltalk class/method sample
into a scratch package with guaranteed teardown (install:/install:slots:/removeInstalled).

Parsing rules (chunks.md, veto-open): a fence opens and closes on a line beginning ```; its
info is the trimmed, lowercased remainder of the opening line; only smalltalk/ston blocks are
samples (untagged/other fences are prose). A class-sample body splits at listing headers
`Name >> selector...` / `Name class >> selector...`; the pre-header segment, when it holds <<,
is a fluid class definition installed via the verified cascade `Super << #Name package: 'P';
install` (D-71), with `slots: #(...)` spliced in for the author-storage input path; each header
segment's method source is the header line minus its `Name( class)? >> ` prefix plus the
following lines, so one-liners and comment-only bodies compile verbatim.

Teardown: every installed class and its package is recorded on instance state (no class-side
state, R-35) and dropped by removeInstalled; callers wrap use in ensure:. Scratch names
(PGR-Scratch-*) match no swept test pattern, so the runner never adopts them.
"
Class {
	#name : 'PGRQuickstartSampleHarness',
	#superclass : 'Object',
	#instVars : [
		'installedClasses',
		'installedPackages'
	],
	#category : 'Phi-Guardrails-Tests-Gate',
	#package : 'Phi-Guardrails-Tests-Gate'
}

{ #category : 'compiling' }
PGRQuickstartSampleHarness >> compileSegment: segmentLines [
	"Compile one listing segment (header line + following body lines) into its named class,
	instance side or metaclass per the `class >>` form."
	| tokens className isClassSide target |
	tokens := segmentLines first substrings.
	className := tokens first.
	isClassSide := tokens size >= 3 and: [ (tokens at: 2) = 'class' ].
	target := Smalltalk globals at: className asSymbol.
	isClassSide
		ifTrue: [ target class compile: (self methodSourceFrom: segmentLines) ]
		ifFalse: [ target compile: (self methodSourceFrom: segmentLines) ]
]

{ #category : 'reading' }
PGRQuickstartSampleHarness >> guideNamed: aFileName [
	"Answer the text of docs/quickstarts/<aFileName> via the repo-root locator: upward from the
	working directory, then a SmalltalkCI-provided project directory when that global exists,
	then upward from the image directory; all three failing is a loud error, never a skip."
	| parts found |
	parts := { 'docs'. 'quickstarts'. aFileName }.
	found := (self locateUpwardFrom: FileSystem workingDirectory for: parts)
		ifNil: [ (self smalltalkCILocateFor: parts)
			ifNil: [ self locateUpwardFrom: FileLocator imageDirectory for: parts ] ].
	found ifNil: [ ^ self error: 'quickstart guide not found: ' , aFileName ].
	^ found contents
]

{ #category : 'initialization' }
PGRQuickstartSampleHarness >> initialize [
	super initialize.
	installedClasses := OrderedCollection new.
	installedPackages := OrderedCollection new
]

{ #category : 'compiling' }
PGRQuickstartSampleHarness >> install: aSmalltalkSampleBody [
	"Plain install is the slotless variant - listing-only bodies compile into already-installed
	classes; a body with a fluid pre-header segment installs the class first."
	^ self install: aSmalltalkSampleBody slots: #()
]

{ #category : 'compiling' }
PGRQuickstartSampleHarness >> install: aSmalltalkSampleBody slots: slotNameArray [
	"Split the body at listing headers; install the fluid pre-header definition (splicing
	slots: when given), then compile each header segment into its class."
	| lines headerIndices preHeaderLines |
	lines := aSmalltalkSampleBody lines.
	headerIndices := (1 to: lines size) select: [ :i | self isListingHeader: (lines at: i) ].
	preHeaderLines := headerIndices isEmpty
		ifTrue: [ lines ]
		ifFalse: [ lines copyFrom: 1 to: headerIndices first - 1 ].
	self installClassDefinitionFrom: preHeaderLines slots: slotNameArray.
	headerIndices doWithIndex: [ :startIdx :n |
		| endIdx |
		endIdx := n < headerIndices size
			ifTrue: [ (headerIndices at: n + 1) - 1 ]
			ifFalse: [ lines size ].
		self compileSegment: (lines copyFrom: startIdx to: endIdx) ]
]

{ #category : 'compiling' }
PGRQuickstartSampleHarness >> installClassDefinitionFrom: preHeaderLines slots: slotNameArray [
	"When the pre-header segment carries a fluid class definition (<<), evaluate it with slots
	spliced in and `; install` cascaded (D-71 verified idiom), recording the class and its
	package for teardown; a listing-only body has no such segment and installs nothing here."
	| definition installed |
	(preHeaderLines anySatisfy: [ :line | line includesSubstring: '<<' ]) ifFalse: [ ^ self ].
	definition := String streamContents: [ :stream |
		preHeaderLines do: [ :line | stream nextPutAll: line ] separatedBy: [ stream lf ].
		slotNameArray isEmpty
			ifFalse: [ stream nextPutAll: '; slots: '; nextPutAll: slotNameArray printString ].
		stream nextPutAll: '; install' ].
	installed := OpalCompiler new evaluate: definition.
	installedClasses addFirst: installed.
	installedPackages addFirst: installed package
]

{ #category : 'parsing' }
PGRQuickstartSampleHarness >> isListingHeader: aLine [
	"A listing header is a line whose first two tokens are an identifier and >>, or whose first
	three are identifier, class, >> - the method-definition form the guides list."
	| tokens |
	tokens := aLine substrings.
	tokens size >= 2 ifFalse: [ ^ false ].
	(self isIdentifierToken: tokens first) ifFalse: [ ^ false ].
	(tokens at: 2) = '>>' ifTrue: [ ^ true ].
	^ tokens size >= 3 and: [ (tokens at: 2) = 'class' and: [ (tokens at: 3) = '>>' ] ]
]

{ #category : 'parsing' }
PGRQuickstartSampleHarness >> isIdentifierToken: aToken [
	^ aToken notEmpty
		and: [ aToken first isLetter
		and: [ aToken allSatisfy: [ :ch | ch isLetter or: [ ch isDigit ] ] ] ]
]

{ #category : 'reading' }
PGRQuickstartSampleHarness >> locateUpwardFrom: aDirectory for: parts [
	"Walk upward at most 8 levels from aDirectory, answering the first candidate at which
	parts resolves to an existing file; nil if none does."
	| current |
	current := aDirectory asFileReference.
	8 timesRepeat: [
		| candidate |
		candidate := parts inject: current into: [ :dir :segment | dir / segment ].
		candidate isFile ifTrue: [ ^ candidate ].
		current := current parent ].
	^ nil
]

{ #category : 'compiling' }
PGRQuickstartSampleHarness >> methodSourceFrom: segmentLines [
	"Method source = the header line minus its `Name( class)? >> ` prefix, plus every following
	line verbatim - so one-liners, multi-line bodies, and comment-only bodies compile alike."
	| header afterMarker |
	header := segmentLines first.
	afterMarker := (header
		copyFrom: (header indexOfSubCollection: '>>') + 2
		to: header size) trimLeft.
	^ String streamContents: [ :stream |
		stream nextPutAll: afterMarker.
		segmentLines allButFirst do: [ :line | stream lf; nextPutAll: line ] ]
]

{ #category : 'teardown' }
PGRQuickstartSampleHarness >> removeInstalled [
	"Drop every class then every package this harness created; guarded so double removal and
	an already-swept package cannot raise. Callers invoke this from an ensure: block."
	installedClasses do: [ :cls |
		(Smalltalk globals includesKey: cls name asSymbol) ifTrue: [ cls removeFromSystem ] ].
	installedPackages do: [ :pkg |
		(PackageOrganizer default hasPackage: pkg name asString) ifTrue: [ pkg removeFromSystem ] ].
	installedClasses := OrderedCollection new.
	installedPackages := OrderedCollection new
]

{ #category : 'parsing' }
PGRQuickstartSampleHarness >> samplesIn: aGuideText [
	"Answer the ordered smalltalk/ston fenced blocks as (infoSymbol -> bodyString) pairs; a
	fence opens and closes on a line beginning ```, its info is the trimmed lowercased opening
	remainder, and untagged or otherwise-tagged fences are prose and excluded."
	| samples inFence info body |
	samples := OrderedCollection new.
	inFence := false.
	info := nil.
	body := nil.
	aGuideText lines do: [ :line |
		(line beginsWith: '```')
			ifTrue: [
				inFence
					ifTrue: [
						inFence := false.
						(#( 'smalltalk' 'ston' ) includes: info) ifTrue: [
							samples add: info asSymbol
								-> ((String with: Character lf) join: body) ] ]
					ifFalse: [
						inFence := true.
						info := (line allButFirst: 3) trimBoth asLowercase.
						body := OrderedCollection new ] ]
			ifFalse: [ inFence ifTrue: [ body add: line ] ] ].
	^ samples
]

{ #category : 'reading' }
PGRQuickstartSampleHarness >> smalltalkCILocateFor: parts [
	"Fallback locator: when a SmalltalkCI global is present and offers a project directory, walk
	upward from it; otherwise nil, so guideNamed: falls through to the image-directory walk."
	^ Smalltalk globals at: #SmalltalkCI ifPresent: [ :sci |
		(sci respondsTo: #projectDirectory)
			ifTrue: [ self locateUpwardFrom: sci projectDirectory for: parts ]
			ifFalse: [ nil ] ]
]
