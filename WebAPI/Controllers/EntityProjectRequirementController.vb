Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

Public Class EntityProjectRequirementController
    Inherits ApiController

    <System.Web.Http.HttpPost> _
    <Route("api/EntityProjectRequirement")> _
    Public Function AddEntityProjectRequirement(ByVal postObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim intIdent As Int64
        Dim intSortOrder As Int64 = 0

        Try

            If Not postObject("sortOrder") Is Nothing Then

                Int64.TryParse(postObject("sortOrder"), intSortOrder)

            End If

            slParameters = New SortedList
            slParameters.Add("EntityProjectIdent", CType(postObject("EntityProjectIdent"), Int64))
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("RequirementTypeIdent", CType(postObject("RequirementTypeIdent"), Int64))
            slParameters.Add("Label", CType(postObject("label"), String))
            slParameters.Add("Desc1", CType(postObject("description"), String))
            slParameters.Add("PlaceholderText", CType(postObject("placeholder"), String))
            slParameters.Add("HelpText", CType(postObject("helpText"), String))
            slParameters.Add("Options", CType(postObject("options"), String))
            slParameters.Add("SortOrder", intSortOrder)
            slParameters.Add("CreateToDoUponCompletion", CType(postObject("CreateToDoUponCompletion"), Boolean))
            slParameters.Add("ToDoTitle", CType(postObject("ToDoTitle"), String))
            slParameters.Add("ToDoDesc1", CType(postObject("ToDoDesc1"), String))
            slParameters.Add("ToDoAssigneeEntityIdent", CType(postObject("ToDoAssigneeEntityIdent"), Int64))
            slParameters.Add("ToDoDueDateNoOfDays", CType(postObject("ToDoDueDateNoOfDays"), Integer))
            slParameters.Add("SupressOutput", False)

            If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityProjectRequirement", slParameters, intIdent, dsMessage) Then

                If intIdent > 0 Then

                    Return Request.CreateResponse(HttpStatusCode.OK, intIdent)

                End If

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

    <System.Web.Http.HttpPut> _
    <Route("api/EntityProjectRequirement/{Ident}")> _
    Public Function EditEntityProjectRequirement(ByVal Ident As Int64, ByVal postObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim intIdent As Int64

        Try

            slParameters = New SortedList
            slParameters.Add("Ident", Ident)
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("RequirementTypeIdent", CType(postObject("RequirementTypeIdent"), Int64))
            slParameters.Add("Label", CType(postObject("label"), String))
            slParameters.Add("Desc1", CType(postObject("description"), String))
            slParameters.Add("PlaceholderText", CType(postObject("placeholder"), String))
            slParameters.Add("HelpText", CType(postObject("helpText"), String))
            slParameters.Add("Options", CType(postObject("options"), String))
            slParameters.Add("SortOrder", CType(postObject("sortOrder"), Integer))
            slParameters.Add("CreateToDoUponCompletion", CType(postObject("CreateToDoUponCompletion"), Boolean))
            slParameters.Add("ToDoTitle", CType(postObject("ToDoTitle"), String))
            slParameters.Add("ToDoDesc1", CType(postObject("ToDoDesc1"), String))
            slParameters.Add("ToDoAssigneeEntityIdent", CType(postObject("ToDoAssigneeEntityIdent"), Int64))
            slParameters.Add("ToDoDueDateNoOfDays", CType(postObject("ToDoDueDateNoOfDays"), Integer))

            If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspEditEntityProjectRequirementByIdent", slParameters, intIdent, dsMessage) Then

                If intIdent > 0 Then

                    Return Request.CreateResponse(HttpStatusCode.OK)

                End If

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

    <System.Web.Http.HttpPut> _
    <Route("api/EntityProjectRequirement")> _
    Public Function EditAllEntityProjectRequirement(ByVal postArray As JArray)

        Dim strSelectToken As String = ""
        Dim intPosition As Integer = 0

        Try

            strSelectToken = "[" & CType(intPosition, String) & "]"

            While Not postArray.SelectToken(strSelectToken) Is Nothing

                Call EditEntityProjectRequirement(CType(postArray.SelectToken(strSelectToken)("Ident"), Int64), postArray.SelectToken(strSelectToken))

                intPosition += 1
                strSelectToken = "[" & CType(intPosition, String) & "]"

            End While

            Return Request.CreateResponse(HttpStatusCode.OK)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        End Try

    End Function


    <System.Web.Http.HttpDelete> _
    <Route("api/EntityProjectRequirement/{Ident}")> _
    Public Function DeleteEntityProjectRequirement(ByVal Ident As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim intIdent As Int64

        Try

            slParameters = New SortedList
            slParameters.Add("Ident", Ident)
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspDeleteEntityProjectRequirementByIdent", slParameters, intIdent, dsMessage) Then

                If intIdent > 0 Then

                    Return Request.CreateResponse(HttpStatusCode.OK)

                End If

            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

    <HttpGet> _
    <Route("api/EntityProjectRequirement/{ident}")> _
    Public Function GetEntityProjectRequirementByEntityHierarchy(ByVal ident As Int64, Optional ByVal measureTypeIdent As Int64 = 0)

        Dim slParameters As SortedList = Nothing
        Dim dsResults As DataSet = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim records As New List(Of EntityProjectMeasure)
        Dim objReturnObject As JObject = Nothing
        Dim measureTotal As New List(Of EntityProjectMeasure)
        Dim drTotalRow As DataRow = Nothing

        Try

            objReturnObject = New JObject

            slParameters = New SortedList
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("EntityProjectRequirementIdent", ident)
            slParameters.Add("MeasureTypeIdent", measureTypeIdent)
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityProjectRequirementByEntityHierarchy", slParameters, True, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                     dsResults.Tables.Count = 6 AndAlso
                     dsResults.Tables(1).Rows.Count > 0 Then

                    dsResults.Tables(0).TableName = "EntityMeasure"
                    dsResults.Tables(1).TableName = "EntityProjectMeasure"
                    dsResults.Tables(2).TableName = "Values"
                    dsResults.Tables(3).TableName = "Participants"
                    dsResults.Tables(4).TableName = "EntityProjectMeasureTotal"
                    dsResults.Tables(5).TableName = "EntityProjectMeasureTotalValues"

                    For Each drRow In dsResults.Tables("EntityProjectMeasure").Rows

                        records.Add(
                            New EntityProjectMeasure() With {
                                .EntityIdent = drRow.Item("EntityIdent"),
                                .OrganizationIdent = drRow.Item("OrganizationIdent"),
                                .MeasureName = drRow.Item("Name1"),
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
                                .Question1Value = drRow.Item("Question1Value"),
                                .Question2Value = drRow.Item("Question2Value"),
                                .TotalResourcesComplete = drRow.Item("TotalResourcesComplete"),
                                .TotalResourcesAvailable = drRow.Item("TotalResourcesAvailable"),
                                .Values = Helper.GetEntityProjectMeasureValuesByOrganizationIdent(drRow.Item("OrganizationIdent"), dsResults.Tables("Values"))
                            }
                        )
                    Next

                    For Each drTotalRow In dsResults.Tables("EntityProjectMeasureTotal").Rows


                        measureTotal.Add(
                            New EntityProjectMeasure() With {
                                    .EntityIdent = drTotalRow.Item("EntityIdent"),
                                    .MeasureName = drTotalRow.Item("Name1"),
                                    .DataTypeIdent = drTotalRow.Item("EntitySearchDataTypeIdent"),
                                    .HasDenominator = drTotalRow.Item("HasDenominator"),
                                    .HasTargetValue = drTotalRow.Item("HasTargetValue"),
                                    .IsAverage = drTotalRow.Item("IsAverage"),
                                    .IsPercentage = drTotalRow.Item("IsPercentage"),
                                    .MeasureTypeIdent = drTotalRow.Item("MeasureTypeIdent"),
                                    .MeasureType = drTotalRow.Item("MeasureType"),
                                    .EntityProject1Ident = drTotalRow.Item("EntityProject1Ident"),
                                    .EntityProject1Name = drTotalRow.Item("EntityProject1Name"),
                                    .Question1EntityProjectRequirementIdent = drTotalRow.Item("Question1EntityProjectRequirementIdent"),
                                    .Question1RequirementTypeIdent = drTotalRow.Item("Question1RequirementTypeIdent"),
                                    .Question1Value = drTotalRow.Item("Question1Value"),
                                    .Question2Value = drTotalRow.Item("Question2Value"),
                                    .TotalResourcesComplete = drTotalRow.Item("TotalResourcesComplete"),
                                    .TotalResourcesAvailable = drTotalRow.Item("TotalResourcesAvailable"),
                                    .Values = Helper.GetEntityProjectMeasureValuesByOrganizationIdent(drTotalRow.Item("OrganizationIdent"), dsResults.Tables("EntityProjectMeasureTotalValues"))
                                }
                        )

                    Next

                    objReturnObject.Add("EntityMeasureTotal", JArray.Parse(Newtonsoft.Json.JsonConvert.SerializeObject(measureTotal)))
                    objReturnObject.Add("EntityMeasure", JValue.Parse(Newtonsoft.Json.JsonConvert.SerializeObject(dsResults.Tables("EntityMeasure").Rows(0)("Name1"))))
                    objReturnObject.Add("Dials", JArray.Parse(Newtonsoft.Json.JsonConvert.SerializeObject(records)))
                    objReturnObject.Add("Participants", JArray.Parse(Newtonsoft.Json.JsonConvert.SerializeObject(dsResults.Tables("Participants"))))

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
            Helper.CleanUp(measureTotal)

        End Try

    End Function

End Class