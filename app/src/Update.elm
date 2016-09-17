module Update exposing (..)

import Messages exposing (Msg(..))
import Models exposing (Model, initialModel)

import SearchBars.Update


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchMsg sMsg ->
            let (updatedSearch, cmd) = SearchBars.Update.update sMsg model.search in
            ( { model | search = updatedSearch }, Cmd.map SearchMsg cmd )
        Archive ->
            ( { initialModel | history = (model.history ++ [model.search])}, Cmd.none)
        Switch searchBar ->
            ( { model | search = searchBar, history = model.history}, Cmd.none)
