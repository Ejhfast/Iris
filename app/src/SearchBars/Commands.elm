module SearchBars.Commands exposing (..)
import SearchBars.Models exposing (..)
import SearchBars.Messages exposing (Msg(..))
import Http
import Json.Decode as Decode exposing ((:=))
import Task
import Json.Encode as JS
import Debug
import Dom.Scroll

update_scroll = Dom.Scroll.toBottom "message_pane" |> Task.perform ScrollFail ScrollSucc

encode_message : Message -> JS.Value
encode_message m =
  JS.object [("origin", JS.string m.origin), ("content", JS.string m.content), ("kind", JS.string m.kind)]


encode_question : Question -> JS.Value
encode_question m =
   JS.object [("id", JS.int m.id), ("messages", JS.list (List.map encode_message m.messages))]

loop_url = "http://localhost:8000/loop"

decode_response : Decode.Decoder Response
decode_response = Decode.object2 Response ("action" := Decode.string) ("content" := Decode.list Decode.string)

post_loop question =
    let question_data = encode_question question
        data = Http.multipart [ Http.stringData "question" (JS.encode 0 question_data)] in
    Http.post decode_response loop_url data
        |> Task.perform LoopFail LoopSucc

-- encoders

encode_clarification : Clarification -> JS.Value
encode_clarification {question, response} =
  JS.object [("question", encode_maybe_string question), ("response", encode_maybe_string response)]

encode_clarifications : List Clarification -> JS.Value
encode_clarifications c_lst =
  JS.list (List.map encode_clarification c_lst)

encode_maybe_string : Maybe String -> JS.Value
encode_maybe_string ms =
  case ms of
    Just s -> JS.string s
    Nothing -> JS.null

-- encode_question : UserQuestion -> JS.Value
-- encode_question {question, response, clarifications} =
--   JS.object [("question", encode_maybe_string question),
--              ("response", encode_maybe_string response),
--              ("clarifications", encode_clarifications clarifications)]

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
    ("question" := nullOr Decode.string)
    ("response" := nullOr Decode.string)

question_decoder : Decode.Decoder UserQuestion
question_decoder =
  Decode.object3 UserQuestion
    ("question" := nullOr Decode.string)
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
