module Screen exposing  ( Metrics
                        , zero
                        , set

                        , WidthBucket(..)
                        , FineWidthBucket(..)
                        , toWidthBucket
                        , toFineWidthBucket
                        , HeightBucket(..)
                        , toHeightBucket

                        , handset1
                        , handset2
                        , handset3
                        , portable1
                        , portable2
                        , portable3
                        , wide1
                        , wide2

                        , handset
                        , portable
                        , wide

                        , limited
                        , medium
                        , tall

                        , Bucket
                        , Boundary(..)
                        , BucketAxis(..)

                        , handset1Bkt
                        , handset2Bkt
                        , handset3Bkt
                        , portable1Bkt
                        , portable2Bkt
                        , portable3Bkt
                        , wide1Bkt
                        , wide2Bkt
                        
                        , handsetBkt
                        , portableBkt
                        , wideBkt

                        , limitedBkt
                        , mediumBkt
                        , tallBkt
                        )

{-| A module for storing and interpreting screen dimensions using buckets.

Depending on the situation you need, you can either implement screen
size-based functionality in the form of CSS Media Queries or in Elm code 
with the bucket types and tools.

Either form uses the same core set of display buckets, but Elm Data is
slower because it relies on JavaScript. So when doing style-related
screen things, always use the Media Queries wherever possible.


----

# Storing and using Screen Buckets in the model

Use this array of tools when you need to store and update the screen size
in your model, so you can change your app's functionality based on screen size.

## General screen data
@docs Metrics

## Initialising and updating Metrics
@docs zero, set

## Bucket types and conversions

### Width
@docs WidthBucket, FineWidthBucket, toWidthBucket, toFineWidthBucket

### Height
@docs HeightBucket, toHeightBucket

----

# CSS Media Queries

Use these to create Media Queries to change your app's presentation in elm-css.

```
css [ withMedia [ Screen.handset, Screen.portable1, Screen.portable2 ]
        [ height (px 32)
        , overflow hidden
        ]

    , withMedia [ Screen.portable3, Screen.wide ]
        [ width (px 192)
        , padding4 (px 64) (blc 32) (px 32) (px 48)
        ]
    ]
```

## Width Buckets (broad)
@docs handset, portable, wide

## Width Buckets (fine)
@docs handset1, handset2, handset3, portable1, portable2, portable3, wide1, wide2, wide3

## Height Buckets
@docs limited, medium, tall

----

# Raw numbers
Should you need access to the base metric numbers these buckets are made of.

## Width Buckets (broad)
@docs handsetBkt, portableBkt, wideBkt

## Width Buckets (fine)
@docs handset1Bkt, handset2Bkt, handset3Bkt, portable1Bkt, portable2Bkt, portable3Bkt, wide1Bkt, wide2Bkt

## Height
@docs limitedBkt, mediumBkt, tallBkt

----

# Internal data types

@docs Bucket, Boundary, Axis



-}




import Css exposing (px)
import Css.Media as Media exposing (screen, only)
import Svg.Styled exposing (set)

{-| Makes a starting metrics structure where all the values are 0.

Use this in your initial model, but the model must be properly
initialised afterwards.
-}
zero : Metrics
zero =
    { width =   { exact = 0
                , broad = toWidthBucket 0
                , fine = toFineWidthBucket 0
                }
    , height =  { exact = 0
                , broad = toHeightBucket 0
                }
    }



---------------------- data storage and updating ----------------------

{-| The type for storing all screen information.

```
{ width :   { exact : Int
            , broad : WidthBucket
            , fine : FineWidthBucket
            }
, height :  { exact : Int
            , broad : HeightBucket
            }
}
```

Widths are generally more important than height for determining
screen layout so there's both broad and fine buckets for width.

-}

type alias Metrics =
    { width : WidthMetrics
    , height : HeightMetrics
    }

{-| The record for the width portion of Metrics.

Widths are generally more important than height for determining
screen layout so there's both broad and fine buckets.
-}
type alias WidthMetrics =
    { exact : Int
    , broad : WidthBucket
    , fine : FineWidthBucket
    }

{-| The record  for the height portion of Metrics.

Heights are generally less important than height for determining
screen layout so there's only broad buckets.
-}
type alias HeightMetrics =
    { exact : Int
    , broad : HeightBucket
    }



{-| Takes the width and height values that you'd get from functions like
`Browser.Events.onResize` and updates the screen metrics structure based
on those values.

Because bucket boundaries are in Ints while functions like
`Browser.Events.onResize` produce Floats, the function rounds those
values up when comparing against buckets.

````
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ScreenResize w h ->
            ( { model | screen = Screen.set w h model.screen }, Cmd.none )

````
-}
set : Int -> Int -> Metrics -> Metrics
set w h metrics =
    metrics
    |> setWidth w
    |> setHeight h

{-| Internal function that updates the width portion of Metrics.
-}
setWidth : Int -> Metrics -> Metrics
setWidth w metrics =
        let
            newWidth =
                metrics.width
                |> (\x -> { x | exact = w })
                |> (\b -> { b | broad = toWidthBucket w })
                |> (\b -> { b | fine = toFineWidthBucket w })
        in
            { metrics | width = newWidth }

{-| Internal function that updates the height portion of Metrics.
-}
setHeight : Int -> Metrics -> Metrics
setHeight h metrics =
        let
            newHeight =
                metrics.height
                |> (\x -> { x | exact = h })
                |> (\x -> { x | broad = toHeightBucket h })
        in
            { metrics | height = newHeight }


----------------



{-| A single screen dimension bucket.
-}
type alias Bucket =
    { min : Boundary
    , max : Boundary
    , axis : BucketAxis
    }


{-| The value that the minimum or a maximum of a bucket can be at.

- NoLimit: Either zero (for min) or infinity (for max).
- Defined: A definite value (in px, represented as Ints here).
-}
type Boundary
    = NoLimit -- either zero or infinity
    | Defined Int


{-| Defines what axis a bucket is for.
-}
type BucketAxis
    = Width
    | Height
    

{-| Checks whether a value is in a bucket.
-}
inBucket : Bucket -> Int -> Bool
inBucket bucket v =
    case bucket.min of
        NoLimit ->
            case bucket.max of
            Defined max -> (v <= max)
            NoLimit -> True -- if there's no limit at either end, it's always in the bucket.
        Defined min ->
            case bucket.max of
            Defined max -> (v >= min && v <= max)
            NoLimit -> (v >= min)



{-| Internal function that will produce a Boundary that is -1 of the minimum boundary of the given Bucket.
If the minimum is not Definite, then it will just return NoLimit.
-}
stepBelow : Bucket -> Boundary
stepBelow bucket =
    case bucket.min of
        Defined i -> Defined <| i - 1
        NoLimit -> NoLimit








-------------------- internal CSS media functions -------------------------------


{-| Creates a media query based on a Bucket.
-}
toMediaQuery : Bucket -> Media.MediaQuery
toMediaQuery bucket =
    let
        mediaMin = 
            case bucket.axis of
                Width -> Media.minWidth
                Height -> Media.minHeight
        
        mediaMax = 
            case bucket.axis of
                Width -> Media.maxWidth
                Height -> Media.maxHeight

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





---------------------- width ----------------------




{-| Broad buckets for screen width.

- Handset : The display area can be held in one hand.
- Portable : The display area is portable, but not a handset.
- Wide : Usually desktop contexts.
-}
type WidthBucket
    = Handset
    | Portable
    | Wide


handsetBkt : Bucket
handsetBkt =    { min = NoLimit
                , max = handset3Bkt.max
                , axis = Width
                }


portableBkt : Bucket
portableBkt =   { min = portable1Bkt.min
                , max = portable3Bkt.max
                , axis = Width
                }

wideBkt : Bucket
wideBkt =   { min = wide1Bkt.min
            , max = NoLimit
            , axis = Width
            }




{-| Finer buckets for screen width.

- Handset1 : Tiny phones phones such as Palm, iPhone SE 1st gen. (Usually sub-5")
- Handset2 : Regular phones. (~5" - 6")
- Handset3 : Large phones. ( ~6" - 7")
- Portable1 : Small tablets (~7-8"), narrow desktop windows.
- Portable2 : Regular tablets in portrait (~10"), small desktop windows.
- Portable3 : Large tablets in portrait, small and regular tablets in landscape.
- Wide1 : Large tablets in landscape and budget laptops. 720p, 1366x768, 1280x800.
- Wide2 : Desktop and large laptop displays. 1680x1050, 1080p, 1440p, 4K.
-}
type FineWidthBucket
    = Handset1
    | Handset2
    | Handset3
    | Portable1
    | Portable2
    | Portable3
    | Wide1
    | Wide2


handset1Bkt : Bucket
handset1Bkt =   { min = NoLimit
                , max = stepBelow handset2Bkt
                , axis = Width
                }

handset2Bkt : Bucket
handset2Bkt =   { min = Defined 352 -- 16 * 22
                , max = stepBelow handset3Bkt
                , axis = Width
                }

handset3Bkt : Bucket
handset3Bkt =   { min = Defined 384 -- 16 * 24
                , max = stepBelow portable1Bkt
                , axis = Width
                }

portable1Bkt : Bucket
portable1Bkt =  { min = Defined 512 -- 16 * 32
                , max = stepBelow portable2Bkt
                , axis = Width
                }

portable2Bkt : Bucket
portable2Bkt =  { min = Defined 640 -- 16 * 40
                , max = stepBelow portable3Bkt
                , axis = Width
                }

portable3Bkt : Bucket
portable3Bkt =  { min = Defined 864 -- 16 * 54
                , max = stepBelow wide1Bkt 
                , axis = Width
                }

wide1Bkt : Bucket
wide1Bkt =  { min = Defined 1056 -- 16 * 66
            , max = stepBelow wide2Bkt
            , axis = Width
            }

wide2Bkt : Bucket
wide2Bkt =  { min = Defined 1440 -- 16 * 90
            , max = NoLimit
            , axis = Width
            }






{-| CSS Media query for the handset1 bucket. -}
handset1 : Media.MediaQuery
handset1 = toMediaQuery handset1Bkt

{-| CSS Media query for the handset2 bucket. -}
handset2 : Media.MediaQuery
handset2 = toMediaQuery handset2Bkt

{-| CSS Media query for the handset3 bucket. -}
handset3 : Media.MediaQuery
handset3 = toMediaQuery handset3Bkt

{-| CSS Media query for the portable1 bucket. -}
portable1 : Media.MediaQuery
portable1 = toMediaQuery portable1Bkt

{-| CSS Media query for the portable2 bucket. -}
portable2 : Media.MediaQuery
portable2 = toMediaQuery portable2Bkt


{-| CSS Media query for the portable3 bucket. -}
portable3 : Media.MediaQuery
portable3 = toMediaQuery portable3Bkt

{-| CSS Media query for the wide1 bucket. -}
wide1 : Media.MediaQuery
wide1 = toMediaQuery wide1Bkt

{-| CSS Media query for the wide2 bucket. -}
wide2 : Media.MediaQuery
wide2 = toMediaQuery wide2Bkt







{-| CSS Media query covering all handset width buckets (handset1 - handset3). -}
handset : Media.MediaQuery
handset = toMediaQuery handsetBkt

{-| CSS Media query covering all portable width buckets (portable1 - portable3). -}
portable : Media.MediaQuery
portable = toMediaQuery portableBkt

{-| CSS Media query covering all wide width buckets (wide1 - wide2). -}
wide : Media.MediaQuery
wide = toMediaQuery wideBkt






{-| Takes an int representing screen width in pixels
and converts it into a (broad) screen width bucket.

https://github.com/dzuk-mutant/Helium/blob/master/docs/display.md#display-width-groups
-}
toWidthBucket : Int -> WidthBucket
toWidthBucket w =
    if inBucket handsetBkt w then
        Handset
    else if inBucket portableBkt w then
        Portable
    else
        Wide


{-| Takes a Int representing screen width and 
 and converts it into a fine screen width bucket.

https://github.com/dzuk-mutant/Helium/blob/master/docs/display.md#display-width-groups
-}
toFineWidthBucket : Int -> FineWidthBucket
toFineWidthBucket w =
    if inBucket handset1Bkt w then
        Handset1
    else if inBucket handset2Bkt w then
        Handset2
    else if inBucket handset3Bkt w then
        Handset3
    else if inBucket portable1Bkt w then
        Portable1
    else if inBucket portable2Bkt w then
        Portable2
    else if inBucket portable3Bkt w then
        Portable3
    else if inBucket wide1Bkt w then
        Wide1
    else
        Wide2











---------------------- height ----------------------


{-| Buckets for screen height.

There aren't as many as screen width because it has
generally limited implications for web application design.

- Limited : Handsets in landscape. Very limited screen space.
- Portable : Small and regular tablets in landscape. Restricted screen space.
- Wide : Large tablet in landscape, laptop or desktop contexts. Ample screen space.
-}
type HeightBucket
    = Limited
    | Medium
    | Tall


limitedBkt : Bucket
limitedBkt =    { min = NoLimit
                , max = stepBelow mediumBkt
                , axis = Height
                }

mediumBkt : Bucket
mediumBkt =     { min = Defined 512 -- 16 * 32
                , max = stepBelow tallBkt
                , axis = Height
                }

tallBkt : Bucket
tallBkt =   { min = Defined 864 -- 16 * 54
            , max = NoLimit
            , axis = Height
            }






{-| CSS Media query covering the limited height bucket.
-}
limited : Media.MediaQuery
limited = toMediaQuery limitedBkt

{-| CSS Media query covering the medium height bucket.
-}
medium : Media.MediaQuery
medium = toMediaQuery mediumBkt

{-| CSS Media query covering the tall height bucket.
-}
tall : Media.MediaQuery
tall = toMediaQuery tallBkt





{-| Takes an int representing a screen height in pixels
and converts it into a screen height bucket.

 Buckets boundaries are Ints, so this function rounds the
 screen width Int *up*.

https://github.com/dzuk-mutant/Helium/blob/master/docs/display.md#display-height-groups
-}
toHeightBucket : Int -> HeightBucket
toHeightBucket h =
    if inBucket limitedBkt h then
        Limited
    else if inBucket mediumBkt h then
        Medium
    else
        Tall
