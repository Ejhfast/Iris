module Models exposing (..)

import SearchBars.Models exposing (SearchBar)

-- MODEL

type alias Model =
    { search : SearchBar }


initialModel = { search = {query = "search", classification = Nothing,
                 labels = [], output = Nothing } }
