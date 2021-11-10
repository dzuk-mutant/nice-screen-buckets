module Screen exposing  ( isIn
                        , withMedia
                        )

{-| A module that contains functions for comparing Screen Metrics against
Screen Buckets so you can change your app's functionality or presentation
based on how big the user's screen is.

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

-}




import Css exposing (Style)
import Css.Media
import Screen.Metrics exposing (Metrics)
import Screen.Bucket as Bucket exposing (Bucket, Axis(..), Boundary(..))


{-| Checks to see if the screen size (represented by `Metrics`) matches
any buckets that you provide.

Useful when you want to swap out functionality, layouts or
interface elements based on screen size.

    Html.div
        []
        -- show mobile menu if screen width is small enough
        [   ( if Screen.isIn [ handset, portable1 ] model.screen then
                Html.div [] [ Html.text "menu" ]
            else
                []
            )   
        ]
-}
isIn : List Bucket -> Metrics -> Bool
isIn buckets metrics =
    buckets
    |> List.map (inBucket metrics)
    |> List.any (\a -> a == True)



{-| Wraps styles within a CSS media query that matches the given Screen Buckets.

It performs the equivalent of `Css.Media.withMedia`.

    css [ Screen.withMedia [ handset, portable1, portable2 ]
            [ height (px 32)
            , overflow hidden
            ]

        
        , Screen.withMedia [ portable3, wide ]
            [ width (px 192)
            , padding4 (px 64) (px 32) (px 32) (px 48)
            ]
        ]

See `Screen.Bucket.toMediaQuery` to see how the media queries for each bucket get made.

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






