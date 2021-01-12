module Screen.Metrics exposing  ( Metrics, zero, set, setFloats)
{-|

A module for creating and storing screen metrics in your model.

Use this array of tools when you need to store and update the screen size
in your model, so you can change your app's functionality based on screen
size by comparing them to Buckets.

# General screen data
@docs Metrics, zero, set, setFloats

-}


{-| The type for storing all screen information.
-}

type alias Metrics =
    { width : Int
    , height : Int
    }




{-| Makes a starting metrics structure where all the values are 0.

Use this as an initial value for your model that you can then initialise from.
-}
zero : Metrics
zero =
    { width = 0
    , height = 0
    }



{-| Takes the width and height values that you'd get from functions like
`Browser.Events.onResize` and updates the screen metrics structure based
on those values.

    update : Msg -> Model -> ( Model, Cmd Msg )
    update msg model =
        case msg of
            ScreenResize w h ->
                ( { model | screen = Screen.Metrics.set w h model.screen }, Cmd.none )

-}
set : Int -> Int -> Metrics -> Metrics
set w h metrics =
    metrics
    |> (\m -> { m | width = w })
    |> (\m -> { m | height = h })



{-| When you want to initialise your Metrics, you'll probably end up using
`Browser.Dom.getViewport`. Functions like this return pixels represented as Floats
instead of Ints, so use this function in these cases, which will correctly round
the Floats up into Ints for storage in `Metrics`.
-}
setFloats : Float -> Float -> Metrics -> Metrics
setFloats w h metrics = set (ceiling w) (ceiling h) metrics

