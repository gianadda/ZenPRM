Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

Public Class EntityTaxonomyController
    Inherits ApiController

    Public Function post(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList

            slParameters.Add("EntityIdent", CType(putObject("EntityIdent"), Int64))
            slParameters.Add("TaxonomyIdent", CType(putObject("TaxonomyIdent"), Int64))
            slParameters.Add("AddASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("Active", CBool(putObject("Active")))

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityTaxonomyXRef", slParameters, False, dsResults, dsMessage) Then

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
            
            slParameters.Add("EntityIdent", CType(putObject("EntityIdent"), Int64))
            slParameters.Add("TaxonomyIdent", CType(putObject("TaxonomyIdent"), Int64))
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("EditDateTime", Helper.GetLocalTime)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspDeleteEntityTaxonomyXRefByIdent", slParameters, False, dsResults, dsMessage) Then

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


