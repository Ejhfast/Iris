module SearchBars.Commands exposing (..)
import SearchBars.Models exposing (Classification)
import SearchBars.Messages exposing (Msg(..))
import Http
import Json.Decode as Decode exposing ((:=))
import Task
import Json.Encode as JS
import Debug


post_classify data =
    let query_data = Http.multipart [ Http.stringData "query" data] in
    Http.post memberDecoder classify_url query_data
        |> Task.perform ClassifyFail ClassifySucc

classify_url : String
classify_url =
    "http://localhost:8000/classify"

collectionDecoder : Decode.Decoder (List Classification)
collectionDecoder =
    Decode.list memberDecoder

memberDecoder : Decode.Decoder Classification
memberDecoder =
    Decode.object4 Classification
        ("cmds" := Decode.list Decode.string)
        ("prob" := Decode.float)
        ("class" := Decode.int)
        ("args" := Decode.int)

-- execution

execute_url = "http://localhost:8000/execute"

post_execute model =
  let model_class = (case model.classification of
        Just c -> c.id
        Nothing -> -1)
      label_encode = JS.list (List.map (JS.encode 0) model.labels)
      ex_data = Http.multipart [ Http.stringData "class" (toString model_class),
                                 Http.stringData "args" (JS.encode 0 label_encode)] in
      Http.post execute_decoder execute_url ex_data
        |> Task.perform ExecuteFail ExecuteSucc

execute_decoder = ("exe" := Decode.string)
