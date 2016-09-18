module Models exposing (..)
import SearchBars.Models exposing (..)

-- MODEL

type alias Model =
    { dialog : Conversation }


initialModel = {dialog = { dialog = [],
                           current = { id = 0,
                                       messages = [  ] },
                           input = ""}}

-- initialModel = { dialog = {dialog = [
--                    {question = Just "this is a test", response = Just "sounds great!", clarifications = [
--                       {question = Just "clarification?", response = Just "no problem!"}
--                    ]}
--                  ],
--                  current = {question = Nothing, response = Nothing, clarifications = []},
--                  input = "" }}
