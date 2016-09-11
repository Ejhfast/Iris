module View exposing (..)

import Html exposing (Html, div, text)
import Html.App
import Messages exposing (Msg(..))
import Models exposing (Model)

import SearchBars.View

-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ page model ]

page : Model -> Html Msg
page model =
    div [] [Html.App.map SearchMsg (SearchBars.View.view model.search)]
