module Models exposing (..)
import SearchBars.Models exposing (..)

-- MODEL

type alias Model =
    { dialog : Conversation }


initialModel = {dialog = { dialog = [initq],
                           current = { id = 0,
                                       messages = [  ] },
                           input = ""}}
