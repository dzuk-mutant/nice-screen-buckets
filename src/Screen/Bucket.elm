module Screen.Bucket exposing ( Bucket
                              , Boundary(..)
                              , Axis(..)
                              , create
                              , encompass
                              , stepBelow
                              , toMediaQuery

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

{-| A module for creating sets of screen boundaries (here, called 'buckets').

These buckets can then be used to compare against the user's screen size
directly or converted to CSS Media queries.

This module also contains optional premade Buckets.

# Types
@docs Bucket, Boundary, Axis

# Creating buckets
@docs create, encompass, stepBelow

# Conversions
@docs toMediaQuery

---

# Premade Buckets

## Width Buckets
Because width tends to be more important than height in creating
responsive interfaces, width buckets have more detail, with two
parallel levels of detail for convenience - broad buckets, which
are not numbered, and fine buckets, which are numbered.

### Handset
@docs handset, handset1, handset2, handset3

### Portable
@docs portable, portable1, portable2, portable3

### Wide
@docs wide, wide1, wide2

## Height Buckets
@docs limited, medium, tall


-}

import Css exposing (px)
import Css.Media exposing (MediaQuery, screen, only)

{-| A bucket. Can only be used for one specific dimension as defined by it's `axis` value.
-}
type alias Bucket =
    { min : Boundary
    , max : Boundary
    , axis : Axis
    }


{-| The value that the minimum or a maximum of a Bucket can be at.

- `NoLimit`: Represents either zero (if min) or infinity (if max).
- `Defined`: A definite value (in px, represented as Ints).

When creating a minimum boundary of zero, use `NoLimit` instead of `Defined 0`.
-}
type Boundary
    = NoLimit -- either zero or infinity
    | Defined Int


{-| Defines what axis a bucket is for.
-}
type Axis
    = Width
    | Height
    


{-| A function that creates a Bucket.

Consider using `stepBelow` in conjunction with this function to create
buckets that neatly slot next to each other.

    mobile : Bucket
    mobile = Bucket.create Width NoLimit (stepBelow tablet) 

    tablet : Bucket
    tablet = Bucket.create Width (Defined 412) (stepBelow desktop) 

    desktop : Bucket
    desktop = Bucket.create Width (Defined 1052) NoLimit

-}

create : Axis -> Boundary -> Boundary -> Bucket
create axis min max =
    { min = min
    , max = max
    , axis = axis
    }

{-| Creates a bucket that encompasses the minimum of the
first bucket and the maximum of the second bucket.

Useful when you want to create buckets that are larger groupings of smaller buckets.

    wide1 : Bucket
    wide1 = Bucket.create Width (Defined 1056) (stepBelow wide2)

    wide2 : Bucket
    wide2 = Bucket.create Width (Defined 1440) NoLimit

    wide : Bucket
    wide = Bucket.encompass Width wide1 wide2
    -- creates a bucket between 1056 and NoLimit

-}
encompass : Axis -> Bucket -> Bucket -> Bucket
encompass axis minBucket maxBucket =
    create axis minBucket.min maxBucket.max


{-| Will produce a Boundary that is -1 of the minimum
boundary of the given Bucket, if that Boundary is `Definite`.

If the minimum is `NoLimit` instead, then it will just return `NoLimit`.

Useful when you want to create buckets that neatly
slot next to each other.


    tablet : Bucket
    tablet = Bucket.create Width (Defined 512) (stepBelow desktop) 

    desktop : Bucket
    desktop = Bucket.create Width (Defined 1052) NoLimit

-}
stepBelow : Bucket -> Boundary
stepBelow bucket =
    case bucket.min of
        Defined i -> Defined <| i - 1
        NoLimit -> NoLimit




{-| A function that converts a Bucket into an elm-css MediaQuery
that covers the boundaries given by the bucket at the correct axis.

These media queries can be stacked in a list wth functions such
as withMedia, so you can cover larger areas with multiple
contiguous buckets.

This function exists for possible edge cases that you might have. 
If you want to use buckets as media queries in a typical way,
you'll probably want to look at `Screen.withMedia` instead.


    tablet : Bucket
    tablet = Bucket.create Width (Defined 512) (stepBelow desktop) 

    tabletMq : MediaQuery
    tabletMq = Bucket.toMediaQuery tablet
    -- produces: only screen [ minWidth (px 512), maxWidth (px 1051) ]

    desktop : Bucket
    desktop = Bucket.create Width (Defined 1052) NoLimit

    desktopMq : MediaQuery
    desktopMq = Bucket.toMediaQuery desktop
    -- produces: only screen [ minWidth (px 1052) ]

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








---------------------- PRE-MADE BUCKETS ----------------------

{-| A width bucket that covers all 'handset' buckets (`handset1`,
`handset2` and `handset3`).

A 'handset' here refers to a device that can be held in one hand. 
This usually means phones.

This bucket can also encompass particularly narrow browser windows
in desktop and tablets.
-}
handset : Bucket
handset = encompass Width handset1 handset3


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
handset1 = create Width NoLimit (stepBelow handset2)


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
handset2 = create Width (Defined 352) (stepBelow handset3)


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
handset3 = create Width (Defined 384) (stepBelow portable1)







{-| A width bucket that covers all 'portable' buckets (`portable1`,
`portable2` and `portable3`).

'portable' buckets encompass these things:
- tablets (of varying sizes, use the smaller buckets to be more precise)
- medium-sized windows in tablet splitscreen modes and desktops.
-}
portable : Bucket
portable = encompass Width portable1 portable3


{-| A width bucket that's between 512 and 639px.

This encompasses the relatively archaic 7"/'flyer'
tablet format in portrait, as well as particularly
narrow windows in desktop and certain splitscreen tablet views.

Device examples (in portrait):
- Google Nexus 7 (2013) - 600 x 960 (@3x)

-}
portable1 : Bucket
portable1 = create Width (Defined 512) (stepBelow portable2)

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
portable2 = create Width (Defined 640) (stepBelow portable3)


{-| A width bucket that's between 864 and 1055px.

This encompasses the largest tablets in portrait. Typically around 13".

Device examples (in portrait):
- Apple iPad Pro (2015-2017, 2018-2020) 12.9" - 1024 x 1366
- Microsoft Surface Pro 2017 - 912 x 1368

-}
portable3 : Bucket
portable3 = create Width (Defined 864) (stepBelow wide1)







{-| A width bucket that encompasses all 'wide' buckets
(`wide1` and `wide2`).

Wide buckets encompass these things:
- Desktop displays in fullscreen (or close to it).
- Large laptops in fullscreen (or close to it).

'wide' buckets are handy when you want to handle particularly
wide interfaces for maximum productivity.

-}
wide : Bucket
wide = encompass Width wide1 wide2


{-| A width bucket that represents large tablets in landscape 
and small and budget laptops. (All in fullscreen.)

Example resolutions:
- 720p
- 1366 x 768
- 1280 x 800. 
-}
wide1 : Bucket
wide1 = create Width (Defined 1056) (stepBelow wide2)


{-| The widest width bucket this module offers.
This represents typical desktop displays in fullscreen.

Desktop and other large displays.
Example resolutions:
- 1680 x 1050
- 1080p, 4K
- 1440p, 5K
-}
wide2 : Bucket
wide2 = create Width (Defined 1440) NoLimit













{-| A height bucket representing handset devices (ie. phones)
in landscape. The amount of vertical space is very limited.

The maximum of this bucket is the same as `handset`, but in height.
-}
limited : Bucket
limited = create Height NoLimit (stepBelow medium)


{-| A height bucket representing small and regular tablets in
landscape. The amount of vertical space is restricted.

This buckets bounds are the same as `portable1` - `portable2` but in height.
-}
medium : Bucket
medium = create Height portable2.max (stepBelow tall)


{-| A height bucket representing large landscape tablet,
laptop or desktop contexts. The amount of vertical space is
generally ample.

The minimum of this bucket is the same as `portable3`, but in height.
-}
tall : Bucket
tall = create Height portable3.min NoLimit
