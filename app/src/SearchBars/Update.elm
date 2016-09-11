module SearchBars.Update exposing (..)

import SearchBars.Messages exposing (Msg(..))
import SearchBars.Models exposing (SearchBar, Label, Classification)
import SearchBars.Commands exposing (post_classify)
import Random
import List
import Array
import String
import Http
import Debug

classify : List Classification
classify = [{id = -1, cmds = [], prob = 0}]
  -- let choices = ["open the door", "turn on the lights", "run away"]
  --     seed = Random.initialSeed 0
  --     generator = Random.int 0 ((List.length choices) - 1)
  --     random_choice = fst (Random.step generator seed)
  --     element = Array.get random_choice (Array.fromList choices)
  -- in
  -- case element of
  --     Just el -> el
  --     Nothing -> "Nothing"

flip_if_match : Int -> Label -> Label
flip_if_match idx clabel =
  case (clabel.index == idx, clabel.label) of
      (True, 1) -> {clabel | label = 0}
      (True, 0) -> {clabel | label = 1}
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
            ({ model | query = input, labels = labels, classification = [] }, Cmd.none )
        LabelToggle w ->
            let match_w = flip_if_match w
                new_labels = List.map match_w model.labels in
            ({ model | labels = new_labels }, Cmd.none)
        Submit ->
            (model, post_classify model.query)
        ClassifyFail error ->
            (model, Cmd.none)
        ClassifySucc results ->
            let x = Debug.log("succ") in
            ({model | classification = results}, Cmd.none)
