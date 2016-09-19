module SearchBars.Messages exposing (..)
import SearchBars.Models exposing (..)
import Http
import Dom

type Msg
      = ChangeInput String
      | NoOp
      | Submit
      | LoopFail (Http.Error)
      | LoopSucc (Response)
      | ScrollSucc ()
      | ScrollFail (Dom.Error)

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
