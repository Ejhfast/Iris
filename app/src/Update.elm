module Update exposing (..)

import Messages exposing (Msg(..))
import Models exposing (Model)

import SearchBars.Update


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchMsg sMsg ->
            let (updatedSearch, cmd) = SearchBars.Update.update sMsg model.search in
            ( { model | search = updatedSearch }, Cmd.map SearchMsg cmd )
