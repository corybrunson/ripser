This branch (`ripserq`) and its sub-branches are testing grounds for planned changes to {ripserr}.

# next version

## censored death values

This version addresses #39 by encoding deaths that exceed the threshold as undefined (`NaN`) rather than infinite (`Inf`) then converting these values to missing (`NA_REAL`) while populating the `Rcpp::NumericMatrix` returned to R.
A single infinite degree-0 feature for the connected component is associated with the point of first index.
