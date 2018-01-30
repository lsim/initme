module InitMe exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Model =
    { workingDirectory : String
    }


initialModel : Model
initialModel =
    { workingDirectory = ""
    }


type Msg
    = None
    | WorkingDirectoryChanged String


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Init Me" ]
        , viewInputs
        , hr [] []
        , viewSystemCtlOutput model
        ]


viewInputs : Html Msg
viewInputs =
    div []
        [ div [] [ text "Working directory:", input [ type_ "text", onInput WorkingDirectoryChanged ] [] ]
        , div [] [ text "input1", input [ type_ "text" ] [] ]
        ]


viewSystemCtlOutput : Model -> Html msg
viewSystemCtlOutput model =
    let
        printLn txt =
            div [] [ text txt ]
    in
        div []
            [ printLn ("foo: " ++ model.workingDirectory)
            , printLn "bar: barbar"
            , printLn "baz: bass"
            ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        None ->
            ( model, Cmd.none )

        WorkingDirectoryChanged value ->
            ( { model | workingDirectory = value }, Cmd.none )


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }
