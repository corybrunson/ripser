This branch (`ripserq`) and its sub-branches are testing grounds for planned changes to {ripserr}.

# next version

## float to double

Ripser (the C++ library) stores values of the `value_t` type and `ratio` as floats. This is not incompatible with R, but R users are likely to expect numeric values to be handled as doubles. The C++ code in the ripserq branch now stores and handles both values as doubles.

## censored death values

This version addresses #39 by encoding deaths that exceed the threshold as undefined (`NaN`) rather than infinite (`Inf`) then converting these values to missing (`NA_REAL`) while populating the `Rcpp::NumericMatrix` returned to R.
A single infinite degree-0 feature for the connected component is associated with the point of first index.
