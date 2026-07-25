"B-03 lint-environment trait-attribution probe — evidence behind decision-log D-71
 (run 2026-07-25, Pharo 13, scratch COPY of the .build/work/phi.image work image —
 never saved; probe packages exist only inside the scratch run).
 Question: does the ch. 2 §2.3 RBPackageEnvironment-scoped lint run see a
 trait-provided method in the USING class's package, or only in the trait's
 DEFINING package (the B-03 escape)? Rule under test: the shipped
 ReCodeCruftLeftInMethodsRule (fires on `self flag:` — verified live, D-28).

 RESULTS (printed output of the run of 2026-07-25, verbatim; exit 0):
   ProbeB-User -> 0 critique(s)
   ProbeB-Traits -> 1 critique(s)
     TCruftProbe>>#probeCruft
 ESCAPE CONFIRMED: the package-scoped lint run attributes the trait-provided
 method ONLY to the trait's defining package — the using class's package run sees
 nothing, so a trait defined in an exempt-role package but used from a production
 class escapes lint. Decision-log D-71; decision-sheet Q-32 (open) recommends the
 remedy — this probe rules nothing."

"— fixture (Pharo 13 fluid definitions, trait-attribution-probe.st style; headless-st
   form per m0-regex-setup.st: no compile-time reference to a just-created class) —"
(Trait << #TCruftProbe
    package: 'ProbeB-Traits';
    install) compile: 'probeCruft self flag: #probe'.

Object << #ProbeBUser
    traits: { (Smalltalk globals at: #TCruftProbe) };
    package: 'ProbeB-User';
    install.

"— the two package-scoped lint runs (checker spelling verified, D-15) —"
#('ProbeB-User' 'ProbeB-Traits') do: [:pkgName |
    | rule checker critics |
    rule := ReCodeCruftLeftInMethodsRule new.
    checker := ReSmalllintChecker new
        rule: { rule };
        environment: (RBPackageEnvironment packageName: pkgName);
        run;
        yourself.
    critics := checker criticsOf: rule.
    Stdio stdout
        nextPutAll: pkgName; nextPutAll: ' -> ';
        print: critics size; nextPutAll: ' critique(s)'; lf.
    critics do: [:c |
        Stdio stdout nextPutAll: '  '; nextPutAll: c sourceAnchor entity printString; lf]].
Stdio stdout flush.
Smalltalk exit: 0
