Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

<RoutePrefix("api/entitymeasures")> _
Public Class EntityProjectMeasureController
    Inherits ApiController

    <HttpGet> _
    <Route("")> _
    Public Function GetEntityProjectMeasuresByEntityIdent(Optional ByVal measureLocationIdent As Int64 = 0, _
                                                          Optional ByVal projectIdent As Int64 = 0, _
                                                          Optional ByVal resourceIdent As Int64 = 0, _
                                                          Optional ByVal organizationIdent As Int64 = 0)

        Dim slParameters As SortedList = Nothing
        Dim dsResults As DataSet = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim strSP As String = ""
        Dim records As New List(Of EntityProjectMeasure)

        Try

            slParameters = New SortedList
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("MeasureLocationIdent", measureLocationIdent)

            If (measureLocationIdent = Helper.enmMeasureLocation.Dashboard Or _
                measureLocationIdent = 0) Then

                strSP = "uspGetEntityProjectMeasureByEntityIdent"

            ElseIf measureLocationIdent = Helper.enmMeasureLocation.ProjectOverview Then

                slParameters.Add("EntityProjectIdent", projectIdent)

                strSP = "uspGetEntityProjectMeasureByEntityProjectIdent"

            ElseIf measureLocationIdent = Helper.enmMeasureLocation.ResourceProfile Then

                slParameters.Add("ResourceIdent", resourceIdent)

                strSP = "uspGetEntityProjectMeasureByResourceIdent"

            ElseIf measureLocationIdent = Helper.enmMeasureLocation.OrganizationStructure Then

                slParameters.Add("OrganizationIdent", organizationIdent)

                strSP = "uspGetEntityProjectMeasureByOrganizationIdent"

            End If

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, strSP, slParameters, True, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                     dsResults.Tables.Count = 4 AndAlso
                     dsResults.Tables(0).Rows.Count > 0 Then

                    For Each drRow In dsResults.Tables(0).Rows

                        records.Add(
                            New EntityProjectMeasure() With {
                                .Ident = drRow.Item("Ident"),
                                .EntityIdent = drRow.Item("EntityIdent"),
                                .MeasureName = drRow.Item("Name1"),
                                .MeasureDescription = drRow.Item("Desc1"),
                                .EntitySearchIdent = drRow("EntitySearchIdent"),
                                .DataTypeIdent = drRow.Item("EntitySearchDataTypeIdent"),
                                .HasDenominator = drRow.Item("HasDenominator"),
                                .HasTargetValue = drRow.Item("HasTargetValue"),
                                .IsAverage = drRow.Item("IsAverage"),
                                .IsPercentage = drRow.Item("IsPercentage"),
                                .MeasureTypeIdent = drRow.Item("MeasureTypeIdent"),
                                .MeasureType = drRow.Item("MeasureType"),
                                .EntityProject1Ident = drRow.Item("EntityProject1Ident"),
                                .EntityProject1Name = drRow.Item("EntityProject1Name"),
                                .Question1EntityProjectRequirementIdent = drRow.Item("Question1EntityProjectRequirementIdent"),
                                .Question1RequirementTypeIdent = drRow.Item("Question1RequirementTypeIdent"),
                                .EntityProject2Ident = drRow.Item("EntityProject2Ident"),
                                .EntityProject2Name = drRow.Item("EntityProject2Name"),
                                .Question2EntityProjectRequirementIdent = drRow.Item("Question2EntityProjectRequirementIdent"),
                                .TargetValue = drRow.item("TargetValue"),
                                .LastRecalculateDate = drRow.Item("LastRecalculateDate"),
                                .Question1Value = drRow.Item("Question1Value"),
                                .Question2Value = drRow.Item("Question2Value"),
                                .TotalResourcesComplete = drRow.Item("TotalResourcesComplete"),
                                .TotalResourcesAvailable = drRow.Item("TotalResourcesAvailable"),
                                .Ranges = GetEntityProjectMeasureRangesByEntityProjectMeasureIdent(drRow.Item("Ident"), dsResults.Tables(1)),
                                .Location = GetEntityProjectMeasureLocationsByEntityProjectMeasureIdent(drRow("Ident"), dsResults.Tables(2)),
                                .Values = GetEntityProjectMeasureValuesByEntityProjectMeasureIdent(drRow("Ident"), dsResults.Tables(3))
                            }
                        )
                    Next

                End If

                Return Request.CreateResponse(HttpStatusCode.OK, records)

            End If

            'No user input, something went wrong at the server level
            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsResults)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(records)

        End Try

    End Function

    <System.Web.Http.HttpPost> _
    <Route("")> _
    Public Function AddEntityProjectMeasure(objMeasure As EntityProjectMeasure)

        Return AddEditEntityProjectMeasure(objMeasure, 0)

    End Function

    <System.Web.Http.HttpPut> _
    <Route("{ident}")> _
    Public Function AddEditEntityProjectMeasure(objMeasure As EntityProjectMeasure, Optional ByVal ident As Int64 = 0)

        Dim cmdCommand As System.Data.SqlClient.SqlCommand = Nothing
        Dim daDataAdapter As System.Data.SqlClient.SqlDataAdapter = Nothing
        Dim cnnConnection As System.Data.SqlClient.SqlConnection = Nothing

        Try

            If Not objMeasure Is Nothing Then

                cnnConnection = New System.Data.SqlClient.SqlConnection
                cmdCommand = New System.Data.SqlClient.SqlCommand
                daDataAdapter = New SqlClient.SqlDataAdapter

                If cnnConnection.State = ConnectionState.Closed Then

                    cnnConnection.ConnectionString = ConfigurationManager.ConnectionStrings("DatabaseConnectionString").ConnectionString
                    cnnConnection.Open()

                End If

                With cmdCommand

                    .Connection = cnnConnection
                    .CommandType = CommandType.StoredProcedure
                    .CommandTimeout = cnnConnection.ConnectionTimeout
                    .CommandText = "uspAddEditEntityProjectMeasure"
                    .Parameters.Add("@bntIdent", SqlDbType.BigInt).Value = ident
                    .Parameters.Add("@bntASUserIdent", SqlDbType.BigInt).Value = Helper.AddEditASUserIdent
                    .Parameters.Add("@bntEntityIdent", SqlDbType.BigInt).Value = Helper.ASUserIdent
                    .Parameters.Add("@nvrName1", SqlDbType.NVarChar, -1).Value = objMeasure.MeasureName
                    .Parameters.Add("@nvrDesc1", SqlDbType.NVarChar, -1).Value = objMeasure.MeasureDescription
                    .Parameters.Add("@bntEntitySearchIdent", SqlDbType.BigInt).Value = objMeasure.EntitySearchIdent
                    .Parameters.Add("@bntMeasureTypeIdent", SqlDbType.BigInt).Value = objMeasure.MeasureTypeIdent
                    .Parameters.Add("@bntQuestion1EntityProjectRequirementIdent", SqlDbType.BigInt).Value = objMeasure.Question1EntityProjectRequirementIdent
                    .Parameters.Add("@bntQuestion2EntityProjectRequirementIdent", SqlDbType.BigInt).Value = objMeasure.Question2EntityProjectRequirementIdent
                    .Parameters.Add("@decTargetValue", SqlDbType.Decimal).Value = objMeasure.TargetValue
                    .Parameters.Add("@tblRanges", SqlDbType.Structured).Value = CreateEntityProjectMeasureRangeDataTableForSQLParameter(objMeasure.Ranges)
                    .Parameters.Add("@tblLocation", SqlDbType.Structured).Value = CreateEntityProjectMeasureLocationDataTableForSQLParameter(objMeasure.Location)

                    ident = CType(.ExecuteScalar(), Int64)

                End With 'With cmdCommand

                If ident > 0 Then

                    Return Request.CreateResponse(HttpStatusCode.OK, ident)

                Else

                    Return Request.CreateResponse(HttpStatusCode.BadRequest)

                End If

            End If 'If Not searchObject Is Nothing

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            If Not cmdCommand Is Nothing Then

                cmdCommand.Dispose()

            End If

            If Not daDataAdapter Is Nothing Then

                daDataAdapter.Dispose()

            End If

            If Not cnnConnection Is Nothing Then

                If cnnConnection.State = ConnectionState.Open Then

                    cnnConnection.Close()

                End If

                cnnConnection.Dispose()

            End If

            Helper.CleanUp(cmdCommand)
            Helper.CleanUp(daDataAdapter)
            Helper.CleanUp(cnnConnection)

        End Try

    End Function

    <System.Web.Http.HttpDelete> _
    <Route("{ident}")> _
    Public Function DeleteEntityProjectMeasure(ident As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("Ident", ident)
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.ExecuteNonQuery(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspDeleteEntityProjectMeasureByIdent", slParameters, dsMessage) Then

                Return Request.CreateResponse(HttpStatusCode.OK)

            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

    <HttpGet> _
    <Route("{ident}/organizations")> _
    Public Function GetEntityProjectMeasuresByEntityHierarchy(ByVal ident As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsResults As DataSet = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim records As New List(Of EntityProjectMeasure)
        Dim ranges As New List(Of EntityProjectMeasureRange)
        Dim objReturnObject As JObject = Nothing

        Try

            objReturnObject = New JObject

            slParameters = New SortedList
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("EntityProjectMeasureIdent", ident)
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityProjectMeasureByEntityHierarchy", slParameters, True, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                     dsResults.Tables.Count = 5 AndAlso
                     dsResults.Tables(1).Rows.Count > 0 Then

                    ranges = GetEntityProjectMeasureRangesByEntityProjectMeasureIdent(dsResults.Tables(1).Rows(0)("Ident"), dsResults.Tables(2))

                    For Each drRow In dsResults.Tables(1).Rows

                        records.Add(
                            New EntityProjectMeasure() With {
                                .Ident = drRow.Item("Ident"),
                                .EntityIdent = drRow.Item("EntityIdent"),
                                .OrganizationIdent = drRow.Item("OrganizationIdent"),
                                .MeasureName = drRow.Item("Name1"),
                                .MeasureDescription = drRow.Item("Desc1"),
                                .EntitySearchIdent = drRow.Item("EntitySearchIdent"),
                                .DataTypeIdent = drRow.Item("EntitySearchDataTypeIdent"),
                                .HasDenominator = drRow.Item("HasDenominator"),
                                .HasTargetValue = drRow.Item("HasTargetValue"),
                                .IsAverage = drRow.Item("IsAverage"),
                                .IsPercentage = drRow.Item("IsPercentage"),
                                .MeasureTypeIdent = drRow.Item("MeasureTypeIdent"),
                                .MeasureType = drRow.Item("MeasureType"),
                                .EntityProject1Ident = drRow.Item("EntityProject1Ident"),
                                .EntityProject1Name = drRow.Item("EntityProject1Name"),
                                .Question1EntityProjectRequirementIdent = drRow.Item("Question1EntityProjectRequirementIdent"),
                                .Question1RequirementTypeIdent = drRow.Item("Question1RequirementTypeIdent"),
                                .EntityProject2Ident = drRow.Item("EntityProject2Ident"),
                                .EntityProject2Name = drRow.Item("EntityProject2Name"),
                                .Question2EntityProjectRequirementIdent = drRow.Item("Question2EntityProjectRequirementIdent"),
                                .TargetValue = drRow.item("TargetValue"),
                                .LastRecalculateDate = drRow.Item("LastRecalculateDate"),
                                .Question1Value = drRow.Item("Question1Value"),
                                .Question2Value = drRow.Item("Question2Value"),
                                .TotalResourcesComplete = drRow.Item("TotalResourcesComplete"),
                                .TotalResourcesAvailable = drRow.Item("TotalResourcesAvailable"),
                                .Ranges = ranges,
                                .Values = Helper.GetEntityProjectMeasureValuesByOrganizationIdent(drRow.Item("OrganizationIdent"), dsResults.Tables(3))
                            }
                        )
                    Next


                    objReturnObject.Add("EntityMeasure", JValue.Parse(Newtonsoft.Json.JsonConvert.SerializeObject(dsResults.Tables(0).Rows(0)("Name1"))))
                    objReturnObject.Add("Dials", JArray.Parse(Newtonsoft.Json.JsonConvert.SerializeObject(records)))
                    objReturnObject.Add("Participants", JArray.Parse(Newtonsoft.Json.JsonConvert.SerializeObject(dsResults.Tables(4))))

                End If

                Return Request.CreateResponse(HttpStatusCode.OK, objReturnObject)

            End If

            'No user input, something went wrong at the server level
            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsResults)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(records)
            Helper.CleanUp(ranges)

        End Try

    End Function

    Protected Function GetEntityProjectMeasureRangesByEntityProjectMeasureIdent(ByVal intEntityProjectMeasureIdent As Int64, _
                                                                                ByVal dtRanges As DataTable) As List(Of EntityProjectMeasureRange)

        Dim objRanges As New List(Of EntityProjectMeasureRange)

        Try

            For Each drRow In dtRanges.Select("EntityProjectMeasureIdent = " & CType(intEntityProjectMeasureIdent, String))

                objRanges.Add(
                    New EntityProjectMeasureRange() With {
                        .Ident = drRow.Item("Ident"),
                        .EntityProjectMeasureIdent = intEntityProjectMeasureIdent,
                        .Label = drRow.Item("Name1"),
                        .Color = drRow.Item("Color"),
                        .Low = drRow.Item("RangeStartValue"),
                        .High = drRow.Item("RangeEndValue")
                    }
                )
            Next

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetEntityProjectMeasureRangesByEntityProjectMeasureIdent = objRanges

            Helper.CleanUp(objRanges)

        End Try

    End Function

    Protected Function GetEntityProjectMeasureLocationsByEntityProjectMeasureIdent(ByVal intEntityProjectMeasureIdent As Int64, _
                                                                                ByVal dtLocation As DataTable) As List(Of EntityProjectMeasureLocation)

        Dim objLocation As New List(Of EntityProjectMeasureLocation)

        Try

            For Each drRow In dtLocation.Select("EntityProjectMeasureIdent = " & CType(intEntityProjectMeasureIdent, String))

                objLocation.Add(
                    New EntityProjectMeasureLocation() With {
                        .Ident = drRow.Item("Ident"),
                        .EntityProjectMeasureIdent = intEntityProjectMeasureIdent,
                        .MeasureLocationIdent = drRow.Item("MeasureLocationIdent"),
                        .LocationName = drRow.Item("LocationName"),
                        .Selected = drRow.Item("Active")
                    }
                )
            Next

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetEntityProjectMeasureLocationsByEntityProjectMeasureIdent = objLocation

            Helper.CleanUp(objLocation)

        End Try

    End Function

    Protected Function GetEntityProjectMeasureValuesByEntityProjectMeasureIdent(ByVal intEntityProjectMeasureIdent As Int64, _
                                                                                ByVal dtValue As DataTable) As List(Of EntityProjectMeasureValue)

        Dim objValues As New List(Of EntityProjectMeasureValue)

        Try

            For Each drRow In dtValue.Select("EntityProjectMeasureIdent = " & CType(intEntityProjectMeasureIdent, String))

                objValues.Add(
                    New EntityProjectMeasureValue() With {
                        .Ident = drRow.Item("Ident"),
                        .EntityProjectMeasureIdent = intEntityProjectMeasureIdent,
                        .Value1 = drRow.Item("Value1"),
                        .ValueCount = drRow.Item("ValueCount")
                    }
                )
            Next

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetEntityProjectMeasureValuesByEntityProjectMeasureIdent = objValues

            Helper.CleanUp(objValues)

        End Try

    End Function

    Private Shared Function CreateEntityProjectMeasureRangeDataTableForSQLParameter(objRanges As IEnumerable(Of EntityProjectMeasureRange)) As DataTable

        Dim dtRanges As New DataTable()
        Dim objRange As EntityProjectMeasureRange = Nothing
        Dim drRow As DataRow = Nothing

        Try

            dtRanges.Columns.Add("EntityProjectMeasureIdent", GetType(Int64))
            dtRanges.Columns.Add("Name1", GetType(String))
            dtRanges.Columns.Add("Color", GetType(String))
            dtRanges.Columns.Add("RangeStartValue", GetType(Decimal))
            dtRanges.Columns.Add("RangeEndValue", GetType(Decimal))

            For Each objRange In objRanges

                drRow = dtRanges.NewRow

                drRow("EntityProjectMeasureIdent") = objRange.EntityProjectMeasureIdent
                drRow("Name1") = objRange.Label
                drRow("Color") = objRange.Color
                drRow("RangeStartValue") = objRange.Low
                drRow("RangeEndValue") = objRange.High

                dtRanges.Rows.Add(drRow)

            Next

            Return dtRanges

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Nothing

        Finally

            Helper.CleanUp(dtRanges)
            Helper.CleanUp(objRange)
            Helper.CleanUp(drRow)

        End Try

    End Function

    Private Shared Function CreateEntityProjectMeasureLocationDataTableForSQLParameter(objLocations As IEnumerable(Of EntityProjectMeasureLocation)) As DataTable

        Dim dtLocations As New DataTable()
        Dim objLocation As EntityProjectMeasureLocation = Nothing
        Dim drRow As DataRow = Nothing

        Try

            dtLocations.Columns.Add("Ident", GetType(Int64))
            dtLocations.Columns.Add("EntityProjectMeasureIdent", GetType(Int64))
            dtLocations.Columns.Add("MeasureLocationIdent", GetType(Int64))
            dtLocations.Columns.Add("Selected", GetType(Boolean))

            For Each objLocation In objLocations

                drRow = dtLocations.NewRow

                drRow("Ident") = objLocation.Ident
                drRow("EntityProjectMeasureIdent") = objLocation.EntityProjectMeasureIdent
                drRow("MeasureLocationIdent") = objLocation.MeasureLocationIdent
                drRow("Selected") = objLocation.Selected

                dtLocations.Rows.Add(drRow)

            Next

            Return dtLocations

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Nothing

        Finally

            Helper.CleanUp(dtLocations)
            Helper.CleanUp(objLocation)
            Helper.CleanUp(drRow)

        End Try

    End Function

    Private Shared Function CreateEntityProjectMeasureValuesDataTableForSQLParameter(objValues As IEnumerable(Of EntityProjectMeasureValue)) As DataTable

        Dim dtValues As New DataTable()
        Dim objValue As EntityProjectMeasureValue = Nothing
        Dim drRow As DataRow = Nothing

        Try

            dtValues.Columns.Add("Ident", GetType(Int64))
            dtValues.Columns.Add("EntityProjectMeasureIdent", GetType(Int64))
            dtValues.Columns.Add("Value1", GetType(String))
            dtValues.Columns.Add("ValueCount", GetType(Int64))

            For Each objValue In objValues

                drRow = dtValues.NewRow

                drRow("Ident") = objValue.Ident
                drRow("EntityProjectMeasureIdent") = objValue.EntityProjectMeasureIdent
                drRow("Value1") = objValue.Value1
                drRow("ValueCount") = objValue.ValueCount

                dtValues.Rows.Add(drRow)

            Next

            Return dtValues

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Nothing

        Finally

            Helper.CleanUp(dtValues)
            Helper.CleanUp(objValue)
            Helper.CleanUp(drRow)

        End Try

    End Function

End Class