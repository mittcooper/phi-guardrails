"M0 flush probe (D-61.b) — does stdout written just before `Smalltalk exit:` reach
 the caller intact, and is an explicit flush required? This file is the NO-FLUSH
 source (arms A/C); tools/probe-m0.sh derives the flush-bearing variant (arms B/D)
 by inserting `Stdio stdout flush.` before the exit line. Results: decision-log D-63."
| payload |
payload := String new: 100000 withAll: $x.
Stdio stdout nextPutAll: payload; nextPutAll: 'END-OF-REPORT'; lf.
Smalltalk exit: 7
