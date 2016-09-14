Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

Public Class LookupController
    Inherits ApiController

    <AllowAnonymous> _
    <System.Web.Http.HttpGet> _
    <Route("api/Lookup/GetLookupTables")> _
    Public Function GetLookupTables()

        Dim dsResults As DataSet = Nothing

        Try

            If LookupTables.GetLookupTables(dsResults) Then

                Return Request.CreateResponse(HttpStatusCode.OK, dsResults)

            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dsResults)

        End Try

    End Function

    <System.Web.Http.HttpGet> _
    <Route("api/Lookup/ImportColumns")> _
    Public Function GetImportColumns()

        Dim dtImportColumn As DataTable = Nothing

        Try

            If LookupTables.GetImportColumns(dtImportColumn) Then

                Return Request.CreateResponse(HttpStatusCode.OK, dtImportColumn)

            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dtImportColumn)

        End Try

    End Function

End Class