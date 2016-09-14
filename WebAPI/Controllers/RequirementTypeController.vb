Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

Public Class RequirementTypeController
    Inherits ApiController

    <System.Web.Http.HttpGet> _
    Public Function GetAllRequirementType()

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetAllActiveRequirementType", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count > 0 AndAlso
                    dsResults.Tables(0).Rows.Count > 0 Then

                    Return dsResults.Tables(0)

                End If

                Return Request.CreateResponse(HttpStatusCode.OK)

            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsResults)
            Helper.CleanUp(dsMessage)

        End Try

    End Function


End Class