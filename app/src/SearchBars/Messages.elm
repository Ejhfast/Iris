module SearchBars.Messages exposing (..)
import SearchBars.Models exposing (Classification)
import Http

-- MESSAGES

type Msg
    = ChangeInput String
    | Submit
    | Execute
    | LabelToggle Int
    | ClassifyFail (Http.Error)
    | ClassifySucc (Classification)
    | ExecuteFail (Http.Error)
    | ExecuteSucc (String)
