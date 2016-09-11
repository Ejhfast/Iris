module SearchBars.View exposing (..)

import Html exposing (Html, div, text, input, a, span, h4)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import SearchBars.Messages exposing (Msg(..))
import SearchBars.Models exposing (SearchBar, Label, Classification)

-- VIEW

button : String -> Msg -> Html Msg
button str m = a [ class "btn", onClick m ] [text str]

word_span : Label -> Html Msg
word_span label = span [class ("label-word color-"++(toString label.label)), onClick (LabelToggle label.index)] [(text label.text)]

input_field : Html Msg
input_field = input [type' "text", placeholder "your command", onInput ChangeInput ] []

list_commands : List String -> Html Msg
list_commands c =
  div [] (List.map (\x -> div [] [(text x)]) c)

if_classified : SearchBar -> Html Msg
if_classified model =
  case List.head model.classification of
    Nothing -> div [] []
    Just c ->
      div [class "content"] [
        h4 [] [(text "Cmd:")],
        list_commands c.cmds,
        h4 [] [(text "Select arguments:")],
        -- div [class "classification"] [text "Classification:", text (toString c)],
        div [class "seq_box"] (List.map word_span model.labels)
      ]

view : SearchBar -> Html Msg
view model =
    div []
        [ div [class "input_box"] [input_field, button "Execute" Submit],
          if_classified model
        ]
          -- div [class "query_box"] [text model.query],
          -- ,
