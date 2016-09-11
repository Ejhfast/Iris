module SearchBars.Messages exposing (..)
import SearchBars.Models exposing (Classification)
import Http

-- MESSAGES

type Msg
    = ChangeInput String
    | Submit
    | LabelToggle Int
    | ClassifyFail (Http.Error)
    | ClassifySucc (List Classification)
