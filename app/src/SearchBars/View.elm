module SearchBars.View exposing (..)

import Html exposing (Html, div, text, input, a, span, h4, button)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import SearchBars.Messages exposing (Msg(..))
import SearchBars.Models exposing (SearchBar, Label, Classification)

-- VIEW

button' : String -> Msg -> Html Msg
button' str m = button [ class "button", onClick m ] [text str]

word_span : Label -> Html Msg
word_span label = span [class ("label-word color-"++(toString label.label)), onClick (LabelToggle label.index)] [(text label.text)]

input_field : SearchBar -> Html Msg
input_field model = input [type' "text", placeholder "your command", onInput ChangeInput, value model.query] []

list_commands : List String -> Html Msg
list_commands c =
  div [] (List.map (\x -> div [] [(text x)]) c)

if_classified : SearchBar -> Html Msg
if_classified model =
  case model.classification of
    Nothing -> div [] []
    Just c ->
      div [class "content"] [
        h4 [] [(text "Cmd:")],
        list_commands c.cmds,
        h4 [] [(text "Select arguments:")],
        -- div [class "classification"] [text "Classification:", text (toString c)],
        div [class "seq_box"] (List.map word_span model.labels),
        div [class "execute"] [button' "Run" Execute]
      ]

if_run : SearchBar -> Html Msg
if_run model =
  case model.output of
    Just out ->
      div [class "content"] [
        div [class "out_box"] [(text out)]
      ]
    Nothing -> div [] []

view : SearchBar -> Html Msg
view model =
    div []
        [ div [class "input_box"] [input_field model, button' "Execute" Submit],
          if_classified model,
          if_run model
        ]
          -- div [class "query_box"] [text model.query],
          -- ,
