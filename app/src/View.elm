module View exposing (..)

import Html exposing (Html, div, text, button, a, h4)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (..)
import Html.App
import Messages exposing (Msg(..))
import Models exposing (Model)
import SearchBars.Models exposing (Dialog)


import SearchBars.View

-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ page model ]

page : Model -> Html Msg
page model =
    div [] [ Html.App.map SearchMsg (SearchBars.View.page model.dialog)]
