module Screen.Bucket.Examples exposing (handset
                              , handset1
                              , handset2
                              , handset3

                              , portable
                              , portable1
                              , portable2

                              , wide
                              , wide1
                              , wide2

                              , limited
                              , medium
                              , tall)

{-| 

# Premade example buckets

## Width Buckets
Because width tends to be more important than height in creating
responsive interfaces, width buckets have more detail, with two
parallel levels of detail for convenience - broad buckets, which
are not numbered, and fine buckets, which are numbered.

### Handset
@docs handset, handset1, handset2, handset3

### Portable
@docs portable, portable1, portable2

### Wide
@docs wide, wide1, wide2

## Height Buckets
@docs limited, medium, tall

-}

import Screen.Bucket exposing (..)


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

This has become quite a niche use case, but the users of these
devices need particular catering to to make web layouts work,
especially by making side margins not too big.

This is also relevant to web views in Apple Watch.

Device examples (in portrait):
- Apple iPhone 5s, SE (1st gen) - 320 x 568 
- Apple Watch (web views are rendered around 320px wide with double-size fonts)
-}
handset1 : Bucket
handset1 = create Width NoLimit (stepBelow handset2)


{-| A width bucket that's between 352 and 383px.

This typically represents devices that can be held in one
hand but are not entirely operable with one hand.
Nowadays, this typically means devices between
5" - 6" in screen size.

Device examples (in portrait):
- Apple iPhone 12-13 Mini - 360 x 780px
- Samsung Galaxy S20, S21, S21+ - 360 x 800px
- Samsung Z Flip3 - 360 x 880px
- Apple iPhone 6-8, SE (2nd gen) - 375 x 667px
- Apple iPhone X, XS, 11 Pro - 375 x 812px

-}
handset2 : Bucket
handset2 = create Width (Defined 340) (stepBelow handset3)


{-| A width bucket that's between 384 and 511px.

This represents devices that can be held in one hand, but are not
operable with one hand. Nowadays this typically means devices
between 6" - 7" in screen size.

Device examples (in portrait): 
- Apple iPhone 6-8 Plus - 414 x 736px
- Apple iPhone 12-13, 12-13 Pro - 390 x 844px
- Samsung Galaxy S20+ - 384 x 854px
- Samsung Galaxy S10+, Note 10, Note 10+ - 412 x 869px
- Apple iPhone XR, XS Max, 11, 11 Pro Max - 414 x 896px
- Apple iPhone 12-13 Pro - 428 - 926px
- Sony Xperia 1 - 411 x 960
-}
handset3 : Bucket
handset3 = create Width (Defined 378) (stepBelow portable1)







{-| A width bucket that covers all 'portable' buckets (`portable1`,
`portable2` and `portable3`).

'portable' buckets encompass these things:
- tablets (of varying sizes, use the smaller buckets to be more precise)
- medium-sized windows in tablet splitscreen modes and desktops.
-}
portable : Bucket
portable = encompass Width portable1 portable2


{-| A width bucket that's between 512 and 896px.

This encompasses smaller tablets (typically between 8-10" in size).
-}
portable1 : Bucket
portable1 = create Width (Defined 512) (stepBelow portable2)

{-| A width bucket that's between 896 and 863px.

This encompasses the most common tablet sizes in
portrait. Typically between 8" and 11".
-}
portable2 : Bucket
portable2 = create Width (Defined 896) (stepBelow wide1)






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
medium = create Height portable1.max (stepBelow tall)


{-| A height bucket representing large landscape tablet,
laptop or desktop contexts. The amount of vertical space is
generally ample.

The minimum of this bucket is the same as `portable2`, but in height.
-}
tall : Bucket
tall = create Height portable2.min NoLimit
