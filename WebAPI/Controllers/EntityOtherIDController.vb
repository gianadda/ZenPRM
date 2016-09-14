Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

Public Class EntityOtherIDController
    Inherits ApiController

    Public Function post(putObject As JObject)

        Dim objReturn As JObject = Nothing
        Dim intIdent As Int64 = 0
        Dim intEntityIdent As Int64 = 0

        Try

            Call Int64.TryParse(putObject("EntityIdent"), intEntityIdent)

            If intEntityIdent > 0 AndAlso _
                Not putObject("IDType") Is Nothing AndAlso _
                Not putObject("IDNumber") Is Nothing Then

                If Entity.AddEntityOtherID(intEntityIdent, putObject("IDType"), putObject("IDNumber"), Helper.AddEditASUserIdent, intIdent) Then

                    objReturn = New JObject
                    objReturn("Ident") = intIdent

                    Return Request.CreateResponse(HttpStatusCode.OK, objReturn)

                End If ' If Entity.AddEntityOtherID()

            End If 'If intEntityIdent > 0 

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(objReturn)

        End Try

    End Function


    Public Function Put(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList

            slParameters.Add("Ident", putObject("Ident"))
            slParameters.Add("EntityIdent", CType(putObject("EntityIdent"), Int64))
            slParameters.Add("IDType", CType(putObject("IDType"), String))
            slParameters.Add("IDNumber", CType(putObject("IDNumber"), String))
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("Active", CBool(putObject("Active")))

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspEditEntityOtherIDByIdent", slParameters, False, dsResults, dsMessage) Then

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


    Public Function Delete(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try


            slParameters = New SortedList

            slParameters.Add("Ident", putObject("Ident"))
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("EditDateTime", Helper.GetLocalTime)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspDeleteEntityOtherIDByIdent", slParameters, False, dsResults, dsMessage) Then

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
End Class

