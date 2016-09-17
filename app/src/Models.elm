module Models exposing (..)

import SearchBars.Models exposing (Dialog)

-- MODEL

type alias Model =
    { dialog : Dialog }


initialModel = { dialog = {dialog = [
                   {question = "this is a test", response = Just "sounds great!", clarifications = [
                      {question = "clarification?", response = Just "no problem!"}
                   ]}
                 ],
                 current = {question = "", response = Nothing, clarifications = []}} }
