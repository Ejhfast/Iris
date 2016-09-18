module SearchBars.Models exposing (..)

-- MODEL

type alias Clarification = {question : Maybe String, response : Maybe String}

type alias UserQuestion = {question : Maybe String, response : Maybe String, clarifications : List Clarification}

type alias Dialog = {dialog : List UserQuestion, current : UserQuestion, input : String}

emptyUQ = {question = Nothing, response = Nothing, clarifications = []}

type alias Message = { origin : String, content : String }
type alias Question = { id : Int, messages : List Message }
type alias Conversation = {dialog : List Question, current : Question, input : String}

type alias Response = { action : String, content : String }
