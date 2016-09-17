module SearchBars.View exposing (..)

import Html exposing (Html, div, text, input, a, span, h4, button, body)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick, on, keyCode)
import SearchBars.Messages exposing (Msg(..))
import SearchBars.Models exposing (Clarification, UserQuestion, Dialog)
import Json.Decode as JS


onEnter : Msg -> Html.Attribute Msg
onEnter msg =
  let
    tagger code =
      if code == 13 then msg else NoOp
  in
    on "keydown" (JS.map tagger keyCode)

iris_message : String -> Html Msg
iris_message s =
  div [class "message left"] [div [class "bubble"] [text s]]

user_message : String -> Html Msg
user_message s =
  div [class "message right"] [div [class "bubble"] [text s]]

qr_view {question, response} =
  let qm = [iris_message question]
      im = (case response of
            Just r -> [user_message r]
            Nothing -> []) in
  qm ++ im

user_question_view : UserQuestion -> List (Html Msg)
user_question_view {question, response, clarifications} =
  let q_init = [user_message question]
      c_middle = List.concatMap qr_view clarifications
      r_final = (case response of
                 Just r -> [iris_message r]
                 Nothing -> []) in
  q_init ++ c_middle ++ r_final

content_box : List UserQuestion -> Html Msg
content_box qs =
  let content = List.concatMap user_question_view qs in
  div [class "content_box"] content

input_box : UserQuestion -> Html Msg
input_box uq =
  div [class "input_box"]
      [input [type' "text", placeholder "your message here",
              onInput ChangeInput, onEnter Submit, value uq.question] []]

left_pane : Dialog -> Html Msg
left_pane model =
  div [class "left_pane"] [
    content_box model.dialog,
    input_box model.current
  ]

right_pane : Html Msg
right_pane =
  div [class "right_pane"] [
    div [class "subtitle"] [text "IrisML"],
    div [class "snippet"] [text "A basic prototype, built in Elm. More will appear in the sidebar soon."]
  ]

page : Dialog -> Html Msg
page model =
  div [] [
    left_pane model,
    right_pane
  ]

-- old stuff

-- VIEW

-- button' : String -> Msg -> Html Msg
-- button' str m = button [ class "button", onClick m ] [text str]
--
-- word_span : Label -> Html Msg
-- word_span label = span [class ("label-word color-"++(toString label.label)), onClick (LabelToggle label.index)] [(text label.text)]
--
-- input_field : SearchBar -> Html Msg
-- input_field model = input [type' "text", placeholder "your command", onInput ChangeInput, value model.query] []
--
-- list_commands : List String -> Html Msg
-- list_commands c =
--   div [] (List.map (\x -> div [] [(text x)]) c)
--
-- if_classified : SearchBar -> Html Msg
-- if_classified model =
--   case model.classification of
--     Nothing -> div [] []
--     Just c ->
--       div [class "content"] [
--         h4 [] [(text "Cmd:")],
--         list_commands c.cmds,
--         h4 [] [(text "Select arguments:")],
--         -- div [class "classification"] [text "Classification:", text (toString c)],
--         div [class "seq_box"] (List.map word_span model.labels),
--         div [class "execute"] [button' "Run" Execute]
--       ]
--
-- if_run : SearchBar -> Html Msg
-- if_run model =
--   case model.output of
--     Just out ->
--       div [class "content"] [
--         div [class "out_box"] [(text out)]
--       ]
--     Nothing -> div [] []
--
-- view : SearchBar -> Html Msg
-- view model =
--     div []
--         [ div [class "input_box"] [input_field model, button' "Execute" Submit],
--           if_classified model,
--           if_run model
--         ]
--           -- div [class "query_box"] [text model.query],
--           -- ,
