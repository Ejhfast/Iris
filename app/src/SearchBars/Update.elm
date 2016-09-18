module SearchBars.Update exposing (..)

import SearchBars.Messages exposing (Msg(..))
import SearchBars.Models exposing (..)
import SearchBars.Commands exposing (..)
import Random
import List
import Array
import String
import Http
import Debug


-- update_question : String -> UserQuestion -> UserQuestion
-- update_question s q =
--   case q.question of
--     Just eq ->
--       let curr_clar = q.clarifications
--           new_info = {question = Nothing, response = Just s} in
--       { q | clarifications = (curr_clar ++ [new_info])}
--     Nothing ->
--       {q | question = Just s}

update_current_messages : Question -> Message -> Question
update_current_messages q m =
  let curr_messages = q.messages in
  { q | messages = (curr_messages ++ [m])}

update : Msg -> Conversation -> (Conversation, Cmd Msg)
update msg model =
  case msg of
    ChangeInput s ->
      ({ model | input = s }, Cmd.none)
    NoOp -> (model, Cmd.none)
    LoopFail error -> (model, Cmd.none)
    LoopSucc response ->
     let iris_message = { origin = "iris", content = response.content, kind = response.action }
         update_current = update_current_messages model.current iris_message in
     case response.action of
       "succeed" ->
         let new_question = {id = model.current.id + 1, messages = []}
             curr_dialog = model.dialog in
         ( {model | current = new_question, dialog = (curr_dialog ++ [update_current]) }, Cmd.none )
       _ ->
         ( { model | current = update_current }, Cmd.none)
    Submit ->
      let curr_dialog = model.dialog
          new_message = { origin = "user", content = model.input, kind = "question" }
          new_current = update_current_messages model.current new_message in
      ({ model | current = new_current, input = ""}, post_loop new_current)

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
