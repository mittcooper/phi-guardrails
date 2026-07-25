"
Pins the run-scoped suite result cache (spec ch. 5 par. 5.4): the par. 5.2 test-class filter shared with the suite check (C03), the lazy pull reproducing C01's pinned package-run facts, and the single-run guarantee as object identity within one cache but never across caches (D-36, R-35). Swept, green-only.
"
Class {
	#name : 'PCKSuiteRunCacheTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Tests-Behavioral',
	#package : 'Phi-Coding-Kit-Tests-Behavioral'
}

{ #category : 'accessing' }
PCKSuiteRunCacheTest >> fixturesPackageName [
	^ 'Phi-Coding-Kit-Fixtures-Behavioral'
]

{ #category : 'tests' }
PCKSuiteRunCacheTest >> testLazyPullRunsTheWholePackageOnce [
	"C01's pinned package-run facts, reproduced by the lazy pull - both D-15 semantic traps pinned on this image (skips sit outside runCount; an expected failure sits outside failures). If the abstract fixture leaked past the filter, failureCount would read 2."
	| result |
	result := PCKSuiteRunCache new resultsForPackage: self fixturesPackageName.
	self assert: result failureCount equals: 1.
	self assert: result errorCount equals: 1.
	self assert: result skippedCount equals: 1.
	self assert: result expectedDefectCount equals: 1.
	self assert: result runCount equals: 4
]

{ #category : 'tests' }
PCKSuiteRunCacheTest >> testSecondPullAnswersTheIdenticalResult [
	"The single-run guarantee is object identity within one cache (D-36); across constructions the pull is fresh - run-scoped, never shared (R-35)."
	| cache first |
	cache := PCKSuiteRunCache new.
	first := cache resultsForPackage: self fixturesPackageName.
	self assert: (cache resultsForPackage: self fixturesPackageName) identicalTo: first.
	self deny: (PCKSuiteRunCache new resultsForPackage: self fixturesPackageName) identicalTo: first
]

{ #category : 'tests' }
PCKSuiteRunCacheTest >> testTestClassInventoryIsConcreteTestCasesOnly [
	"Par. 5.2's filter, decided here once for both readers (C03's zero-test-classes decision reuses this query): concrete TestCase classes only, in name order - the abstract class and the baseline resident stay out."
	self
		assert: (PCKSuiteRunCache testClassesIn: self fixturesPackageName)
		equals: { PCKFailingFixtureTest. PCKPassingFixtureTest. PCKSkippingFixtureTest }
]
