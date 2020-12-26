module Screen exposing  ( isIn
                        , withMedia

                        , handset
                        , handset1
                        , handset2
                        , handset3

                        , portable
                        , portable1
                        , portable2
                        , portable3

                        , wide
                        , wide1
                        , wide2

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

## Width Buckets
Because width tends to be more important than height in creating
responsive interfaces, width buckets have more detail, with two parallel levels
of detail for convenience - broad buckets, which are not numbered, and fine
buckets, which are numbered.

### Handset
@docs handset, handset1, handset2, handset3

### Portable
@docs portable, portable1, portable2, portable3

### Wide
@docs wide, wide1, wide2

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
        {- this creates a media query that looks like this:
        withMedia [ only screen [ minWidth (px 864), maxWidth (px 1051) ]
                    , only screen [ minWidth (px 1052) ]
                    ]
        -}

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







---------------------- PRE-MADE BUCKETS ----------------------

{-| A width bucket that covers all 'handset' buckets (`handset1`,
`handset2` and `handset3`).

A 'handset' here refers to a device that can be held in one hand. 
This usually means phones.

This bucket can also encompass particularly narrow browser windows
in desktop and tablets.
-}
handset : Bucket
handset = Bucket.encompass Width handset1 handset3


{-| A width bucket that's 351px and under.

This represents the smallest handsets available in recent memory.
This typically means devices below 4.7" in screen size.

Many of the devices in this bucket may be becoming archaic
(by 2020 standards), but it's still a useful bucket,
especially if you want to be inclusive to particularly small
screen sizes, which require particular attention to make
work in responsive design.

Device examples (in portrait):
- Apple iPhone 1-3G - 320 x 480 (@1x)
- Apple iPhone 4, 4S - 320 x 480 (@2x)
- Apple iPhone 5, 5c, 5s, SE (1st gen) - 320 x 568 (@2x)
-}
handset1 : Bucket
handset1 = Bucket.create Width NoLimit (stepBelow handset2)


{-| A width bucket that's between 352 and 383px.

This typically represents devices that can be held in one
hand but are not entirely operable with one hand.
Nowadays, this typically means devices between
5" - 6" in screen size.

Device examples (in portrait):
- Apple iPhone 12 Mini - 360 x 780 (@3x)
- Apple iPhone 6-8, SE (2nd gen) - 375 x 687 (@2x)
- Apple iPhone X, XS, 11 Pro - 375 x 812 (@3x)
- Sony Xperia XZ2 Compact - 360 x 720
-}
handset2 : Bucket
handset2 = Bucket.create Width (Defined 352) (stepBelow handset3)


{-| A width bucket that's between 384 and 511px.

This represents devices that can be held in one hand, but are not
operable with one hand. Nowadays this typically means devices
between 6" - 7" in screen size.

Device examples (in portrait): 
- Apple iPhone 6-8 Plus - 414 x 736 (@2x)
- Apple iPhone XR, XS Max, 11, 11 Pro Max - 414 x 896
- Google Pixel XL - 412 x 732
- Google Pixel 3 - 411 x 823 (@2.625x)
- Google Pixel 3 XL - 411 x 846 (@3x)
- Samsung Galaxy S9+ - 411 x 846 
- Sony Xperia 1 - 411 x 960 (@4x)
-}
handset3 : Bucket
handset3 = Bucket.create Width (Defined 384) (stepBelow portable1)


{-| A width bucket that covers all 'portable' buckets (`portable1`,
`portable2` and `portable3`).

'portable' buckets encompass these things:
- tablets (of varying sizes, use the smaller buckets to be more precise)
- medium-sized windows in tablet splitscreen modes and desktops.
-}
portable : Bucket
portable = Bucket.encompass Width portable1 portable3


{-| A width bucket that's between 512 and 639px.

This encompasses the relatively archaic 7"/'flyer'
tablet format in portrait, as well as particularly
narrow windows in desktop and certain splitscreen tablet views.

Device examples (in portrait):
- Google Nexus 7 (2013) - 600 x 960 (@3x)

-}
portable1 : Bucket
portable1 = Bucket.create Width (Defined 512) (stepBelow portable2)

{-| A width bucket that's between 640 and 863px.

This encompasses the most common tablet sizes in
portrait. Typically between 8" and 11".

Device examples (in portrait):
- Apple iPad 9.7", mini - 768 x 1024 (they are different sizes but a web browser doesn't see them any differently)
- Apple iPad 10.2" - 810 x 1080
- Apple iPad Pro (2015-2017) 10.5" - 834 x 1112
- Apple iPad Pro (2018-2020) 11" - 834 x 1194
- Google Pixel C - 900 x 1280
-}
portable2 : Bucket
portable2 = Bucket.create Width (Defined 640) (stepBelow portable3)


{-| A width bucket that's between 864 and 1055px.

This encompasses the largest tablets in portrait. Typically around 13".

Device examples (in portrait):
- Apple iPad Pro (2015-2017, 2018-2020) 12.9" - 1024 x 1366
- Microsoft Surface Pro 2017 - 912 x 1368

-}
portable3 : Bucket
portable3 = Bucket.create Width (Defined 864) (stepBelow wide1)


{-| A width bucket that encompasses all 'wide' buckets
(`wide1` and `wide2`).

Wide buckets encompass these things:
- Desktop displays in fullscreen (or close to it).
- Large laptops in fullscreen (or close to it).

'wide' buckets are handy when you want to handle particularly
wide interfaces for maximum productivity.

-}
wide : Bucket
wide = Bucket.encompass Width wide1 wide2


{-| A width bucket that represents large tablets in landscape 
and small and budget laptops. (All in fullscreen.)

Example resolutions:
- 720p
- 1366 x 768
- 1280 x 800. 
-}
wide1 : Bucket
wide1 = Bucket.create Width (Defined 1056) (stepBelow wide2)


{-| The widest width bucket this module offers.
This represents typical desktop displays in fullscreen.

Desktop and other large displays.
Example resolutions:
- 1680 x 1050
- 1080p, 4K
- 1440p, 5K
-}
wide2 : Bucket
wide2 = Bucket.create Width (Defined 1440) NoLimit


{-| A height bucket representing handset devices (ie. phones)
in landscape. The amount of vertical space is very limited.

The maximum of this bucket is the same as `handset`, but in height.
-}
limited : Bucket
limited = Bucket.create Height NoLimit (stepBelow medium)


{-| A height bucket representing small and regular tablets in
landscape. The amount of vertical space is restricted.

This buckets bounds are the same as `portable1` - `portable3` but in height.
-}
medium : Bucket
medium = Bucket.create Height portable.min (stepBelow tall)


{-| A height bucket representing large landscape tablet,
laptop or desktop contexts. The amount of vertical space is
generally ample.

The minimum of this bucket is the same as `portable3`, but in height.
-}
tall : Bucket
tall = Bucket.create Height portable3.min NoLimit


-----