"
E09-C04 pin tests for PGRQuickstartSampleHarness (ch. 9 P-GUIDE-EXEC, the harness half). Two
freeze the committed sample inventory of guides 2-3 so a guide edit is a visible test event,
not silent drift (testGuideTwoSampleInventory / testGuideThreeSampleInventory); two prove the
class-sample compilation and teardown machinery C05 drives - the install:slots: storage-input
path and slot round-trip (testClassSampleInstallsAndRemoves), and that listing headers split
class-side, one-line, and multi-line definitions identically (testListingHeaderSplitsClassSideAndOneLiners).
The round-trip arms create and remove their own scratch classes/packages under ensure:, the
sanctioned scratch pattern; the inventory arms only read the producer-owned guides.
"
Class {
	#name : 'PGRQuickstartSampleHarnessTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-Gate',
	#package : 'Phi-Guardrails-Tests-Gate'
}

{ #category : 'tests' }
PGRQuickstartSampleHarnessTest >> testClassSampleInstallsAndRemoves [
	"C05 storage-input path: a fluid definition plus a one-line method installed with an
	author-supplied slot, then a listing-only setter/reader pair compiled into the same class;
	the class answers its method, slot state round-trips, and removeInstalled clears it."
	| harness cls inst |
	harness := PGRQuickstartSampleHarness new.
	[
		harness
			install: 'Object << #PGRScratchGuideProbe package: ''PGR-Scratch-Guide''
PGRScratchGuideProbe >> answer ^ #probed'
			slots: #(probeSlot).
		harness install: 'PGRScratchGuideProbe >> setProbe: anObject    probeSlot := anObject
PGRScratchGuideProbe >> probe    ^ probeSlot'.
		self assert: (Smalltalk globals includesKey: #PGRScratchGuideProbe).
		cls := Smalltalk globals at: #PGRScratchGuideProbe.
		self assert: cls new answer equals: #probed.
		inst := cls new.
		inst setProbe: 1764.
		self assert: inst probe equals: 1764
	] ensure: [ harness removeInstalled ].
	self deny: (Smalltalk globals includesKey: #PGRScratchGuideProbe)
]

{ #category : 'tests' }
PGRQuickstartSampleHarnessTest >> testGuideThreeSampleInventory [
	"Freeze 03-build-a-kit.md's inventory: exactly 2 samples - the untagged naming-tree fence
	is prose and excluded, leaving one smalltalk and one ston block, in order."
	| harness samples |
	harness := PGRQuickstartSampleHarness new.
	samples := harness samplesIn: (harness guideNamed: '03-build-a-kit.md').
	self assert: samples size equals: 2.
	self assert: (samples collect: [ :each | each key ]) asArray
		equals: #( smalltalk ston )
]

{ #category : 'tests' }
PGRQuickstartSampleHarnessTest >> testGuideTwoSampleInventory [
	"Freeze 02-write-a-check.md's inventory: exactly 5 samples, tags smalltalk/smalltalk/
	smalltalk/ston/smalltalk in order - the freeze that makes a guide edit a test event."
	| harness samples |
	harness := PGRQuickstartSampleHarness new.
	samples := harness samplesIn: (harness guideNamed: '02-write-a-check.md').
	self assert: samples size equals: 5.
	self assert: (samples collect: [ :each | each key ]) asArray
		equals: #( smalltalk smalltalk smalltalk ston smalltalk )
]

{ #category : 'tests' }
PGRQuickstartSampleHarnessTest >> testListingHeaderSplitsClassSideAndOneLiners [
	"A single body with a fluid definition, a class >> method, and a one-line instance method:
	the class-side selector lands on the metaclass only, the instance one-liner compiles and
	answers - the guides' section 2/3 listing forms are all parseable and split correctly."
	| harness cls |
	harness := PGRQuickstartSampleHarness new.
	[
		harness install: 'Object << #PGRScratchSplitProbe package: ''PGR-Scratch-Guide''
PGRScratchSplitProbe class >> builtBy    ^ #harness
PGRScratchSplitProbe >> answer    ^ #instanceAnswer'.
		cls := Smalltalk globals at: #PGRScratchSplitProbe.
		self assert: (cls class includesSelector: #builtBy).
		self deny: (cls includesSelector: #builtBy).
		self assert: cls builtBy equals: #harness.
		self assert: cls new answer equals: #instanceAnswer
	] ensure: [ harness removeInstalled ].
	self deny: (Smalltalk globals includesKey: #PGRScratchSplitProbe)
]
