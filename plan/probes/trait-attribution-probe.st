"Trait-attribution probe — evidence behind decision-log D-15.b (run 2026-07-13, Pharo 13).
 Question: how does the ch. 4 §4.2 walk (definedClasses → methods → referencedClasses)
 see trait-provided methods?

 RESULTS (all confirmed live, inspector evidence in the decision log):
   1. Trait methods surface in each using class's `methods`; `referencedClasses` works —
      the walk judges them in EACH USING CLASS'S layer; finding targets name the using class.
   2. `CompiledMethod>>package` answers the TRAIT's package; `origin` the trait —
      irrelevant to the walk (attributes by defining class), binding on any future
      package-filtered method query (see backlog B-03 for the lint-environment variant).
   3. Class-side trait methods behave identically.
   4. The trait itself appears in its own package's definedClasses — a layered trait
      package additionally yields the finding at TraitName>>#selector in the trait's
      layer (accepted duplication, defense in depth)."

"— fixture (Pharo 13 fluid definitions) —"
Object << #PFTarget
    package: 'Probe-Forbidden';
    install.

Trait << #TProbe
    package: 'Probe-Traits';
    install.
TProbe compile: 'probeRef ^ PFTarget new'.
TProbe classSide compile: 'classProbeRef ^ PFTarget'.

Object << #ProbeUserA
    traits: { TProbe };
    package: 'Probe-UserA';
    install.

Object << #ProbeUserB
    traits: { TProbe };
    package: 'Probe-UserB';
    install.

"— queries (inspect each) —"
(ProbeUserA methods anySatisfy: [:m | m selector = #probeRef]).        "→ true"
((ProbeUserA >> #probeRef) referencedClasses includes: PFTarget).       "→ true"
(ProbeUserA >> #probeRef) package name.                                 "→ 'Probe-Traits'"
(ProbeUserA >> #probeRef) origin.                                       "→ TProbe (users: A and B)"
ProbeUserB >> #probeRef.                                                "→ its own CompiledMethod, same source"
(ProbeUserA class >> #classProbeRef) referencedClasses.                 "→ {PFTarget}"
(PackageOrganizer default packageNamed: 'Probe-UserA') definedClasses.  "→ {ProbeUserA}"
(PackageOrganizer default packageNamed: 'Probe-Traits') definedClasses. "→ {TProbe}  (residual query)"
