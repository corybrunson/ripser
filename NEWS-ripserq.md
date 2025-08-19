This branch (`ripserq`) and its sub-branches are testing grounds for planned changes to {ripserr}.

## float to double (2025 Aug 7)

Ripser stores values of the `value_t` type and `ratio` as floats. This is not incompatible with R, but R users are likely to expect numeric values to be handled as doubles. Both values are now stored as doubles in {ripserq}.
