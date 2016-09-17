module SearchBars.Update exposing (..)

import SearchBars.Messages exposing (Msg(..))
import SearchBars.Models exposing (Dialog, UserQuestion, Clarification, emptyUQ)
import SearchBars.Commands exposing (..)
import Random
import List
import Array
import String
import Http
import Debug


update : Msg -> Dialog -> (Dialog, Cmd Msg)
update msg model =
  case msg of
    ChangeInput s ->
      let current = model.current
          new_q = {current | question = s} in
      ({ model | current = new_q }, Cmd.none)
    NoOp -> (model, Cmd.none)
    Submit ->
      let curr_dialog = model.dialog
          curr_question = model.current
          fake_out = { curr_question | response = Just "got it :p" } in
      ({ model | current = emptyUQ, dialog = (curr_dialog ++ [curr_question])}, Cmd.none)

-- -- UPDATE
--
-- update1 : DMsg -> SearchBar -> ( SearchBar, Cmd Msg )
-- update1 msg model =
--     case msg of
--         ChangeInput input ->
--             let labels = make_labels input in
--             ({ model | query = input, labels = labels, classification = Nothing, output = Nothing }, Cmd.none)
--         LabelToggle w ->
--             let match_w = flip_if_match w model.classification
--                 new_labels = List.map match_w model.labels in
--             ({ model | labels = new_labels }, Cmd.none)
--         Submit ->
--             (model, post_classify model.query)
--         Execute ->
--             (model, post_execute model)
--         ClassifyFail error ->
--             (model, Cmd.none)
--         ClassifySucc results ->
--             ({model | classification = Just results, labels = results.labels}, Cmd.none)
--         ExecuteFail error ->
--             (model, Cmd.none)
--         ExecuteSucc str ->
--             ({model | output = Just str}, Cmd.none)
