module Screen exposing  ( isIn
                        , withMedia

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
                        )

{-| A module that contains functions for comparing Screen Metrics against
Screen Buckets so you can change your app's functionality or presentation
based on how big the user's screen is.

This module also contains optional pre-built Buckets.

# Checking Metrics against Buckets

Depending on the situation you need, you can either check via:

- Checking the Metrics values in the model.
- CSS media queries in elm-css.

All methods use the same Bucket data type, but doing anything with
data in Elm is slower because it relies on JavaScript. So when doing
presentation-related things with elm-css, always use the media queries
wherever possible.

## Checking with Elm data
@docs isIn

## Checking with CSS media queries
@docs withMedia

----


# Default Buckets
These are the default buckets that come with this, but you can make your own with `Screen.Bucket`.

Details about what sizes these buckets are and what they're for can be found in the readme.

## Width Buckets
Because width tends to be more important than height in creating
responsive interfaces, width buckets have more detail, with have two
different parallel levels of detail for convenience.

### Broad buckets
@docs handset, portable, wide

### Fine Buckets
@docs handset1, handset2, handset3, portable1, portable2, portable3, wide1, wide2

## Height Buckets
@docs limited, medium, tall


-}




import Css exposing (Style)
import Css.Media exposing (withMedia)
import Screen.Metrics exposing (Metrics)
import Screen.Bucket as Bucket exposing (Bucket, Axis(..), Boundary(..), stepBelow)


{-| Checks to see if the screen size (represented by `Metrics`) matches
any buckets that you provide.

Useful when you want to swap out functionality, layouts or
interface elements based on screen size.
```
Html.div
    []
    -- show mobile menu if screen width is small enough
    [   ( if Screen.isIn [ handset, portable1 ] model.screen then
            Html.div [] [ Html.text "menu" ]
          else
            []
        )   
    ]
```
-}
isIn : List Bucket -> Metrics -> Bool
isIn buckets metrics =
    buckets
    |> List.map (inBucket metrics)
    |> List.any (\a -> a == True)



{-| Converts a list of buckets and a list of elm-css Styles into a Style
that become active depending on whether or not the screen size
is in the given buckets.

It performs the equivalent of `Css.Media.withMedia`.

```
css [ Screen.withMedia [ handset, portable1, portable2 ]
        [ height (px 32)
        , overflow hidden
        ]

    , Screen.withMedia [ portable3, wide ]
        [ width (px 192)
        , padding4 (px 64) (px 32) (px 32) (px 48)
        ]
    ]
```

This doesn't use your model's `Metrics` because CSS media
queries don't get checked against the screen size within Elm,
but by the browsers directly.
-}
withMedia : List Bucket -> List Style -> Style
withMedia buckets styles =
    Css.Media.withMedia ( List.map Bucket.toMediaQuery buckets ) styles




{-| Internal function that checks if Screen Metrics is in a Screen Bucket.
-}
inBucket : Metrics -> Bucket -> Bool
inBucket metrics bucket =
    let
        v = case bucket.axis of
            Width -> metrics.width
            Height -> metrics.height
    in
        case bucket.min of
            NoLimit ->
                case bucket.max of
                    Defined max -> (v <= max)
                    NoLimit -> True -- if there's no limit at either end, it's always in the bucket.
            Defined min ->
                case bucket.max of
                    Defined max -> (v >= min && v <= max)
                    NoLimit -> (v >= min)







---------------------- PRE-MADE BUCKETS ----------------------



{-| A bucket that covers all 'handset' buckets (`handset1`, `handset2` and `handset3`).
-}
handset : Bucket
handset =   { min = NoLimit
            , max = handset3.max
            , axis = Width
            }

{-| A bucket that covers all 'portable' buckets (`portable1`, `portable2` and `portable3`).
-}
portable : Bucket
portable =  { min = portable1.min
            , max = portable3.max
            , axis = Width
            }

{-| A bucket that covers all 'wide' buckets (`wide1` and `wide2`).
-}
wide : Bucket
wide =  { min = wide1.min
        , max = NoLimit
        , axis = Width
        }




{-| The handset1 width bucket.
-}
handset1 : Bucket
handset1 =  { min = NoLimit
            , max = stepBelow handset2
            , axis = Width
            }

{-| The handset2 width bucket.
-}
handset2 : Bucket
handset2 =  { min = Defined 352 -- 16 * 22
            , max = stepBelow handset3
            , axis = Width
            }

{-| The handset3 width bucket.
-}
handset3 : Bucket
handset3 =  { min = Defined 384 -- 16 * 24
            , max = stepBelow portable1
            , axis = Width
            }

{-| The portable1 width bucket.
-}
portable1 : Bucket
portable1 = { min = Defined 512 -- 16 * 32
            , max = stepBelow portable2
            , axis = Width
            }

{-| The portable2 width bucket.
-}
portable2 : Bucket
portable2 = { min = Defined 640 -- 16 * 40
            , max = stepBelow portable3
            , axis = Width
            }

{-| The portable3 width bucket.
-}
portable3 : Bucket
portable3 = { min = Defined 864 -- 16 * 54
            , max = stepBelow wide1 
            , axis = Width
            }

{-| The wide1 width bucket.
-}
wide1 : Bucket
wide1 = { min = Defined 1056 -- 16 * 66
        , max = stepBelow wide2
        , axis = Width
        }

{-| The wide2 width bucket.
-}
wide2 : Bucket
wide2 = { min = Defined 1440 -- 16 * 90
        , max = NoLimit
        , axis = Width
        }


{-| The limited height bucket.
-}
limited : Bucket
limited =   { min = NoLimit
            , max = stepBelow medium
            , axis = Height
            }

{-| The medium height bucket.
-}
medium : Bucket
medium =    { min = Defined 512 -- 16 * 32
            , max = stepBelow tall
            , axis = Height
            }

{-| The tall height bucket.
-}
tall : Bucket
tall =  { min = Defined 864 -- 16 * 54
        , max = NoLimit
        , axis = Height
        }


-----