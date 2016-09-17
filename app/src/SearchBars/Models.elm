module SearchBars.Models exposing (..)

-- MODEL

type alias Clarification = {question : String, response : Maybe String}

type alias UserQuestion = {question : String, response : Maybe String, clarifications : List Clarification}

type alias Dialog = {dialog : List UserQuestion, current : UserQuestion}

emptyUQ = {question = "", response = Nothing, clarifications = []}
