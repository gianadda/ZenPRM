Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq


Namespace Controllers
    Public Class EntityReportController
        Inherits ApiController

        <System.Web.Http.HttpGet> _
        Public Function GetEntityReports()

            Dim slParameters As SortedList = Nothing
            Dim dsMessage As DataSet = Nothing
            Dim dsResults As DataSet = Nothing

            Try

                slParameters = New SortedList

                slParameters.Add("EntityIdent", Helper.ASUserIdent)
                slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)

                If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityReportByEntityIdent", slParameters, False, dsResults, dsMessage) Then

                    If Not dsResults Is Nothing AndAlso
                        dsResults.Tables.Count > 0 Then

                        dsResults.Tables(0).TableName = "EntityReport"

                        Return Request.CreateResponse(HttpStatusCode.OK, dsResults)

                    End If 'If Not dsResults Is Nothing

                End If 'If Not searchObject Is Nothing

                Return Request.CreateResponse(HttpStatusCode.BadRequest)

            Catch ex As Exception

                Messaging.LogError(ex)

                Return Request.CreateResponse(HttpStatusCode.InternalServerError)

            Finally

                Helper.CleanUp(dsResults)
                Helper.CleanUp(dsMessage)

            End Try

        End Function

        <System.Web.Http.HttpGet> _
        <Route("api/EntityReport/{ident}")> _
        Public Function GetEntityReport(ident As Int64)

            Dim slParameters As SortedList = Nothing
            Dim dsMessage As DataSet = Nothing
            Dim dsResults As DataSet = Nothing

            Try

                slParameters = New SortedList

                slParameters.Add("Ident", ident)
                slParameters.Add("EntityIdent", Helper.ASUserIdent)
                slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)

                If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityReportByIdent", slParameters, False, dsResults, dsMessage) Then

                    If Not dsResults Is Nothing AndAlso
                        dsResults.Tables.Count > 0 Then

                        dsResults.Tables(0).TableName = "EntityReport"

                        Return Request.CreateResponse(HttpStatusCode.OK, dsResults)

                    End If 'If Not dsResults Is Nothing

                End If 'If Not searchObject Is Nothing

                Return Request.CreateResponse(HttpStatusCode.BadRequest)

            Catch ex As Exception

                Messaging.LogError(ex)

                Return Request.CreateResponse(HttpStatusCode.InternalServerError)

            Finally

                Helper.CleanUp(dsResults)
                Helper.CleanUp(dsMessage)

            End Try

        End Function


        <System.Web.Http.HttpPost> _
        Public Function post(putObject As JObject)

            Dim slParameters As SortedList = Nothing
            Dim dsMessage As DataSet = Nothing
            Dim dsResults As DataSet = Nothing

            Dim strName1 As String = ""
            Dim strDesc1 As String = ""
            Dim strTemplateHTML As String = ""

            Try

                slParameters = New SortedList

                strName1 = IIf(CType(putObject("Name1"), String) Is Nothing, "", CType(putObject("Name1"), String))
                strDesc1 = IIf(CType(putObject("Desc1"), String) Is Nothing, "", CType(putObject("Desc1"), String))
                strTemplateHTML = IIf(CType(putObject("TemplateHTML"), String) Is Nothing, "", CType(putObject("TemplateHTML"), String))

                slParameters.Add("EntityIdent", Helper.ASUserIdent)
                slParameters.Add("ReportTypeIdent", 1)
                slParameters.Add("Name1", strName1)
                slParameters.Add("Desc1", strDesc1)
                slParameters.Add("TemplateHTML", strTemplateHTML)
                slParameters.Add("PrivateReport", CType(putObject("PrivateReport"), Boolean))
                slParameters.Add("AddASUserIdent", Helper.AddEditASUserIdent)
                slParameters.Add("Active", CBool(putObject("Active")))

                If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityReport", slParameters, False, dsResults, dsMessage) Then

                    If Not dsResults Is Nothing AndAlso
                        dsResults.Tables.Count > 0 AndAlso
                        dsResults.Tables(0).Rows.Count > 0 Then

                        Return Request.CreateResponse(HttpStatusCode.OK, dsResults.Tables(0))

                    End If


                End If

                Return Request.CreateResponse(HttpStatusCode.BadRequest)

            Catch ex As Exception

                Messaging.LogError(ex)

                Return Request.CreateResponse(HttpStatusCode.InternalServerError)

            Finally

                Helper.CleanUp(slParameters)
                Helper.CleanUp(dsMessage)
                Helper.CleanUp(dsResults)

            End Try

        End Function


        <System.Web.Http.HttpPut> _
        <Route("api/EntityReport/{ident}")> _
        Public Function put(ByVal ident As Int64, putObject As JObject)

            Dim slParameters As SortedList = Nothing
            Dim dsMessage As DataSet = Nothing
            Dim intIdent As Int64 = 0

            Dim strName1 As String = ""
            Dim strDesc1 As String = ""
            Dim strTemplateHTML As String = ""

            Try

                slParameters = New SortedList

                strName1 = IIf(CType(putObject("Name1"), String) Is Nothing, "", CType(putObject("Name1"), String))
                strDesc1 = IIf(CType(putObject("Desc1"), String) Is Nothing, "", CType(putObject("Desc1"), String))
                strTemplateHTML = IIf(CType(putObject("TemplateHTML"), String) Is Nothing, "", CType(putObject("TemplateHTML"), String))

                slParameters.Add("Ident", ident)
                slParameters.Add("EntityIdent", Helper.ASUserIdent)
                slParameters.Add("Name1", strName1)
                slParameters.Add("Desc1", strDesc1)
                slParameters.Add("TemplateHTML", strTemplateHTML)
                slParameters.Add("PrivateReport", CType(putObject("PrivateReport"), Boolean))
                slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)

                If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspEditEntityReportByIdent", slParameters, intIdent, dsMessage) Then

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


        Public Function Delete(putObject As JObject)

            Dim slParameters As SortedList = Nothing
            Dim dsMessage As DataSet = Nothing
            Dim dsResults As DataSet = Nothing

            Try


                slParameters = New SortedList

                slParameters.Add("EntityIdent", Helper.ASUserIdent)
                slParameters.Add("EntityReportIdent", putObject("EntityReportIdent"))
                slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)
                slParameters.Add("EditDateTime", Helper.GetLocalTime)

                If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspDeleteEntityReportByIdent", slParameters, False, dsResults, dsMessage) Then

                    If Not dsResults Is Nothing AndAlso
                        dsResults.Tables.Count > 0 Then

                        Return Request.CreateResponse(HttpStatusCode.OK, dsResults.Tables(0))

                    End If

                End If

                Return Request.CreateResponse(HttpStatusCode.BadRequest)

            Catch ex As Exception

                Messaging.LogError(ex)

                Return Request.CreateResponse(HttpStatusCode.InternalServerError)

            Finally

                Helper.CleanUp(slParameters)
                Helper.CleanUp(dsMessage)
                Helper.CleanUp(dsResults)

            End Try

        End Function

    End Class
End Namespace