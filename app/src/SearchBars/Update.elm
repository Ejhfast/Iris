module SearchBars.Update exposing (..)

import SearchBars.Messages exposing (Msg(..))
import SearchBars.Models exposing (SearchBar, Label, Classification)
import SearchBars.Commands exposing (post_classify, post_execute)
import Random
import List
import Array
import String
import Http
import Debug


flip_if_match : Int -> Maybe Classification -> Label -> Label
flip_if_match idx class clabel =
  let m = (case class of
    Just c -> c.args + 1
    Nothing -> 1) in
  case (clabel.index == idx, clabel.label) of
      (True, i) -> {clabel | label = (i + 1) % m }
      (_, _) -> clabel

make_labels : String -> List Label
make_labels s =
  let words = String.split " " s in
  List.indexedMap (\i x -> {index = i, text = x, label = 0}) words

-- UPDATE

update : Msg -> SearchBar -> ( SearchBar, Cmd Msg )
update msg model =
    case msg of
        ChangeInput input ->
            let labels = make_labels input in
            ({ model | query = input, labels = labels, classification = Nothing, output = Nothing }, Cmd.none)
        LabelToggle w ->
            let match_w = flip_if_match w model.classification
                new_labels = List.map match_w model.labels in
            ({ model | labels = new_labels }, Cmd.none)
        Submit ->
            (model, post_classify model.query)
        Execute ->
            (model, post_execute model)
        ClassifyFail error ->
            (model, Cmd.none)
        ClassifySucc results ->
            ({model | classification = Just results, labels = results.labels}, Cmd.none)
        ExecuteFail error ->
            (model, Cmd.none)
        ExecuteSucc str ->
            ({model | output = Just str}, Cmd.none)
