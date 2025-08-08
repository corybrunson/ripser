This branch (`ripserq`) and its sub-branches are testing grounds for planned changes to {ripserr}.

# next version

This version fully addresses #39 by encoding deaths that subceed the threshold as missing (`NA`) rather than undefined (`NaN`) or infinite (`Inf`).
A single infinite degree-0 feature is retained.
