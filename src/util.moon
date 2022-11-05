_mathmin = math.min
_mathmax = math.max

clamp = ( value, min, max ) ->
    return _mathmin( max, _mathmax( value, min ) )
