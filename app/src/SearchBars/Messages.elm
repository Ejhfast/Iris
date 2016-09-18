module SearchBars.Messages exposing (..)
import SearchBars.Models exposing (..)
import Http

type Msg
      = ChangeInput String
      | NoOp
      | Submit
      | LoopFail (Http.Error)
      | LoopSucc (Response)

-- MESSAGES

-- type DMsg
--     = ChangeInput String
--     | Submit
--     | Execute
--     | LabelToggle Int
--     | ClassifyFail (Http.Error)
--     | ClassifySucc (Classification)
--     | ExecuteFail (Http.Error)
--     | ExecuteSucc (String)
