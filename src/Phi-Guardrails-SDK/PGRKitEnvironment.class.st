"
The read-only environment view the core publishes to kits (D-81). A curated projection of resolved configuration facts - productionPackages, testsPackages, exemptPackages (each a package-name String list, the resolved role expansions), and srcPath (an absolute path String, or nil when the configuration declares no #src). Built by the core (E11-C02), read by kits (E11-C04); kits still never receive the configuration object itself (D-53.5), only this curated projection.

Named readers only - no generic key lookup (at:-style access is expressly out, D-81): the published set is deliberate and enumerable here, and a misquery is a doesNotUnderstand, the loud failure the ruling wants. Growth path: a future published fact is one new reader on this class, a decision-sheet-recorded amendment after E11 freezes the surface, never a new kit-protocol selector.

A value, not a window: the three collection readers each answer a fresh Array copy per send, so no kit can reach another's or mutate the view (R-35). srcPath answers the stored String (or nil) as-is - the core resolved it already.
"
Class {
	#name : 'PGRKitEnvironment',
	#superclass : 'Object',
	#instVars : [
		'productionPackages',
		'testsPackages',
		'exemptPackages',
		'srcPath'
	],
	#category : 'Phi-Guardrails-SDK',
	#package : 'Phi-Guardrails-SDK'
}

{ #category : 'instance creation' }
PGRKitEnvironment class >> productionPackages: prodNames testsPackages: testsNames exemptPackages: exemptNames srcPath: aStringOrNil [
	^ self new
		setProductionPackages: prodNames testsPackages: testsNames exemptPackages: exemptNames srcPath: aStringOrNil;
		yourself
]

{ #category : 'accessing' }
PGRKitEnvironment >> exemptPackages [
	"The resolved exempt package names; a fresh Array copy per send - the collection is defensive, the members are the run's own (R-35)."
	^ exemptPackages copy
]

{ #category : 'accessing' }
PGRKitEnvironment >> productionPackages [
	"The resolved production package names; a fresh Array copy per send - the collection is defensive, the members are the run's own (R-35)."
	^ productionPackages copy
]

{ #category : 'accessing' }
PGRKitEnvironment >> srcPath [
	"The resolved #src path (absolute String), or nil when the configuration declares no #src (D-81)."
	^ srcPath
]

{ #category : 'accessing' }
PGRKitEnvironment >> testsPackages [
	"The resolved tests package names; a fresh Array copy per send - the collection is defensive, the members are the run's own (R-35)."
	^ testsPackages copy
]

{ #category : 'private' }
PGRKitEnvironment >> setProductionPackages: prodNames testsPackages: testsNames exemptPackages: exemptNames srcPath: aStringOrNil [
	"Store construction-time copies so the view is a value, not a window onto caller collections (D-81)."
	productionPackages := prodNames asArray.
	testsPackages := testsNames asArray.
	exemptPackages := exemptNames asArray.
	srcPath := aStringOrNil
]
