module Model
    exposing
        ( Model
        , Page(..)
        , PageState(..)
        , initialModel
        )

import Data.Baby exposing (BabyRecord)
import Data.DataCache exposing (DataCache)
import Data.Labor exposing (LaborRecord)
import Data.LaborStage1 exposing (LaborStage1Record)
import Data.Patient exposing (PatientRecord)
import Data.Pregnancy exposing (PregnancyId(..), PregnancyRecord, getPregId)
import Data.SelectData exposing (SelectDataRecord)
import Data.Session as Session exposing (Session)
import Data.SiteMessage exposing (SiteKeyValue(..))
import Data.TableMeta
    exposing
        ( initializeTableMetaCollection
        , TableMetaCollection
        )
import Data.Toast exposing (ToastRecord, ToastType)
import Data.User as DU
import Date exposing (Date)
import Dict exposing (Dict)
import Page.Admitting as PageAdmitting
import Page.BirthCert as PageBirthCert
import Page.ContPP as PageContPP
import Page.Errored as Errored exposing (PageLoadError, view)
import Page.LaborDelIpp as PageLaborDelIpp
import Page.Postpartum as PagePostpartum
import Processing exposing (ProcessStore)
import Time exposing (Time)
import Window


type Page
    = Blank
    | NotFound
    | Errored PageLoadError
    | Admitting PageAdmitting.Model
    | ContPP PageContPP.Model
    | LaborDelIpp PageLaborDelIpp.Model
    | Postpartum PagePostpartum.Model
    | BirthCert PageBirthCert.Model


type PageState
    = Loaded Page
    | TransitioningFrom Page


type alias Model =
    { browserSupportsDate : Bool
    , currTime : Time
    , currPregId : Maybe PregnancyId
    , pageState : PageState
    , session : Session
    , toast : Maybe ToastRecord
    , processStore : ProcessStore
    , dataCache : Dict String DataCache
    , window : Maybe Window.Size
    , dialogActive : Bool
    , siteMessages : Dict String SiteKeyValue
    , tableMetaCollection : TableMetaCollection
    , users : Dict Int DU.User
    , userId : Int
    , supervisorId : Maybe Int
    }


initialModel : Bool -> Maybe PregnancyId -> Time -> Dict Int DU.User -> Int -> Maybe Int -> Model
initialModel browserSupportsDate pregId time users userId supervisorId =
    let
        ( page, newStore ) =
            initialPage browserSupportsDate Processing.processStoreInit pregId
    in
    { browserSupportsDate = browserSupportsDate
    , currTime = time
    , currPregId = pregId
    , pageState = Loaded page
    , session = { user = Nothing, serverTouch = 0.0, clientTouch = 0.0 }
    , toast = Nothing
    , processStore = newStore
    , window = Nothing
    , dialogActive = False
    , dataCache = Dict.empty
    , siteMessages = Dict.empty
    , tableMetaCollection = initializeTableMetaCollection
    , users = users
    , userId = userId
    , supervisorId = supervisorId
    }


initialPage : Bool -> ProcessStore -> Maybe PregnancyId -> ( Page, ProcessStore )
initialPage browserSupportsDate store pregId =
    case pregId of
        Just pid ->
            let
                ( subModel, newStore, newCmd ) =
                    PageLaborDelIpp.buildModel browserSupportsDate
                        0
                        store
                        pid
                        Nothing
                        Nothing
                        Nothing
            in
            ( LaborDelIpp subModel, newStore )

        Nothing ->
            ( Blank, store )


