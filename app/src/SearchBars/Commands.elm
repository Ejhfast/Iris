module SearchBars.Commands exposing (..)
import SearchBars.Models exposing (Clarification, UserQuestion)
import SearchBars.Messages exposing (Msg(..))
import Http
import Json.Decode as Decode exposing ((:=))
import Task
import Json.Encode as JS
import Debug


-- encoders

encode_clarification : Clarification -> JS.Value
encode_clarification {question, response} =
  JS.object [("question", JS.string question), ("response", encode_maybe_string response)]

encode_clarifications : List Clarification -> JS.Value
encode_clarifications c_lst =
  JS.list (List.map encode_clarification c_lst)

encode_maybe_string : Maybe String -> JS.Value
encode_maybe_string ms =
  case ms of
    Just s -> JS.string s
    Nothing -> JS.null

encode_question : UserQuestion -> JS.Value
encode_question {question, response, clarifications} =
  JS.object [("question", JS.string question),
             ("response", encode_maybe_string response),
             ("clarifications", encode_clarifications clarifications)]

--decoders

nullOr : Decode.Decoder a -> Decode.Decoder (Maybe a)
nullOr decoder =
    Decode.oneOf
      [ Decode.null Nothing
      , Decode.map Just decoder
      ]

clarification_decoder : Decode.Decoder Clarification
clarification_decoder =
  Decode.object2 Clarification
    ("question" := Decode.string)
    ("response" := nullOr Decode.string)

question_decoder : Decode.Decoder UserQuestion
question_decoder =
  Decode.object3 UserQuestion
    ("question" := Decode.string)
    ("response" := nullOr Decode.string)
    ("clarifications" := Decode.list clarification_decoder)

-- -- old commands
--
-- post_classify data =
--     let query_data = Http.multipart [ Http.stringData "query" data] in
--     Http.post memberDecoder classify_url query_data
--         |> Task.perform ClassifyFail ClassifySucc
--
-- classify_url : String
-- classify_url =
--     "http://localhost:8000/classify"
--
-- collectionDecoder : Decode.Decoder (List Classification)
-- collectionDecoder =
--     Decode.list memberDecoder
--
-- label_decoder = Decode.object3 Label ("text" := Decode.string) ("index" := Decode.int) ("label" := Decode.int)
--
-- memberDecoder : Decode.Decoder Classification
-- memberDecoder =
--     Decode.object5 Classification
--         ("cmds" := Decode.list Decode.string)
--         ("prob" := Decode.float)
--         ("class" := Decode.int)
--         ("args" := Decode.int)
--         ("labels" := Decode.list label_decoder)
--
-- -- execution
--
-- execute_url = "http://localhost:8000/execute"
--
-- label_to_value : Label -> JS.Value
-- label_to_value {text,index,label} =
--     JS.object [("text", JS.string text), ("index", JS.int index), ("label", JS.int label)]
--
-- post_execute model =
--   let model_class = (case model.classification of
--         Just c -> c.id
--         Nothing -> -1)
--       label_encode = JS.list (List.map label_to_value model.labels)
--       ex_data = Http.multipart [ Http.stringData "class" (toString model_class),
--                                  Http.stringData "args" (JS.encode 0 label_encode)] in
--       Http.post execute_decoder execute_url ex_data
--         |> Task.perform ExecuteFail ExecuteSucc
--
-- execute_decoder = ("result" := Decode.string)
