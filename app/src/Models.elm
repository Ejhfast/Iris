module Models exposing (..)

import SearchBars.Models exposing (SearchBar)

-- MODEL

type alias Model =
    { search : SearchBar, history : List SearchBar }


initialModel = { search = {query = "", classification = Nothing,
                 labels = [], output = Nothing }, history = [] }
