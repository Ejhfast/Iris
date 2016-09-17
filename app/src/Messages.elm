module Messages exposing (..)
import SearchBars.Models exposing (SearchBar)

import SearchBars.Messages

-- MESSAGES

type Msg
    = SearchMsg SearchBars.Messages.Msg
    | Archive
    | Switch SearchBar
