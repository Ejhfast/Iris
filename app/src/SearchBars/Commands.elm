module SearchBars.Commands exposing (..)
import SearchBars.Models exposing (Classification)
import SearchBars.Messages exposing (Msg(..))
import Http
import Json.Decode as Decode exposing ((:=))
import Task
import Json.Encode as JS
import Debug



-- post_classify : Http.Body -> Cmd Msg
post_classify data =
    let query_data = Http.multipart [ Http.stringData "query" data] in
    Http.post collectionDecoder classify_url query_data
        |> Task.perform ClassifyFail ClassifySucc

classify_url : String
classify_url =
    "http://localhost:8000/classify"

collectionDecoder : Decode.Decoder (List Classification)
collectionDecoder =
    Decode.list memberDecoder

memberDecoder : Decode.Decoder Classification
memberDecoder =
    Decode.object3 Classification
        ("cmds" := Decode.list Decode.string)
        ("prob" := Decode.float)
        ("class" := Decode.int)
