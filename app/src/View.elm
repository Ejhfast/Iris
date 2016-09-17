module View exposing (..)

import Html exposing (Html, div, text, button, a, h4)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (..)
import Html.App
import Messages exposing (Msg(..))
import Models exposing (Model)
import SearchBars.Models exposing (SearchBar)


import SearchBars.View

-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ page model ]

old_cmd : SearchBar -> Html Msg
old_cmd model =
  div [] [ a [onClick (Switch model)] [text model.query]]

old_cmds : List SearchBar -> Html Msg
old_cmds models =
  div [class "content"] ([h4 [] [(text "History:")]] ++ (List.map old_cmd models))

archive : Html Msg
archive = button [class "button", onClick Archive] [text "Archive"]

page : Model -> Html Msg
page model =
    div [] [ Html.App.map SearchMsg (SearchBars.View.view model.search),
             div [class "content"] [archive],
            old_cmds model.history ]
