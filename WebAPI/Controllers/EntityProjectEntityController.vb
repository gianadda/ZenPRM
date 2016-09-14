Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

<RoutePrefix("api/entityproject/{ident}/entity")> _
Public Class EntityProjectEntityController
    Inherits ApiController

    <System.Web.Http.HttpGet> _
    <Route("history")> _
    <Route("{entityIdent}/history")> _
    <Route("{entityIdent}/history/{entityProjectRequirementIdent}")> _
    Public Function GetEntityAnswerHistory(ByVal ident As Int64, Optional ByVal entityIdent As Int64 = 0, Optional ByVal entityProjectRequirementIdent As Int64 = 0, _
                                                 Optional ByVal pageNumber As Integer = 1, Optional ByVal resultsShown As Int64 = 100, _
                                                 Optional ByVal startDate As DateTime = Nothing, Optional ByVal endDate As DateTime = Nothing)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing
        Dim strCustomMessage As String = ""

        Try

            If startDate = Nothing Then

                startDate = "1/1/1900"

            End If

            If endDate = Nothing Then

                endDate = "1/1/1900"

            End If

            slParameters = New SortedList
            slParameters.Add("EntityProjectIdent", ident)
            slParameters.Add("EntityIdent", entityIdent)
            slParameters.Add("EntityProjectRequirementIdent", entityProjectRequirementIdent)
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)
            slParameters.Add("StartDate", startDate)
            slParameters.Add("EndDate", endDate)
            slParameters.Add("PageNumber", pageNumber)
            slParameters.Add("ResultsShown", resultsShown)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityProjectEntityAnswerHistoryByEntityProjectEntityIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso _
                    dsResults.Tables.Count > 0 Then

                    dsResults.Tables(0).TableName = "results"
                    dsResults.Tables(1).TableName = "resultCounts"

                    Return Request.CreateResponse(HttpStatusCode.OK, dsResults)

                End If


            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dsResults)
            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

End Class