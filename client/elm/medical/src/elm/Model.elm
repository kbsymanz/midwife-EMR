module Model
    exposing
        ( initialModel
        , Model
        , Page(..)
        , PageState(..)
        )

import Dict exposing (Dict)
import Time exposing (Time)
import Window


-- LOCAL IMPORTS --

import Data.Labor exposing (LaborRecord)
import Data.Patient exposing (PatientRecord)
import Data.Pregnancy exposing (getPregId, PregnancyRecord, PregnancyId(..))
import Data.Session as Session exposing (Session)
import Data.SiteMessage exposing (SiteKeyValue(..))
import Page.Errored as Errored exposing (PageLoadError, view)
import Page.LaborDelIpp as PageLaborDelIpp
import Processing exposing (ProcessStore)


type Page
    = Blank
    | NotFound
    | Errored PageLoadError
    | LaborDelIpp PageLaborDelIpp.Model


type PageState
    = Loaded Page
    | TransitioningFrom Page


type alias Model =
    { browserSupportsDate : Bool
    , currTime : Time
    , currPregId : Maybe PregnancyId
    , pageState : PageState
    , session : Session
    , processStore : ProcessStore
    , window : Maybe Window.Size
    , siteMessages : Dict String SiteKeyValue
    , laborRecord : Maybe (List LaborRecord)
    , patientRecord : Maybe PatientRecord
    , pregnancyRecord : Maybe PregnancyRecord
    }


initialModel : Bool -> Maybe PregnancyId -> Time -> Model
initialModel browserSupportsDate pregId time =
    { browserSupportsDate = browserSupportsDate
    , currTime = time
    , currPregId = pregId
    , pageState = Loaded <| initialPage browserSupportsDate pregId
    , session = { user = Nothing }
    , processStore = Processing.processStoreInit
    , window = Nothing
    , siteMessages = Dict.empty
    , laborRecord = Nothing
    , patientRecord = Nothing
    , pregnancyRecord = Nothing
    }


initialPage : Bool -> Maybe PregnancyId -> Page
initialPage browserSupportsDate pregId =
    case pregId of
        Just pid ->
            LaborDelIpp
                <| PageLaborDelIpp.buildModel browserSupportsDate
                      0
                      pid
                      Nothing
                      Nothing
                      Nothing

        Nothing ->
            Blank