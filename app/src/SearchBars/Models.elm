module SearchBars.Models exposing (..)

-- MODEL

type alias Message = { origin : String, content : String, kind: String }
type alias Question = { id : Int, messages : List Message }
type alias Conversation = {dialog : List Question, current : Question, input : String}

type alias Response = { action : String, content : List String }

initq = { id = 0, messages = [{origin = "iris", content = "What would you like to do today?", kind = "init" }]}
