module Screen.Bucket exposing (Bucket, Boundary(..), Axis(..), create, stepBelow, toMediaQuery)

{-| A module for creating sets of screen boundaries (here, called 'buckets') for comparing against the user's screen size.

## Types
@docs Bucket, Boundary, Axis

## Functions
@docs create, stepBelow

## Conversions
@docs toMediaQuery

-}

import Css exposing (px)
import Css.Media exposing (MediaQuery, screen, only)

{-| A single bucket. Can only be used for one dimension (as defined by it's axis).
-}
type alias Bucket =
    { min : Boundary
    , max : Boundary
    , axis : Axis
    }


{-| The value that the minimum or a maximum of a Bucket can be at.

- `NoLimit`: Represents either zero (if min) or infinity (if max).
- `Defined`: A definite value (in px, represented as Ints).
-}
type Boundary
    = NoLimit -- either zero or infinity
    | Defined Int


{-| Defines what axis a bucket is for.
-}
type Axis
    = Width
    | Height
    


{-| A function that creates a Bucket using the normal values that Buckets contain.

Consider using `stepBelow` in conjunction with this function to create
buckets that neatly slot next to each other.
```
mobile : Bucket
mobile = Bucket.create Width NoLimit (stepBelow tablet) 

tablet : Bucket
tablet = Bucket.create Width (Defined 412) (stepBelow desktop) 

desktop : Bucket
desktop = Bucket.create Width (Defined 1052) NoLimit
```
-}

create : Axis -> Boundary -> Boundary -> Bucket
create axis min max =
    { min = min
    , max = max
    , axis = axis
    }



{-| Will produce a Boundary that is -1 of the minimum
boundary of the given Bucket, if that Boundary is `Definite`.

If the minimum is `NoLimit` instead, then it will just return `NoLimit`.

Useful when you want to create buckets that neatly
slot next to each other.


```
tablet : Bucket
tablet = Bucket.create Width (Defined 512) (stepBelow desktop) 

desktop : Bucket
desktop = Bucket.create Width (Defined 1052) NoLimit
```
-}
stepBelow : Bucket -> Boundary
stepBelow bucket =
    case bucket.min of
        Defined i -> Defined <| i - 1
        NoLimit -> NoLimit




{-| A function that converts a Bucket into an elm-css MediaQuery.

This function exists for possible edge cases that you might have. 
If you want to use buckets as media queries in a typical way,
you'll probably want to look at `Screen.withMedia` instead.
-}
toMediaQuery : Bucket -> MediaQuery
toMediaQuery bucket =
    let
        -- figure out what axis we're working with
        mediaMin = 
            case bucket.axis of
                Width -> Css.Media.minWidth
                Height -> Css.Media.minHeight
        
        mediaMax = 
            case bucket.axis of
                Width -> Css.Media.maxWidth
                Height -> Css.Media.maxHeight

        -- ints in CSS are floats, so an extra conversion has to take place.
        toPx int = px <| toFloat int
    
    in
        case bucket.min of
            NoLimit ->
                case bucket.max of
                    Defined max -> only screen [ mediaMax (toPx max)]
                    NoLimit -> only screen [ mediaMax (toPx 0)]

            Defined min ->
                case bucket.max of
                    Defined max -> only screen  [ mediaMin (toPx min), mediaMax (toPx max) ]
                    NoLimit -> only screen [ mediaMin (toPx min)]

