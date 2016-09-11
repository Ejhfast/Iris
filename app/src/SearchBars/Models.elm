module SearchBars.Models exposing (..)

-- MODEL

type alias Label = {text : String, index : Int, label : Int}

type alias Classification = {cmds : List String, prob : Float, id : Int}

type alias SearchBar =
    { query : String, classification : List Classification, labels : List Label}
