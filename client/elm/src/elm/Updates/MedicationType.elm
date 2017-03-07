module Updates.MedicationType exposing (..)

import Form exposing (Form)
import Json.Encode as JE
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))
import Task


-- LOCAL IMPORTS

import Decoders exposing (..)
import Encoders as E
import Model exposing (..)
import Models.MedicationType as MedType
import Msg exposing (..)
import Ports
import Transactions as Trans
import Types exposing (..)
import Utils as U


{-| Alias for updating medicationType functions.
-}
type alias UpdateMedicationType =
    Int
    -> (MedicationTypeTable -> MedicationTypeTable)
    -> RemoteData String (List MedicationTypeTable)
    -> RemoteData String (List MedicationTypeTable)


updateMedicationType : MedicationTypeMsg -> Model -> ( Model, Cmd Msg )
updateMedicationType msg ({ medicationTypeModel } as model) =
    case msg of
        FormMsg formMsg ->
            case ( formMsg, Form.getOutput medicationTypeModel.medicationTypeForm ) of
                ( Form.Submit, Just medicationType ) ->
                    -- If we get here, it passed valiation.
                    if medicationTypeModel.editMode == EditModeAdd then
                        updateMedicationType MedicationTypeAdd model
                    else
                        updateMedicationType MedicationTypeSave model

                _ ->
                    -- Otherwise, pass it through validation again.
                    (medicationTypeModel
                        |> MedType.setMedicationTypeForm
                            (Form.update MedType.medicationTypeValidate
                                formMsg
                                medicationTypeModel.medicationTypeForm
                            )
                        |> asMedicationTypeModelIn model
                    )
                        ! []

        SelectedRecordId id ->
            { model | medicationTypeModel = MedType.setSelectedRecordId id medicationTypeModel } ! []

        SelectedEditModeRecord mode id ->
            (medicationTypeModel
                |> MedType.setSelectedRecordId id
                |> MedType.setEditMode mode
                |> (\mtm ->
                        if mode /= EditModeTable && id /= Nothing then
                            MedType.populateSelectedTableForm mtm
                        else
                            mtm
                   )
                |> asMedicationTypeModelIn model
            )
                ! []

        MedicationTypeResponse medicationTypeTbl ->
            let
                -- Load the form as well.
                newModel =
                    medicationTypeModel
                        |> MedType.setMedicationType medicationTypeTbl
                        |> asMedicationTypeModelIn model
            in
                -- TODO: fix this. Is it right yet?
                newModel ! [ Task.perform SelectTableRecord (Task.succeed 0) ]

        MedicationTypeSave ->
            -- User saved on medicationType form.
            --
            -- This is an optimistic workflow:
            --    1. Save current rec as a transation.
            --    2. Convert form values to record format.
            --    3. Update the current rec from the form values.
            --    4. Create the command to send updated record to server.
            let
                -- 1. Encode original entity record to a string and
                --    save the original rec to transactions in exchange
                --    for a transaction id.
                ( newModel, stateId ) =
                    case getSelectedRecordAsString medicationTypeModel of
                        Just s ->
                            Trans.setState s Nothing model

                        Nothing ->
                            ( model, Nothing )

                -- 2. Convert the form values which user just created into a table record.
                mtTable =
                    medicationTypeForm2Table newModel.medicationTypeModel.medicationTypeForm stateId

                -- 3. Save form values to entity record which is the optimistic update.
                updatedMedicationTypeRecords =
                    case medicationTypeModel.selectedRecordId of
                        Just id ->
                            updateMedicationTypeById id
                                (\r ->
                                    { r
                                        | stateId = stateId
                                        , name = mtTable.name
                                        , description = mtTable.description
                                        , sortOrder = mtTable.sortOrder
                                    }
                                )
                                newModel.medicationTypeModel.medicationType

                        Nothing ->
                            newModel.medicationTypeModel.medicationType

                -- 4. Create the Cmd to send data to the server.
                newCmd =
                    Ports.medicationTypeUpdate <| E.medicationTypeToValue mtTable
            in
                ( newModel.medicationTypeModel
                    |> MedType.setMedicationType updatedMedicationTypeRecords
                    |> MedType.setEditMode EditModeView
                    |> asMedicationTypeModelIn newModel
                    |> (\m -> { m | selectedTableEditMode = EditModeView })
                , newCmd
                )

        MedicationTypeCancel ->
            let
                -- User canceled, so reset data back to what we had before.
                newModel =
                    MedType.populateSelectedTableForm medicationTypeModel
                        |> MedType.setEditMode EditModeView
                        |> asMedicationTypeModelIn model
            in
                newModel ! []

        MedicationTypeSaveResponse change ->
            let
                -- Remove the state id no matter what.
                noStateIdMedicationTypeRecords =
                    updateMedicationTypeById change.id
                        (\r -> { r | stateId = Nothing })
                        medicationTypeModel.medicationType

                updatedMedicationTypeRecords =
                    case change.success of
                        True ->
                            noStateIdMedicationTypeRecords

                        False ->
                            -- Server rejected change. Reset record back to
                            -- original and send a message to the user.
                            case
                                Trans.getState change.stateId model
                                    |> Decoders.decodeMedicationTypeRecord
                            of
                                Just r ->
                                    updateMedicationTypeById change.id
                                        (\rec ->
                                            { rec
                                                | name = r.name
                                                , description = r.description
                                                , sortOrder = r.sortOrder
                                            }
                                        )
                                        medicationTypeModel.medicationType

                                Nothing ->
                                    -- TODO: if we get here, something is really messed
                                    -- up because we can't find our original record in
                                    -- the transaction manager.
                                    noStateIdMedicationTypeRecords

                -- Save the records to the model, update the form,
                -- and remove stored state from transaction manager.
                ( newModel, _ ) =
                    medicationTypeModel
                        |> MedType.setMedicationType updatedMedicationTypeRecords
                        |> MedType.populateSelectedTableForm
                        |> asMedicationTypeModelIn model
                        |> Trans.delState change.stateId

                -- Give a message to the user upon failure.
                ( newModel2, newCmd2 ) =
                    if not change.success then
                        (if String.length change.msg == 0 then
                            "Sorry, the server rejected that change."
                         else
                            change.msg
                        )
                            |> flip U.addWarning newModel
                    else
                        ( newModel, Cmd.none )
            in
                newModel2 ! [ newCmd2 ]

        MedicationTypeDelete id ->
            -- This is an optimistic workflow.
            -- NOTE: this assumes that a delete was performed with the correct record
            -- loaded in the form.
            case id of
                Just recId ->
                    let
                        -- Save current rec as a transaction.
                        ( newModel, stateId ) =
                            case getSelectedRecordAsString medicationTypeModel of
                                Just s ->
                                    Trans.setState s Nothing model

                                Nothing ->
                                    ( model, Nothing )

                        -- Create command to send record to delete to the server.
                        newCmd2 =
                            medicationTypeForm2Table newModel.medicationTypeModel.medicationTypeForm stateId
                                |> E.medicationTypeToValue
                                |> Ports.medicationTypeDel

                        -- Delete the record from the client and return to table view.
                        newModel2 =
                            newModel.medicationTypeModel
                                |> MedType.delSelectedRecord
                                |> MedType.setSelectedRecordId Nothing
                                |> MedType.setEditMode EditModeTable
                                |> asMedicationTypeModelIn newModel

                    in
                        newModel2 ! [ newCmd2 ]

                Nothing ->
                    model ! []

        MedicationTypeDelResponse response ->
            let
                -- 1. Update the model according to success or failure.
                ( newModel1, _ ) =
                    case response.success of
                        True ->
                            -- Optimistic update, so nothing to do.
                            (model, Nothing)

                        False ->
                            -- Server rejected change. Insert record back,
                            -- select the record and populate the form.
                            -- Finally, remove transaction record.
                            case
                                Trans.getState response.stateId model
                                    |> Decoders.decodeMedicationTypeRecord
                            of
                                Just r ->
                                    addMedicationTypeTable r model
                                        |> (\m -> MedType.setSelectedRecordId (Just response.id) m.medicationTypeModel)
                                        |> MedType.populateSelectedTableForm
                                        |> MedType.setEditMode EditModeView
                                        |> asMedicationTypeModelIn model
                                        |> Trans.delState response.stateId

                                Nothing ->
                                    -- TODO: if we get here, something is really messed
                                    -- up because we can't find our original record in
                                    -- the transaction manager.
                                    (model, Nothing)

                -- Give a message to the user upon failure.
                ( newModel2, newCmd2 ) =
                    if not response.success then
                        (if String.length response.msg == 0 then
                            "Sorry, the server rejected that deletion."
                         else
                            response.msg
                        )
                            |> flip U.addWarning newModel1
                    else
                        ( newModel1, Cmd.none )
            in
                newModel2 ! [ newCmd2 ]

        MedicationTypeAdd ->
            let
                -- Get the table record from the form.
                medicationTypeRecord =
                    medicationTypeForm2Table medicationTypeModel.medicationTypeForm Nothing

                -- Determine if the sortOrder field is unique. It would be best to
                -- do this in validation instead of here if possible.
                failSortOrder =
                    case RD.toMaybe medicationTypeModel.medicationType of
                        Just recs ->
                            case
                                LE.find (\r -> r.sortOrder == medicationTypeRecord.sortOrder) recs
                            of
                                Just r ->
                                    True

                                Nothing ->
                                    False

                        Nothing ->
                            -- What should this be?
                            False

                -- Add the record to the model with a pending id and create the
                -- Cmd to send data to the server. Or give a message to the user.
                (newModel, newCmd) =
                    if not failSortOrder then
                        ( addMedicationTypeTable medicationTypeRecord model
                        , Ports.medicationTypeAdd <| E.medicationTypeToValue medicationTypeRecord
                        )
                    else
                        U.addMessage "The sort order number is not unique." model
            in
                newModel ! [ newCmd ]

        MedicationTypeAddResponse { id, pendingId, success, msg } ->
            let
                -- Update the model with the server assigned id for the record.
                ( updatedMedicationTypeRecords, ( newModel, newCmd ) ) =
                    case success of
                        True ->
                            ( updateMedicationTypeById pendingId
                                (\r -> { r | id = id })
                                medicationTypeModel.medicationType
                            , ( model, Cmd.none )
                            )

                        False ->
                            -- Give a message to the user upon failure.
                            ( medicationTypeModel.medicationType
                            , (if String.length msg == 0 then
                                "Sorry, the server rejected that addition."
                               else
                                msg
                              )
                                |> flip U.addWarning model
                            )

                -- Update the form and remove stored state from transaction manager.
                newModel2 =
                    MedType.setMedicationType updatedMedicationTypeRecords medicationTypeModel
                        |> MedType.setEditMode EditModeView
                        |> MedType.setSelectedRecordId (Just id)
                        |> MedType.populateSelectedTableForm
                        |> asMedicationTypeModelIn newModel
            in
                newModel2 ! [ newCmd ]

        FirstMedicationTypeRecord ->
            ( MedType.firstRecord medicationTypeModel
                |> asMedicationTypeModelIn model
            , Cmd.none
            )

        PrevMedicationTypeRecord ->
            ( MedType.prevRecord medicationTypeModel
                |> asMedicationTypeModelIn model
            , Cmd.none
            )

        NextMedicationTypeRecord ->
            ( MedType.nextRecord medicationTypeModel
                |> asMedicationTypeModelIn model
            , Cmd.none
            )

        LastMedicationTypeRecord ->
            ( MedType.lastRecord medicationTypeModel
                |> asMedicationTypeModelIn model
            , Cmd.none
            )


updateMedicationTypeById : UpdateMedicationType
updateMedicationTypeById id func records =
    case records of
        Success recs ->
            case LE.findIndex (\r -> r.id == id) recs of
                Just idx ->
                    updateMedicationTypeByIndex idx func records

                Nothing ->
                    records

        _ ->
            records


updateMedicationTypeByIndex : UpdateMedicationType
updateMedicationTypeByIndex idx func records =
    case records of
        Success recs ->
            case LE.updateAt idx func recs of
                Just updatedRecs ->
                    RD.succeed updatedRecs

                Nothing ->
                    records

        _ ->
            records


addMedicationTypeTable : MedicationTypeTable -> Model -> Model
addMedicationTypeTable mtTable ({ medicationTypeModel } as model) =
    medicationTypeModel
        |> MedType.setMedicationType (RD.map (\list -> list ++ [ mtTable ]) medicationTypeModel.medicationType)
        |> asMedicationTypeModelIn model


medicationTypeForm2Table : Form () MedType.MedicationTypeForm -> Maybe Int -> MedicationTypeTable
medicationTypeForm2Table mt transId =
    let
        ( f_id, f_name, f_description, f_sortOrder ) =
            ( Form.getFieldAsString "id" mt
                |> .value
                |> U.maybeStringToInt -1
            , Form.getFieldAsString "name" mt
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "description" mt
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "sortOrder" mt
                |> .value
                |> U.maybeStringToInt -1
            )
    in
        MedicationTypeTable f_id f_name f_description f_sortOrder transId


getSelectedRecordAsString : MedType.MedicationTypeModel -> Maybe String
getSelectedRecordAsString mtModel =
    case ( mtModel.medicationType, mtModel.selectedRecordId ) of
        ( Success data, Just id ) ->
            case LE.find (\r -> r.id == id) data of
                Just rec ->
                    JE.encode 0 (E.medicationTypeToValue rec) |> Just

                Nothing ->
                    Nothing

        _ ->
            Nothing