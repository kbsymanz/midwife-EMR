module Types
    exposing
        ( AddResponse
        , ChangeResponse
        , DelResponse
        , EditMode(..)
        , emptySystemMessage
        , ErrorCode(..)
        , EventTypeTable
        , LabSuiteTable
        , LabTestTable
        , LabTestValueTable
        , MedicationTypeTable
        , PregnoteTypeTable
        , RiskCodeTable
        , RoleTable
        , SelectQuery
        , SystemMessage
        , Table(..)
        , TableMetaInfo
        , UserTable
        , VaccinationTypeTable
        )

import RemoteData as RD exposing (RemoteData(..))


type Table
    = Unknown
    | CustomField
    | CustomFieldType
    | Event
    | EventType
    | HealthTeaching
    | LabSuite
    | LabTest
    | LabTestResult
    | LabTestValue
    | Medication
    | MedicationType
    | Patient
    | Pregnancy
    | PregnancyHistory
    | Pregnote
    | PregnoteType
    | PrenatalExam
    | Priority
    | Risk
    | RiskCode
    | Referral
    | RoFieldsByRole
    | Role
    | Schedule
    | SelectData
    | User
    | Vaccination
    | VaccinationType


type EditMode
    = EditModeAdd
    | EditModeEdit
    | EditModeView
    | EditModeTable


type ErrorCode
    = NoErrorCode
    | UnknownErrorCode
    | SessionExpiredErrorCode
    | SqlErrorCode


type alias SystemMessage =
    { id : String
    , msgType : String
    , updatedAt : Int
    , workerId : String
    , processedBy : List String
    , systemLog : String
    }


{-| Used when there is an error decoding from JS.
-}
emptySystemMessage : SystemMessage
emptySystemMessage =
    { id = "ERROR"
    , msgType = ""
    , updatedAt = 0
    , workerId = ""
    , processedBy = []
    , systemLog = ""
    }


type alias SelectQuery =
    { table : Table
    , id : Maybe Int
    , patient_id : Maybe Int
    , pregnancy_id : Maybe Int
    }


type alias TableMetaInfo =
    { table : Table
    , name : String
    , desc : String
    }


type alias UserTable =
    { id : Int
    , username : String
    , firstname : String
    , lastname : String
    , password : String
    , email : String
    , lang : String
    , shortName : String
    , displayName : String
    , status : Bool
    , note : String
    , isCurrentTeacher : Bool
    , roleId : Int
    }


type alias RoleTable =
    { id : Int
    , name : String
    , description : String
    }


type alias EventTypeTable =
    { id : Int
    , name : String
    , description : String
    }


type alias LabSuiteTable =
    { id : Int
    , name : String
    , description : String
    , category : String
    }


type alias LabTestTable =
    { id : Int
    , name : String
    , abbrev : String
    , normal : String
    , unit : String
    , minRangeDecimal : Float
    , maxRangeDecimal : Float
    , minRangeInteger : Int
    , maxRangeInteger : Int
    , isRange : Bool
    , isText : Bool
    , labSuite_id : Int
    }


type alias LabTestValueTable =
    { id : Int
    , value : String
    , labTest_id : Int
    }


type alias MedicationTypeTable =
    { id : Int
    , name : String
    , description : String
    , sortOrder : Int
    , stateId : Maybe Int
    }


type alias PregnoteTypeTable =
    { id : Int
    , name : String
    , description : String
    }


type alias RiskCodeTable =
    { id : Int
    , name : String
    , riskType : String
    , description : String
    }


type alias VaccinationTypeTable =
    { id : Int
    , name : String
    , description : String
    , sortOrder : Int
    }


type alias ChangeResponse =
    { id : Int
    , table : Table
    , stateId : Int
    , success : Bool
    , errorCode : ErrorCode
    , msg : String
    }


type alias AddResponse =
    { id : Int
    , table : Table
    , pendingId : Int
    , success : Bool
    , errorCode : ErrorCode
    , msg : String
    }


type alias DelResponse =
    { id : Int
    , table : Table
    , stateId : Int
    , success : Bool
    , errorCode : ErrorCode
    , msg : String
    }
