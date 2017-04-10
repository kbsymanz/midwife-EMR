module Msg
    exposing
        ( Msg(..)
        , AdhocResponseMessage(..)
        , MedicationTypeMsg(..)
        , RoleMsg(..)
        , UserMsg(..)
        )

import Form exposing (Form)
import Material
import Material.Snackbar as Snackbar
import Navigation exposing (Location)
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Model exposing (..)
import Types exposing (..)


type Msg
    = AddSelectedTable
    | AdhocResponseMessages AdhocResponseMessage
    | CancelSelectedTable
    | CreateResponseMsg (Maybe CreateResponse)
    | DeleteResponseMsg (Maybe DeleteResponse)
    | EditSelectedTable
    | EventTypeResponse (RemoteData String (List EventTypeRecord))
    | FirstRecord
    | LabSuiteResponse (RemoteData String (List LabSuiteRecord))
    | LabTestResponse (RemoteData String (List LabTestRecord))
    | LabTestValueResponse (RemoteData String (List LabTestValueRecord))
    | LastRecord
    | Login
    | LoginFormMsg Form.Msg
    | Mdl (Material.Msg Msg)
    | MedicationTypeMessages MedicationTypeMsg
    | NewSystemMessage SystemMessage
    | NextRecord
    | NoOp
    | PregnoteTypeResponse (RemoteData String (List PregnoteTypeRecord))
    | PreviousRecord
    | RequestUserProfile
    | RiskCodeResponse (RemoteData String (List RiskCodeRecord))
    | RoleMessages RoleMsg
    | SaveSelectedTable
    | SelectedTableEditMode EditMode (Maybe Int)
    | SelectQueryMsg SelectQuery
    | SelectQueryResponseMsg (RemoteData String SelectQueryResponse)
    | SelectQuerySelectTable SelectQuery
    | SelectTableRecord Int
    | SelectPage Page
    | SessionExpired
    | Snackbar (Snackbar.Msg String)
    | UpdateResponseMsg (Maybe UpdateResponse)
    | UrlChange Location
    | UserMessages UserMsg
    | VaccinationTypeResponse (RemoteData String (List VaccinationTypeRecord))


type MedicationTypeMsg
    = CancelEditMedicationType
    | CreateMedicationType
    | CreateResponseMedicationType CreateResponse
    | DeleteMedicationType (Maybe Int)
    | DeleteResponseMedicationType DeleteResponse
    | FirstMedicationType
    | FormMsgMedicationType Form.Msg
    | LastMedicationType
    | NextMedicationType
    | PrevMedicationType
    | ReadResponseMedicationType (RemoteData String (List MedicationTypeRecord)) (Maybe SelectQuery)
    | SelectedRecordEditModeMedicationType EditMode (Maybe Int)
    | SelectedRecordMedicationType (Maybe Int)
    | UpdateMedicationType
    | UpdateResponseMedicationType UpdateResponse

type AdhocResponseMessage
    = AdhocUnknownMsg String
    | AdhocLoginResponseMsg AuthResponse
    | AdhocUserProfileResponseMsg AuthResponse

type RoleMsg
    = ReadResponseRole (RemoteData String (List RoleRecord)) (Maybe SelectQuery)

type UserMsg
    = CancelEditUser
    | CreateResponseUser CreateResponse
    | CreateUser
    | CreateUserForm
    | DeleteResponseUser DeleteResponse
    | DeleteUser (Maybe Int)
    | FirstUser
    | FormMsgUser Form.Msg
    | FormMsgUserSearch Form.Msg
    | LastUser
    | NextUser
    | PrevUser
    | ReadResponseUser (RemoteData String (List UserRecord)) (Maybe SelectQuery)
    | SelectedRecordEditModeUser EditMode (Maybe Int)
    | UpdateResponseUser UpdateResponse
    | UpdateUser
